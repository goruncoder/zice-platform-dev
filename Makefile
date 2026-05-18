.PHONY: dev dev-frontend dev-backend stop restart status logs logs-frontend logs-backend \
       test test-frontend test-backend lint lint-frontend lint-backend check \
       clone install clean smoke db-migrate db-reset \
       update checkout-pr

REPOS_DIR := repos
CORE_DIR := $(REPOS_DIR)/zice-core
FRONTEND_DIR := $(REPOS_DIR)/zice-frontend
LOG_DIR := .logs
BACKEND_PID := $(LOG_DIR)/backend.pid
FRONTEND_PID := $(LOG_DIR)/frontend.pid

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
	@echo "Starting backend..."
	@cd $(CORE_DIR) && make dev > ../../$(LOG_DIR)/backend.log 2>&1 & echo $$! > ../../$(BACKEND_PID)
	@echo "Starting frontend..."
	@cd $(FRONTEND_DIR) && npm run dev > ../../$(LOG_DIR)/frontend.log 2>&1 & echo $$! > ../../$(FRONTEND_PID)
	@echo ""
	@echo "Services starting:"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  Backend:   http://localhost:8080"
	@echo "  Database:  localhost:54322"
	@echo ""
	@echo "Use 'make logs-frontend' or 'make logs-backend' to tail output."
	@echo "Use 'make stop' to shut down."

dev-frontend: ## Start only the frontend
	cd $(FRONTEND_DIR) && make dev

dev-backend: ## Start only the backend
	cd $(CORE_DIR) && make dev

stop: ## Stop all running services
	@echo "Stopping Docker services..."
	docker compose down
	@echo "Stopping background processes..."
	-@if [ -f $(BACKEND_PID) ]; then kill $$(cat $(BACKEND_PID)) 2>/dev/null; rm -f $(BACKEND_PID); fi
	-@if [ -f $(FRONTEND_PID) ]; then kill $$(cat $(FRONTEND_PID)) 2>/dev/null; rm -f $(FRONTEND_PID); fi
	@echo "All services stopped."

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

update: clone ## Pull latest main for all service repos
	@echo "Updating zice-core..."
	@cd $(CORE_DIR) && git checkout main && git pull origin main
	@echo "Updating zice-frontend..."
	@cd $(FRONTEND_DIR) && git checkout main && git pull origin main
	@echo "All repos updated to latest main."

checkout-pr: ## Checkout a PR branch for local testing (usage: make checkout-pr REPO=zice-core PR=15)
	@if [ -z "$(REPO)" ] || [ -z "$(PR)" ]; then \
		echo "Usage: make checkout-pr REPO=<zice-core|zice-frontend> PR=<number>"; \
		echo ""; \
		echo "Examples:"; \
		echo "  make checkout-pr REPO=zice-core PR=15"; \
		echo "  make checkout-pr REPO=zice-frontend PR=8"; \
		exit 1; \
	fi
	@echo "Fetching PR #$(PR) for $(REPO)..."
	@cd $(REPOS_DIR)/$(REPO) && git fetch origin pull/$(PR)/head:pr-$(PR) && git checkout pr-$(PR)
	@echo "Checked out PR #$(PR) on $(REPO). Run 'make install' to update dependencies."

install: ## Install dependencies for all repos
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
		PGPASSWORD=postgres psql -h localhost -p 54322 -U postgres -d postgres -f "$$f"; \
	done
	@echo "Migrations complete."

db-reset: ## Reset database and re-run all migrations
	@echo "Resetting database..."
	PGPASSWORD=postgres psql -h localhost -p 54322 -U postgres -d postgres -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
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
# Help
# =============================================================================

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
