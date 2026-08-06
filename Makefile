.PHONY: help build start clean logs stop restart update-version dev dev-down

DOCKER ?= $(shell if docker info >/dev/null 2>&1; then echo docker; else echo sudo docker; fi)

# Default target
help:
	@echo "🚀 Palmr - Available Commands:"
	@echo ""
	@echo "  make build         - Build Docker image with multi-platform support"
	@echo "  make update-version - Update version in all package.json files"
	@echo "  make start         - Start the application using docker-compose"
	@echo "  make dev           - Start the monorepo in development mode with Docker Compose"
	@echo "  make dev-down      - Stop the development containers"
	@echo "  make stop          - Stop all running containers"
	@echo "  make logs          - Show application logs"
	@echo "  make clean         - Clean up containers and images"
	@echo "  make shell         - Access the application container shell"
	@echo ""
	@echo "📁 Scripts location: ./infra/"

# Build Docker image using the build script
build:
	@echo "🏗️  Building Palmr Docker image..."
	@echo "📝 This will update version numbers in all package.json files before building"
	@echo ""
	@chmod +x ./infra/update-versions.sh
	@chmod +x ./infra/build-docker.sh
	@echo "🔄 Starting build process..."
	@./infra/build-docker.sh

# Update version in all package.json files
update-version:
	@echo "🔄 Updating version numbers..."
	@echo "🏷️  Please enter the new version (e.g., v3.0.0, 3.0-beta):"
	@read -p "Version: " VERSION; \
	if [ -z "$$VERSION" ]; then \
		echo "❌ Error: Version cannot be empty"; \
		exit 1; \
	fi; \
	chmod +x ./infra/update-versions.sh; \
	./infra/update-versions.sh "$$VERSION"

# Start the application
start:
	@echo "🚀 Starting Palmr application..."
	@$(DOCKER) compose up -d

# Start the monorepo in development mode using Docker Compose
dev:
	@echo "🚀 Starting Palmr in development mode..."
	@$(DOCKER) compose -f docker-compose.dev.yml up -d --build
	@echo "✅ Development stack started."
	@echo "   Web: http://localhost:3000"
	@echo "   API: http://localhost:3333"
	@echo "   Logs: make logs"

# Stop the development containers
dev-down:
	@echo "🛑 Stopping Palmr development containers..."
	@$(DOCKER) compose -f docker-compose.dev.yml down

# Stop the application
stop:
	@echo "🛑 Stopping Palmr application..."
	@$(DOCKER) compose down

# Show logs
logs:
	@echo "📋 Showing Palmr logs..."
	@$(DOCKER) compose -f docker-compose.dev.yml logs -f

# Clean up containers and images
clean:
	@echo "🧹 Cleaning up Docker containers and images..."
	@$(DOCKER) compose down -v
	@docker system prune -f
	@echo "✅ Cleanup completed!"

# Access container shell
shell:
	@echo "🐚 Accessing Palmr container shell..."
	@docker-compose exec palmr /bin/sh