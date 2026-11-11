.PHONY: update up down logs

network:
	@docker network inspect healthcare-internal >/dev/null 2>&1 || docker network create healthcare-internal

update: network
	@echo "Parsing healthcare.json and updating workspace repositories..."
	@python3 -c '\
	import json, os, subprocess; \
	data = json.load(open("healthcare.json")); \
	gitignore_path = ".gitignore"; \
	existing_ignore = open(gitignore_path, "r").read() if os.path.exists(gitignore_path) else ""; \
	git_ignore_file = open(gitignore_path, "a"); \
	for repo, config in data.items(): \
		if not os.path.exists(repo): \
			print(f"Cloning component: {repo}..."); \
			subprocess.run(["git", "clone", config["url"], repo]); \
		if repo not in existing_ignore: \
			git_ignore_file.write(f"\n{repo}"); \
	git_ignore_file.close(); \
	'

up: update
	@echo "Launching unified healthcare microservice workspace stack..."
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f