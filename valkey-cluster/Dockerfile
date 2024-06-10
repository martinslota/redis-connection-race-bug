FROM valkey/valkey:7

RUN apt-get update \
    && apt-get install --no-install-recommends -y supervisor gettext-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY valkey-cluster.tmpl /valkey-cluster.tmpl
COPY generate-supervisor-conf.sh /generate-supervisor-conf.sh

RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["valkey-cluster"]
