.PHONY: dev dev-frontend dev-backend stop teardown teardown-volumes restart status logs logs-frontend logs-backend \
       test test-frontend test-backend lint lint-frontend lint-backend check \
       integration integration-ci integration-roles integration-all test-full test-full-with-teardown seed clone sync-repos setup _require-repos install clean smoke db-migrate db-reset

REPOS_DIR := repos
CORE_DIR := $(REPOS_DIR)/zice-core
FRONTEND_DIR := $(REPOS_DIR)/zice-frontend
LOG_DIR := .logs
BACKEND_PID := $(LOG_DIR)/backend.pid
FRONTEND_PID := $(LOG_DIR)/frontend.pid
# Default branch with full application code (main is README-only in both repos)
REPO_BRANCH ?= merge-all

# Load .env if it exists
-include .env
export

# =============================================================================
# Development
# =============================================================================

dev: ## Start all services
	@mkdir -p $(LOG_DIR)
	@echo "Starting database..."
	docker compose up -d --wait
	@$(MAKE) --no-print-directory _require-repos
	@echo "Starting backend..."
	@(set -a && [ -f .env ] && . ./.env; set +a; cd $(CORE_DIR) && go run ./cmd/server) > $(LOG_DIR)/backend.log 2>&1 & echo $$! > $(BACKEND_PID)
	@echo "Starting frontend..."
	@(set -a && [ -f .env ] && . ./.env; set +a; cd $(FRONTEND_DIR) && npm run dev) > $(LOG_DIR)/frontend.log 2>&1 & echo $$! > $(FRONTEND_PID)
	@echo ""
	@echo "Services starting:"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  Backend:   http://localhost:8080"
	@echo "  Database:  localhost:54322"
	@echo ""
	@echo "Use 'make logs-frontend' or 'make logs-backend' to tail output."
	@echo "Use 'make stop' to shut down."

dev-frontend: _require-repos ## Start only the frontend
	cd $(FRONTEND_DIR) && npm run dev

dev-backend: _require-repos ## Start only the backend
	@set -a && [ -f .env ] && . ./.env; set +a; cd $(CORE_DIR) && go run ./cmd/server

stop: ## Stop all running services
	@echo "Stopping Docker services..."
	docker compose down
	@echo "Stopping background processes..."
	-@if [ -f $(BACKEND_PID) ]; then kill $$(cat $(BACKEND_PID)) 2>/dev/null; rm -f $(BACKEND_PID); fi
	-@if [ -f $(FRONTEND_PID) ]; then kill $$(cat $(FRONTEND_PID)) 2>/dev/null; rm -f $(FRONTEND_PID); fi
	-@fuser -k 8080/tcp 2>/dev/null || true
	-@fuser -k 3000/tcp 2>/dev/null || true
	@echo "All services stopped."

teardown: ## Stop all services and remove Docker images (VOLUMES=1 to wipe DB)
	@echo "Stopping background processes..."
	-@if [ -f $(BACKEND_PID) ]; then kill $$(cat $(BACKEND_PID)) 2>/dev/null; rm -f $(BACKEND_PID); fi
	-@if [ -f $(FRONTEND_PID) ]; then kill $$(cat $(FRONTEND_PID)) 2>/dev/null; rm -f $(FRONTEND_PID); fi
	@echo "Stopping Docker services and removing images$(if $(VOLUMES), and volumes,)..."
	@docker compose down --rmi all $(if $(VOLUMES),-v,)
	@echo "Teardown complete. Run 'make dev' to pull images and start again.$(if $(VOLUMES), Then run 'make db-migrate'.,)"

teardown-volumes: ## Stop all services, remove images, and wipe DB volume
	$(MAKE) teardown VOLUMES=1

restart: stop dev ## Restart all services

status: ## Show status of all services
	@echo "=== Docker Services ==="
	@docker compose ps 2>/dev/null || echo "Docker Compose not running"
	@echo ""
	@echo "=== Backend (port 8080) ==="
	@curl -s http://localhost:8080/api/v1/health 2>/dev/null && echo "" || echo "Not running"
	@echo ""
	@echo "=== Frontend (port 3000) ==="
	@curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:3000 2>/dev/null && echo "" || echo "Not running"

logs: ## Tail logs from all Docker services
	docker compose logs -f

logs-frontend: ## Tail frontend logs
	@if [ -f $(LOG_DIR)/frontend.log ]; then tail -f $(LOG_DIR)/frontend.log; else echo "No frontend log found. Start services with 'make dev' first."; fi

logs-backend: ## Tail backend logs
	@if [ -f $(LOG_DIR)/backend.log ]; then tail -f $(LOG_DIR)/backend.log; else echo "No backend log found. Start services with 'make dev' first."; fi

# =============================================================================
# Code Quality
# =============================================================================

test: test-backend test-frontend ## Run all tests

test-frontend: ## Run frontend tests
	cd $(FRONTEND_DIR) && npx vitest run

test-backend: ## Run backend tests
	cd $(CORE_DIR) && go test -race ./...

lint: lint-backend lint-frontend ## Run all linters

lint-frontend: ## Run frontend linter
	cd $(FRONTEND_DIR) && npm run lint

lint-backend: ## Run backend linter
	cd $(CORE_DIR) && golangci-lint run ./...

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
	@$(MAKE) sync-repos

sync-repos: ## Checkout application branch in service repos (default: merge-all)
	@echo "Syncing zice-core to $(REPO_BRANCH)..."
	@cd $(CORE_DIR) && (git fetch origin $(REPO_BRANCH) 2>/dev/null || true) \
		&& git checkout -B $(REPO_BRANCH) origin/$(REPO_BRANCH) \
		&& (git pull --ff-only origin $(REPO_BRANCH) 2>/dev/null || true)
	@echo "Syncing zice-frontend to $(REPO_BRANCH)..."
	@cd $(FRONTEND_DIR) && (git fetch origin $(REPO_BRANCH) 2>/dev/null || true) \
		&& git checkout -B $(REPO_BRANCH) origin/$(REPO_BRANCH) \
		&& (git pull --ff-only origin $(REPO_BRANCH) 2>/dev/null || true)

setup: clone install ## Clone repos, sync branches, and install dependencies

_require-repos:
	@test -f "$(CORE_DIR)/cmd/server/main.go" || (echo "Error: zice-core is missing application code. Run 'make sync-repos' or 'make setup'." && exit 1)
	@test -f "$(FRONTEND_DIR)/package.json" || (echo "Error: zice-frontend is missing application code. Run 'make sync-repos' or 'make setup'." && exit 1)

install: ## Install dependencies for all repos
	@$(MAKE) --no-print-directory _require-repos
	cd $(FRONTEND_DIR) && npm install
	cd $(CORE_DIR) && go mod download

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
	@echo "Migrations complete."

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
