# Book Writer

A Claude Code, Codex, Antigravity, and opencode plugin for generating children's books — from story ideas to full chapters, character profiles, cover images, and EPUB exports.

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

### Claude Code

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

### Codex

Codex plugin metadata is available in `.codex-plugin/plugin.json`, and it points to the same `skills/` directory used by the Claude Code plugin.

Install it from the Codex marketplace:

```bash
codex plugin marketplace add funivan/book-writer
codex plugin add book-writer
```

### Antigravity

Antigravity configuration is available in `.agents/skills.json` and `.antigravity-plugin/plugin.json`.

Install it as a local Antigravity plugin:

```bash
agy plugin install .
```

Or open the repository in Antigravity IDE / CLI directly; workspace skills in `skills/` are discovered automatically via `.agents/skills.json`.

### opencode

opencode has no plugin marketplace — plugins are loaded from `.opencode/plugins/`
(project) or `~/.config/opencode/plugins/` (global), and skill directories are
registered through `opencode.json`. See the [opencode plugin docs](https://opencode.ai/docs/plugins/).

This repository ships both:

- `opencode.json` — registers `./skills` when the repo itself is opened in opencode
- `.opencode/plugins/book-writer.js` — a plugin that adds the skills directory to
  the opencode config, resolved relative to the plugin file

To use the skills from another project, pick one of:

```bash
# 1. Symlink the plugin globally (skills resolve back to this checkout)
mkdir -p ~/.config/opencode/plugins
ln -s "$PWD/.opencode/plugins/book-writer.js" ~/.config/opencode/plugins/book-writer.js
```

```jsonc
// 2. Point your project's opencode.json at this checkout
{
  "$schema": "https://opencode.ai/config.json",
  "skills": ["/absolute/path/to/book-writer/skills"]
}
```

```bash
# 3. Copy or symlink the skills into a project's .opencode/skills/
./install-opencode.sh /path/to/project        # symlink
./install-opencode.sh --copy /path/to/project # copy
```

Restart opencode afterwards — skills and plugins are loaded at startup.

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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for project structure, CI details, and local validation instructions.

## License

MIT
