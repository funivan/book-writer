import fs from "node:fs"
import path from "node:path"

// Resolve skills/ relative to this plugin file so the plugin also works when it is
// symlinked into ~/.config/opencode/plugins/ from a book-writer checkout.
const SKILLS_DIR = path.resolve(import.meta.dirname, "..", "..", "skills")

/**
 * Registers the book-writer skills directory with opencode.
 * See https://opencode.ai/docs/plugins/
 */
export const BookWriter = async () => {
  return {
    config: async (config) => {
      if (!fs.existsSync(SKILLS_DIR)) return
      const skills = new Set(config.skills ?? [])
      skills.add(SKILLS_DIR)
      config.skills = [...skills]
    },
  }
}
