#!/bin/bash
# Script to generate a secure keyfile for MongoDB replica set authentication
# Run this locally and use the output as your KEYFILE environment variable

# Generate a 1024-byte random key and encode it in base64
openssl rand -base64 756 | tr -d '\n' > keyfile.txt

echo "Generated keyfile saved to keyfile.txt"
echo "Use this content as your KEYFILE environment variable:"
echo "=================================================="
cat keyfile.txt
echo ""
echo "=================================================="
echo ""
echo "Make sure to set this same KEYFILE value for all MongoDB nodes!"
echo "Keep this keyfile secure - it's used for authentication between replica set members."
