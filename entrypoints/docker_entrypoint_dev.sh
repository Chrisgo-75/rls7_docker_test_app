#!/bin/bash

# Entrypoint files are used to set up or configure a container at runtime.

# Tells shell that runs the script to fail fast if there are any problems later in the script.
set -e

# Run multiple services in a container.
# https://docs.docker.com/config/containers/multi-service_container/
# Using Bash Job Controls
# --turn on bash's job control
set -m

cp -r /usr/src/cache/node_modules/. /usr/src/app/node_modules/

# Compile Rails Assets at runtime.
RAILS_ENV=development bundle exec rake assets:precompile

# Start the primary process and put it in the background
bundle exec passenger start &

# Start the helper process
#bundle exec sidekiq -C config/sidekiq.yml

# now we bring the primary process back into the foreground
# and leave it there
fg %1

# Then exec the container's main process (what's set as CMD in the Dockerfile).
#exec "$@"
#service cron start && \
#  bundle exec passenger start