FROM docker.n8n.io/n8nio/n8n:latest

USER root

RUN mkdir -p /opt/n8n-external-modules && \
    cd /opt/n8n-external-modules && \
    echo '{"name":"n8n-external-modules","version":"1.0.0","private":true}' > package.json && \
    npm install --omit=dev --no-audit --no-fund docx && \
    chmod -R a+r /opt/n8n-external-modules

COPY n8n-task-runners.json /etc/n8n-task-runners.json

USER node

ENV NODE_FUNCTION_ALLOW_EXTERNAL=docx
ENV NODE_PATH=/opt/n8n-external-modules/node_modules
