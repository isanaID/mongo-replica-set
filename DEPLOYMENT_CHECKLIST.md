# ✅ MongoDB Replica Set Deployment Checklist

## Pre-Deployment

- [ ] **Generate Keyfile**

  - Windows: Jalankan `generate-keyfile.cmd`
  - Linux/Mac: Jalankan `generate-keyfile-local.sh`
  - Simpan output keyfile untuk digunakan nanti

- [ ] **Prepare Credentials**
  - Username: `admin`
  - Password: Buat password yang kuat (contoh: `MySecurePass123!`)
  - Simpan credential ini untuk semua services

## Railway Deployment Steps

### Step 1: Deploy MongoDB Node 1 (Primary)

- [ ] Buat service baru dengan nama: `mongo1`
- [ ] Set Dockerfile path: `nodes/Dockerfile`
- [ ] Add environment variables:
  ```
  MONGO_INITDB_ROOT_USERNAME=admin
  MONGO_INITDB_ROOT_PASSWORD=MySecurePass123!
  REPLICA_SET_NAME=rs0
  KEYFILE=<your-generated-keyfile>
  ```
- [ ] Set restart policy: `Always`
- [ ] Deploy dan tunggu sampai status `Running` dan health check `Passing`

### Step 2: Deploy MongoDB Node 2 (Secondary)

- [ ] Buat service baru dengan nama: `mongo2`
- [ ] Set Dockerfile path: `nodes/Dockerfile`
- [ ] Add environment variables yang SAMA seperti mongo1:
  ```
  MONGO_INITDB_ROOT_USERNAME=admin
  MONGO_INITDB_ROOT_PASSWORD=MySecurePass123!
  REPLICA_SET_NAME=rs0
  KEYFILE=<same-keyfile-as-mongo1>
  ```
- [ ] Set restart policy: `Always`
- [ ] Deploy dan tunggu sampai status `Running` dan health check `Passing`

### Step 3: Deploy MongoDB Node 3 (Secondary)

- [ ] Buat service baru dengan nama: `mongo3`
- [ ] Set Dockerfile path: `nodes/Dockerfile`
- [ ] Add environment variables yang SAMA seperti mongo1 & mongo2:
  ```
  MONGO_INITDB_ROOT_USERNAME=admin
  MONGO_INITDB_ROOT_PASSWORD=MySecurePass123!
  REPLICA_SET_NAME=rs0
  KEYFILE=<same-keyfile-as-mongo1>
  ```
- [ ] Set restart policy: `Always`
- [ ] Deploy dan tunggu sampai status `Running` dan health check `Passing`

### Step 4: Deploy Init Service (Temporary)

- [ ] Buat service baru dengan nama: `mongo-init`
- [ ] Set Dockerfile path: `initService/Dockerfile`
- [ ] Add environment variables:
  ```
  MONGOUSERNAME=admin
  MONGOPASSWORD=MySecurePass123!
  REPLICA_SET_NAME=rs0
  MONGO_PRIMARY_HOST=mongo1.railway.internal
  MONGO_REPLICA_HOST=mongo2.railway.internal
  MONGO_REPLICA2_HOST=mongo3.railway.internal
  MONGO_PORT=27017
  DEBUG=1
  ```
- [ ] Set restart policy: `Never`
- [ ] Deploy dan monitor logs

### Step 5: Verify and Cleanup

- [ ] Check init service logs untuk pesan sukses:
  ```
  ✓ Replica set initiated successfully
  PLEASE DELETE THIS SERVICE
  ```
- [ ] **DELETE** mongo-init service setelah berhasil
- [ ] Verify semua 3 mongo nodes masih running dengan health check passing

## Post-Deployment Verification

### Test Connection

- [ ] Test connection string:
  ```
  mongodb://admin:MySecurePass123!@mongo1.railway.internal:27017,mongo2.railway.internal:27017,mongo3.railway.internal:27017/test?replicaSet=rs0&authSource=admin
  ```

### Verify Replica Set Status

- [ ] Connect ke salah satu node dan jalankan:
  ```javascript
  rs.status();
  ```
- [ ] Pastikan ada 3 members dengan status:
  - 1 PRIMARY
  - 2 SECONDARY

### Test Auto-Reconnect

- [ ] Restart salah satu secondary node
- [ ] Verify replica set masih berfungsi
- [ ] Restart primary node (akan ada failover)
- [ ] Verify new primary terpilih otomatis

## Common Issues & Solutions

### ❌ Authentication Failed

**Problem**: Error "MongoServerError: Authentication failed"
**Solution**:

- [ ] Verify `MONGOPASSWORD` = `MONGO_INITDB_ROOT_PASSWORD`
- [ ] Verify `MONGOUSERNAME` = `MONGO_INITDB_ROOT_USERNAME`
- [ ] Redeploy init service dengan credentials yang benar

### ❌ Node Not Accessible

**Problem**: Cannot connect to mongo node
**Solution**:

- [ ] Verify service names: `mongo1`, `mongo2`, `mongo3`
- [ ] Verify hostnames: `mongo1.railway.internal`, etc.
- [ ] Check if all mongo nodes are running

### ❌ Keyfile Issues

**Problem**: Replica set fails to start
**Solution**:

- [ ] Verify same `KEYFILE` value di semua 3 nodes
- [ ] Generate keyfile baru jika perlu
- [ ] Redeploy semua mongo nodes dengan keyfile yang sama

## Success Criteria

✅ **Deployment berhasil jika:**

- [ ] 3 MongoDB nodes running dengan health check passing
- [ ] Init service completed successfully dan sudah di-delete
- [ ] Connection string dapat connect
- [ ] `rs.status()` menunjukkan 1 PRIMARY + 2 SECONDARY
- [ ] Auto-reconnect works setelah restart nodes

## Final Connection String

```
mongodb://admin:MySecurePass123!@mongo1.railway.internal:27017,mongo2.railway.internal:27017,mongo3.railway.internal:27017/your-database?replicaSet=rs0&authSource=admin
```

**Replace `your-database` dengan nama database aplikasi Anda.**
