#!/bin/bash -
#===============================================================================
#
#          FILE: genGtags.sh
#
#         USAGE: ./genGtags.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 24/05/26 11:55:42 AM IST
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error


#Gtags for cscope
gtags --gtagslabel=universal-ctags

#For tags
ctags -L gtags.files -f ./tags \
    --tag-relative=no \
    --sort=yes \
    --extra=+q \
    --fields=+iaS \
    .
