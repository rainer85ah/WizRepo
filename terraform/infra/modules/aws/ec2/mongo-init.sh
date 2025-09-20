#!/bin/bash
systemctl enable mongod
systemctl start mongod

# Run rs.initiate only on node 0
if [ "${index}" -eq 0 ]; then
  mongo --eval "rs.initiate({
    _id: 'rs0',
    members: [
      { _id: 0, host: '${node0_ip}:27017' },
      { _id: 1, host: '${node1_ip}:27017' },
      { _id: 2, host: '${node2_ip}:27017' }
    ]
  })"
fi
