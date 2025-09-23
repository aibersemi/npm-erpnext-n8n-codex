ARG FRAPPE_TAG
FROM frappe/erpnext:${FRAPPE_TAG}

USER root

# Install Node.js 18 LTS, yarn, and tini for proper init
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg tini; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs; \
    npm install -g yarn; \
    apt-get clean; rm -rf /var/lib/apt/lists/*

# Prepare entrypoint wrapper to build assets on first run
COPY docker-entrypoint.sh /usr/local/bin/erpnext-entrypoint.sh
RUN chmod +x /usr/local/bin/erpnext-entrypoint.sh

ENV USE_TINI=1

ENTRYPOINT ["/usr/local/bin/erpnext-entrypoint.sh"]

