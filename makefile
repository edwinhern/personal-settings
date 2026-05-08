fmt:
	./scripts/format.sh
.PHONY: fmt

lint:
	./scripts/lint.sh
.PHONY: lint

compile:
	./scripts/compile.sh
.PHONY: compile

apply:
	chezmoi apply --source "$(CURDIR)"
.PHONY: apply

diff:
	chezmoi diff --source "$(CURDIR)"
.PHONY: diff
