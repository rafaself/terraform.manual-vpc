#!/usr/bin/env bash

ansible-playbook \
  -i "$(terraform output -raw ec2_public_ip)," \
  -u ubuntu \
  --private-key ./keys/aws_key \
  assets/ansible/playbook.yml