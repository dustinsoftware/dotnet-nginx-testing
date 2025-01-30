#!/bin/bash
# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --route-name) ROUTE_NAME="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if ROUTE_NAME is set
if [ -z "$ROUTE_NAME" ]; then
    echo "Error: --route-name argument is required."
    exit 1
fi

declare -a TEST_CASES=(
    "nginx:18151/$ROUTE_NAME -c 100"
    "nginx:18151/$ROUTE_NAME -c 500"
    "nginx:18151/$ROUTE_NAME -c 1000"
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
