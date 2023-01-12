#!/usr/bin/env bash
set -eo pipefail

# Create mount directory for service
mkdir -p $MNT_DIR
chmod g+w $MNT_DIR

echo "Mounting bucket $BUCKET GCS on $MNT_DIR"
gcsfuse --debug_gcs --debug_fuse --implicit-dirs --stat-cache-ttl 0  -o rw,allow_other -file-mode=777 -dir-mode=777  $BUCKET $MNT_DIR
echo "Mounting completed."

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app &

# Exit immediately when one of the background processes terminate.
wait -n