.PHONY: dev dev-frontend dev-backend stop restart status logs logs-frontend logs-backend \
       test test-frontend test-backend lint lint-frontend lint-backend check \
       clone install clean smoke db-migrate db-reset

REPOS_DIR := repos
CORE_DIR := $(REPOS_DIR)/zice-core
FRONTEND_DIR := $(REPOS_DIR)/zice-frontend

# Load .env if it exists
-include .env
export

# =============================================================================
# Development
# =============================================================================

dev: ## Start all services
	@echo "Starting database..."
	docker compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 3
	@echo "Starting backend..."
	cd $(CORE_DIR) && make dev &
	@echo "Starting frontend..."
	cd $(FRONTEND_DIR) && make dev &
	@echo ""
	@echo "Services starting:"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  Backend:   http://localhost:8080"
	@echo "  Database:  localhost:54322"
	@echo ""
	@echo "Use 'make logs' to tail output, 'make stop' to shut down."

dev-frontend: ## Start only the frontend
	cd $(FRONTEND_DIR) && make dev

dev-backend: ## Start only the backend
	cd $(CORE_DIR) && make dev

stop: ## Stop all running services
	@echo "Stopping Docker services..."
	docker compose down
	@echo "Stopping background processes..."
	-@pkill -f "zice-core" 2>/dev/null || true
	-@pkill -f "next dev" 2>/dev/null || true
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
	cd $(FRONTEND_DIR) && npm run dev 2>&1

logs-backend: ## Tail backend logs
	cd $(CORE_DIR) && make dev 2>&1

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
	@for f in $(CORE_DIR)/supabase/migrations/*.sql; do \
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
