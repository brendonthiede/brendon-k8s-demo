#!/bin/bash

/etc/setup/controller/initialize-cluster.sh
/etc/setup/controller/install-cni.sh
/etc/setup/controller/generate-join-token.sh
