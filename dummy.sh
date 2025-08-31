#!/bin/bash


echo "All arguments: $@"
opts=$(getopt -o a --long help,dir::,mode: -- "$@")
eval set -- "$opts"
echo "All arguments after getopt: $@"

