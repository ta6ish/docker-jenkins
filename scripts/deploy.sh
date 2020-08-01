#!/usr/bin/env bash

#Set variables
set -e
COMMIT=$(git rev-parse HEAD)
APP_NAME="nodeapp-$BRANCH_NAME"
NGINX_NAME="nginx-$BRANCH_NAME"
IMAGE_NAME="nodeapp/$BRANCH_NAME:$COMMIT"
CONTAINER_IDS=$(docker container ls -a -q --filter="name=$APP_NAME")
NGINX_CONTAINER=$(docker container ls -q --filter="name=$NGINX_NAME")
NETWORK_ID=$(docker network ls --filter="name=$APP_NAME" -q)
CONTAINER_NAME="$APP_NAME-$COMMIT"

echo "Deploying $CONTAINER_NAME FROM $IMAGE_NAME"

# Create network
if [ -z "$NETWORK_ID" ]; then
  echo "Deploying Network"
  docker network create "$APP_NAME"
fi


echo "Deploying app"
# Run new app Container
NEW_CONTAINER_ID=$(docker container run -d --network="$APP_NAME" -e NODE_ENV=production --name "$CONTAINER_NAME" "$IMAGE_NAME" )

# Confirm Container Status
attempt=0
while [ $attempt -le 10 ]; do
    attempt=$(($attempt + 1))
    echo "Waiting for container (attempt: $attempt)..."
    result=$(docker inspect -f '{{.State.Running}}' "$NEW_CONTAINER_ID")
    if [[ "$result" == "true" ]]; then
      echo "App container is up!"
      break
    fi
    sleep 2
done;

# Update Nginx config
echo "Updating Nginx"
sed -i "s/server nodeapp.*/server $CONTAINER_NAME:3000;/" ./scripts/nginx.conf/default.conf

# Run Nginx
if [ -z "$NGINX_CONTAINER" ]; then
  echo "Deploying Nginx $NGINX_CONTAINER"
  docker container run -v "$(pwd)/scripts/nginx.conf":/etc/nginx/conf.d -d --network="$APP_NAME" --name="$NGINX_NAME" -p 8081:8081 nginx:alpine
  sleep 2
fi

# Verify nginx
echo "Verifying Nginx"
docker container exec "$NGINX_NAME" nginx -t
LAST_RES=$?
if [ $LAST_RES -eq 0 ]; then
  echo "Reloading nginx"
  docker kill -s HUP "$NGINX_NAME"

  # Remove old container
  if [ -n "$CONTAINER_IDS" ]; then
    echo "Removing existing containers"
    docker container stop $CONTAINER_IDS
    docker container rm $CONTAINER_IDS
    WAIT_SEC=5
    echo "Waiting for $WAIT_SEC seconds"
    sleep $WAIT_SEC
  fi
else
  echo "Nginx config failure"
  exit 1
fi

# Remove dangling images
DANGLING_IMAGES=$(docker image ls -q -f "dangling=true")

if [ -n "$DANGLING_IMAGES" ]; then
  echo "Removing dangling images"
  docker image rm $(docker image ls -q -f "dangling=true")
fi

echo "Done";
