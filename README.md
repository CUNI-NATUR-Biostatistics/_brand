# _brand — Visual Identity for Biostatistika (MB120P163)

This repository is the **single source of truth** for the visual identity of the
[Biostatistika (MB120P163)](https://github.com/CUNI-NATUR-Biostatistics) course
at the Faculty of Science, Charles University.

## Recommended workspace

This repository is designed to be maintained in the `CUNI-NATUR-Biostatistics` multi-root workspace. Shared course context and canonical AI-agent guidance live in the private `_internal` repository; the recommended setup is documented in `_internal/workspace-setup.md`. An AI assistant working from this repository alone may not have the complete course context.

## Contents

- [`quarto/`](quarto/) — canonical JSON configuration files for all Quarto and R themes
  - [`colors.json`](quarto/colors.json) — colour palette (8 primary + 15 semantic entries)
  - [`fonts.json`](quarto/fonts.json) — typography (families, sizes per context, weights)
  - [`custom_theme.json`](quarto/custom_theme.json) — spacing, code, blockquote, table styles
- [`brand_guidelines.qmd`](brand_guidelines.qmd) — full visual identity guide, published as a Quarto website

## Live brand guidelines

Published at: <https://CUNI-NATUR-Biostatistics.github.io/_brand/>

## How each lecture repo uses these files

Every supported lesson render entry point (`R/render_skripta.R`,
`R/render_presentation.R`, and `R/render_all.R`) runs `R/generate_theme.R`
before rendering. In the development workspace the generator prefers the local
sibling `_brand` repository; elsewhere it downloads the canonical files from
GitHub.

Lessons that contain `pollslive/config.json` also run the version-pinned
PollsLive preparation client before a complete presentation render. The helper
contacts the central `_internal` workflow through authenticated `gh`; the
PollsLive credential never leaves GitHub. It renders live HTML and a separate
static RevealJS input for PDF, and publishes the customary output filenames
only after both variants succeed. Set `POLLSLIVE_RENDER_MODE=offline` for a
fully native HTML/PDF render that makes no synchronization request.

Direct `quarto render` and `quarto preview` do not perform PollsLive
synchronization. They can use the most recently verified generated include for
authoring previews, but only `R/render_presentation.R` or `R/render_all.R`
produces release outputs under this contract.
The raw GitHub URLs are:

```
https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/quarto/colors.json
https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/quarto/fonts.json
https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/quarto/custom_theme.json
```

If synchronization fails (for example without internet access),
`generate_theme.R` falls back to committed local copies and emits an explicit
warning that the cache may be stale. It also writes
`theme/brand_manifest.json`, whose deterministic fingerprint makes the exact
set of synchronized inputs visible. Cached inputs and generated artifacts
should remain committed so offline rendering works.

## Updating the theme

1. Edit the JSON files in `quarto/` here.
2. Commit and push to `main`.
3. Every lecture repo picks up the change automatically on its next supported
   render. Direct `quarto render` calls bypass the synchronization contract and
   should not be used for release rendering.
4. To update the brand guidelines website, run `quarto render` from this directory
   and push the updated `docs/` folder.

## Rendering the brand guidelines website locally

Requirements: R ≥ 4.4, Quarto ≥ 1.5, and the following R packages:
`here`, `jsonlite`, `ggplot2`, `tibble`, `purrr`

```r
quarto::quarto_render()
```

## Repository conventions

- **This repo is public** — all content must be appropriate for public viewing.
- JSON files in `quarto/`, generators under `R/Functions/Theme_generation/`,
  render helpers under `R/`, the glossary helper, and the Lua filter are
  canonical inputs copied into lecture repositories. Do not rename or
  restructure them without updating `R/generate_theme.R`.
- `docs/` is the GitHub Pages output — commit rendered output after updating guidelines.

## License

Original explanatory and rendered content is licensed under CC BY 4.0, while code, styles, and generators are licensed under MIT. See [`LICENSE.md`](LICENSE.md) for the precise scope, attribution request, and third-party exclusions.
