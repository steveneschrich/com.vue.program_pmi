# PROGRAM-PMI
---
Application to accept PMID and PMCID to obtain citation to upload the citation to a user's RedCap instance

### Contents
1. [Requirements](#requirements)
1. [Git](#git)
1. [Dockerhub](#dockerhub)
1. [Docker Compose](#docker-compose)

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

### Dockerhub
- The images pulled from Dockerhub are configured to run on a local machine only
- If your needs are to deploy the application on a server you will need to edit the Vue application Docker image, which will be discussed below in the [Docker Compose section](#docker-compose)

### Docker Compose