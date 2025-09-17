COMPOSE_NPM := infra/nginx-proxy-manager/compose.yaml
COMPOSE_N8N := infra/n8n/compose.yaml
COMPOSE_ERP := infra/erpnext/compose.yaml

.PHONY: status \
        npm-up npm-down npm-logs \
        n8n-up n8n-down n8n-logs \
        erp-up erp-down erp-logs

status:
	@echo "== Docker containers =="
	@docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | egrep '(^npm$$|^n8n$$|erpnext-)'

# NPM
npm-up:
	docker compose -f $(COMPOSE_NPM) up -d
npm-down:
	docker compose -f $(COMPOSE_NPM) down
npm-logs:
	docker compose -f $(COMPOSE_NPM) logs -f --tail=200

# n8n
n8n-up:
	docker compose -f $(COMPOSE_N8N) up -d
n8n-down:
	docker compose -f $(COMPOSE_N8N) down
n8n-logs:
	docker compose -f $(COMPOSE_N8N) logs -f --tail=200

# ERPNext
erp-up:
	docker compose -f $(COMPOSE_ERP) up -d
erp-down:
	docker compose -f $(COMPOSE_ERP) down
erp-logs:
	docker compose -f $(COMPOSE_ERP) logs -f --tail=200
