FROM leanix/ubuntu-ansible

RUN apt-get update && apt-get install -y \
	apache2 \
	libapache2-mod-shib2 && \
	rm -f /var/log/shibboleth/shibd*.log && \
    ln -s /dev/stdout /var/log/shibboleth/shibd.log && \
    ln -s /dev/stderr /var/log/shibboleth/shibd_warn.log
COPY ansible /ansible
WORKDIR /ansible
RUN ansible-playbook provision.yml -c local -vv
COPY run-app.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-app.sh

EXPOSE 80

CMD ["/usr/local/bin/run-app.sh"]

