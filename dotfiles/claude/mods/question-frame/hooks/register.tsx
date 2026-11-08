import type { Register } from 'claude-code'

// Catppuccin Mocha mauve, matching the prismantis settings in ~/.claude/settings.json
const FRAME = '#cba6f7'

// Wraps Claude's question dialog in a rounded frame; the dialog itself is untouched.
export const register: Register = on => {
  on('ui.render', { component: 'AskUserQuestion' }, async ($, e, next) => {
    const engine = await next(e)
    const { Box } = $.ui.resolve(e)

    return (
      <Box flexDirection="column" borderStyle="round" borderColor={FRAME} paddingX={1}>
        {engine}
      </Box>
    )
  })
}
