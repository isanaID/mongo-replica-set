#!/bin/bash

set -e

debug_log() {
  if [[ "$DEBUG" == "1" ]]; then
    echo "DEBUG: $1"
  fi
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

print_on_start() {
  echo "**********************************************************"
  echo "*                                                        *"
  echo "*  Deploying a Mongo Replica Set to Railway...           *"
  echo "*                                                        *"
  echo "*  To enable verbose logging, set DEBUG=1                *"
  echo "*  and redeploy the service.                             *"
  echo "*                                                        *"
  echo "**********************************************************"
}

check_mongo() {
  local host=$1
  local port=$2
  local max_retries=30
  local retry_count=0
  
  while [ $retry_count -lt $max_retries ]; do
    mongo_output=$(mongosh --host "$host" --port "$port" --eval "db.adminCommand('ping')" --quiet 2>&1)
    mongo_exit_code=$?
    debug_log "MongoDB check attempt $((retry_count + 1))/$max_retries - exit code: $mongo_exit_code"
    debug_log "MongoDB check output: $mongo_output"
    
    if [ $mongo_exit_code -eq 0 ]; then
      return 0
    fi
    
    retry_count=$((retry_count + 1))
    sleep 2
  done
  
  return 1
}

check_all_nodes() {
  local nodes=("$@")
  for node in "${nodes[@]}"; do
    local host=$(echo $node | cut -d: -f1)
    local port=$(echo $node | cut -d: -f2)
    log "Waiting for MongoDB to be available at $host:$port"
    if check_mongo "$host" "$port"; then
      log "✓ MongoDB node $host:$port is ready"
    else
      log "✗ Failed to connect to MongoDB node $host:$port after maximum retries"
      return 1
    fi
  done
  log "All MongoDB nodes are up and running."
}

check_replica_status() {
  local host=$1
  local port=$2
  
  log "Checking if replica set is already configured..."
  
  # First try without authentication to see if node is accessible
  ping_output=$(mongosh --host "$host" --port "$port" --eval "db.adminCommand('ping')" --quiet 2>&1)
  ping_exit_code=$?
  
  debug_log "Ping check exit code: $ping_exit_code"
  debug_log "Ping output: $ping_output"
  
  if [ $ping_exit_code -ne 0 ]; then
    log "ERROR: Cannot connect to MongoDB at $host:$port"
    log "This usually means the MongoDB service is not running or not accessible"
    return 2
  fi
  
  # Try with authentication
  status_output=$(mongosh --host "$host" --port "$port" --username "$MONGOUSERNAME" --password "$MONGOPASSWORD" --authenticationDatabase "admin" --eval "rs.status()" --quiet 2>&1)
  status_exit_code=$?
  
  debug_log "Replica status check exit code: $status_exit_code"
  debug_log "Replica status output: $status_output"
  
  if [[ "$status_output" == *"Authentication failed"* ]]; then
    log "ERROR: Authentication failed!"
    log "Please verify:"
    log "  1. MONGOUSERNAME=$MONGOUSERNAME matches MONGO_INITDB_ROOT_USERNAME on nodes"
    log "  2. MONGOPASSWORD matches MONGO_INITDB_ROOT_PASSWORD on nodes"
    log "  3. All MongoDB nodes have the same credentials"
    return 3
  fi
  
  if [ $status_exit_code -eq 0 ]; then
    log "Replica set is already configured. Checking configuration..."
    return 0
  else
    log "Replica set is not configured yet."
    return 1
  fi
}

initiate_replica_set() {
  log "Initiating replica set configuration..."
  debug_log "_id: $REPLICA_SET_NAME"
  debug_log "Primary member: $MONGO_PRIMARY_HOST:$MONGO_PORT"
  debug_log "Replica member 1: $MONGO_REPLICA_HOST:$MONGO_PORT"
  debug_log "Replica member 2: $MONGO_REPLICA2_HOST:$MONGO_PORT"

  mongosh --host "$MONGO_PRIMARY_HOST" --port "$MONGO_PORT" --username "$MONGOUSERNAME" --password "$MONGOPASSWORD" --authenticationDatabase "admin" --quiet <<EOF
try {
  var config = {
    _id: "$REPLICA_SET_NAME",
    members: [
      { _id: 0, host: "$MONGO_PRIMARY_HOST:$MONGO_PORT", priority: 2 },
      { _id: 1, host: "$MONGO_REPLICA_HOST:$MONGO_PORT", priority: 1 },
      { _id: 2, host: "$MONGO_REPLICA2_HOST:$MONGO_PORT", priority: 1 }
    ],
    settings: {
      electionTimeoutMillis: 5000,
      heartbeatTimeoutSecs: 5,
      heartbeatIntervalMillis: 2000
    }
  };
  
  var result = rs.initiate(config);
  print("Replica set initiation result: " + JSON.stringify(result));
  
  if (result.ok === 1) {
    print("SUCCESS: Replica set initiated successfully");
  } else {
    print("ERROR: Failed to initiate replica set");
    quit(1);
  }
} catch (e) {
  print("ERROR: Exception during replica set initiation: " + e);
  quit(1);
}
EOF
  init_exit_code=$?
  debug_log "Replica set initiation exit code: $init_exit_code"
  return $init_exit_code
}

wait_for_replica_ready() {
  log "Waiting for replica set to be fully operational..."
  local max_wait=120
  local wait_count=0
  
  while [ $wait_count -lt $max_wait ]; do
    status_output=$(mongosh --host "$MONGO_PRIMARY_HOST" --port "$MONGO_PORT" --username "$MONGOUSERNAME" --password "$MONGOPASSWORD" --authenticationDatabase "admin" --eval "rs.status().ok" --quiet 2>&1)
    
    if [[ "$status_output" == *"1"* ]]; then
      log "✓ Replica set is fully operational"
      return 0
    fi
    
    wait_count=$((wait_count + 5))
    sleep 5
  done
  
  log "⚠ Timeout waiting for replica set to be fully operational"
  return 1
}

# Main execution
nodes=("$MONGO_PRIMARY_HOST:$MONGO_PORT" "$MONGO_REPLICA_HOST:$MONGO_PORT" "$MONGO_REPLICA2_HOST:$MONGO_PORT")

print_on_start

# Check if all nodes are available
if ! check_all_nodes "${nodes[@]}"; then
  log "ERROR: Not all MongoDB nodes are available. Exiting."
  exit 1
fi

# Check if replica set is already configured
replica_status_result=$(check_replica_status "$MONGO_PRIMARY_HOST" "$MONGO_PORT")
replica_status_code=$?

if [ $replica_status_code -eq 0 ]; then
  log "Replica set is already configured. No action needed."
  log "**********************************************************"
  log "*           Replica set is already operational.          *"
  log "*              PLEASE DELETE THIS SERVICE.               *"
  log "**********************************************************"
  exit 0
elif [ $replica_status_code -eq 2 ]; then
  log "ERROR: Cannot connect to primary MongoDB node. Exiting."
  exit 1
elif [ $replica_status_code -eq 3 ]; then
  log "ERROR: Authentication failed. Please check credentials and redeploy."
  log "**********************************************************"
  log "*                 AUTHENTICATION ERROR                   *"
  log "*                                                        *"
  log "*  Please verify environment variables:                  *"
  log "*  - MONGOUSERNAME should match MONGO_INITDB_ROOT_USERNAME *"
  log "*  - MONGOPASSWORD should match MONGO_INITDB_ROOT_PASSWORD *"
  log "*  - All MongoDB nodes should have same credentials      *"
  log "*                                                        *"
  log "**********************************************************"
  exit 1
fi

# Initiate replica set
if initiate_replica_set && wait_for_replica_ready; then
  log "**********************************************************"
  log "**********************************************************"
  log "*                                                        *"
  log "*           Replica set initiated successfully.          *"
  log "*                                                        *"
  log "*              PLEASE DELETE THIS SERVICE.               *"
  log "*                                                        *"
  log "**********************************************************"
  exit 0
else
  log "**********************************************************"
  log "**********************************************************"
  log "*                                                        *"
  log "*           Failed to initiate replica set.              *"
  log "*                                                        *"
  log "*           Please check the MongoDB service logs        *"
  log "*                 for more information.                  *"
  log "*                                                        *"
  log "*          You can also set DEBUG=1 as a variable        *"
  log "*            on this service for verbose logging.        *"
  log "*                                                        *"
  log "**********************************************************"
  exit 1
fi
