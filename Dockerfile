FROM debian:stretch-slim

# Run the following commands:
# 1) Install packages for ansible dependencies and supervisor
# 2) Install ansible module using pip
# 3) Setup basic ansible config
# 4) Remove apt packages that were only needed for ansible install
# 5) Cleanup apt cache
RUN apt-get update && \
    apt-get install -y \
        libffi-dev \
        libssl-dev \
        libyaml-dev \
        python \
        python-dev \
        python-pip \
        python-httplib2 \
        supervisor && \
    pip install -U setuptools && \
    pip install --no-cache-dir ansible && \
    mkdir /etc/ansible/ && echo '[local]\nlocalhost\n' > /etc/ansible/hosts && \
    apt-get remove -y \
        libffi-dev \
        libssl-dev \
        libyaml-dev \
        python-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Listen on port 80
EXPOSE 80

# Copy the bootstrap script and make it executable
COPY run-app.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-app.sh

# Copy ansible folder from src, set work dir, run the ansible provision script
COPY ansible /ansible
WORKDIR /ansible
RUN ansible-playbook provision.yml -c local -vv

# Replace shibboleth log files with links to stdout and stderr
RUN rm -f /var/log/shibboleth/shibd*.log && \
    ln -s /dev/stdout /var/log/shibboleth/shibd.log && \
    ln -s /dev/stderr /var/log/shibboleth/shibd_warn.log

# Set the bootstrap script as our entry point
CMD ["/usr/local/bin/run-app.sh"]
