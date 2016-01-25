#!/bin/bash
#
# Stolen from https://github.com/shepmaster/nginx-template-image

set -eu

render-templates.sh /etc/nginx/cond.d.t /etc/nginx/conf.d
exec $@
