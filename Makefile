.PHONY: dev dev-all dev-frontend dev-backend dev-agent _start-agent stop teardown teardown-volumes restart status logs logs-frontend logs-backend logs-agent \
       test test-frontend test-backend test-agent lint lint-frontend lint-backend lint-agent check \
       integration integration-ci integration-roles integration-all test-full test-full-with-teardown seed clone sync-repos sync-agent-docs setup _require-repos install clean smoke db-migrate db-migrate-agent db-reset \
       update checkout-pr

REPOS_DIR := repos
CORE_DIR := $(REPOS_DIR)/zice-core
FRONTEND_DIR := $(REPOS_DIR)/zice-frontend
AGENT_DIR := $(REPOS_DIR)/zice-agent
LOG_DIR := .logs
BACKEND_PID := $(LOG_DIR)/backend.pid
FRONTEND_PID := $(LOG_DIR)/frontend.pid
AGENT_PID := $(LOG_DIR)/agent.pid
# Per-repo branches (override on the make command line, e.g. make sync-repos FRONTEND_BRANCH=main)
CORE_BRANCH ?= main
FRONTEND_BRANCH ?= main
AGENT_BRANCH ?= main
# Deprecated: use CORE_BRANCH / FRONTEND_BRANCH instead
REPO_BRANCH ?= $(FRONTEND_BRANCH)

# Load .env if it exists
-include .env
export

# =============================================================================
# Development
# =============================================================================

dev: ## Start DB, backend, and frontend
	@mkdir -p $(LOG_DIR)
	@echo "Starting database..."
	docker compose up -d --wait
	@$(MAKE) --no-print-directory _require-repos
	@echo "Starting backend..."
	@(cd $(CORE_DIR) && exec go run ./cmd/server) > $(LOG_DIR)/backend.log 2>&1 & echo $$! > $(BACKEND_PID)
	@echo "Starting frontend..."
	@(cd $(FRONTEND_DIR) && exec npm run dev) > $(LOG_DIR)/frontend.log 2>&1 & echo $$! > $(FRONTEND_PID)
	@echo ""
	@echo "Services starting:"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  Backend:   http://localhost:8080"
	@echo "  Database:  localhost:54322"
	@echo ""
	@echo "Use 'make dev-all' to also start the AI agent."
	@echo "Use 'make logs-frontend' or 'make logs-backend' to tail output."
	@echo "Use 'make stop' to shut down."

dev-all: ## Start full stack (DB + backend + frontend + agent)
	@$(MAKE) --no-print-directory dev
	@$(MAKE) --no-print-directory _start-agent
	@echo "  Agent:     http://localhost:8081"
	@echo "Use 'make logs-agent' to tail agent output."

_start-agent: _require-agent
	@echo "Starting agent..."
	@mkdir -p $(LOG_DIR)
	@(set -a && [ -f .env ] && . ./.env; set +a; cd $(AGENT_DIR) && go run ./cmd/server) > $(LOG_DIR)/agent.log 2>&1 & echo $$! > $(AGENT_PID)

dev-frontend: _require-repos ## Start only the frontend
	cd $(FRONTEND_DIR) && npm run dev

dev-backend: _require-repos ## Start only the backend
	@set -a && [ -f .env ] && . ./.env; set +a; cd $(CORE_DIR) && go run ./cmd/server

dev-agent: _require-agent ## Start only the AI agent service (port 8081)
	@set -a && [ -f .env ] && . ./.env; set +a; cd $(AGENT_DIR) && go run ./cmd/server

stop: ## Stop all running services
	@echo "Stopping Docker services..."
	docker compose down
	@echo "Stopping background processes..."
	-@if [ -f $(BACKEND_PID) ]; then kill $$(cat $(BACKEND_PID)) 2>/dev/null; rm -f $(BACKEND_PID); fi
	-@if [ -f $(FRONTEND_PID) ]; then kill $$(cat $(FRONTEND_PID)) 2>/dev/null; rm -f $(FRONTEND_PID); fi
	-@if [ -f $(AGENT_PID) ]; then kill $$(cat $(AGENT_PID)) 2>/dev/null; rm -f $(AGENT_PID); fi
	-@pid=$$(lsof -ti:8080 2>/dev/null); [ -n "$$pid" ] && kill $$pid 2>/dev/null || true
	-@pid=$$(lsof -ti:8081 2>/dev/null); [ -n "$$pid" ] && kill $$pid 2>/dev/null || true
	-@pid=$$(lsof -ti:3000 2>/dev/null); [ -n "$$pid" ] && kill $$pid 2>/dev/null || true
	@echo "All services stopped."

teardown: ## Stop all services and remove Docker images (VOLUMES=1 to wipe DB)
	@echo "Stopping background processes..."
	-@if [ -f $(BACKEND_PID) ]; then kill $$(cat $(BACKEND_PID)) 2>/dev/null; rm -f $(BACKEND_PID); fi
	-@if [ -f $(FRONTEND_PID) ]; then kill $$(cat $(FRONTEND_PID)) 2>/dev/null; rm -f $(FRONTEND_PID); fi
	-@if [ -f $(AGENT_PID) ]; then kill $$(cat $(AGENT_PID)) 2>/dev/null; rm -f $(AGENT_PID); fi
	@echo "Stopping Docker services and removing images$(if $(VOLUMES), and volumes,)..."
	@docker compose down --rmi all $(if $(VOLUMES),-v,)
	@echo "Teardown complete. Run 'make dev' to pull images and start again.$(if $(VOLUMES), Then run 'make db-migrate'.,)"

teardown-volumes: ## Stop all services, remove images, and wipe DB volume
	$(MAKE) teardown VOLUMES=1

restart: stop dev-all ## Restart full stack

status: ## Show status of all services
	@echo "=== Docker Services ==="
	@docker compose ps 2>/dev/null || echo "Docker Compose not running"
	@echo ""
	@echo "=== Backend (port 8080) ==="
	@curl -s http://localhost:8080/api/v1/health 2>/dev/null && echo "" || echo "Not running"
	@echo ""
	@echo "=== Frontend (port 3000) ==="
	@curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:3000 2>/dev/null && echo "" || echo "Not running"
	@echo ""
	@echo "=== Agent (port 8081) ==="
	@curl -s http://localhost:8081/api/v1/health 2>/dev/null && echo "" || echo "Not running"

logs: ## Tail logs from all Docker services
	docker compose logs -f

logs-frontend: ## Tail frontend logs
	@if [ -f $(LOG_DIR)/frontend.log ]; then tail -f $(LOG_DIR)/frontend.log; else echo "No frontend log found. Start services with 'make dev' first."; fi

logs-backend: ## Tail backend logs
	@if [ -f $(LOG_DIR)/backend.log ]; then tail -f $(LOG_DIR)/backend.log; else echo "No backend log found. Start services with 'make dev' first."; fi

logs-agent: ## Tail agent logs
	@if [ -f $(LOG_DIR)/agent.log ]; then tail -f $(LOG_DIR)/agent.log; else echo "No agent log found. Start with 'make dev-agent' first."; fi

# =============================================================================
# Code Quality
# =============================================================================

test: test-backend test-frontend test-agent ## Run all tests

test-frontend: ## Run frontend tests
	cd $(FRONTEND_DIR) && npx vitest run

test-backend: ## Run backend tests
	cd $(CORE_DIR) && go test -race ./...

test-agent: _require-agent ## Run agent tests
	cd $(AGENT_DIR) && go test -race ./...

lint: lint-backend lint-frontend lint-agent ## Run all linters

lint-frontend: ## Run frontend linter
	cd $(FRONTEND_DIR) && npm run lint

lint-backend: ## Run backend linter
	cd $(CORE_DIR) && golangci-lint run ./...

lint-agent: _require-agent ## Run agent linter
	cd $(AGENT_DIR) && golangci-lint run ./...

check: lint test ## Lint + test (prepare for merge)
	@echo "All checks passed."

# =============================================================================
# Setup
# =============================================================================

clone: ## Clone all service repos
	@mkdir -p $(REPOS_DIR)
	@if [ ! -d "$(CORE_DIR)/.git" ]; then \
		echo "Cloning zice-core..."; \
		git clone https://github.com/goruncoder/zice-core.git $(CORE_DIR); \
	else \
		echo "zice-core already cloned"; \
	fi
	@if [ ! -d "$(FRONTEND_DIR)/.git" ]; then \
		echo "Cloning zice-frontend..."; \
		git clone https://github.com/goruncoder/zice-frontend.git $(FRONTEND_DIR); \
	else \
		echo "zice-frontend already cloned"; \
	fi
	@if [ ! -d "$(AGENT_DIR)/.git" ]; then \
		echo "Cloning zice-agent..."; \
		git clone https://github.com/goruncoder/zice-agent.git $(AGENT_DIR); \
	else \
		echo "zice-agent already cloned"; \
	fi
	@$(MAKE) sync-repos
	@$(MAKE) --no-print-directory sync-agent-docs

sync-agent-docs: ## Copy AGENTS.md templates into cloned service repos
	@chmod +x scripts/sync-agent-docs.sh
	@./scripts/sync-agent-docs.sh

sync-repos: ## Checkout configured branches in service repos
	@echo "Syncing zice-core to $(CORE_BRANCH)..."
	@cd $(CORE_DIR) && git fetch origin $(CORE_BRANCH) \
		&& git checkout -B $(CORE_BRANCH) origin/$(CORE_BRANCH) \
		&& git pull --ff-only origin $(CORE_BRANCH)
	@echo "Syncing zice-frontend to $(FRONTEND_BRANCH)..."
	@cd $(FRONTEND_DIR) && (git fetch origin $(FRONTEND_BRANCH) 2>/dev/null || true) \
		&& git checkout -B $(FRONTEND_BRANCH) origin/$(FRONTEND_BRANCH) \
		&& (git pull --ff-only origin $(FRONTEND_BRANCH) 2>/dev/null || true)
	@if [ -d "$(AGENT_DIR)/.git" ]; then \
		echo "Syncing zice-agent to $(AGENT_BRANCH)..."; \
		cd $(AGENT_DIR) && git fetch origin $(AGENT_BRANCH) \
			&& git checkout -B $(AGENT_BRANCH) origin/$(AGENT_BRANCH) \
			&& git pull --ff-only origin $(AGENT_BRANCH); \
	fi

setup: clone install ## Clone repos, sync branches, and install dependencies

_require-repos:
	@test -f "$(CORE_DIR)/cmd/server/main.go" || (echo "Error: zice-core is missing application code. Run 'make sync-repos' or 'make setup'." && exit 1)
	@test -f "$(FRONTEND_DIR)/package.json" || (echo "Error: zice-frontend is missing application code. Run 'make sync-repos' or 'make setup'." && exit 1)

update: clone ## Pull latest main for all service repos
	@echo "Updating zice-core..."
	@cd $(CORE_DIR) && git checkout main && git pull origin main
	@echo "Updating zice-frontend..."
	@cd $(FRONTEND_DIR) && git checkout main && git pull origin main
	@if [ -d "$(AGENT_DIR)/.git" ]; then \
		echo "Updating zice-agent..."; \
		cd $(AGENT_DIR) && git checkout main && git pull origin main; \
	fi
	@echo "All repos updated to latest main."

checkout-pr: ## Checkout a PR branch for local testing (usage: make checkout-pr REPO=zice-core PR=15)
	@if [ -z "$(REPO)" ] || [ -z "$(PR)" ]; then \
		echo "Usage: make checkout-pr REPO=<zice-core|zice-frontend|zice-agent> PR=<number>"; \
		echo ""; \
		echo "Examples:"; \
		echo "  make checkout-pr REPO=zice-core PR=15"; \
		echo "  make checkout-pr REPO=zice-frontend PR=8"; \
		echo "  make checkout-pr REPO=zice-agent PR=7"; \
		exit 1; \
	fi
	@case "$(REPO)" in zice-core|zice-frontend|zice-agent) ;; \
		*) echo "Error: REPO must be zice-core, zice-frontend, or zice-agent"; exit 1;; \
	esac
	@echo "Fetching PR #$(PR) for $(REPO)..."
	@cd $(REPOS_DIR)/$(REPO) && git fetch origin pull/$(PR)/head && git checkout -B pr-$(PR) FETCH_HEAD
	@echo "Checked out PR #$(PR) on $(REPO). Run 'make install' to update dependencies."

install: ## Install dependencies for all repos
	@$(MAKE) --no-print-directory _require-repos
	cd $(FRONTEND_DIR) && npm install
	cd $(CORE_DIR) && go mod download
	@if [ -f "$(AGENT_DIR)/go.mod" ]; then cd $(AGENT_DIR) && go mod download; fi

_require-agent:
	@test -f "$(AGENT_DIR)/cmd/server/main.go" || (echo "Error: zice-agent is missing. Run 'make clone'." && exit 1)

clean: ## Remove build artifacts and dependencies
	cd $(FRONTEND_DIR) && rm -rf node_modules .next
	cd $(CORE_DIR) && go clean -cache

# =============================================================================
# Database
# =============================================================================

db-migrate: ## Run pending database migrations
	@echo "Applying migrations from zice-core..."
	@for f in $$(ls $(CORE_DIR)/supabase/migrations/*.sql 2>/dev/null | sort); do \
		echo "Applying: $$f"; \
		if command -v psql >/dev/null 2>&1; then \
			PGPASSWORD=postgres psql -h localhost -p 54322 -U postgres -d postgres -f "$$f"; \
		else \
			docker compose exec -T db psql -U postgres -d postgres -f - < "$$f"; \
		fi; \
	done
	@echo "Core migrations complete."
	@$(MAKE) --no-print-directory db-migrate-agent

db-migrate-agent: ## Apply zice-agent SQL migrations
	@if [ ! -d "$(AGENT_DIR)/sql/migrations" ]; then \
		echo "Skipping agent migrations (zice-agent not cloned)"; \
	else \
		echo "Applying migrations from zice-agent..."; \
		for f in $$(ls $(AGENT_DIR)/sql/migrations/*.sql 2>/dev/null | sort); do \
			echo "Applying: $$f"; \
			if command -v psql >/dev/null 2>&1; then \
				PGPASSWORD=postgres psql -h localhost -p 54322 -U postgres -d postgres -f "$$f"; \
			else \
				docker compose exec -T db psql -U postgres -d postgres -f - < "$$f"; \
			fi; \
		done; \
		echo "Agent migrations complete."; \
	fi

db-reset: ## Reset database and re-run all migrations
	@echo "Resetting database..."
	@if command -v psql >/dev/null 2>&1; then \
		PGPASSWORD=postgres psql -h localhost -p 54322 -U postgres -d postgres -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"; \
	else \
		docker compose exec -T db psql -U postgres -d postgres -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"; \
	fi
	$(MAKE) db-migrate

# =============================================================================
# Smoke Tests
# =============================================================================

DEPLOY_URL_BACKEND ?= http://localhost:8080
DEPLOY_URL_FRONTEND ?= http://localhost:3000

smoke: ## Run smoke tests against local or deployed services
	@echo "=== Backend Smoke Tests ==="
	$(CORE_DIR)/scripts/smoke-test.sh $(DEPLOY_URL_BACKEND)
	@echo ""
	@echo "=== Frontend Smoke Tests ==="
	$(FRONTEND_DIR)/scripts/smoke-test.sh $(DEPLOY_URL_FRONTEND)

# =============================================================================
# Integration Tests (platform end-to-end)
# =============================================================================

integration: _require-repos ## Run stack integration tests (requires: make dev + make seed)
	@chmod +x scripts/integration-test.sh
	@./scripts/integration-test.sh

integration-roles: _require-repos ## Login as each test user and verify role API access
	@chmod +x scripts/integration-roles-test.sh
	@./scripts/integration-roles-test.sh

integration-all: integration integration-roles ## Run stack + role integration tests

integration-ci: _require-repos ## Bootstrap stack, seed, run all integration tests, then stop
	@chmod +x scripts/integration-ci.sh scripts/integration-test.sh scripts/integration-roles-test.sh scripts/seed.sh
	@./scripts/integration-ci.sh

test-full: integration-ci ## Bootstrap stack, seed, run all integration tests

test-full-with-teardown: _require-repos ## Bootstrap stack, run all integration tests, then remove Docker images
	@status=0; \
	$(MAKE) --no-print-directory integration-ci || status=$$?; \
	$(MAKE) --no-print-directory teardown || true; \
	exit $$status

seed: _require-repos ## Seed DB with test org, team, roster, and users
	@chmod +x scripts/seed.sh
	@./scripts/seed.sh

# =============================================================================
# Help
# =============================================================================

help: ## Show this help
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
