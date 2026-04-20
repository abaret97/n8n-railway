# Stage 1 : récupérer su-exec depuis alpine
FROM alpine:3.22 AS su-exec-src
RUN apk add --no-cache su-exec

# Stage 2 : image finale
FROM docker.n8n.io/n8nio/n8n:latest

USER root

COPY --from=su-exec-src /sbin/su-exec /usr/local/bin/su-exec

RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'chown -R node:node /home/node/.n8n 2>/dev/null || true' \
    'exec /usr/local/bin/su-exec node:node tini -- /docker-entrypoint.sh "$@"' \
    > /usr/local/bin/fix-perms-entrypoint.sh \
  && chmod +x /usr/local/bin/fix-perms-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/fix-perms-entrypoint.sh"]
CMD []
