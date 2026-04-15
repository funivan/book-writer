# Book Writer

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin for generating children's books — from story ideas to full chapters, character profiles, cover images, and EPUB exports.

## Skills

| Skill | Description |
|-------|-------------|
| `generate-story-idea` | Analyze source material and generate structured story ideas with plot variants for user selection |
| `prepare-characters` | Extract and structure character descriptions from source text |
| `generate-full-story` | Generate a complete multi-chapter story sequentially, one chapter per agent |
| `generate-image` | Create book covers or chapter illustrations via Unsplash API with ImageMagick processing |
| `convert-md-to-epub` | Merge markdown chapter files into a single EPUB ebook |
| `write-bug` | Create structured bug reports with reproduction steps and environment details |

## Installation

Run these commands inside Claude Code:

```
/plugin marketplace add funivan/book-writer
/plugin install book-writer@funivan-book-writer
```

After installation, all skills are available as `/book-writer:generate-story-idea`, `/book-writer:prepare-characters`, etc.

To update the plugin later:

```
/reload-plugins
```

### Optional dependencies

Core skills only need Claude Code and a Bash shell (macOS or Linux). Some skills require additional tools:

| Tool | Required by | macOS | Linux |
|------|-------------|-------|-------|
| `pandoc` | `convert-md-to-epub` | `brew install pandoc` | `apt install pandoc` |
| `imagemagick` | `generate-image` | `brew install imagemagick` | `apt install imagemagick` |
| `jq` | `generate-image` | `brew install jq` | `apt install jq` |
| `coreutils` | `convert-md-to-epub` | `brew install coreutils` | included by default |

### Environment variables

Create a `.env` file with API keys used by the image skill:

```bash
echo "UNSPLASH_API_KEY=your_unsplash_access_key" > .env
```

## Usage

Skills are invoked inside Claude Code using the `/` prefix or by describing the task in natural language:

```
# Generate a story idea from source material
/generate-story-idea

# Prepare character profiles
/prepare-characters

# Generate the full story
/generate-full-story --book_folder books/my-book --original_file books/original.txt

# Generate a book cover
/generate-image

# Convert to EPUB
/convert-md-to-epub

# File a bug report
/write-bug --title "Issue title" --description "What went wrong"
```

When installed as a plugin, prefix skills with the plugin name:

```
/book-writer:generate-story-idea
/book-writer:convert-md-to-epub
```

## Workflow

The typical book generation workflow:

1. Place source material in `original.txt`
2. **generate-story-idea** — pick a plot direction, produces `book-idea.txt`
3. **prepare-characters** — produces `characters.txt`
4. **generate-full-story** — produces chapter files (`s1-*.md`, `s2-*.md`, ...)
5. **generate-image** — produces `cover.jpeg` and chapter images
6. **convert-md-to-epub** — produces the final `.epub`

## Project structure

```
book-writer/
  .claude-plugin/
    plugin.json              # Plugin metadata
    marketplace.json         # Marketplace catalog
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
      validate-scripts.yml   # ShellCheck + syntax + permissions CI
      validate-json.yml      # JSON lint + marketplace schema CI
  README.md
```

## CI

Shell scripts and JSON files are validated on every push and pull request via GitHub Actions:

- **ShellCheck** — static analysis for common shell scripting issues
- **Bash syntax check** — validates all `.sh` files parse correctly
- **Executable permission check** — ensures scripts have `+x` permission
- **JSON lint** — validates all `.json` files have correct syntax
- **Marketplace schema check** — ensures `marketplace.json` has required fields (`name`, `owner`, `plugins[].source`)

## License

MIT
