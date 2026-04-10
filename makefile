fmt:
	sh scripts/format.sh
.PHONY: fmt

lint:
	sh scripts/lint.sh
.PHONY: lint

compile:
	sh scripts/compile.sh
.PHONY: compile
