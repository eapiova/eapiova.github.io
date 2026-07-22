# Academic site

A minimal, durable academic website for Riccardo Borsetto. It is built from Markdown and BibTeX with Pandoc, the American Mathematical Society label CSL style, one HTML template, one CSS file, GNU Make, and a pinned Nix environment. It produces ordinary static files and contains no JavaScript, external fonts, analytics, cookies, or third-party embeds.

## Repository map

```text
.
├── flake.nix
├── flake.lock
├── Makefile
├── metadata.yaml
├── template.html
├── pages/
├── bib/publications.bib
├── csl/american-mathematical-society-label.csl
├── static/style.css
├── static/files/cv.pdf
├── static/files/slides/
└── public/                 # generated; do not commit by default
```

## Build and preview

With Nix installed and flakes enabled:

```sh
nix develop
make
make serve
```

Then open <http://127.0.0.1:8000/>. Set another port with `make serve PORT=9000`.

Outside Nix, install Pandoc with citeproc support, GNU Make, and Python 3, then run the same `make` commands. `make clean` removes only the generated `public/` directory.

For a hermetic production build:

```sh
nix build
```

The `result` symlink points to a Nix output containing only the deployable site. The flake lock pins the exact nixpkgs revision used for Pandoc and the other build tools.

## Content maintenance

1. Edit global author, language, description, and canonical origin settings in `metadata.yaml`. Keep `site-url` free of a trailing slash.
2. Edit page content in `pages/`. Each file supplies one page title, and the template emits the single `h1`.
3. Maintain publication records in `bib/publications.bib`. The publications page alone runs `--citeproc`, `--bibliography`, and `--csl`.
4. Put PDFs and other static files under `static/`. They are copied to the root of `public/`, so use relative links such as `files/slides/name.pdf`.
5. Adjust `static/style.css` sparingly. The generated HTML remains complete and understandable without it.

When adding a page, add its basename to `ORDINARY_PAGES` in the Makefile and add its navigation link to `template.html`. Run `make clean && make` after deleting or renaming source files; the build also prunes unexpected top-level HTML files.

## Publication formatting

`csl/american-mathematical-society-label.csl` is vendored and selected explicitly. Editing either the CSL file or the BibTeX database rebuilds `publications.html`; ordinary pages do not depend on either file. The generated copy of `bib/publications.bib` lets readers download the site's source bibliography.

## Deployment

Deployment is manual by design, with no CI. The `deploy` target rebuilds the site from a clean tree, prepares the `pages` branch in a temporary Git worktree, commits the generated static files there if they changed, and pushes that branch to GitHub (and to Codeberg too, if that remote is configured). It does not alter the source worktree. The target stops with a clear message if the GitHub remote is missing, if the source has no initial commit, or if the GitHub remote cannot be reached to check for the branch.

The active host is **GitHub Pages**, serving the site at `https://eapiova.github.io/`. Codeberg Pages is an optional second host that can be added later without changing anything here. Both hosts serve from a branch named `pages`, which is why the deploy pushes `pages:pages`; if Codeberg is added, do not override `DEPLOY_BRANCH`, because Codeberg's git-pages serves a branch fixed to the name `pages`.

One-time setup (GitHub):

1. Create the GitHub repository `eapiova.github.io`.
2. Add the remote:

```sh
git remote add github-pages git@github.com:eapiova/eapiova.github.io.git
```

3. Enable Pages in Settings > Pages > Build and deployment: choose "Deploy from a branch" and select `pages` / `/ (root)`. If the repository is created empty and `pages` is the first branch ever pushed, GitHub adopts it as the default branch, so this step is usually automatic for a `<user>.github.io` site. A `.nojekyll` marker is deployed automatically so paths are served verbatim.

After the one-time setup and an initial source commit, publish manually with:

```sh
make deploy
```

Adding Codeberg later: create a Codeberg repository named `pages`, add a webhook on it (Settings > Webhooks) with target URL `https://<codeberg-user>.codeberg.page/` and the branch filter set to `pages` (its "Test delivery" button reports a false failure; a real push is what publishes), then `git remote add codeberg-pages git@codeberg.org:<codeberg-user>/pages.git`. The next `make deploy` pushes to both hosts automatically.

The Makefile variables `GITHUB_USER` and `CODEBERG_USER` default to `eapiova`; the remote names can be changed with `GITHUB_REMOTE` and `CODEBERG_REMOTE`, and the published branch with `DEPLOY_BRANCH` (default `pages`; see the caveat above before changing it).

If a machine is force-killed mid-deploy, a stale worktree registration can remain; `deploy` runs `git worktree prune` on each run to clear it, but if a subsequent deploy still reports that `pages` is already checked out, remove the leftover with `git worktree remove --force <path>` (see `git worktree list`).

## Maintenance

- Prefer stable filenames and citation keys; URLs outlive redesigns more easily than site structures.
- Mark working notes, superseded papers, corrections, and archived software honestly.
- Link legal open copies and retain source/reproducibility instructions where possible.
- Periodically test internal links and rebuild with the locked Nix environment.
- Update the lock intentionally with `nix flake update`, review the change, and rebuild.
