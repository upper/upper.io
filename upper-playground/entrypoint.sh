#!/bin/bash

/bin/app \
  -db /var/data/playground.db \
  -allow-share \
  -s "http://$UNSAFEBOX_PORT_8080_TCP_ADDR:$UNSAFEBOX_PORT_8080_TCP_PORT/compile?output=json"
