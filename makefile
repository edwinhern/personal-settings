.PHONY: init
init:
	chezmoi init --apply --verbose

.PHONY: diff
diff:
	chezmoi diff

.PHONY: update
update:
	chezmoi apply --verbose

.PHONY: watch
watch:
	DOTFILES_DEBUG=1 watchexec -- chezmoi apply --verbose

.PHONY: reset
reset:
	chezmoi state delete-bucket --bucket=scriptState

.PHONY: reset-config
reset-config:
	chezmoi init --data=false

.PHONY: format
format:
	./scripts/format.sh

.PHONY: lint
lint:
	./scripts/lint.sh

.PHONY: compile
compile:
	./scripts/compile.sh
