#!/bin/sh
DIR=$(readlink -f $(dirname $0))
export LUA_PATH="$DIR/src/?.lua;$DIR/src/?/init.lua;;"
exec "$DIR/bin/moonhowl" "$@"
