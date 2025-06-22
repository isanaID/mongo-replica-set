# Mongo Replica Set with Keyfile Auth - Latest Version

This repo contains the resources required to deploy a MongoDB replica set with the latest MongoDB version in Railway from a template. The setup includes auto-reconnect capabilities and optimized configurations for production use.

## 🚀 Quick Deploy

To deploy your own Mongo replica set in Railway, just click the button below!

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/ha-mongo)

## ✨ Features

- **Latest MongoDB Version**: Uses `mongo:latest` Docker image
- **Auto-Reconnect**: Optimized heartbeat and election timeout settings
- **Resilient Deployment**: Automatic restart policies and health checks
- **Secure Authentication**: Keyfile-based authentication between nodes
- **Production Ready**: Optimized cache settings and connection handling
- **Detailed Logging**: Optional debug logging for troubleshooting

## 📖 Documentation

For detailed deployment instructions, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)

For even more information, check out the tutorial in Railway: [Deploy and Monitor a MongoDB Replica Set](https://docs.railway.com/tutorials/deploy-and-monitor-mongo)

### About the MongoDB Nodes

The MongoDB nodes in the replica set are built from the latest [Mongo CE image in Docker Hub](https://hub.docker.com/_/mongo). Key customizations include:

- **Keyfile Authentication**: Secure inter-node communication
- **Health Checks**: Built-in monitoring for Railway
- **Optimized Settings**: Memory and performance optimizations
- **Auto-Restart**: Automatic recovery from failures

### About the Init Service

The init service executes the required commands to initiate the replica set with enhanced features:

- **Smart Detection**: Checks if replica set is already configured
- **Retry Logic**: Robust connection handling with timeouts
- **Status Validation**: Waits for full replica set operational status
- **Enhanced Logging**: Timestamp-based logging for better debugging

## 🔧 Environment Variables

### Required for MongoDB Nodes:

```bash
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=your-secure-password
REPLICA_SET_NAME=rs0
KEYFILE=your-base64-encoded-keyfile
```

### Required for Init Service:

```bash
MONGOUSERNAME=admin
MONGOPASSWORD=your-secure-password
REPLICA_SET_NAME=rs0
MONGO_PRIMARY_HOST=primary-node-host
MONGO_REPLICA_HOST=replica1-node-host
MONGO_REPLICA2_HOST=replica2-node-host
MONGO_PORT=27017
DEBUG=0  # Set to 1 for verbose logging
```

## 🔌 Connection String

```
mongodb://admin:password@node1:27017,node2:27017,node3:27017/database?replicaSet=rs0&authSource=admin
```

## 🛠 Troubleshooting

1. **Enable Debug Logging**: Set `DEBUG=1` on the init service
2. **Check Node Status**: Verify all nodes are running and accessible
3. **Verify Environment Variables**: Ensure all required variables are set
4. **Network Connectivity**: Check inter-node communication

## 🤝 Contributions

Pull requests are welcome. If you have any suggestions for how to improve this implementation of MongoDB replica sets, please feel free to make the changes in a PR.
