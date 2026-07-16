# Global Instructions

- Do not create helper functions that are only referenced once unless explicitly asked.
- When working on a branch stack, analyze the stack first and decide which commit/branch a change logically belongs on before making it.
- After amending a branch in a stack, rebase the dependent branches to keep the stack consistent.
- When switching from plan mode to build mode, save the plan to `.plan/` in the project root as a markdown file named after the task (e.g. `.plan/add-auth-to-settings.md`). Create the `.plan/` directory if it does not exist. This directory is globally gitignored.
