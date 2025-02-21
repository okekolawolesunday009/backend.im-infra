.PHONY: build up down logs clean dep run

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

clean:
	docker compose down -v
	rm -rf repos-data/* kube-config/*

deps:
	@echo "Installing Go dependencies..."
	go mod tidy

run:
	@echo "Starting Go application..."
	go run main.go
