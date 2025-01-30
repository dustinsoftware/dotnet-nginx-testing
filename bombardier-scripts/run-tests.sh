#!/bin/bash

# Define the test cases
declare -a TEST_CASES=(
    "nginx:18151/async-slow?delay=1000 -c 100"
    "nginx:18151/async-slow?delay=1000 -c 500"
    "nginx:18151/async-slow?delay=1000 -c 1000"
    "nginx:18151/sync-slow?delay=1000 -c 100"
    "nginx:18151/sync-slow?delay=1000 -c 500"
    "nginx:18151/sync-slow?delay=1000 -c 1000"
)

# Loop through the test cases and run bombardier for each
for TEST_CASE in "${TEST_CASES[@]}"; do
    URL=$(echo $TEST_CASE | awk '{print $1}')
    CONNECTIONS=$(echo $TEST_CASE | awk '{print $3}')
    
    echo "✨ Running test for URL: $URL with $CONNECTIONS connections"
    bombardier -c $CONNECTIONS -H "use-thread-pool-limiter: 200" $URL
    
    if [ $? -eq 0 ]; then
        echo "✅ Test for $URL with $CONNECTIONS connections completed successfully."
    else
        echo "❌ Test for $URL with $CONNECTIONS connections failed."
    fi
done
