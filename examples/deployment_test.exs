defmodule ProfileService.DeploymentTest do
  use ExUnit.Case

  @moduletag :deployment_test

  setup do
    Application.ensure_all_started(:httpoison)
    []
  end

  @tag timeout: 600_000
  test "Can deploy an instance" do
    start_containers()
    build_target_release("0.1.1")
    deploy_to_containers("0.1.1", ["node-1", "node-2"])
  end

  @tag timeout: 600_000
  test "Can upgrade from last tag to latest git ref" do
    start_containers()
    old_version = hd(versions())
    next_version = current_ref()
    build_target_release(old_version)
    deploy_to_containers(old_version, ["node-1", "node-2"])

    build_target_release(next_version)
    deploy_to_containers(next_version, ["node-1", "node-2"])
  end


  defp start_containers() do
    {_, 0} = System.cmd("make",
      ["run-profiles-service-containers"],
      cd: "docker")
  end

  defp build_target_release(commit_ref) do
    {_, 0} = System.cmd("make",
      ["profile_service.tar.gz", "commit_ref=#{commit_ref}"], cd: "docker")
  end

  defp deploy_to_containers(commit_ref, nodes) do
    #TODO: profile-service.1:profile-service.2
    {_, 0} = System.cmd("make",
      ["deploy", "inventory=test.inventory", "db_hostname=mysql-server",
       "commit_ref=#{commit_ref}"], cd: "ansible")
  end

  defp current_ref do
    {r, 0} = System.cmd("git", ["rev-parse", "HEAD"])
    String.trim(r)
  end

  defp versions do
    {versions, 0} = System.cmd("git", ["tag", "--sort=-v:refname"])
    String.split(versions)
  end

end
