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
until [ "$(curl -s http://${HUB_HOST:-hub}:4444/status | jq -r .value.ready)" == "true" ]; do
  count=$((count+1))
  echo "Hub not ready yet - Attempt ${count}"
  if [ "$count" -ge 30 ]; then
    echo "**** HUB IS NOT READY WITHIN 30 SECONDS ****"
    exit 1
  fi
  sleep 1
done

echo "Selenium Hub is up. Now checking if browser nodes are registered..."

# Step 2: Wait for the appropriate browser node to register (Improved with /grid/status)
browser_type="${BROWSER:-chrome}"
count=0

while true; do
  grid_response=$(curl -s http://${HUB_HOST:-hub}:4444/grid/status)

  has_nodes=$(echo "$grid_response" | jq '.nodes | type == "array"')
  if [ "$has_nodes" == "true" ]; then
    node_count=$(echo "$grid_response" | jq ".nodes[] | select(.slots[].stereotype.browserName==\"${browser_type}\")" | wc -l)
  else
    node_count=0
  fi

  if [ "$node_count" -ge 1 ]; then
    echo "$browser_type node(s) registered with Selenium Grid."
    break
  fi

  count=$((count+1))
  echo "Waiting for $browser_type node to register... Attempt ${count}"
  if [ "$count" -ge 30 ]; then
    echo "**** $browser_type NODE NOT REGISTERED WITHIN 30 SECONDS ****"
    exit 1
  fi
  sleep 1
done

# Step 3: Start the test suite
echo "Running the tests now..."

java -cp 'libs/*' \
     -Dselenium.grid.enabled=true \
     -Dselenium.grid.hubHost="${HUB_HOST:-hub}" \
     -Dbrowser="${BROWSER:-chrome}" \
     org.testng.TestNG \
     -threadcount "${THREAD_COUNT:-1}" \
     -d /home/selenium-docker/test-output \
     test-suites/"${TEST_SUITE}"
