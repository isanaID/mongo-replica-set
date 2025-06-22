# MongoDB Replica Set Deployment Guide

Panduan lengkap untuk deploy MongoDB Replica Set di Railway dengan MongoDB versi terbaru dan auto-reconnect.

## 🔧 Environment Variables Required

### Langkah 1: Generate Keyfile

Pertama, generate keyfile untuk autentikasi antar node:

```bash
# Di terminal lokal
openssl rand -base64 756 | tr -d '\n'
```

Simpan output ini sebagai nilai `KEYFILE` environment variable.

### Langkah 2: Set Environment Variables

#### Untuk MongoDB Nodes (3 services):

**PENTING**: Gunakan nilai yang SAMA untuk semua 3 node MongoDB!

```
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=SuperSecurePassword123!
REPLICA_SET_NAME=rs0
KEYFILE=<hasil-dari-openssl-command-diatas>
```

#### Untuk Init Service (1 service):

```
MONGOUSERNAME=admin
MONGOPASSWORD=SuperSecurePassword123!
REPLICA_SET_NAME=rs0
MONGO_PRIMARY_HOST=mongo1.railway.internal
MONGO_REPLICA_HOST=mongo2.railway.internal
MONGO_REPLICA2_HOST=mongo3.railway.internal
MONGO_PORT=27017
DEBUG=1
```

## 🚀 Deployment Steps (Urutan Penting!):

### Langkah 1: Deploy MongoDB Nodes

1. **Deploy Node 1** (Primary):

   - Service name: `mongo1`
   - Dockerfile path: `nodes/Dockerfile`
   - Set environment variables di atas
   - **TUNGGU sampai sepenuhnya running**

2. **Deploy Node 2** (Secondary):

   - Service name: `mongo2`
   - Dockerfile path: `nodes/Dockerfile`
   - Set environment variables yang sama
   - **TUNGGU sampai sepenuhnya running**

3. **Deploy Node 3** (Secondary):
   - Service name: `mongo3`
   - Dockerfile path: `nodes/Dockerfile`
   - Set environment variables yang sama
   - **TUNGGU sampai sepenuhnya running**

### Langkah 2: Deploy Init Service

4. **Deploy Init Service**:
   - Service name: `mongo-init`
   - Dockerfile path: `initService/Dockerfile`
   - Set environment variables init service
   - **Restart policy**: Never
   - **TUNGGU sampai selesai dan delete service ini**

## 🔗 Connection String:

Setelah replica set berhasil di-setup:

```
mongodb://admin:SuperSecurePassword123!@mongo1.railway.internal:27017,mongo2.railway.internal:27017,mongo3.railway.internal:27017/your-database?replicaSet=rs0&authSource=admin
```

## ✅ Verifikasi Deployment:

### Cek Status Replica Set:

```javascript
// Connect ke salah satu node dan jalankan:
rs.status();
```

### Test Connection:

```javascript
// Verifikasi semua node dapat berkomunikasi:
db.adminCommand("ping");
```

## 🚨 Troubleshooting Masalah Autentikasi:

### 1. Authentication Failed Error:

**Penyebab**: Password atau keyfile tidak sama di semua node

**Solusi**:

- Pastikan `MONGO_INITDB_ROOT_PASSWORD` SAMA di semua 3 node
- Pastikan `MONGOPASSWORD` di init service = `MONGO_INITDB_ROOT_PASSWORD`
- Pastikan `KEYFILE` SAMA di semua 3 node

### 2. Node Cannot Connect:

**Penyebab**: Network atau hostname salah

**Solusi**:

- Pastikan hostname menggunakan format: `servicename.railway.internal`
- Contoh: `mongo1.railway.internal`, `mongo2.railway.internal`, dll

### 3. Init Service Gagal:

**Solusi**:

- Set `DEBUG=1` pada init service
- Cek logs untuk detail error
- Pastikan semua 3 node sudah running sebelum deploy init service

## 🔄 Auto-Reconnect Features:

Setelah setup berhasil, replica set akan otomatis:

- **Reconnect saat restart**: Menggunakan heartbeat optimized settings
- **Failover otomatis**: Jika primary down, secondary akan menjadi primary
- **Health monitoring**: Railway akan restart service jika health check gagal

## 📝 Important Notes:

- **MongoDB Version**: Menggunakan `mongo:latest` (versi terbaru)
- **Memory Optimization**: WiredTiger cache di-set 0.25GB untuk Railway
- **Restart Policy**: Node MongoDB = "always", Init service = "never"
- **Security**: Keyfile authentication untuk komunikasi antar node
- **Performance**: Optimized connection pooling dan cache settings

## 🔧 Post-Deployment Tasks:

1. **Delete Init Service** setelah berhasil
2. **Backup keyfile** untuk recovery di masa depan
3. **Test failover** dengan restart salah satu node
4. **Monitor logs** untuk memastikan semua berjalan normal

## 📞 Support:

Jika masih ada masalah:

1. Set `DEBUG=1` di init service
2. Check logs setiap service di Railway dashboard
3. Pastikan semua environment variables benar
4. Verify network connectivity antar services
