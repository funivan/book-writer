# Book Writer

A Claude Code skills plugin for generating children's books — from story ideas to full chapters, character profiles, cover images, and EPUB exports.

## Skills

| Skill | Description |
|-------|-------------|
| `generate-story-idea` | Analyze source material and generate structured story ideas with plot variants for user selection |
| `prepare-characters` | Extract and structure character descriptions from source text |
| `generate-full-story` | Generate a complete multi-chapter story sequentially, one chapter per agent |
| `generate-image` | Create book covers or chapter illustrations via Unsplash API with ImageMagick processing |
| `convert-md-to-epub` | Merge markdown chapter files into a single EPUB ebook |
| `write-bug` | Create structured bug reports with reproduction steps and environment details |

## Setup

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- Bash shell (macOS or Linux)

### Optional dependencies (per skill)

| Tool | Required by | Install |
|------|-------------|---------|
| `pandoc` | `convert-md-to-epub` | `brew install pandoc` / `apt install pandoc` |
| `imagemagick` | `generate-image` | `brew install imagemagick` / `apt install imagemagick` |
| `curl`, `jq` | `generate-image` | `brew install jq` / `apt install jq` |
| `coreutils` | `convert-md-to-epub` (macOS) | `brew install coreutils` |

### Environment variables

Create a `.env` file in the project root for API keys:

```
UNSPLASH_API_KEY=your_unsplash_access_key
```

## Usage

Skills are invoked through Claude Code using the `@skills/` prefix or by describing the task:

```
# Generate a story idea from source material
@skills/generate-story-idea

# Prepare character profiles
@skills/prepare-characters

# Generate the full story
@skills/generate-full-story --book_folder books/my-book --original_file books/original.txt

# Generate a book cover
@skills/generate-image

# Convert to EPUB
@skills/convert-md-to-epub

# File a bug report
@skills/write-bug --title "Issue title" --description "What went wrong"
```

## Project structure

```
book-writer/
  skills/
    generate-story-idea/
      SKILL.md
    prepare-characters/
      SKILL.md
    generate-full-story/
      SKILL.md
      scripts/
        count-scenes.sh
    generate-image/
      SKILL.md
      scripts/
        image-downloader.sh
    convert-md-to-epub/
      SKILL.md
      scripts/
        convert.sh
    write-bug/
      SKILL.md
      scripts/
        slugify.sh
  .github/
    workflows/
      validate-scripts.yml    # ShellCheck + syntax + permissions CI
  README.md
```

## Workflow

The typical book generation workflow:

1. Place source material in `original.txt`
2. **generate-story-idea** — pick a plot direction, produces `book-idea.txt`
3. **prepare-characters** — produces `characters.txt`
4. **generate-full-story** — produces chapter files (`s1-*.md`, `s2-*.md`, ...)
5. **generate-image** — produces `cover.jpeg` and chapter images
6. **convert-md-to-epub** — produces the final `.epub`

## CI

Shell scripts are validated on every push and pull request via GitHub Actions:

- **ShellCheck** — static analysis for common shell scripting issues
- **Bash syntax check** — validates all `.sh` files parse correctly
- **Executable permission check** — ensures scripts have `+x` permission

## License

MIT
