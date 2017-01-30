#!/usr/bin/env bash
# #################
#
# Bash script to run the test suite against the Vagrant environment.
#
# version: 1.2
#
# usage:
#
#   # run tests against all enabled Vagrant boxes
#   $ bash vagrant.sh
#
#   # run tests against a single Vagrant box
#   $ bash vagrant.sh --box precise64.vagrant.dev
#
#
# changelog:
#
#   v1.6 : 10 Jun 2016
#     - exit if USER environment variable is travis
#
#   v1.4 : 10 Jul 2015
#     - remove environment variable ANSIBLE_ASK_SUDO_PASS
#
# author(s):
#   - Pedro Salgado <steenzout@ymail.com>
#
# #################

test $USER == 'travis' && exit 0

DIR="$(dirname "$0")"

cd $DIR

# the path to the Ansible inventory generated by Vagrant
INVENTORY=${DIR}/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory


while [[ $# > 1 ]]
do
key="$1"

    case $key in

        --box)
        # the name of the Vagrant box to run tests against
        BOX="$2"
        shift;;

        *)
        # unknown option
        ;;

    esac
    shift
done

for VAGRANT_BOX in `grep vagrant.dev boxes.yml | sed 's/://g'`
do
    if [ ! -n "${BOX+1}" ] || [ "${BOX}" = "${VAGRANT_BOX}" ]; then

        echo "[INFO] preparing ${VAGRANT_BOX}..."
        vagrant up ${VAGRANT_BOX} 2> /dev/null
        if [ $? -ne 0 ]; then
            # box not enabled
            continue
        fi

        bash ${DIR}/test_idempotence.sh --box ${VAGRANT_BOX} --inventory $INVENTORY
        bash ${DIR}/test_checkmode.sh --box ${VAGRANT_BOX} --inventory $INVENTORY

        echo "[INFO] destroy ${VAGRANT_BOX}..."
        vagrant destroy -f ${VAGRANT_BOX}
    fi
done

