#!/bin/sh

set -e

update-ca-certificates

cd /ansible
ansible-playbook configure.yml -c local -v
/usr/bin/supervisord
