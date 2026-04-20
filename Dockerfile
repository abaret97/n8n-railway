FROM n8nio/n8n:latest

USER root
RUN mkdir -p /home/node/.n8n/nodes && \
    cd /home/node/.n8n/nodes && \
    npm init -y && \
    npm install docx
USER node
