# MongoDB Replica Set Deployment Guide

## Environment Variables Required

### For MongoDB Nodes:

```
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=<your-secure-password>
REPLICA_SET_NAME=rs0
KEYFILE=<your-base64-encoded-keyfile>
```

### For Init Service:

```
MONGOUSERNAME=admin
MONGOPASSWORD=<same-as-root-password>
REPLICA_SET_NAME=rs0
MONGO_PRIMARY_HOST=<primary-node-host>
MONGO_REPLICA_HOST=<replica1-node-host>
MONGO_REPLICA2_HOST=<replica2-node-host>
MONGO_PORT=27017
DEBUG=0  # Set to 1 for verbose logging
```

## Deployment Steps:

1. **Deploy 3 MongoDB nodes** using the `nodes/` configuration
2. **Deploy the init service** using `initService/` configuration
3. **Wait for init completion** and then delete the init service
4. **Test the replica set** connection

## Connection String:

```
mongodb://admin:<password>@<node1-host>:27017,<node2-host>:27017,<node3-host>:27017/<database>?replicaSet=rs0&authSource=admin
```

## Important Notes:

- The MongoDB nodes use the latest MongoDB version
- Auto-reconnect is configured with optimized heartbeat settings
- Restart policy is set to "always" for automatic recovery
- Healthchecks are configured for better monitoring
- Keyfile authentication ensures secure inter-node communication

## Troubleshooting:

- Set `DEBUG=1` on init service for detailed logs
- Check individual node logs for connectivity issues
- Ensure all environment variables are properly set
- Verify network connectivity between nodes
