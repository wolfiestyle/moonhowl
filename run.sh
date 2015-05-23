#!/bin/sh
export LUA_PATH="./src/?.lua;./src/?/init.lua;;"
exec "./bin/moonhowl" "$@"
