FROM alpine:3.15

# Install postfix
RUN apk update && \
    apk upgrade && \
    apk add postfix && \
    rm -rf /var/cache/apk/*

# Copy our init script over
COPY run.sh /
RUN chmod 700 /run.sh

CMD ["/run.sh"]
