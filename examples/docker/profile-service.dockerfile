FROM amazonlinux:2017.03

LABEL maintainer="Chat Team <chat@grindr.com>"

# we need openssh
RUN yum install -y openssh-server
RUN yum install -y sudo which

RUN sed -i -e 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

COPY ansible/deployment_test_key.pub /

RUN useradd -m -p "gibberish" -s /bin/bash ec2-user && \
    usermod -aG wheel ec2-user && \
    mkdir /home/ec2-user/.ssh/ && \
    cat /deployment_test_key.pub >> /home/ec2-user/.ssh/authorized_keys &&\
    rm /deployment_test_key.pub && \
    chown -R ec2-user:ec2-user /home/ec2-user && \
    chmod 700 /home/ec2-user/.ssh && \
    chmod 600 /home/ec2-user/.ssh/authorized_keys && \
    echo "ec2-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# SSH
EXPOSE 22
# WebSockets
EXPOSE 4000
# Info
EXPOSE 9000

CMD /etc/init.d/sshd start && tail /dev/null -f