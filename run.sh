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
VAR_PREFIX="POSTCONF_MAIN_"
VAR_REGEX="^${VAR_PREFIX}\([A-Za-z_]\+\)=\(.*\)$"
env | grep "^${VAR_PREFIX}" | while read -r ENV_VAR;
do
    VAR_NAME=$(echo "$ENV_VAR" | sed -e 's/'"${VAR_REGEX}"'/\1/' | tr '[:upper:]' '[:lower:]')
    VAR_VALUE=$(echo "$ENV_VAR" | sed -e 's/'"${VAR_REGEX}"'/\2/')
    postconf -e "${VAR_NAME}=${VAR_VALUE}"
done

# Take environment variables and pass them to `postmap`
# FIXME: Hardcoded just to test things.
echo "${POSTMAP}" | postmap -i lmdb:/etc/postfix/virtual

# Start postfix in the foreground
exec /usr/sbin/postfix start-fg
