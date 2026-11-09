network:
	@docker network inspect healthcare-internal >/dev/null 2>&1 || docker network create healthcare-internal

start: network
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f