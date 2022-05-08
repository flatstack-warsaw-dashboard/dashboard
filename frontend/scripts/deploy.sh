#!/usr/bin/env bash
set -e

dist_rel_path=$(dirname $0)/../dist
dist_path=$(realpath $dist_rel_path)
rm -rf $dist_path
mkdir -p $dist_path
docker build -t dashboard-app .
docker run -v $dist_path:/opt/mount --rm dashboard-app sh -c "cp -R /usr/src/app/dist/. /opt/mount/ && chown -R ${UID}:${GID} /opt/mount"
terraform apply "$@"
