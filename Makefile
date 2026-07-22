PANDOC ?= pandoc
PYTHON ?= python3
PORT ?= 8000
# GitHub Pages is the active deploy target; Codeberg is optional (its remote
# can be added later, then it is pushed alongside GitHub automatically).
CODEBERG_USER ?= eapiova
GITHUB_USER ?= eapiova
CODEBERG_REMOTE ?= codeberg-pages
GITHUB_REMOTE ?= github-pages
DEPLOY_BRANCH ?= pages

OUT := public
TEMPLATE := template.html
METADATA := metadata.yaml
STYLESHEET := static/style.css
BIBLIOGRAPHY := bib/publications.bib
CSL := csl/american-mathematical-society-label.csl

ORDINARY_PAGES := index research notes talks teaching software cv contact
ORDINARY_HTML := $(addprefix $(OUT)/,$(addsuffix .html,$(ORDINARY_PAGES)))
PUBLICATIONS_HTML := $(OUT)/publications.html
HTML_OUTPUTS := $(ORDINARY_HTML) $(PUBLICATIONS_HTML)

COMMON_DEPS := $(TEMPLATE) $(METADATA) $(STYLESHEET)
COMMON_FLAGS := --standalone --to=html5 --wrap=none --template=$(TEMPLATE) \
	--metadata-file=$(METADATA) --css=style.css --email-obfuscation=references

.DEFAULT_GOAL := all

.PHONY: all assets serve deploy clean

all: $(HTML_OUTPUTS) assets
	@for file in $(OUT)/*.html; do \
		test -e "$$file" || continue; \
		case " $(HTML_OUTPUTS) " in *" $$file "*) ;; *) rm -f "$$file" ;; esac; \
	done

$(OUT)/%.html: pages/%.md $(COMMON_DEPS)
	@mkdir -p $(OUT)
	$(PANDOC) $(COMMON_FLAGS) --metadata=canonical-path:$*.html --output=$@ $<

$(PUBLICATIONS_HTML): pages/publications.md $(COMMON_DEPS) $(BIBLIOGRAPHY) $(CSL)
	@mkdir -p $(OUT)
	$(PANDOC) $(COMMON_FLAGS) --metadata=canonical-path:publications.html \
		--citeproc --bibliography=$(BIBLIOGRAPHY) --csl=$(CSL) --output=$@ $<

assets:
	@mkdir -p $(OUT)
	cp -R static/. $(OUT)/
	@mkdir -p $(OUT)/bib
	cp $(BIBLIOGRAPHY) $(OUT)/bib/publications.bib

serve: all
	@printf 'Serving http://127.0.0.1:%s/\n' '$(PORT)'
	cd $(OUT) && $(PYTHON) -m http.server $(PORT) --bind 127.0.0.1

# A clean rebuild so that assets removed from static/ do not survive in the
# published tree (assets is copy-over, not sync). deploy has no prerequisites:
# the recipe rebuilds from scratch itself to keep the ordering deterministic.
# GitHub Pages is the required target; the Codeberg remote is pushed too when
# it is configured, so a second host can be added later without changes here.
deploy:
	@set -eu; \
	if ! git remote get-url '$(GITHUB_REMOTE)' >/dev/null 2>&1; then \
		printf 'Deployment aborted: Git remote "%s" is not configured.\n' '$(GITHUB_REMOTE)' >&2; \
		printf 'Configure it with: git remote add %s git@github.com:%s/%s.github.io.git\n' '$(GITHUB_REMOTE)' '$(GITHUB_USER)' '$(GITHUB_USER)' >&2; \
		exit 1; \
	fi; \
	have_codeberg=0; \
	if git remote get-url '$(CODEBERG_REMOTE)' >/dev/null 2>&1; then have_codeberg=1; fi; \
	if ! git rev-parse --verify HEAD >/dev/null 2>&1; then \
		printf 'Deployment aborted: create the initial source commit first.\n' >&2; \
		exit 1; \
	fi; \
	$(MAKE) --no-print-directory clean; \
	$(MAKE) --no-print-directory all; \
	site_root=$$(pwd -P); \
	git worktree prune; \
	deploy_dir=$$(mktemp -d "$${TMPDIR:-/tmp}/academic-site-deploy.XXXXXX"); \
	cleanup() { \
		git worktree remove --force "$$deploy_dir" >/dev/null 2>&1 || true; \
		rmdir "$$deploy_dir" >/dev/null 2>&1 || true; \
	}; \
	trap cleanup EXIT HUP INT TERM; \
	if git show-ref --verify --quiet 'refs/heads/$(DEPLOY_BRANCH)'; then \
		git worktree add "$$deploy_dir" '$(DEPLOY_BRANCH)'; \
	else \
		if remote_heads=$$(git ls-remote --heads '$(GITHUB_REMOTE)' '$(DEPLOY_BRANCH)' 2>/dev/null); then \
			:; \
		else \
			printf 'Deployment aborted: cannot reach remote "%s" to check for the %s branch.\n' '$(GITHUB_REMOTE)' '$(DEPLOY_BRANCH)' >&2; \
			exit 1; \
		fi; \
		if [ -n "$$remote_heads" ]; then \
			git fetch '$(GITHUB_REMOTE)' '$(DEPLOY_BRANCH):$(DEPLOY_BRANCH)'; \
			git worktree add "$$deploy_dir" '$(DEPLOY_BRANCH)'; \
		else \
			git worktree add --detach "$$deploy_dir" HEAD; \
			git -C "$$deploy_dir" switch --orphan '$(DEPLOY_BRANCH)'; \
		fi; \
	fi; \
	git -C "$$deploy_dir" rm -rf --ignore-unmatch . >/dev/null; \
	cp -R "$$site_root/$(OUT)/." "$$deploy_dir/"; \
	touch "$$deploy_dir/.nojekyll"; \
	git -C "$$deploy_dir" add -A; \
	if git -C "$$deploy_dir" diff --cached --quiet; then \
		printf 'No site changes to commit on branch %s.\n' '$(DEPLOY_BRANCH)'; \
	else \
		git -C "$$deploy_dir" commit -m 'Publish academic site'; \
	fi; \
	git -C "$$deploy_dir" push '$(GITHUB_REMOTE)' '$(DEPLOY_BRANCH):$(DEPLOY_BRANCH)'; \
	if [ "$$have_codeberg" -eq 1 ]; then \
		git -C "$$deploy_dir" push '$(CODEBERG_REMOTE)' '$(DEPLOY_BRANCH):$(DEPLOY_BRANCH)'; \
	else \
		printf 'Note: Codeberg remote "%s" is not configured; pushed to GitHub only.\n' '$(CODEBERG_REMOTE)'; \
	fi

clean:
	rm -rf $(OUT)
