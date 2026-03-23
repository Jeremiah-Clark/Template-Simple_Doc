# Simple Doc - Template System

I was looking for a simple way to write in Markdown—using a Git system for versioning and possible collaboration—while still producing consistently formatted, attractive files. I couldn't find anything that quite did what I wanted in the way I wanted. That's why I made this "Simple Doc" template system. Simple Doc is meant to be simple and reusable. It is designed to produce cleanly and consistently styled PDFs from pure GitHub-flavored Markdown files. The content and styling are kept separate to keep the files as readable and flexible as possible.

---

### Project Structure

```
├── .gitignore
├── master.yaml                    # Metadata + style settings (edit)
├── titlepage.tex                  # Title page layout (edit if needed)
├── build.sh                       # Build script (edit)
├── template.tex                   # Formatting template (usable as is)
├── gfm-to-latex.lua               # GFM-to-LaTeX filter (usable as is)
└── images/
    └── logo.png
```

## Starting a New Project

To create a new document:

1. Copy these files to a new folder: `template.tex`, `titlepage.tex`, `gfm-to-latex.lua`, `build.sh`, and `master.yaml`
2. Edit `master.yaml` with your document's metadata and style preferences
   - Edit `titlepage.tex` only if you need to change the structural layout (element order, custom LaTeX, etc.). All spacing, sizing, and margin settings are controlled from `master.yaml`.
3. Write your content as standard GFM Markdown files
   - Make each section its own file for greater flexibility
4. Update the file list in `build.sh` to point to your new Markdown files
   - The PDF will begin with the title page, then each of the documents listed in the build file, in the order listed

> [!NOTE]
> The template file types are included in the .gitignore file (at the very bottom of the file). I like to keep those local-only after setup; delete those lines if you want to keep them in sync.

### How It Works

The content files are written in standard GitHub Flavored Markdown (GFM). They are fully readable on GitHub as-is.

When you build the PDF, Pandoc reads the Markdown files and converts them to a formatted document using three supporting files:

- **`template.tex`** — The reusable formatting template. Controls typography, colors, callout box styling, headers/footers, and overall page layout. You don't need to edit this file unless you want to change the structure of the document layout itself.
- **`titlepage.tex`** — The title page layout. Edit this file only if you need to rearrange elements or add custom LaTeX. All spacing and sizing is now driven by `master.yaml`.
- **`gfm-to-latex.lua`** — A filter that bridges GFM features to the PDF. It converts callout blockquotes into styled boxes, makes images full-width, and inserts page breaks before each major section. You should not need to edit this file.
- **`master.yaml`** — All document metadata and style settings in one place. This is the primary file you edit to change the document's title, author, fonts, colors, margins, spacing, and other options. See **Settings Reference** below for a full list.

### Building the PDF

#### Requirements

- [Pandoc](https://pandoc.org/) (3.x recommended)
- A LaTeX distribution with XeLaTeX (such as [TeX Live](https://tug.org/texlive/) or [MiKTeX](https://miktex.org/))
- The fonts specified in `master.yaml` must be installed on your system (Noto Sans and Noto Sans Mono by default, available from [Google Fonts](https://fonts.google.com/noto))

### Installation

Pick your platform and run the commands below. This installs everything the template needs in one shot.

**Ubuntu / Debian:**

```bash
# Pandoc
sudo apt install pandoc

# TeX Live (XeLaTeX + all required LaTeX packages)
sudo apt install texlive-xetex texlive-latex-extra texlive-fonts-recommended texlive-pictures

# Default fonts
sudo apt install fonts-noto-core
```

**macOS (Homebrew):**

```bash
# Pandoc
brew install pandoc

# Full TeX distribution (includes XeLaTeX and all packages)
brew install --cask mactex

# Default fonts
brew install --cask font-noto-sans font-noto-sans-mono
```

If you prefer a smaller install, use BasicTeX instead of MacTeX and install packages manually:

```bash
brew install --cask basictex
sudo tlmgr update --self
sudo tlmgr install enumitem mdframed titlesec soul booktabs bookmark \
  newunicodechar zref needspace pgf xcolor fancyhdr fontspec
```

**Windows:**

1. Install [Pandoc](https://pandoc.org/installing.html)
2. Install [MiKTeX](https://miktex.org/download) — during setup, choose "Yes" for automatic package installation. MiKTeX will download any missing packages on first build.
3. Install [Noto Sans fonts](https://fonts.google.com/noto) — download, unzip, and right-click → "Install for all users"

### Verify Your Installation

```bash
pandoc --version        # Should show 3.x
xelatex --version      # Should show XeTeX
fc-list | grep "Noto"  # Should list Noto Sans and Noto Sans Mono
```

### Build Command

```bash
chmod +x build.sh
./build.sh
```

This generates the output PDF in the project directory (the filename is set at the end of `build.sh`).

#### A Note on Pandoc Versions

The build script uses `--from gfm-alerts` instead of `--from gfm`. This disables Pandoc's built-in alert handling (added in 3.1.7), which would otherwise intercept callouts before the Lua filter can process them. If your version of Pandoc doesn't recognize `gfm-alerts`, Pandoc will print a harmless warning and continue. The build will still succeed.

---

## Settings Reference

All settings live in `master.yaml`. Every style setting has a built-in default, so you can omit any of them and the template will still work.

### Document Metadata

| Setting    | Description                                                  | Example                  |
| ---------- | ------------------------------------------------------------ | ------------------------ |
| `title`    | Document title (appears on title page, footer, and PDF metadata) | `"My Document"`          |
| `author`   | Author name                                                  | `"Jane Smith"`           |
| `date`     | Date string (any format)                                     | `"2026-02-11"`           |
| `version`  | Version number (appears in top-right of title page and in footer; omit to hide) | `"1.0"`                  |
| `keywords` | List of keywords for PDF metadata                            | `[gaming, regulations]`  |
| `subject`  | Subject line for PDF metadata                                | `"Industry regulations"` |

### Title Page Controls

| Setting                 | Description                                                  | Example                   |
| ----------------------- | ------------------------------------------------------------ | ------------------------- |
| `logo`                  | Path to a logo image displayed on the title page (omit to hide) | `"images/logo.png"`       |
| `disclaimer`            | Text displayed in a warning box at the bottom of the title page (supports **bold** via `**text**`; omit to hide) | `"**Not legal advice.**"` |
| `logo-width`            | Logo width as a fraction of the text width                   | `"0.8"`                   |
| `titlepage-post-rule`   | Space after the top rule, before the title                   | `"2em"`                   |
| `titlepage-post-title`  | Space after the title, before the author                     | `"0.75em"`                |
| `titlepage-post-author` | Space after the author, before the date                      | `"0.5em"`                 |
| `titlepage-post-date`   | Space after the date, before the logo                        | `"3em"`                   |

### PDF and Layout

| Setting       | Default  | Description                                                  |
| ------------- | -------- | ------------------------------------------------------------ |
| `fontsize`    | `11pt`   | Base font size                                               |
| `papersize`   | `letter` | Paper size (`letter` or `a4`)                                |
| `toc`         | `true`   | Whether to generate a table of contents                      |
| `toc-depth`   | `2`      | How many heading levels to include in the TOC                |
| `secnumdepth` | `0`      | Section numbering depth. `0` = no numbers, `1` = sections only, `2` = + subsections, `3` = + subsubsections |

### Margins

All margin values accept any standard LaTeX dimension (`in`, `cm`, `mm`, `pt`, `em`).

| Setting         | Default  | Description            |
| --------------- | -------- | ---------------------- |
| `margin`        | `1in`    | Left and right margins |
| `margin-top`    | `1.25in` | Top margin             |
| `margin-bottom` | `1.25in` | Bottom margin          |

### Header and Footer

Spacing values accept any standard LaTeX dimension. Set a rule width to `0pt` to hide it.

| Setting       | Default | Description                                               |
| ------------- | ------- | --------------------------------------------------------- |
| `headheight`  | `14pt`  | Height of the header box                                  |
| `headsep`     | `12pt`  | Gap between the header rule and the body text             |
| `footskip`    | `30pt`  | Distance from the body text bottom to the footer baseline |
| `header-rule` | `0.4pt` | Thickness of the rule below the header                    |
| `footer-rule` | `0.4pt` | Thickness of the rule above the footer                    |

> [!NOTE]
> Header and footer settings apply to body pages only. The title page uses `\thispagestyle{empty}` and displays no header or footer.

### Fonts

| Setting        | Default          | Description                                                  |
| -------------- | ---------------- | ------------------------------------------------------------ |
| `font-body`    | `Noto Sans`      | Font for body text                                           |
| `font-heading` | `Noto Sans`      | Font for section headings and title page                     |
| `font-mono`    | `Noto Sans Mono` | Font for any monospaced/code text                            |
| `linespread`   | `1.25`           | Line spacing multiplier (1.0 = single, 1.5 = one-and-a-half) |

### Colors

Section heading and link colors use RGB values. Callout colors use LaTeX color names.

| Setting           | Default     | Format     | Description                                    |
| ----------------- | ----------- | ---------- | ---------------------------------------------- |
| `color-heading`   | `25,55,120` | `"R,G,B"`  | Color of section headings (H1)                 |
| `color-link`      | `40,80,180` | `"R,G,B"`  | Color of hyperlinks (also used for underlines) |
| `color-important` | `red`       | color name | Important callout                              |
| `color-note`      | `blue`      | color name | Note callout                                   |
| `color-warning`   | `orange`    | color name | Warning callout                                |
| `color-tip`       | `green`     | color name | Tip callout                                    |
| `color-caution`   | `yellow`    | color name | Caution callout                                |
| `color-summary`   | `violet`    | color name | Summary callout                                |
| `color-example`   | `black`     | color name | Example callout                                |

For each callout, the template automatically derives the title bar and border color (a darker shade) and the background color (a very light tint) from the single base color you specify.

Available LaTeX color names include: `red`, `blue`, `green`, `orange`, `yellow`, `violet`, `black`, `cyan`, `magenta`, `teal`, `brown`, `purple`, `olive`, `darkgray`, `gray`, and `lightgray`.

### Writing Callouts

Callouts use GitHub's blockquote alert syntax. They render as colored alert boxes on GitHub and as styled framed boxes in the PDF\*.

\* *The Summary and Example callout types are not standard, and thus not directly supported on GitHub. They will work fine, but will not show full formatting outside of the script-built PDF.*

#### Supported Types

`IMPORTANT`, `NOTE`, `WARNING`, `TIP`, `CAUTION`, `SUMMARY`, `EXAMPLE`

#### Basic Callout (Default Title)

The title bar will display the type name (e.g., "Warning"):

```markdown
> [!WARNING]
>
> This is a warning callout.
> It supports **bold**, *italic*, [links](https://example.com), and lists.
```

#### Callout with Custom Title

Add your custom title text after the type marker. In the PDF, this replaces the default title in the title bar. On GitHub, the custom title text will appear as body text inside the callout (GitHub does not support custom alert titles).

```markdown
> [!TIP] Example Tax Withholding
>
> A distributor has net revenues of $1,235,350.00 ...
```

This creates a callout box titled "Example Tax Withholding" instead of "Tip".

## Changelog

* 2026-02-27 **v0.5** — Initial release of finalized template system. 
* 2026-03-14 **v0.8** — Added streamlined instructions for installing required Pandoc and LaTeX packages. 
* 2026-03-22 **v1.0** — Moved margin, header and footer, and title page layout controls into the YAML file. 
