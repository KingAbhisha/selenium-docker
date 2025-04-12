#!/bin/bash

#-------------------------------------------------------------------
#  This script expects the following environment variables:
#     HUB_HOST
#     BROWSER
#     THREAD_COUNT
#     TEST_SUITE
#-------------------------------------------------------------------

echo "-------------------------------------------"
echo "HUB_HOST      : ${HUB_HOST:-hub}"
echo "BROWSER       : ${BROWSER:-chrome}"
echo "THREAD_COUNT  : ${THREAD_COUNT:-1}"
echo "TEST_SUITE    : ${TEST_SUITE}"
echo "-------------------------------------------"

# Step 1: Wait for Selenium Grid Hub to be ready
echo "Checking if hub is ready..!"
count=0
until [ "$(curl -s http://${HUB_HOST:-hub}:4444/status | jq -r .value.ready)" == "true" ]; do  ### <<< MODIFIED
  count=$((count+1))
  echo "Hub not ready yet - Attempt ${count}"       ### <<< MODIFIED
  if [ "$count" -ge 30 ]; then
    echo "**** HUB IS NOT READY WITHIN 30 SECONDS ****"
    exit 1
  fi
  sleep 1
done

echo "Selenium Hub is up. Now checking if browser nodes are registered..."  ### <<< ADDED

# Step 2: Wait for the appropriate browser node to register  ### <<< ADDED
browser_type="${BROWSER:-chrome}"  ### <<< ADDED

count=0
while true; do
  node_count=$(curl -s http://${HUB_HOST:-hub}:4444/grid/status | jq ".nodes[] | select(.slots[].stereotype.browserName==\"${browser_type}\")" | wc -l)
  if [ "$node_count" -ge 1 ]; then
    echo "$browser_type node(s) registered with Selenium Grid."  ### <<< ADDED
    break
  fi
  count=$((count+1))
  echo "Waiting for $browser_type node to register... Attempt ${count}"  ### <<< ADDED
  if [ "$count" -ge 30 ]; then
    echo "**** $browser_type NODE NOT REGISTERED WITHIN 30 SECONDS ****"  ### <<< ADDED
    exit 1
  fi
  sleep 1
done

# Step 3: Start the test suite
echo "Running the tests now..."  ### <<< ADDED

java -cp 'libs/*' \
     -Dselenium.grid.enabled=true \
     -Dselenium.grid.hubHost="${HUB_HOST:-hub}" \
     -Dbrowser="${BROWSER:-chrome}" \
     org.testng.TestNG \
     -threadcount "${THREAD_COUNT:-1}" \
     -d /home/selenium-docker/test-output \
     test-suites/"${TEST_SUITE}"