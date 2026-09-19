<!-- Global gemini-cli/agy memory file (~/.gemini/GEMINI.md, symlinked here by
     gemini/gemini-install.sh). Same problem this solves for Claude Code's
     default-agent-rules plugin: caveman/superpowers/i-have-adhd/no-ai-slop
     don't auto-fire in agy on their own -
     - caveman + superpowers: files are present (agy plugin list confirms
       both imported from gemini-cli), but caveman's SessionStart hook is
       declared only inside .claude-plugin/plugin.json (Claude's plugin
       format), which the gemini-cli importer doesn't read for hooks - only
       superpowers shipped a separate root hooks.json, so only its hook
       component came through. Importing the skill files directly here
       sidesteps needing agy's hook import to work at all.
     - i-have-adhd: ships disable-model-invocation:true, so it only ever
       activates via manual /i-have-adhd - never automatically.
     - no-ai-slop: no plugin bundle ever existed for it in gemini/agy's
       plugin store (it's a loose Claude skill, nothing to import).

     @imports read live from their source - editing the skill there is
     picked up next session with no separate step to re-sync. -->

@/home/default/.gemini/config/plugins/caveman/skills/caveman/SKILL.md
@/home/default/.gemini/config/plugins/superpowers/skills/using-superpowers/SKILL.md
@/home/default/.claude/skills/i-have-adhd/SKILL.md
@/home/default/.claude/skills/no-ai-slop/SKILL.md
