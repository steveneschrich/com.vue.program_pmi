FROM node:17.4.0-alpine3.14

ARG CLIENT_DIR=/opt/client
ARG SERVER_DIR=/opt/server
ARG NODE_OPTIONS=--openssl-legacy-provider

ARG PRODUCTION=false
ARG ZOTERO_TRANSLATOR_HOST=http://localhost
ARG ZOTERO_TRANSLATOR_PORT=1969
ARG CITEPROC_HOST=http://localhost
ARG CITEPROC_PORT=8085
ARG EXPRESS_API_HOST=http://localhost
ARG EXPRESS_API_PORT=5152
ARG NCBI_TOOL_NAME=program_pmi
ARG NCBI_USER_EMAIL=""

RUN mkdir -p ${SERVER_DIR} ${CLIENT_DIR}

COPY client/ ${CLIENT_DIR}/
COPY server/ ${SERVER_DIR}/

RUN cd ${CLIENT_DIR} && \
    npm install && \
    VUE_APP_PRODUCTION=${PRODUCTION} \
        VUE_APP_ZOTERO_TRANSLATOR_HOST=${ZOTERO_TRANSLATOR_HOST} \
        VUE_APP_ZOTERO_TRANSLATOR_PORT=${ZOTERO_TRANSLATOR_PORT} \
        VUE_APP_CITEPROC_HOST=${CITEPROC_HOST} \
        VUE_APP_CITEPROC_PORT=${CITEPROC_PORT} \
        VUE_APP_EXPRESS_API_HOST=${EXPRESS_API_HOST} \
        VUE_APP_EXPRESS_API_PORT=${EXPRESS_API_PORT} \
        VUE_APP_NCBI_TOOL_NAME=${NCBI_TOOL_NAME} \
        VUE_APP_NCBI_USER_EMAIL=${NCBI_USER_EMAIL} \
        npm run build && \
    mv dist/ ${SERVER_DIR}/ && \
    cd ${SERVER_DIR} && \
    npm install

WORKDIR ${SERVER_DIR}

ENTRYPOINT [ "node", "bin/www" ]