# Stage 1 : récupérer su-exec depuis alpine
FROM alpine:3.22 AS su-exec-src
RUN apk add --no-cache su-exec

# Stage 2 : image finale
FROM docker.n8n.io/n8nio/n8n:latest

USER root

COPY --from=su-exec-src /sbin/su-exec /usr/local/bin/su-exec

# Install docx at the NODE_PATH configured in n8n-task-runners.json
# so the JS task runner can resolve require('docx') in Code nodes.
RUN mkdir -p /opt/n8n-external-modules \
  && cd /opt/n8n-external-modules \
  && npm init -y >/dev/null \
  && npm install --omit=dev --no-audit --no-fund docx \
  && chown -R node:node /opt/n8n-external-modules

RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'chown -R node:node /home/node/.n8n 2>/dev/null || true' \
    'exec /usr/local/bin/su-exec node:node tini -- /docker-entrypoint.sh "$@"' \
    > /usr/local/bin/fix-perms-entrypoint.sh \
  && chmod +x /usr/local/bin/fix-perms-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fix-perms-entrypoint.sh"]
CMD []
