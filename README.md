# PROGRAM-PMI
---
Application to accept PMID and PMCID to obtain citation to upload the citation to a user's RedCap instance

### Contents
1. [Requirements](#requirements)
1. [Git](#git)
1. [Docker Compose](#docker-compose)
1. [Execute](#execute)
1. [Troubleshooting](#troubleshooting)

### Requirements
1. nodejs v14.17+ (May work on older versions)
1. Docker v20.10+ (May work on older versions)

### Git
- This project is comprised of several git repositories which can be cloned from here
- **NOTE**: for ease of application building please follow the below instructions:
1. Clone repo **com.vue.program_pmi**
```sh
$ git clone git@github.com:scottmrc/com.vue.program_pmi.git
```
2. Change directory into **com.vue.program_pmi** and clone the following repos:
```sh
$ cd com.vue.program_pmi
$ git clone git@github.com:scottmrc/com.express.api.program_pmi.git
$ git clone git@github.com:scottmrc/citeproc-js-server.git
$ git clone git@github.com:scottmrc/translation-server.git
```
3. The **translation-server** and **citeproc-js-server** repos are forked repositories that simply enable CORS for deploying the application on a server
4. The **translation-server** and **citeproc-js-server** repos contain git submodules that need initialized prior to building Docker images or running the servers locally
```sh
$ cd translation-server
$ git submodule update --init
$ cd ../citeproc-js-server
$ git submodule update --init
```

### Docker Compose
- The docker-compose.yml file is used to build the Docker images and containers needed to deploy the PROGRAM_PMI application on a server
1. The docker-compose.yml is configured to provide some customizations to, namely the **pmi_vue** and **pmi_api** services.
2. **IMPORTANT - pmi_vue service**: it is important to add to the **args** section your email for the variable: **NCBI_USER_EMAIL**
3. **IMPORTANT - pmi_vue service**: it is important to change the hosts for the variables:
    1. ZOTERO_TRANSLATOR_HOST
    2. CITEPROC_HOST
    3. EXPRESS_API_HOST
4. **IMPORTANT - pmi_vue service**: it is important to note that the environment variable **PORT** must be exposed in the **ports** section if you should change it
5. **IMPORTANT - pmi_api service**: it is important to add to the environment variables section values for the following variable:
    1. REDCAP_API_URL
        - this is the url where your RedCap API server is hosted
    2. REDCAP_API_TOKEN
        - this is RedCap API generated token whereby the program_pmi will use it to write the article citation to
6. **NOTE pmi_zotero_translation service**: This service is forked from another project and as such its customization is limited and requires more source code changes than is allowed in the docker-compose.yml
7. **NOTE pmi_citeproc service**: This service is forked from another project and as such its customization is limited and requires more source code changes than is allowed in the docker-compose.yml

### Execute

#### Docker
```sh
$ docker-compose up -d
```

#### Without Docker

1. com.vue.program_pmi
- Create **.env.production** file in client/ and make any necessary changes
- **IMPORTANT**: make sure to add a valid email address to the variable **VUE_APP_NCBI_USER_EMAIL**
- .env.production:
```text
VUE_APP_ZOTERO_TRANSLATOR_HOST=http://localhost
VUE_APP_ZOTERO_TRANSLATOR_PORT=1969
VUE_APP_CITEPROC_HOST=http://localhost
VUE_APP_CITEPROC_PORT=8085
VUE_APP_EXPRESS_API_HOST=http://localhost
VUE_APP_EXPRESS_API_PORT=3001
VUE_APP_NCBI_TOOL_NAME=program_pmi
VUE_APP_NCBI_USER_EMAIL=<EMAIL_ADDRESS>
```
- Build Vue static files in client/:
```sh
$ cd client/
$ npm install
$ npm run build
```
- Move Vue static files folder dist/ to com.vue.program_pmi/server
- Start server (default port is 5151):
```sh
$ cd com.vue.program_pmi/server
$ npm run start
```

2. com.vue.program_pmi/com.express.api.program_pmi
- Create .env.dev file in com.express.api.program_pmi/server/
- .env.dev:
```text
PORT=3001
REDCAP_API_URL=<REDCAP_API_URL>
REDCAP_API_TOKEN=<REDCAP_API_TOKEN>
```
- Start server (port 3001):
```sh
$ cd server/
$ npm install
$ npm run start:dev
```

3. com.vue.program_pmi/citeproc-js-server
- Reference [here](https://github.com/zotero/citeproc-js-server) for details
```sh
$ cd citeproc-js-server
$ npm install 
$ npm start
```

4. com.vue.program_pmi/translation-server
- Reference [here](https://github.com/zotero/translation-server) for details
```sh
$ cd translation-server
$ npm install
$ npm start
```

### Troubleshooting

1. Some IT infrastructures may have inplace various firewall security measures, which may interfere with **** and **** servers, often times throwing SSL certificate warnings and issues.  If you can trust your firewall then an option to override these errors can be enabled as explained below
2. **translation-server**:
    - In **config/default.json** set:
    ```json
    "nodeIgnoreTLS": true,
    ```
3. **citeproc-js-server**:
    - In **config/default.json** set:
    ```json
    "nodeIgnoreTLS": true,
    ```