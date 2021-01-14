#!/bin/bash -l

set -x 

if [ $# != 2 ]
then
  echo "Must provide all required inputs"
  exit 1
fi

SSH_PRIVATE_KEY=$1
PUBLIC_IP=$2

# Note all the below basically:
# - Sets up ssh agent so that the github runner (ubuntu) can run commands
#   (via ssh -C) on the target host.
# - Copies the config.cfg file to the server (this contains all the usernames which algo generates VPN configs for)
# - Downloads the algo vpn master repo, which is Ansible powered
# - Runs the algo ansible playbook in local mode
#   see https://github.com/trailofbits/algo/blob/c14ff0d611b618fe62614263d868c04b508252ee/docs/deploy-to-ubuntu.md
mkdir -p ~/.ssh
eval `ssh-agent -s`
ssh-add - <<< "$SSH_PRIVATE_KEY"
ssh-keyscan -v $PUBLIC_IP >> ~/.ssh/known_hosts
#  -o StrictHostKeyChecking=no is needed since an instance rebuild changes the HostKey
ssh -o StrictHostKeyChecking=no root@$PUBLIC_IP -C "apt-get update"
ssh -o StrictHostKeyChecking=no root@$PUBLIC_IP -C "sudo apt-get install -y --no-install-recommends python3-virtualenv unzip"
ssh -o StrictHostKeyChecking=no root@$PUBLIC_IP -C "curl -L -o algo.zip https://github.com/trailofbits/algo/archive/master.zip"
ssh -o StrictHostKeyChecking=no root@$PUBLIC_IP -C "unzip algo.zip"
ssh -o StrictHostKeyChecking=no root@$PUBLIC_IP -C 'cd algo-master; python3 -m virtualenv --python="$(command -v python3)" .env && source .env/bin/activate && python3 -m pip install -U pip virtualenv && python3 -m pip install -r requirements.txt'
# Copy over algo config
sed -i.bak "s/<public-ip-change-me>/$PUBLIC_IP/g" config.cfg
scp -o StrictHostKeyChecking=no config.cfg root@$PUBLIC_IP:/root/algo-master/config.cfg
# Start the algo install (which runs the algo playbook), -tt needed to force tty allocation
ssh -tt -o StrictHostKeyChecking=no root@$PUBLIC_IP -C "cd algo-master; source .env/bin/activate; ./algo -vvv"
