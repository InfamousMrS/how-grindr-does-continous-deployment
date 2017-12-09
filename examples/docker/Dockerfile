FROM amazonlinux:2017.03

LABEL maintainer="Chat Team <chat@grindr.com>"

WORKDIR /root

RUN yum install -y sed which openssl unzip wget

RUN wget http://packages.erlang-solutions.com/site/esl/esl-erlang/FLAVOUR_1_general/esl-erlang_19.3.6-1~centos~7_amd64.rpm
RUN rpm -i --nodeps esl-erlang_19.3.6-1~centos~7_amd64.rpm

RUN wget https://github.com/elixir-lang/elixir/releases/download/v1.4.4/Precompiled.zip && \
    mkdir -p /opt/elixir/1.4.4/ && \
    unzip Precompiled -d /opt/elixir/1.4.4/

VOLUME /root/_deploy

RUN yum install -y git
 
ENV PATH="/opt/elixir/1.4.4/bin:${PATH}"
ENV LC_ALL="en_US.UTF-8"

CMD cd /root/_deploy/profile-service && rm -rf _build && \
    make setup && make rel && \
  cp _build/prod/rel/profile_service/releases/`git describe --always --tags`/profile_service.tar.gz ../ && \
  cd /root && chmod -R a+rw *
  
