#!/bin/bash
# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --route-name) ROUTE_NAME="$2"; shift ;;
        --thread-pool-limiter) THREAD_POOL_LIMITER="$2"; shift ;;
        --host) HOST="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if ROUTE_NAME and HOST are set
if [ -z "$ROUTE_NAME" ] || [ -z "$HOST" ]; then
    echo "Error: --route-name and --host arguments are required."
    exit 1
fi

declare -a TEST_CASES=(
    "$HOST/$ROUTE_NAME -c 100"
    "$HOST/$ROUTE_NAME -c 500"
    "$HOST/$ROUTE_NAME -c 1000"
    "$HOST/$ROUTE_NAME -c 2000"
)

# Loop through the test cases and run bombardier for each
for TEST_CASE in "${TEST_CASES[@]}"; do
    URL=$(echo $TEST_CASE | awk '{print $1}')
    CONNECTIONS=$(echo $TEST_CASE | awk '{print $3}')
    
    echo "✨ Running test for URL: $URL with $CONNECTIONS connections"
    if [ -z "$THREAD_POOL_LIMITER" ]; then
        bombardier -c $CONNECTIONS -t 30s $URL
    else
        bombardier -c $CONNECTIONS -t 30s -H "thread-pool-limiter: $THREAD_POOL_LIMITER" $URL
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Test for $URL with $CONNECTIONS connections completed successfully."
    else
        echo "❌ Test for $URL with $CONNECTIONS connections failed."
    fi
done
