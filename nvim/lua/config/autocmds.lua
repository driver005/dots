-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Spellcheck everywhere, not just prose filetypes (Doom's active
-- `spell +flyspell +enchant +everywhere`). LazyVim's own wrap_spell
-- autocmd already covers text/markdown/gitcommit/typst -- left alone.
-- This covers code files too: nvim-treesitter's own highlight queries
-- already tag comment/string nodes @spell and code identifiers @nospell
-- for most languages, so spell=true here stays scoped to comments/strings
-- without denylisting every special filetype -- buftype=="" alone already
-- excludes terminal/oil/help/quickfix/trouble/nofile buffers.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("spell_everywhere", { clear = true }),
  callback = function()
    if vim.bo.buftype == "" then
      vim.opt_local.spell = true
    end
  end,
})

-- Continuous auto-revert (like Emacs' global-auto-revert-mode): LazyVim
-- already :checktime's on FocusGained/TermClose/TermLeave, which catches
-- "I alt-tabbed away and something else changed the file" -- this adds the
-- other half, a file changing on disk while nvim STAYS focused (a build
-- script, git hook, another pane/agent editing the same file), checked on
-- every idle pause instead of waiting for a refocus. `:checktime` itself
-- only ever reloads a buffer that has NO unsaved local changes (same
-- clobber-safety Emacs' auto-revert has); 'autoread' (on by default) is
-- what makes that reload silent instead of a "W11" prompt.
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("continuous_checktime", { clear = true }),
  callback = function()
    if vim.bo.buftype == "" and vim.fn.bufname() ~= "" then
      vim.cmd("checktime")
    end
  end,
})

-- Leaving Trouble (any way at all -- <A-hjkl>, <C-w>*, which-key's own
-- <leader>w numbered window-jump, mouse, ...) opens the currently
-- highlighted item wherever focus lands -- like Emacs occur/grep-mode,
-- moving off the results buffer commits to whatever was under point.
--
-- Tracked WinEnter-side, not WinLeave-side: Trouble's OWN internal "main
-- window" tracking (trouble.nvim's lua/trouble/view/main.lua) works the
-- same way -- WinEnter/BufEnter, never WinLeave -- specifically because
-- reacting on arrival, after a window-switch has *fully completed*, sidesteps
-- every intermediate mechanism that switch might go through (a which-key
-- popup, a multi-step hydra, whatever). Reacting on the LEAVE side instead
-- (tried first) meant racing whatever was still mid-flight, and silently
-- didn't fire when which-key's own nowait <leader>w trigger was involved.
--
-- `left_trouble` is only ever set true right as a trouble window is left,
-- and consumed (reset to false) by the very next WinEnter -- so this never
-- fires for switches that have nothing to do with Trouble.
local left_trouble = false

vim.api.nvim_create_autocmd("WinLeave", {
  group = vim.api.nvim_create_augroup("trouble_track_leave", { clear = true }),
  callback = function()
    left_trouble = vim.bo.filetype == "trouble"
  end,
})

vim.api.nvim_create_autocmd("WinEnter", {
  group = vim.api.nvim_create_augroup("trouble_jump_on_enter", { clear = true }),
  -- nested=true so :edit's own autocmd chain (BufReadPost/FileType/
  -- BufWinEnter) isn't suppressed by already running inside this WinEnter.
  -- (Checked with a canary FileType autocmd: it fired either way in my
  -- sandbox, so this alone wasn't the missing piece -- keeping it anyway,
  -- it's still the correct thing to do when :edit-ing from inside another
  -- autocmd, and costs nothing.)
  nested = true,
  callback = function()
    if not left_trouble then return end
    left_trouble = false

    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    -- Skip landing back on Trouble itself, its preview overlay, or any
    -- float -- only a real destination window counts (mirrors the
    -- validity checks trouble.nvim's own Main._valid() uses).
    if vim.bo[buf].filetype == "trouble" then return end
    if vim.w[win].trouble or vim.w[win].trouble_preview then return end
    if vim.api.nvim_win_get_config(win).relative ~= "" then return end
    if vim.bo[buf].buftype ~= "" then return end

    local ok, trouble_view = pcall(require, "trouble.view")
    if not ok then return end
    for _, v in ipairs(trouble_view.get({ open = true })) do
      local at = v.view:at()
      local item = at and at.item
      if item and item.filename then
        -- Plain :edit, exactly as if typed by hand in this window -- no
        -- bufadd()/bufload()/nvim_win_set_buf() bookkeeping, no
        -- nvim_win_call wrapper. This also fixes item.buf possibly being
        -- Trouble's own preview.scratch=true throwaway nofile buffer (its
        -- "auto_preview"/"follow" stand-in when the real file isn't
        -- loaded yet): :edit always resolves the real, on-disk buffer,
        -- never that stand-in.
        vim.api.nvim_set_current_win(win)
        vim.cmd.edit(vim.fn.fnameescape(item.filename))
        pcall(vim.api.nvim_win_set_cursor, win, item.pos)
        return
      end
    end
  end,
})

-- Trim trailing whitespace on save  (like Doom's `whitespace +trim`)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
  callback = function()
    -- Skip writes triggered by auto-save-visited: it must not reflow code mid-edit
    if vim.b.autosaving then return end
    local ft = vim.bo.filetype
    -- Skip filetypes where trailing whitespace is meaningful
    local skip = { "markdown", "diff", "gitsendemail", "mail" }
    for _, v in ipairs(skip) do
      if ft == v then return end
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Auto-save-visited (like Emacs' auto-save-visited-mode): save modified,
-- file-backed buffers automatically. Never touches oil (buftype=acwrite),
-- terminals, scratch buffers, or files that haven't been saved once already.
do
  local timers = {} ---@type table<integer, uv.uv_timer_t>
  local DELAY_MS = 5000

  local function eligible(buf)
    if not vim.api.nvim_buf_is_valid(buf) then return false end
    if vim.bo[buf].buftype ~= "" then return false end
    if not vim.bo[buf].modifiable or not vim.bo[buf].modified then return false end
    local name = vim.api.nvim_buf_get_name(buf)
    return name ~= "" and vim.fn.filereadable(name) == 1
  end

  local function save(buf)
    if not eligible(buf) then return end
    vim.b[buf].autosaving = true
    vim.api.nvim_buf_call(buf, function()
      pcall(vim.cmd, "silent! update")
    end)
    vim.b[buf].autosaving = false
  end

  local function cancel(buf)
    local t = timers[buf]
    if t then
      t:stop()
      t:close()
      timers[buf] = nil
    end
  end

  local function schedule(buf)
    cancel(buf)
    local t = vim.uv.new_timer()
    timers[buf] = t
    t:start(DELAY_MS, 0, vim.schedule_wrap(function()
      cancel(buf)
      save(buf)
    end))
  end

  local augroup = vim.api.nvim_create_augroup("auto_save_visited", { clear = true })

  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    group = augroup,
    callback = function(ev) schedule(ev.buf) end,
  })

  vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
    group = augroup,
    callback = function(ev)
      cancel(ev.buf)
      save(ev.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    callback = function(ev) cancel(ev.buf) end,
  })
end

-- Restore last session on start, or open *scratch* instead of the dashboard
-- (like Doom's doom/quickload-session + Emacs' *scratch* buffer).
--
-- NOTE: this file is loaded on the `VeryLazy` event, which always fires
-- *after* `VimEnter` -- an autocmd registered here for `VimEnter` would never
-- fire (that event already happened). `vim.schedule` instead runs this once,
-- on the next tick, fully outside VeryLazy's own autocmd nesting, so
-- `persistence.load()`'s `:source` still triggers normal BufReadPost/LSP
-- autocmds for the buffers it restores.
vim.schedule(function()
  if vim.fn.argc() > 0 or vim.o.diff then return end

  local buf = vim.api.nvim_get_current_buf()
  local wins = vim.api.nvim_list_wins()
  if #wins ~= 1 or vim.bo[buf].modified or vim.api.nvim_buf_get_name(buf) ~= "" then
    return
  end
  if vim.api.nvim_buf_line_count(buf) > 1 or (vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "") ~= "" then
    return -- something (e.g. piped stdin) already put text in the buffer
  end
  local uis = vim.api.nvim_list_uis()
  if uis[1] and uis[1].stdout_tty and not uis[1].stdin_tty then
    return -- stdin is piped: not a plain "start with nothing" launch
  end

  local persistence = require("persistence")
  local session = persistence.current()
  if vim.fn.filereadable(session) == 1 then
    persistence.load()
    return
  end

  -- No session to restore: *scratch* buffer instead of the dashboard
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "lua"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "-- *scratch*",
    "-- This buffer is for text that is not saved to disk. Use it for notes or Lua.",
    "",
  })
  vim.bo[buf].modified = false
end)
