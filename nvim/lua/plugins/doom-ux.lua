-- doom-ux.lua
-- Ports Doom Emacs UX behaviours to LazyVim:
--
--   1. Overseer: <leader>or  → re-run last task without picker (like recompile)
--   2. LSP code action: <leader>ca  → auto-apply when only 1 action, else picker
--   3. oil.nvim: "-" → open parent dir as editable buffer  (like dired-jump)
--      • dotfiles always visible  (like dired-listing-switches "-algho")
--      • <leader>- opens cwd  (mirrors Doom SPC -)

-- ── 1. Overseer: re-run last task ─────────────────────────────────────────
return {
  {
    "stevearc/overseer.nvim",
    optional = true,
    keys = {
      {
        "<leader>or",
        function()
          local overseer = require("overseer")
          local tasks = overseer.list_tasks({ recent_first = true })
          if vim.tbl_isempty(tasks) then
            vim.cmd("OverseerRun") -- nothing to rerun, open picker
          else
            tasks[1]:restart(true)
          end
        end,
        desc = "Re-run last task",
      },
    },
  },

  -- ── 2. LSP code action: auto-apply when exactly 1 result ────────────────
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("doom_ux_code_action", { clear = true }),
        callback = function(ev)
          local function smart_code_action()
            local bufnr = ev.buf
            local win = vim.api.nvim_get_current_win()
            local cursor = vim.api.nvim_win_get_cursor(win) -- {row, col}, 1-indexed row
            local lnum = cursor[1] - 1                       -- 0-indexed

            -- Collect diagnostics on this line for the codeAction context
            local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
            local lsp_diags = vim.tbl_map(function(d)
              return vim.diagnostic.toqflist({ d })[1] and d or d
            end, diags)

            local params = vim.lsp.util.make_range_params(win, "utf-8")
            params.context = {
              diagnostics = vim.tbl_map(function(d)
                return {
                  range = {
                    start = { line = d.lnum, character = d.col },
                    ["end"] = { line = d.end_lnum or d.lnum, character = d.end_col or d.col },
                  },
                  message = d.message,
                  severity = d.severity,
                  source = d.source,
                }
              end, lsp_diags),
              only = nil, -- all kinds
            }

            vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(results)
              -- Flatten results from all clients into one list
              local actions = {}
              for _, res in pairs(results) do
                if res.result then
                  for _, a in ipairs(res.result) do
                    table.insert(actions, a)
                  end
                end
              end

              if vim.tbl_isempty(actions) then
                vim.notify("No code actions available", vim.log.levels.INFO)
                return
              end

              if #actions == 1 then
                -- Single action: apply immediately
                local action = actions[1]
                local client_id = (function()
                  for id, res in pairs(results) do
                    if res.result then
                      for _, a in ipairs(res.result) do
                        if a == action then return id end
                      end
                    end
                  end
                end)()
                local client = client_id and vim.lsp.get_client_by_id(client_id)
                if action.edit then
                  vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                end
                if action.command then
                  local cmd = type(action.command) == "table" and action.command or action
                  if client then
                    client:exec_cmd(cmd, { bufnr = bufnr })
                  else
                    vim.lsp.buf.execute_command(cmd)
                  end
                end
                -- Some actions need a resolve step first
                if not action.edit and not action.command and client and client:supports_method("codeAction/resolve") then
                  client:request("codeAction/resolve", action, function(_, resolved)
                    if resolved then
                      if resolved.edit then
                        vim.lsp.util.apply_workspace_edit(resolved.edit, "utf-8")
                      end
                      if resolved.command then
                        client:exec_cmd(resolved.command, { bufnr = bufnr })
                      end
                    end
                  end, bufnr)
                end
              else
                -- Multiple actions: show normal picker
                vim.lsp.buf.code_action()
              end
            end)
          end

          vim.keymap.set(
            { "n", "x" },
            "<leader>ca",
            smart_code_action,
            { buffer = ev.buf, silent = true, desc = "Code Action (auto if single)" }
          )
        end,
      })
    end,
  },

  -- ── 3. oil.nvim ───────────────────────────────────────────────────────────
  -- Dired-jump, multi-pane preview, flat view, expand-dir-to-files
  --
  --  NAVIGATION
  --   -          open parent dir of current file  (dired-jump)
  --   <leader>-  open cwd
  --   <leader>E  fullscreen float + auto-preview panel
  --   h / <Left> go up to parent dir
  --   l / <CR>   enter dir or open file
  --
  --  EXTRA ACTIONS (inside oil buffer)
  --   <Tab>      open every file inside dir under cursor (like dirvish-fd expand)
  --   gf         flat recursive listing of cwd via fd/find  (toggle)
  --   <C-p>      toggle preview panel (split right, full height)
  --   <C-d>/<C-u> scroll preview down/up
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      default_file_explorer = true,
      -- Dotfiles always visible  (like dired -algho)
      view_options = {
        show_hidden = true,
        is_hidden_file = function() return false end,
      },
      -- Dired-style long listing
      columns = { "icon", "permissions", "size", "mtime" },
      -- Auto-update preview when cursor moves
      preview_win = {
        update_on_cursor_moved = true,
        preview_method = "fast_scratch",
        win_options = { wrap = false },
      },
      -- Preview split to the right, width = remaining columns after oil
      float = {
        preview_split = "right",
      },
      keymaps = {
        ["l"]     = "actions.select",
        ["h"]     = "actions.parent",
        ["<CR>"]  = "actions.select",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["gs"]    = "actions.change_sort",
        ["gx"]    = "actions.open_external",
        ["g."]    = "actions.toggle_hidden",
        ["g?"]    = "actions.show_help",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-d>"] = {
          desc = "Scroll preview down",
          callback = function()
            local util = require("oil.util")
            local winid = util.get_preview_win()
            if winid then
              local old_win = vim.api.nvim_get_current_win()
              vim.api.nvim_set_current_win(winid)
              vim.cmd("normal! \x04")
              vim.api.nvim_set_current_win(old_win)
            end
          end,
        },
        ["<C-u>"] = {
          desc = "Scroll preview up",
          callback = function()
            local util = require("oil.util")
            local winid = util.get_preview_win()
            if winid then
              local old_win = vim.api.nvim_get_current_win()
              vim.api.nvim_set_current_win(winid)
              vim.cmd("normal! \x15")
              vim.api.nvim_set_current_win(old_win)
            end
          end,
        },
        ["<C-r>"] = "actions.refresh",
        ["q"]     = "actions.close",

        -- ── Tab: list all files inside the dir under cursor ──────────────
        ["<Tab>"] = {
          desc = "List child files in Trouble",
          callback = function()
            local oil = require("oil")
            local entry = oil.get_cursor_entry()
            if not entry or entry.type ~= "directory" then
              require("oil.actions").select.callback()
              return
            end
            local target_dir = oil.get_current_dir() .. entry.name
            local cmd = vim.fn.executable("fd") == 1
              and { "fd", "--type", "f", "--hidden", ".", target_dir }
              or  { "find", target_dir, "-type", "f" }
            local files = vim.fn.systemlist(cmd)
            if vim.tbl_isempty(files) then
              vim.notify("No files in " .. entry.name, vim.log.levels.INFO)
              return
            end

            oil.close()
            local items = {}
            for _, f in ipairs(files) do
              table.insert(items, {
                filename = f,
                lnum = 1,
                col = 1,
                text = f,
                type = "",
                valid = 1,
              })
            end
            vim.fn.setqflist({}, " ", { title = "Files in " .. entry.name, items = items })
            require("trouble").open({ mode = "qflist" })
          end,
        },

        -- ── gf: flat recursive listing of cwd in Trouble ───────────────
        ["gf"] = {
          desc = "List cwd files in Trouble",
          callback = function()
            local oil = require("oil")
            local cwd = oil.get_current_dir() or vim.uv.cwd()
            local cmd = vim.fn.executable("fd") == 1
              and { "fd", "--type", "f", "--hidden", ".", cwd }
              or  { "find", cwd, "-type", "f" }
            local files = vim.fn.systemlist(cmd)
            if vim.tbl_isempty(files) then
              vim.notify("No files found", vim.log.levels.WARN)
              return
            end

            oil.close()
            local items = {}
            for _, f in ipairs(files) do
              table.insert(items, {
                filename = f,
                lnum = 1,
                col = 1,
                text = f,
                type = "",
                valid = 1,
              })
            end
            vim.fn.setqflist({}, " ", { title = "Flat CWD", items = items })
            require("trouble").open({ mode = "qflist" })
          end,
        },
      },
      use_default_keymaps = false,
    },

    config = function(_, opts)
      require("oil").setup(opts)

      -- Auto-open preview when entering an oil window
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilEnter",
        group = vim.api.nvim_create_augroup("doom_oil_preview", { clear = true }),
        callback = function(args)
          local oil = require("oil")
          if vim.api.nvim_get_current_buf() ~= args.data.buf then return end
          -- Open preview split to the right
          oil.open_preview({
            vertical = true, -- side-by-side split; splitright=true puts it on the right
          })
          -- Resize oil win to ~40% width, preview gets the rest
          local oil_win = vim.api.nvim_get_current_win()
          -- Only resize if it's not a floating window (oil's float has its own dimensions)
          if vim.api.nvim_win_get_config(oil_win).relative == "" then
            vim.api.nvim_win_set_width(oil_win, math.floor(vim.o.columns * 0.40))
          end
        end,
      })
    end,

    keys = {
      { "-",          function() require("oil").open() end,            desc = "Open parent dir (oil)" },
      { "<leader>-",  function() require("oil").open(vim.uv.cwd()) end, desc = "Open cwd (oil)" },
      { "<leader>E",  function() require("oil").open() end,            desc = "Oil in current window" },
    },
  },
}

