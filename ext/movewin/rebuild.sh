#!/bin/sh

clear
[ -f Makefile ] && make clean
ruby extconf.rb && make
