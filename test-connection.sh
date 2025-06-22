#!/bin/bash
# Script to test MongoDB replica set connection and status

# Default values - override with environment variables
PRIMARY_HOST=${MONGO_PRIMARY_HOST:-"localhost"}
REPLICA_HOST=${MONGO_REPLICA_HOST:-"localhost"}
REPLICA2_HOST=${MONGO_REPLICA2_HOST:-"localhost"}
PORT=${MONGO_PORT:-27017}
USERNAME=${MONGOUSERNAME:-"admin"}
PASSWORD=${MONGOPASSWORD:-""}
REPLICA_SET_NAME=${REPLICA_SET_NAME:-"rs0"}

if [ -z "$PASSWORD" ]; then
    echo "Please set MONGOPASSWORD environment variable"
    exit 1
fi

echo "Testing MongoDB Replica Set Connection..."
echo "========================================="

# Test individual nodes
echo "Testing Primary Node: $PRIMARY_HOST:$PORT"
mongosh --host "$PRIMARY_HOST" --port "$PORT" --username "$USERNAME" --password "$PASSWORD" --authenticationDatabase "admin" --eval "db.adminCommand('ping')" --quiet

echo "Testing Replica Node 1: $REPLICA_HOST:$PORT"
mongosh --host "$REPLICA_HOST" --port "$PORT" --username "$USERNAME" --password "$PASSWORD" --authenticationDatabase "admin" --eval "db.adminCommand('ping')" --quiet

echo "Testing Replica Node 2: $REPLICA2_HOST:$PORT"
mongosh --host "$REPLICA2_HOST" --port "$PORT" --username "$USERNAME" --password "$PASSWORD" --authenticationDatabase "admin" --eval "db.adminCommand('ping')" --quiet

echo ""
echo "Checking Replica Set Status..."
echo "=============================="

# Check replica set status
mongosh --host "$PRIMARY_HOST" --port "$PORT" --username "$USERNAME" --password "$PASSWORD" --authenticationDatabase "admin" --eval "
try {
    var status = rs.status();
    print('Replica Set Status: ' + status.ok);
    print('Set Name: ' + status.set);
    print('Members:');
    status.members.forEach(function(member) {
        print('  - ' + member.name + ' (' + member.stateStr + ')');
    });
} catch (e) {
    print('Error checking replica set status: ' + e);
}" --quiet

echo ""
echo "Connection String:"
echo "mongodb://$USERNAME:$PASSWORD@$PRIMARY_HOST:$PORT,$REPLICA_HOST:$PORT,$REPLICA2_HOST:$PORT/your-database?replicaSet=$REPLICA_SET_NAME&authSource=admin"
