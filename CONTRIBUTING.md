# Contributing

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
      validate-scripts.yml     # ShellCheck + syntax + permissions CI
      validate-json.yml        # JSON validation CI
  README.md
```

## CI

Shell scripts and JSON files are validated on every push and pull request via GitHub Actions:

- **ShellCheck** — static analysis for common shell scripting issues
- **Bash syntax check** — validates all `.sh` files parse correctly
- **Executable permission check** — ensures scripts have `+x` permission
- **JSON lint** — validates all `.json` files have correct syntax ([json-yaml-validate](https://github.com/GrantBirki/json-yaml-validate))

You can run validations locally:

```bash
# Shell scripts
shellcheck skills/*/scripts/*.sh

# JSON
python3 -m json.tool .claude-plugin/marketplace.json
python3 -m json.tool .claude-plugin/plugin.json
```
