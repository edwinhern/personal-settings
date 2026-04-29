fmt:
	sh scripts/format.sh
.PHONY: fmt

lint:
	sh scripts/lint.sh
.PHONY: lint

compile:
	sh scripts/compile.sh
.PHONY: compile

install:
	bash scripts/install.sh
.PHONY: install

apply:
	chezmoi apply --source "$(CURDIR)"
.PHONY: apply

diff:
	chezmoi diff --source "$(CURDIR)"
.PHONY: diff
