# Mongo Replica Set with Keyfile Auth - Latest Version

Deploy MongoDB Replica Set dengan versi terbaru di Railway. Setup ini menyediakan auto-reconnect, failover otomatis, dan konfigurasi production-ready.

## 🚀 Quick Deploy

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/ha-mongo)

## ✨ Features

- **Latest MongoDB Version**: Menggunakan `mongo:latest` Docker image
- **Auto-Reconnect**: Optimized heartbeat dan election timeout settings
- **Resilient Deployment**: Automatic restart policies dan health checks
- **Secure Authentication**: Keyfile-based authentication antar nodes
- **Production Ready**: Optimized cache settings dan connection handling
- **Detailed Logging**: Optional debug logging untuk troubleshooting
- **Failover Support**: Automatic primary election saat restart

## � Documentation

| File                                                           | Deskripsi                  |
| -------------------------------------------------------------- | -------------------------- |
| [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)                   | Panduan deployment lengkap |
| [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)           | Checklist step-by-step     |
| [railway-deployment-config.md](./railway-deployment-config.md) | Konfigurasi Railway detail |

## 🛠 Quick Start

### 1. Generate Keyfile

```bash
# Windows
generate-keyfile.cmd

# Linux/Mac
./generate-keyfile-local.sh
```

### 2. Deploy di Railway

Ikuti [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) untuk step-by-step deployment.

### 3. Verifikasi

```javascript
// Connect dan test replica set
rs.status();
```

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
