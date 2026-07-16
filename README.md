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

Each lecture's `R/generate_theme.R` downloads the JSON files at render time.
The raw GitHub URLs are:

```
https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/quarto/colors.json
https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/quarto/fonts.json
https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/quarto/custom_theme.json
```

If the download fails (no internet access), `generate_theme.R` falls back to the
locally cached copies in each lecture's `theme/` folder. The JSON files in `theme/`
should be committed to git so offline rendering always works.

## Updating the theme

1. Edit the JSON files in `quarto/` here.
2. Commit and push to `main`.
3. Every lecture repo picks up the change automatically on next render (via the
   download step in `R/generate_theme.R`).
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
- JSON files in `quarto/` are the **only** files that lecture repos depend on.
  Do not rename or restructure them without updating every lecture's
  `R/generate_theme.R` accordingly.
- `docs/` is the GitHub Pages output — commit rendered output after updating guidelines.
