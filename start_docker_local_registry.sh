#!/bin/bash

cat << EOF

Starting local docker registry:

Note:
  It is assumes the host IP is static otherwise the associated cetificate won't work!

  Removing the container will also deleting all the previously pushed images.

  To list local repo: localregistry [-list | -listall]

EOF

cd $HOME/certs/docker-registry
docker run -d   --restart=always   --name registry   -v "$(pwd)"/certs:/certs   -e REGISTRY_HTTP_ADDR=0.0.0.0:443   -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt   -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key   -p 443:443   registry:2
