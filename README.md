# Academic site

A minimal, durable academic website for Riccardo Borsetto, written as a total Agda program. The site is a function

```agda
document : Date → Page → String
```

from the build date to the HTML of each page. Talks, publications, and projects are values of record types; pages are values of a closed type `Page`; HTML is an inductive type whose typing rules enforce part of HTML's content model. The only effects (reading the date, checking static files, writing files) live in `src/Main.agda`. The output is ordinary static files with no JavaScript, external fonts, analytics, cookies, or third-party embeds.

## Repository map

```text
.
├── flake.nix, flake.lock      pinned Agda + standard library + GHC
├── Makefile                   compile, run, serve, deploy
├── website.agda-lib
├── src/
│   ├── Main.agda              the IO shell
│   ├── Html.agda              typed HTML: Inline (flow | inert), Block
│   ├── Html/Escape.agda       escaping, with its safety proof
│   ├── Html/Render.agda       rendering, Pandoc-style heading identifiers
│   ├── Site/Ids.agda          Page, PubId, Asset, Target (closed universes)
│   ├── Site/Date.agda         dates, written 26 nov 2026
│   ├── Site/Types.agda        Person, Talk, Publication, Project, News
│   ├── Site/Bibliography.agda labels, AMS-style entries, BibTeX file
│   ├── Site/Pages.agda        page bodies and the document layout
│   ├── Site/Properties.agda   theorems about the site
│   └── Content/               the facts: talks, publications, software, prose
├── static/                    style.css, cv.pdf, slides (copied verbatim)
└── public/                    generated; not committed
```

## Build and preview

With Nix (flakes enabled):

```sh
nix develop
make            # compile src/Main.agda, then run it for today's date
make serve      # http://127.0.0.1:8000/  (PORT=9000 to change)
```

Outside Nix you need Agda, the Agda standard library registered as `standard-library`, GHC, GNU Make, and Python 3 for `serve`. `make check` typechecks the theorems only. `make clean` removes `public/`; `make distclean` also removes the Agda/GHC build cache in `_build/`.

The build date is an explicit input: `make TODAY=2026-12-01` builds the site as it will look on that day. `nix build` is hermetic and uses the commit date of the source as the build date; `result` then contains the deployable site.

## What is checked

Compiling `Main` typechecks `Site.Properties`, so no site is built from content that breaks these:

| Theorem | Statement |
|---|---|
| `pages-complete` | every page is generated |
| `nav-complete` | every page except home is in the navigation |
| `path-injective` | distinct pages are written to distinct files |
| `citations-resolve` | for every build date, every citation link has its anchor on the publications page |
| `labels-unique` | bibliography labels (BoZo25a, BoZo25b, …) are distinct |
| `anchors-unique` | for every build date, no page defines an identifier twice |
| `talks-newest-first` | the talk list is in reverse chronological order |
| `assets-complete` | the build checks every static file it links to |
| `text-inert` | escaped text contains no `<`, `>`, or `"` |

By construction (no proof needed): internal links are values of `Target`, so a link to a non-existent page, publication, or file cannot be written; block content cannot appear inside phrasing content; links cannot nest; there is no raw-HTML constructor. At run time, `Main` refuses to build if a static file referenced by an `Asset` is missing.

## Content maintenance

- **A talk:** add a `record talk { … }` to `src/Content/Talks.agda` and put it in `allTalks` at its chronological position (the build rejects a wrong position). The talks page, the home page's "Recent" list, and the upcoming/past wording follow from the record and the build date.
- **A publication:** add a constructor to `PubId` in `src/Site/Ids.agda` (with its BibTeX key in `pubKey`), then a clause of `pub` in `src/Content/Publications.agda`. Agda reports every function that must now handle it (e.g. `allPubIds`, the theorems). The bibliography entry, label, status line, and `bib/publications.bib` are derived.
- **A static file:** put it under `static/`, add a constructor to `Asset` with its path, and link it with `asset`.
- **A page:** add a constructor to `Page`; Agda's coverage checker then lists every place that needs a case (path, title, description, body, the theorems).
- **Prose:** `src/Content/Prose.agda` and `src/Content/Software.agda`. Write `t "text"`, `b` bold, `it` italic, `tt` code, `a target "label"` links, joined with `·`.
- **Style:** `static/style.css`. The HTML stays readable without it.

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
- Rebuild periodically with the locked Nix environment; internal links are checked by types, external ones are not.
- Update the lock intentionally with `nix flake update`, review the change, and rebuild.
