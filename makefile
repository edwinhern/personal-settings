CHEZMOI ?= chezmoi
SOURCE  := $(CURDIR)

.PHONY: init
init:
	$(CHEZMOI) init --apply --verbose --source=$(SOURCE)

.PHONY: diff
diff:
	$(CHEZMOI) diff --source=$(SOURCE)

.PHONY: update
update:
	$(CHEZMOI) apply --verbose --source=$(SOURCE)

.PHONY: reset
reset:
	$(CHEZMOI) state delete-bucket --bucket=scriptState

.PHONY: reset-config
reset-config:
	$(CHEZMOI) init --data=false --source=$(SOURCE)

.PHONY: format
format:
	./scripts/format.sh

.PHONY: lint
lint:
	./scripts/lint.sh

.PHONY: validate
validate:
	./scripts/compile.sh

.PHONY: check
check: lint validate
