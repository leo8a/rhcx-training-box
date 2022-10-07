#!/bin/bash

# Create SSH directory
mkdir -p ~/.ssh/

# Generate key
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

# Copy public key
for s in 2 3 4 5; do
   sshpass -p devops ssh-copy-id ansible$s.rhcx.local -o StrictHostKeyChecking=no ; 
done
