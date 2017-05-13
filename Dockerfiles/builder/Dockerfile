FROM buildpack-deps:jessie
RUN apt-get update && apt-get install -y --no-install-recommends \
    python python-dev python-pip && \
    rm -rf /var/lib/apt/lists/* && \
    pip install awscli && \
    mkdir /root/.aws && \
    { \
        echo '[default]'; \
        echo 'aws_access_key_id = bob'; \
        echo 'aws_secret_access_key = bob'; \
    } > /root/.aws/credentials && \
    chmod 600 /root/.aws/credentials
VOLUME ["/usr/local/db-script"]
WORKDIR /usr/local/db-script
ENTRYPOINT ["/bin/bash", "-c"]
