#!/bin/env bash
# ====================================================
#   Copyright © 2021  All rights reserved.
#
#   Author        : Fiix.one
#   Email         :
#   File Name     : build_html.sh
#   Last Modified : 2021-12-30 08:00
#   Describe      :
#
# ====================================================

tree -s -h -f -N -C \
    -L 2 \
    --dirsfirst \
    --charset=utf8 \
    -T "Shell Script" \
    -H "" \
    -I "CNAME|README.md|*.html|build_html.sh" \
    -o index.html
