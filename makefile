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

.PHONY: test
test:
	mise exec -- bats --recursive tests/unit tests/template

.PHONY: check
check: lint validate test

# --- scoped test targets (for fast iteration) ---

.PHONY: test-unit
test-unit:
	mise exec -- bats --recursive tests/unit

.PHONY: test-template
test-template:
	mise exec -- bats --recursive tests/template
