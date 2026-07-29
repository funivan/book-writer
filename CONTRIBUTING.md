# Contributing

## Project structure

```
book-writer/
  .agents/
    skills.json              # Antigravity workspace skills config
    plugins/
      book-writer/
        plugin.json          # Antigravity workspace plugin metadata
  .antigravity-plugin/
    plugin.json              # Antigravity plugin metadata
  .claude-plugin/
    plugin.json              # Plugin metadata
    marketplace.json         # Marketplace catalog
  .codex-plugin/
    plugin.json              # Codex plugin metadata
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
- **JSON lint** — validates all `.json` files have correct syntax with `python3 -m json.tool`

You can run validations locally:


```bash
# Shell scripts
shellcheck skills/*/scripts/*.sh

# JSON
python3 -m json.tool .agents/skills.json
python3 -m json.tool .agents/plugins/book-writer/plugin.json
python3 -m json.tool .antigravity-plugin/plugin.json
python3 -m json.tool .claude-plugin/marketplace.json
python3 -m json.tool .claude-plugin/plugin.json
python3 -m json.tool .codex-plugin/plugin.json
```

## Developing for a new agent

Skills live in `skills/<skill-name>/SKILL.md` and are agent-agnostic — each agent reads them via its own plugin adapter. To add support for a new agent:

1. **Create a plugin config directory** named after the agent convention (e.g. `.myagent-plugin/`).
2. **Add a `plugin.json`** that declares the plugin name, version, description, author, and a pointer to the `skills/` directory. Use one of the existing files (e.g. `.codex-plugin/plugin.json`) as a template.
3. **Register the skills directory** according to the agent's plugin spec:
   - If the agent supports a `skills` key in `plugin.json`, point it at `"./skills/"`.
   - If the agent uses a JavaScript/TypeScript plugin entry point (like opencode), create a plugin file in `.myagent/plugins/` that resolves the `skills/` path and registers it at startup. See `.opencode/plugins/book-writer.js` for an example.
   - If the agent uses a workspace config file (like Antigravity's `.agents/skills.json`), add an equivalent config that lists the `skills/` directory.
4. **Update `README.md`** with an installation section for the new agent, including the exact command(s) users must run.
5. **Update `CONTRIBUTING.md`** (this file) — add the new `plugin.json` to the JSON lint list in the CI section.
6. **Validate JSON** with `python3 -m json.tool .myagent-plugin/plugin.json` and run the full CI suite locally before opening a PR.

### Key files per agent

| Agent | Config location | Skills pointer |
|-------|----------------|----------------|
| Claude Code | `.claude-plugin/plugin.json` | Marketplace-resolved, skills in `skills/` |
| Codex | `.codex-plugin/plugin.json` | `"skills": "./skills/"` |
| Antigravity | `.antigravity-plugin/plugin.json` | `"skills": "./skills/"` |
| opencode | `.opencode/plugins/book-writer.js` | Resolved at runtime via `import.meta.dirname` |
