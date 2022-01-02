#!/bin/sh

# Stop on errors
set -e

# Print commands for debugging
[ "${DEBUG}" != "" ] && set -x

# Make postfix log to stdout
postconf -e "maillog_file=/dev/stdout"

# Take environment variables and pass them to `postconf`
# e.g. POSTCONF_MAIN_MYHOSTNAME=example.com -> `postconf -e "myhostname=example.com"`

# main.cf
POSTCONF_PREFIX="POSTCONF_MAIN_"
POSTCONF_REGEX="^${POSTCONF_PREFIX}\([A-Za-z_]\+\)=\(.*\)$"
env | grep "^${POSTCONF_PREFIX}" | while read -r ENV_VAR;
do
    VAR_NAME=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_REGEX}"'/\1/' | tr '[:upper:]' '[:lower:]')
    VAR_VALUE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_REGEX}"'/\2/')
    postconf -e "${VAR_NAME}=${VAR_VALUE}"
done

# Take environment variables and pass them to `postmap`
# e.g. POSTMAP_LMDB_VIRTUAL="@example.com john@gmail.com"-> `echo "@example.com john@gmail.com" | postmap -i lmdb:/etc/postfix/virtual`
POSTMAP_PREFIX="POSTMAP_"
POSTMAP_REGEX="^$POSTMAP_PREFIX}\([A-Za-z]\+\)_\(\([A-Za-z_]\+\)=\(.*\)$"
env | grep "^${POSTMAP_PREFIX}" | while read -r ENV_VAR;
do
    FILE_TYPE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTMAP_REGEX}"'/\1/' | tr '[:upper:]' '[:lower:]')
    FILE_NAME=$(echo "$ENV_VAR" | sed -e 's/'"${POSTMAP_REGEX}"'/\2/' | tr '[:upper:]' '[:lower:]')
    FILE_VALUE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTMAP_REGEX}"'/\3/')
    echo "${FILE_VALUE}" | postmap -i "${FILE_TYPE}:/etc/postfix/${FILE_NAME}"
done

# Start postfix in the foreground
exec /usr/sbin/postfix start-fg
