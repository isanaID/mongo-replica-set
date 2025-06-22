# Railway Deployment Configuration

## 🚀 Step-by-Step Deployment di Railway

### Persiapan:

1. Generate keyfile menggunakan `generate-keyfile.cmd` (Windows) atau `generate-keyfile-local.sh` (Linux/Mac)
2. Simpan keyfile yang di-generate

### Service 1: mongo1 (Primary Node)

```
Service Name: mongo1
Dockerfile Path: nodes/Dockerfile
Environment Variables:
  MONGO_INITDB_ROOT_USERNAME=admin
  MONGO_INITDB_ROOT_PASSWORD=YourSecurePassword123!
  REPLICA_SET_NAME=rs0
  KEYFILE=<your-generated-keyfile>
Restart Policy: Always
```

### Service 2: mongo2 (Secondary Node)

```
Service Name: mongo2
Dockerfile Path: nodes/Dockerfile
Environment Variables:
  MONGO_INITDB_ROOT_USERNAME=admin
  MONGO_INITDB_ROOT_PASSWORD=YourSecurePassword123!
  REPLICA_SET_NAME=rs0
  KEYFILE=<same-keyfile-as-mongo1>
Restart Policy: Always
```

### Service 3: mongo3 (Secondary Node)

```
Service Name: mongo3
Dockerfile Path: nodes/Dockerfile
Environment Variables:
  MONGO_INITDB_ROOT_USERNAME=admin
  MONGO_INITDB_ROOT_PASSWORD=YourSecurePassword123!
  REPLICA_SET_NAME=rs0
  KEYFILE=<same-keyfile-as-mongo1>
Restart Policy: Always
```

### Service 4: mongo-init (Init Service - Temporary)

```
Service Name: mongo-init
Dockerfile Path: initService/Dockerfile
Environment Variables:
  MONGOUSERNAME=admin
  MONGOPASSWORD=YourSecurePassword123!
  REPLICA_SET_NAME=rs0
  MONGO_PRIMARY_HOST=mongo1.railway.internal
  MONGO_REPLICA_HOST=mongo2.railway.internal
  MONGO_REPLICA2_HOST=mongo3.railway.internal
  MONGO_PORT=27017
  DEBUG=1
Restart Policy: Never
```

## ⚠️ IMPORTANT NOTES:

1. **Password Consistency**: `MONGO_INITDB_ROOT_PASSWORD` harus SAMA di semua mongo nodes, dan `MONGOPASSWORD` di init service harus sama dengan password tersebut.

2. **Keyfile Consistency**: `KEYFILE` harus SAMA di semua 3 mongo nodes.

3. **Deployment Order**:

   - Deploy mongo1, tunggu sampai running
   - Deploy mongo2, tunggu sampai running
   - Deploy mongo3, tunggu sampai running
   - Deploy mongo-init, tunggu sampai selesai
   - DELETE mongo-init service setelah selesai

4. **Network Names**: Gunakan `servicename.railway.internal` untuk komunikasi antar service.

## 🔗 Final Connection String:

```
mongodb://admin:YourSecurePassword123!@mongo1.railway.internal:27017,mongo2.railway.internal:27017,mongo3.railway.internal:27017/your-database?replicaSet=rs0&authSource=admin
```

## 🔍 Monitoring:

Setelah deployment berhasil:

- Check logs di Railway dashboard
- Verify health checks passing
- Test connection menggunakan MongoDB client
- Monitor CPU/Memory usage

## 🔄 Auto-Recovery:

Replica set akan otomatis:

- Reconnect setelah restart service
- Handle failover jika primary node down
- Maintain data consistency across nodes
- Restart unhealthy containers
