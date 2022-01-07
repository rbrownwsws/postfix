#!/bin/sh

# Stop on errors
set -e

# Print all commands for debugging
[ -n "${DEBUG}" ] && set -x

# Make postfix log to stdout
postconf -e "maillog_file=/dev/stdout"

# Take environment variables and pass them to `postconf`

# main.cf parameters
# e.g. POSTCONF_MAIN_PARAM_MYHOSTNAME=example.com -> `postconf -e "myhostname=example.com"`
POSTCONF_MAIN_PARAM_PREFIX="POSTCONF_MAIN_PARAM_"
POSTCONF_MAIN_PARAM_REGEX="^${POSTCONF_MAIN_PARAM_PREFIX}\([0-9A-Za-z_]\+\)=\(.*\)$"
echo "### Main.cf Parameters ###"
env | grep "^${POSTCONF_MAIN_PARAM_PREFIX}" | while read -r ENV_VAR;
do
    PARAM=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MAIN_PARAM_REGEX}"'/\1/' | tr '[:upper:]' '[:lower:]')
    VALUE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MAIN_PARAM_REGEX}"'/\2/')

    RECORD="${PARAM}=${VALUE}"
    echo "${RECORD}"
    postconf -e "${RECORD}"
done
echo ""

# master.cf service entries
# e.g. POSTCONF_MASTER_ENTRY_SMTP_INET="smtp inet n - n - - smtpd" -> `postconf -M -e "smtp/inet=smtp inet n - n - - smtpd"`
POSTCONF_MASTER_ENTRY_PREFIX="POSTCONF_MASTER_ENTRY_"
POSTCONF_MASTER_ENTRY_REGEX="^${POSTCONF_MASTER_ENTRY_PREFIX}\([0-9A-Za-z]\+\)_\([0-9A-Za-z]\+\)=\(.*\)$"
echo "### Master.cf Entries ###"
env | grep "^${POSTCONF_MASTER_ENTRY_PREFIX}" | while read -r ENV_VAR;
do
    SERVICE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MASTER_ENTRY_REGEX}"'/\1/' | tr '[:upper:]' '[:lower:]')
    TYPE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MASTER_ENTRY_REGEX}"'/\2/'  | tr '[:upper:]' '[:lower:]')
    VALUE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MASTER_ENTRY_REGEX}"'/\3/')

    RECORD="${SERVICE}/${TYPE}=${VALUE}"
    echo "${RECORD}"
    postconf -M -e "${RECORD}"
done
echo ""

# master.cf service parameters
# e.g. POSTCONF_MASTER_PARAM_SMTP_INET_SMTPD_TLS_SECURITY_LEVEL=may -> `postconf -P -e "smtp/inet/smtpd_tls_security_level=may"`
POSTCONF_MASTER_PARAM_PREFIX="POSTCONF_MASTER_PARAM_"
POSTCONF_MASTER_PARAM_REGEX="^${POSTCONF_MASTER_PARAM_PREFIX}\([0-9A-Za-z]\+\)_\([0-9A-Za-z]\+\)_\([0-9A-Za-z_]\+\)=\(.*\)$"
echo "### Master.cf Parameters ###"
env | grep "^${POSTCONF_MASTER_PARAM_PREFIX}" | while read -r ENV_VAR;
do
    SERVICE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MASTER_PARAM_REGEX}"'/\1/' | tr '[:upper:]' '[:lower:]')
    TYPE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MASTER_PARAM_REGEX}"'/\2/'  | tr '[:upper:]' '[:lower:]')
    PARAM=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MASTER_PARAM_REGEX}"'/\3/'  | tr '[:upper:]' '[:lower:]')
    VALUE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTCONF_MASTER_PARAM_REGEX}"'/\4/')

    RECORD="${SERVICE}/${TYPE}/${PARAM}=${VALUE}"
    echo "${RECORD}"
    postconf -P -e "${RECORD}"
done
echo ""

# Take environment variables and pass them to `postmap`
# e.g. POSTMAP_LMDB_VIRTUAL="@example.com john@gmail.com" -> `echo "@example.com john@gmail.com" | postmap -i lmdb:/etc/postfix/virtual`
POSTMAP_PREFIX="POSTMAP_"
POSTMAP_REGEX="^${POSTMAP_PREFIX}\([0-9A-Za-z]\+\)_\([0-9A-Za-z_]\+\)=\(.*\)$"
echo "### Postmap Files ###"
env | grep "^${POSTMAP_PREFIX}" | while read -r ENV_VAR;
do
    FILE_TYPE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTMAP_REGEX}"'/\1/' | tr '[:upper:]' '[:lower:]')
    FILE_NAME=$(echo "$ENV_VAR" | sed -e 's/'"${POSTMAP_REGEX}"'/\2/' | tr '[:upper:]' '[:lower:]')
    FILE_VALUE=$(echo "$ENV_VAR" | sed -e 's/'"${POSTMAP_REGEX}"'/\3/')

    TABLE="${FILE_TYPE}:/etc/postfix/${FILE_NAME}"
    echo "${TABLE}"
    echo "${FILE_VALUE}" | postmap -i "${TABLE}"
done
echo ""

echo "Starting postfix..."
echo ""

# Start postfix in the foreground
exec /usr/sbin/postfix start-fg
