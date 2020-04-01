APP_COMMAND = docker-compose run --rm app

console:
	@$(APP_COMMAND) bin/console

setup:
	@$(APP_COMMAND) bin/setup

shell:
	@$(APP_COMMAND) bash

run_test:
	@$(APP_COMMAND) rake test

run_lint:
	@$(APP_COMMAND) rake rubocop
