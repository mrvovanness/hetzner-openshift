# hetzner-openshift
fully automated deployment of openshift on hetzner bare metal servers

# usage

```
# install local requirements
bin/setup

# build custom centos image
bin/build

# create .env file
cp .env.example .env

# fill .env with valid data

# install cluster
bin/run
