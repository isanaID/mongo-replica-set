#!/bin/bash

# 🔍 MongoDB Replica Set Diagnostic Script for Railway
# Use this to troubleshoot authentication and connectivity issues

set -e

echo "**********************************************************"
echo "*          MongoDB Replica Set Diagnostics              *"
echo "*                                                        *"
echo "*  This script will help diagnose common issues         *"
echo "*  with MongoDB replica set deployment on Railway       *"
echo "**********************************************************"
echo

# Check required environment variables
echo "🔧 Checking Environment Variables:"
echo "=================================="

required_vars=("MONGOUSERNAME" "MONGOPASSWORD" "REPLICA_SET_NAME" "MONGO_PRIMARY_HOST" "MONGO_REPLICA_HOST" "MONGO_REPLICA2_HOST" "MONGO_PORT")

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ $var is not set"
        has_missing_vars=true
    else
        if [[ "$var" == *"PASSWORD"* ]]; then
            echo "✅ $var is set (hidden)"
        else
            echo "✅ $var = ${!var}"
        fi
    fi
done

if [ "$has_missing_vars" = true ]; then
    echo "❌ Some required environment variables are missing!"
    exit 1
fi

echo
echo "🌐 Testing Network Connectivity:"
echo "================================"

# Test network connectivity to each node
test_connectivity() {
    local host=$1
    local port=$2
    echo -n "Testing $host:$port ... "
    
    if timeout 5 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo "✅ Connected"
        return 0
    else
        echo "❌ Failed"
        return 1
    fi
}

connectivity_issues=false

if ! test_connectivity "$MONGO_PRIMARY_HOST" "$MONGO_PORT"; then
    connectivity_issues=true
fi

if ! test_connectivity "$MONGO_REPLICA_HOST" "$MONGO_PORT"; then
    connectivity_issues=true
fi

if ! test_connectivity "$MONGO_REPLICA2_HOST" "$MONGO_PORT"; then
    connectivity_issues=true
fi

echo
echo "🔐 Testing MongoDB Authentication:"
echo "=================================="

# Test MongoDB ping without auth
test_mongo_ping() {
    local host=$1
    local port=$2
    echo -n "Testing MongoDB ping at $host:$port ... "
    
    ping_output=$(mongosh --host "$host" --port "$port" --eval "db.adminCommand('ping')" --quiet 2>&1)
    ping_exit_code=$?
    
    if [ $ping_exit_code -eq 0 ]; then
        echo "✅ MongoDB accessible"
        return 0
    else
        echo "❌ MongoDB not accessible"
        echo "   Error: $ping_output"
        return 1
    fi
}

# Test MongoDB auth
test_mongo_auth() {
    local host=$1
    local port=$2
    echo -n "Testing MongoDB auth at $host:$port ... "
    
    auth_output=$(mongosh --host "$host" --port "$port" --username "$MONGOUSERNAME" --password "$MONGOPASSWORD" --authenticationDatabase "admin" --eval "db.adminCommand('ping')" --quiet 2>&1)
    auth_exit_code=$?
    
    if [ $auth_exit_code -eq 0 ]; then
        echo "✅ Authentication successful"
        return 0
    else
        echo "❌ Authentication failed"
        echo "   Error: $auth_output"
        return 1
    fi
}

echo "Primary Node ($MONGO_PRIMARY_HOST):"
if test_mongo_ping "$MONGO_PRIMARY_HOST" "$MONGO_PORT"; then
    test_mongo_auth "$MONGO_PRIMARY_HOST" "$MONGO_PORT"
fi

echo
echo "Replica Node 1 ($MONGO_REPLICA_HOST):"
if test_mongo_ping "$MONGO_REPLICA_HOST" "$MONGO_PORT"; then
    test_mongo_auth "$MONGO_REPLICA_HOST" "$MONGO_PORT"
fi

echo
echo "Replica Node 2 ($MONGO_REPLICA2_HOST):"
if test_mongo_ping "$MONGO_REPLICA2_HOST" "$MONGO_PORT"; then
    test_mongo_auth "$MONGO_REPLICA2_HOST" "$MONGO_PORT"
fi

echo
echo "📋 Diagnosis Summary:"
echo "===================="

if [ "$connectivity_issues" = true ]; then
    echo "❌ Network Connectivity Issues Found:"
    echo "   - Some MongoDB nodes are not accessible"
    echo "   - Check if all MongoDB services are running in Railway"
    echo "   - Verify service names match: mongo1, mongo2, mongo3"
    echo
fi

echo "🔍 Common Solutions for Authentication Failed:"
echo "=============================================="
echo "1. Verify Environment Variables Match:"
echo "   MongoDB Nodes: MONGO_INITDB_ROOT_USERNAME=admin"
echo "   MongoDB Nodes: MONGO_INITDB_ROOT_PASSWORD=YourPassword"
echo "   Init Service:  MONGOUSERNAME=admin"
echo "   Init Service:  MONGOPASSWORD=YourPassword"
echo
echo "2. Verify Keyfile Consistency:"
echo "   All 3 MongoDB nodes must have the SAME KEYFILE value"
echo
echo "3. Check Service Status:"
echo "   All MongoDB nodes should be 'Running' with health checks 'Passing'"
echo
echo "4. Redeploy If Needed:"
echo "   If credentials were wrong, redeploy MongoDB nodes with correct values"
echo

echo "🚀 Next Steps:"
echo "=============="
echo "1. If auth failed: Fix environment variables and redeploy"
echo "2. If network failed: Check service names and restart services"
echo "3. Set DEBUG=1 on init service for verbose logging"
echo "4. Follow DEPLOYMENT_CHECKLIST.md for step-by-step guide"
echo
