#!/bin/bash
log(){ echo "[$(date +%T)] $*" | tee -a /root/st-lite/install.log; }
