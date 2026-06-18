return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "MeanderingProgrammer/render-markdown.nvim",
      "3ZsForInsomnia/code-companion-picker",
      "3ZsForInsomnia/vs-code-companion",
      "ravitemer/codecompanion-history.nvim",
      "Davidyz/codecompanion-dap.nvim",
      -- "Davidyz/VectorCode", -- commented out, replaced by octocode
      "mrjones2014/codecompanion-ui.nvim",
    },
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionActions",
      "CodeCompanionCLI",
      "CodeCompanionCmd",
      "CodeCompanionPrompts",
      "CodeCompanionHistory",
      "CodeCompanionSummaries",
    },
    event = "VeryLazy",

    opts = function()
      return {
        adapter = function()
          if vim.fn.executable("claude-agent-acp") == 1 then
            return require("codecompanion.adapters").use("acp", "claude_code")
          else
            return require("codecompanion.adapters").use("acp", "opencode")
          end
        end,
        adapters = {
          acp = {
            claude_code = function()
              return require("codecompanion.adapters").extend("claude_code", {
                defaults = {
                  -- Inherit MCP servers from your ~/.config/mcp/servers.json
                  mcpServers = "inherit_from_config",
                  -- Set default session config options
                  session_config_options = {
                    mode = "default",
                  },
                },
              })
            end,
            opencode = function()
              return require("codecompanion.adapters").extend("opencode", {
                defaults = {
                  mcpServers = "inherit_from_config",
                },
              })
            end,
          },
        },
        rules = {
          global_skills = {
            description = "Global agent skills (~/.claude/skills/ + ~/.config/opencode/skills/)",
            parser = "claude",
            files = {
              { path = vim.fn.expand("~/.claude/skills"), files = "*/SKILL.md" },
              { path = vim.fn.expand("~/.config/opencode/skills"), files = "*/SKILL.md" },
            },
          },
          project_skills = {
            description = "Project-local agent skills (.claude/skills/ or .opencode/skills/)",
            parser = "claude",
            enabled = function()
              local cwd = vim.fn.getcwd()
              return vim.fn.isdirectory(cwd .. "/.claude/skills") == 1
                or vim.fn.isdirectory(cwd .. "/.opencode/skills") == 1
            end,
            files = {
              { path = vim.fn.getcwd() .. "/.claude/skills", files = "*/SKILL.md" },
              { path = vim.fn.getcwd() .. "/.opencode/skills", files = "*/SKILL.md" },
            },
          },
          default = {
            description = "Standard AI rules files",
            is_preset = true,
            files = {
              ".clinerules",
              ".cursorrules",
              ".goosehints",
              ".rules",
              ".windsurfrules",
              ".github/copilot-instructions.md",
              "AGENT.md",
              "AGENTS.md",
              { path = "CLAUDE.md", parser = "claude" },
              { path = "CLAUDE.local.md", parser = "claude" },
              { path = "~/.claude/CLAUDE.md", parser = "claude" },
              { path = "~/.config/opencode/AGENTS.md" },
              -- ── Always-on skills ──────────────────────────────────
              { path = "~/.claude/skills/caveman/SKILL.md", parser = "claude" },
              { path = "~/.claude/skills/octocode/SKILL.md", parser = "claude" },
            },
          },
          opts = {
            chat = {
              autoload = function()
                local groups = { "default", "global_skills" }
                local cwd = vim.fn.getcwd()
                if
                  vim.fn.isdirectory(cwd .. "/.claude/skills") == 1
                  or vim.fn.isdirectory(cwd .. "/.opencode/skills") == 1
                then
                  table.insert(groups, "project_skills")
                end
                return groups
              end,
              enabled = true,
            },
          },
        },
        interactions = {
          chat = {
            adapter = "claude_code",
            opts = {
              completion_provider = "blink",
              prompt_decorator = function(message)
                return ("<prompt>%s</prompt>"):format(message)
              end,
              context_management = {
                enabled = function(adapter)
                  return adapter.type == "http"
                end,
                trigger = 0.75,
              },
            },
            slash_commands = {
              ["file"] = { opts = { provider = "snacks" } },
              ["buffer"] = { opts = { provider = "snacks" } },
              ["image"] = {
                enabled = function(opts)
                  return opts.adapter.opts and opts.adapter.opts.vision == true
                end,
              },
              ["xmake_targets"] = {
                description = "Insert xmake build targets",
                callback = function(chat)
                  local handle = io.popen("xmake show -l targets 2>/dev/null")
                  if handle then
                    local result = handle:read("*a")
                    handle:close()
                    chat:add_context(
                      { role = "user", content = "xmake targets:\n" .. result },
                      "xmake",
                      "<xmake_targets>"
                    )
                  end
                end,
                opts = { contains_code = false },
              },
              ["xmake_build"] = {
                description = "Insert last xmake build output (errors, warnings, diagnostics)",
                callback = function(chat)
                  local log_paths = {
                    vim.fn.getcwd() .. "/.xmake/build.log",
                    vim.fn.getcwd() .. "/.xmake/cache/build.log",
                  }
                  local result = nil
                  for _, path in ipairs(log_paths) do
                    local f = io.open(path, "r")
                    if f then
                      result = f:read("*a")
                      f:close()
                      break
                    end
                  end
                  if not result or result == "" then
                    local handle = io.popen("xmake build 2>&1")
                    if handle then
                      result = handle:read("*a")
                      handle:close()
                    end
                  end
                  if result and result ~= "" then
                    chat:add_context(
                      { role = "user", content = "xmake build output:\n```\n" .. result .. "\n```" },
                      "xmake",
                      "<xmake_build>"
                    )
                  else
                    vim.notify("No xmake build output found", vim.log.levels.WARN)
                  end
                end,
                opts = { contains_code = true },
              },
              ["project_index"] = {
                description = "Insert a structured index of the project (dirs, source files, build files)",
                callback = function(chat)
                  local cwd = vim.fn.getcwd()
                  local lines = { "Project root: " .. cwd, "" }

                  local handle = io.popen("git ls-files 2>/dev/null")
                  local git_files = handle and handle:read("*a") or ""
                  if handle then
                    handle:close()
                  end

                  if git_files ~= "" then
                    local dirs = {}
                    local dir_files = {}
                    for filepath in git_files:gmatch("[^\n]+") do
                      local dir = filepath:match("^(.*)/") or "."
                      if not dir_files[dir] then
                        dir_files[dir] = {}
                        table.insert(dirs, dir)
                      end
                      table.insert(dir_files[dir], filepath:match("[^/]+$"))
                    end
                    table.sort(dirs)
                    table.insert(lines, "## Source tree (git-tracked)")
                    for _, dir in ipairs(dirs) do
                      table.insert(lines, "  " .. dir .. "/")
                      for _, fname in ipairs(dir_files[dir]) do
                        table.insert(lines, "    " .. fname)
                      end
                    end
                  else
                    table.insert(lines, "## Source tree (find fallback)")
                    local fh = io.popen(
                      "find . -type f \\( -name '*.cpp' -o -name '*.cppm' -o -name '*.h' "
                        .. "-o -name '*.hpp' -o -name '*.lua' -o -name '*.py' -o -name '*.rs' "
                        .. "-o -name 'xmake.lua' -o -name 'CMakeLists.txt' -o -name 'Makefile' \\) "
                        .. "-not -path '*/.git/*' -not -path '*/build/*' -not -path '*/.xmake/*' "
                        .. "2>/dev/null | sort"
                    )
                    if fh then
                      local out = fh:read("*a")
                      fh:close()
                      for l in out:gmatch("[^\n]+") do
                        table.insert(lines, "  " .. l)
                      end
                    end
                  end

                  local xmake_f = io.open(cwd .. "/xmake.lua", "r")
                  if xmake_f then
                    xmake_f:close()
                    local th = io.popen("xmake show -l targets 2>/dev/null")
                    if th then
                      local targets = th:read("*a")
                      th:close()
                      if targets ~= "" then
                        table.insert(lines, "")
                        table.insert(lines, "## xmake targets")
                        for t in targets:gmatch("[^\n]+") do
                          table.insert(lines, "  " .. t)
                        end
                      end
                    end
                  end

                  chat:add_context({ role = "user", content = table.concat(lines, "\n") }, "project", "<project_index>")
                  vim.notify("Project index added to chat", vim.log.levels.INFO)
                end,
                opts = { contains_code = false },
              },
              ["octocode"] = {
                description = "Semantic search via octocode knowledge graph",
                callback = function(chat)
                  local query = vim.fn.input("Octocode search: ")
                  if query == "" then
                    return
                  end
                  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
                  vim.system({ "octocode", "search", query, "--output", "json" }, { cwd = root }, function(result)
                    vim.schedule(function()
                      if result.code == 0 and result.stdout ~= "" then
                        chat:add_context(
                          { role = "user", content = "Octocode results:\n" .. result.stdout },
                          "octocode",
                          "<octocode_search>"
                        )
                      else
                        vim.notify("Octocode search failed: " .. (result.stderr or ""), vim.log.levels.WARN)
                      end
                    end)
                  end)
                end,
                opts = { contains_code = true },
              },
              -- /codebase VectorCode slash command commented out
              -- ["codebase"] = (function() ... end)(),
            },
            tools = {
              ["insert_edit_into_file"] = { opts = { requires_approval = true } },
              ["create_file"] = { opts = { requires_approval = true } },
              ["delete_file"] = { opts = { requires_approval = true } },
              ["run_command"] = { opts = { requires_approval = true } },
              -- ── LSP navigation tool ──────────────────────────────────
              ["lsp_navigate"] = {
                description = "Navigate code via LSP: get_definition, get_references, get_implementations",
                callback = function(chat, params)
                  local action = (params or {}).action or "definition"
                  local method_map = {
                    definition = "textDocument/definition",
                    references = "textDocument/references",
                    implementation = "textDocument/implementation",
                  }
                  local method = method_map[action]
                  if not method then
                    chat:add_message({ role = "tool", content = "Unknown action: " .. action })
                    return
                  end
                  local bufnr = vim.api.nvim_get_current_buf()
                  local lsp_params = vim.lsp.util.make_position_params()
                  if action == "references" then
                    lsp_params.context = { includeDeclaration = true }
                  end
                  vim.lsp.buf_request(bufnr, method, lsp_params, function(err, result)
                    if err then
                      chat:add_message({ role = "tool", content = "LSP error: " .. err.message })
                      return
                    end
                    if not result or #result == 0 then
                      chat:add_message({ role = "tool", content = "No " .. action .. " found" })
                      return
                    end
                    local out = {}
                    for _, loc in ipairs(result) do
                      local uri = loc.uri or loc.targetUri
                      local range = loc.range or loc.targetSelectionRange
                      local path = vim.fn.fnamemodify(vim.uri_to_fname(uri), ":.")
                      table.insert(out, ("%s:%d:%d"):format(path, range.start.line + 1, range.start.character + 1))
                    end
                    chat:add_message({
                      role = "tool",
                      content = action .. ":\n" .. table.concat(out, "\n"),
                    })
                  end)
                end,
                opts = { requires_approval = false },
              },
            },
            keymaps = {
              options = {
                modes = { n = "?" },
                callback = function()
                  local ok, wk = pcall(require, "which-key")
                  if ok then
                    wk.show({ global = false })
                  end
                end,
                description = "Show chat keymaps",
                hide = true,
              },
            },
          },
          inline = { adapter = "claude_code" },
          cmd = { adapter = "claude_code" },
          background = {
            adapter = "claude_code",
            chat = {
              callbacks = {
                ["on_ready"] = {
                  actions = { "interactions.background.builtin.chat_make_title" },
                  enabled = false,
                },
              },
              opts = { enabled = false },
            },
          },
          cli = {
            agent = "claude_code",
            agents = {
              claude_code = { cmd = "claude", args = {}, description = "Claude Code CLI", provider = "terminal" },
              opencode = { cmd = "opencode", args = {}, description = "OpenCode agent", provider = "terminal" },
            },
          },
        },
        shared = {
          keymaps = {
            always_accept = { callback = "keymaps.always_accept", modes = { n = "ga" } },
            accept_change = { callback = "keymaps.accept_change", modes = { n = "g=" } },
            reject_change = { callback = "keymaps.reject_change", modes = { n = "gR" } },
            next_hunk = { callback = "keymaps.next_hunk", modes = { n = "]h" } },
            previous_hunk = { callback = "keymaps.previous_hunk", modes = { n = "[h" } },
          },
        },
        opts = {
          triggers = {
            acp_slash_commands = "/", -- use / not \ so /mode /command /compact /resume work
            editor_context = "#",
            slash_commands = "/",
            tools = "@",
          },
          system_prompt = function(adapter)
            local base = [[
You are an expert programmer and software engineer working inside Neovim.

## Code style
  * Write idiomatic code for the language in use -- infer it from context
  * Fix problems at the abstraction boundary; never patch individual call sites
  * Prefer the simplest correct solution; avoid over-engineering
  * Match the conventions already present in the surrounding code

## Response style
  * Be concise -- prefer code over prose
  * Think before suggesting a refactor; only propose changes that improve
    correctness, clarity, or performance in a meaningful way
  * When fixing a bug, explain the root cause in one sentence
  * When producing a file, output only the file content unless asked otherwise]]
            if adapter then
              local name = adapter.name or ""
              if name:find("gemini") or name:find("sonnet") then
                return base .. "\n\nNote: you have a large context window -- use it when relevant."
              end
            end
            return base
          end,
          log_level = "ERROR",
          send_code = true,
        },
        display = {
          chat = {
            view = "float",
            show_settings = true,
            show_token_count = true,
            window = {
              layout = "vertical",
              full_height = true,
              position = "right",
              width = 0.38,
              border = "rounded",
              opts = { breakindent = true, linebreak = true, wrap = true },
            },
            floating_window = {
              width = function()
                return math.floor(vim.o.columns * 0.72)
              end,
              height = function()
                return math.floor(vim.o.lines * 0.84)
              end,
              row = function()
                return math.floor((vim.o.lines - math.floor(vim.o.lines * 0.84)) / 2)
              end,
              col = function()
                return math.floor((vim.o.columns - math.floor(vim.o.columns * 0.72)) / 2)
              end,
              relative = "editor",
              border = "rounded",
            },
            roles = {
              llm = function(a)
                return (" %s"):format(a.formatted_name or a.name)
              end,
              user = "  You",
            },
          },
          action_palette = { provider = "snacks", show_preset_prompts = true },
          diff = {
            enabled = true,
            threshold_for_chat = 8,
            word_highlights = { additions = true, deletions = true },
            window = { number = true, relativenumber = false },
            layout = "vertical",
          },
        },

        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_tools = true,
              show_server_tools_in_chat = true,
              add_mcp_prefix_to_tool_names = false,
              show_result_in_chat = true,
              make_vars = false,
              make_slash_commands = true,
            },
          },
          history = {
            enabled = true,
            opts = {
              keymap = "gh",
              save_chat_keymap = "sc",
              auto_save = true,
              expiration_days = 0,
              picker = "snacks",
              chat_filter = function(chat_data)
                return chat_data.cwd == vim.fn.getcwd()
              end,
              picker_keymaps = {
                rename = { n = "r", i = "<M-r>" },
                delete = { n = "d", i = "<M-d>" },
                duplicate = { n = "<C-y>", i = "<C-y>" },
              },
              auto_generate_title = true,
              title_generation_opts = {
                adapter = nil,
                model = nil,
                refresh_every_n_prompts = 3,
                max_refreshes = 5,
              },
              continue_last_chat = false,
              delete_on_clearing_chat = false,
              dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
              enable_logging = false,
              summary = {
                create_summary_keymap = "gcs",
                browse_summaries_keymap = "gbs",
                generation_opts = {
                  adapter = nil,
                  model = nil,
                  context_size = 90000,
                  include_references = true,
                  include_tool_outputs = true,
                },
              },
              memory = {
                auto_create_memories_on_summary_generation = true,
                -- vectorcode_exe = vim.g.vectorcode_cli_cmd or "vectorcode", -- commented out
                tool_opts = { default_num = 10 },
                notify = true,
                index_on_startup = false,
              },
            },
          },
          -- vectorcode extension commented out — replaced by octocode
          -- vectorcode = {
          --   opts = {
          --     tool_group = { enabled = true, collapse = false },
          --     tool_opts = {
          --       ["*"] = { use_lsp = false, requires_approval = false },
          --       query = {
          --         default_num = { chunk = 50, document = 10 },
          --         max_num = { chunk = -1, document = -1 },
          --         no_duplicate = true,
          --         chunk_mode = false,
          --       },
          --       vectorise = { requires_approval = true },
          --     },
          --   },
          -- },
          -- ── codecompanion-ui: separate input buffer with winbar ───────
          ui = {
            enabled = true,
            opts = {
              focus = "input",
              input = {
                height = 10,
                placeholder = "Type your message…",
                winbar = {
                  {
                    component = "mode",
                    icons = {
                      default = "󰺴",
                      acceptEdits = "󱐋",
                      plan = "󰙬",
                      dontAsk = "󰝟",
                      bypassPermissions = "",
                    },
                  },
                  { component = "adapter" },
                  { component = "model" },
                  {
                    component = "spinner",
                    interval_ms = 100,
                    frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                  },
                },
              },
            },
          },
          -- filewise disabled: lyaml incompatible with LuaJIT
          custom_instructions = { enabled = false },
          custom_modes = { enabled = false },
          custom_prompts = { enabled = false },
        },

        prompt_library = {
          ["Explain"] = {
            interaction = "chat",
            description = "Explain selected code",
            opts = { modes = { "v" }, short_name = "explain", auto_submit = true, mapping = "<leader>ape" },
            prompts = {
              {
                role = "user",
                content = function(ctx)
                  local ft = vim.bo[ctx.bufnr].filetype
                  local fence = ft ~= "" and ("```" .. ft) or "```"
                  return "Explain this code, noting any non-obvious idioms or patterns:\n\n"
                    .. fence
                    .. "\n"
                    .. require("codecompanion.helpers.actions").get_code(ctx)
                    .. "\n```"
                end,
              },
            },
          },
          ["Refactor"] = {
            interaction = "inline",
            description = "Refactor selection to idiomatic style for its language",
            opts = { modes = { "v" }, short_name = "refactor", auto_submit = true, mapping = "<leader>apr" },
            prompts = {
              {
                role = "system",
                content = "Refactor the code to idiomatic style for its language. Return ONLY code, no prose.",
              },
              {
                role = "user",
                content = function(ctx)
                  local ft = vim.bo[ctx.bufnr].filetype
                  local fence = ft ~= "" and ("```" .. ft) or "```"
                  return fence .. "\n" .. require("codecompanion.helpers.actions").get_code(ctx) .. "\n```"
                end,
              },
            },
          },
          ["Write Tests"] = {
            interaction = "chat",
            description = "Generate tests for selected code",
            opts = { modes = { "v" }, short_name = "gen_tests", auto_submit = true, mapping = "<leader>apt" },
            prompts = {
              {
                role = "system",
                content = "Write tests for the provided code using the idiomatic test framework for its language. "
                  .. "Return only the test file.",
              },
              {
                role = "user",
                content = function(ctx)
                  local ft = vim.bo[ctx.bufnr].filetype
                  local fence = ft ~= "" and ("```" .. ft) or "```"
                  return fence .. "\n" .. require("codecompanion.helpers.actions").get_code(ctx) .. "\n```"
                end,
              },
            },
          },
          ["Fix Diagnostics"] = {
            interaction = "inline",
            description = "Fix LSP diagnostics in this buffer",
            opts = { short_name = "fix_diag", auto_submit = true, mapping = "<leader>apd" },
            prompts = {
              {
                role = "user",
                content = function(ctx)
                  local diags = vim.diagnostic.get(ctx.bufnr)
                  if #diags == 0 then
                    return "No diagnostics found."
                  end
                  local msgs = {}
                  for _, d in ipairs(diags) do
                    table.insert(msgs, ("Line %d [%s]: %s"):format(d.lnum + 1, d.source or "lsp", d.message))
                  end
                  local ft = vim.bo[ctx.bufnr].filetype
                  local fence = ft ~= "" and ("```" .. ft) or "```"
                  return "Fix these diagnostics:\n"
                    .. table.concat(msgs, "\n")
                    .. "\n\n"
                    .. fence
                    .. "\n"
                    .. table.concat(vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, false), "\n")
                    .. "\n```"
                end,
              },
            },
          },
          ["Implement"] = {
            interaction = "inline",
            description = "Implement a function/method from its declaration or stub",
            opts = { modes = { "v" }, short_name = "implement", auto_submit = true, mapping = "<leader>api" },
            prompts = {
              {
                role = "system",
                content = "Implement the declaration or stub. Match the language and style of the surrounding code. "
                  .. "Return ONLY the implementation, no prose.",
              },
              {
                role = "user",
                content = function(ctx)
                  local ft = vim.bo[ctx.bufnr].filetype
                  local fence = ft ~= "" and ("```" .. ft) or "```"
                  return fence .. "\n" .. require("codecompanion.helpers.actions").get_code(ctx) .. "\n```"
                end,
              },
            },
          },
          ["Review"] = {
            interaction = "chat",
            description = "Review for correctness, style and performance",
            opts = { modes = { "v" }, short_name = "review", auto_submit = true, mapping = "<leader>apv" },
            prompts = {
              {
                role = "user",
                content = function(ctx)
                  local ft = vim.bo[ctx.bufnr].filetype
                  local fence = ft ~= "" and ("```" .. ft) or "```"
                  return "Review for correctness, idiomatic style, and performance. "
                    .. "Flag bugs, unsafe patterns, and API misuse:\n\n"
                    .. fence
                    .. "\n"
                    .. require("codecompanion.helpers.actions").get_code(ctx)
                    .. "\n```"
                end,
              },
            },
          },
          ["Commit Message"] = {
            interaction = "chat",
            description = "Write a conventional commit message from staged diff",
            opts = { short_name = "commit_msg", auto_submit = true, mapping = "<leader>apg" },
            prompts = {
              {
                role = "user",
                content = function()
                  local diff = vim.fn.system("git diff --cached")
                  if diff == "" then
                    return "No staged changes found."
                  end
                  return "Write a conventional commit message:\n```diff\n" .. diff .. "\n```"
                end,
              },
            },
          },
        },
      }
    end,

    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle chat" },
      { "<leader>an", "<cmd>CodeCompanionChat<cr>", mode = { "n" }, desc = "New chat" },
      { "<leader>ac", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "Inline prompt" },
      { "<leader>ab", "<cmd>CodeCompanionChat Add<cr>", mode = { "v" }, desc = "Add selection to chat" },
      {
        "<leader>aw",
        function()
          local cc = require("codecompanion")
          local chat = cc.last_chat and cc.last_chat()
          if not chat then
            vim.notify("No active chat — open one first", vim.log.levels.WARN)
            return
          end
          local bufnr = vim.api.nvim_get_current_buf()
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
          local ft = vim.bo[bufnr].filetype
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local fence = ft ~= "" and ("```" .. ft) or "```"
          chat:add_context(
            { role = "user", content = fence .. "\n" .. table.concat(lines, "\n") .. "\n```" },
            "buffer",
            ("<buffer:%s>"):format(name)
          )
          vim.notify(("Added %s to chat"):format(name), vim.log.levels.INFO)
        end,
        mode = { "n" },
        desc = "Add buffer to chat",
      },
      {
        -- Rename the current chat session (persisted by the history extension)
        "<leader>aT",
        function()
          local cc = require("codecompanion")
          local chat = cc.last_chat and cc.last_chat()
          if not chat then
            vim.notify("No active chat", vim.log.levels.WARN)
            return
          end
          local current = (chat.opts and chat.opts.title) or ""
          vim.ui.input({ prompt = "Chat title: ", default = current }, function(title)
            if not title or title == "" then
              return
            end
            -- Persist via the history extension if available
            local ext = require("codecompanion").extensions
            if ext and ext.history and ext.history.rename_chat then
              ext.history.rename_chat(chat, title)
            else
              -- Fallback: set on the chat opts directly
              chat.opts = chat.opts or {}
              chat.opts.title = title
            end
            vim.notify(("Chat titled: %s"):format(title), vim.log.levels.INFO)
          end)
        end,
        mode = { "n" },
        desc = "Set chat title",
      },
      { "<leader>aP", "<cmd>CodeCompanionPrompts<cr>", mode = { "n", "v" }, desc = "Prompt picker" },
      { "<leader>ape", mode = { "v" }, desc = "Explain" },
      { "<leader>apr", mode = { "v" }, desc = "Refactor" },
      { "<leader>apt", mode = { "v" }, desc = "Write tests" },
      { "<leader>api", mode = { "v" }, desc = "Implement" },
      { "<leader>apv", mode = { "v" }, desc = "Review" },
      { "<leader>apd", mode = { "n" }, desc = "Fix diagnostics" },
      { "<leader>apg", mode = { "n" }, desc = "Commit message" },
      { "<leader>ah", "<cmd>CodeCompanionHistory<cr>", mode = { "n" }, desc = "Chat history" },
      {
        "<leader>aS",
        function()
          local ext = require("codecompanion").extensions
          if ext and ext.history and ext.history.generate_summary then
            ext.history.generate_summary()
          else
            vim.notify("History extension not loaded", vim.log.levels.WARN)
          end
        end,
        mode = { "n" },
        desc = "Generate chat summary",
      },
      { "<leader>aA", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Action palette" },
      { "<leader>al", "<cmd>CodeCompanionCLI<cr>", mode = { "n" }, desc = "Claude Code CLI" },
      { "<leader>am", "<cmd>MCPHub<cr>", mode = { "n" }, desc = "MCP hub" },
      {
        "<leader>as",
        function()
          local skill_dirs = {
            vim.fn.expand("~/.claude/skills"),
            vim.fn.expand("~/.config/opencode/skills"),
            vim.fn.getcwd() .. "/.claude/skills",
            vim.fn.getcwd() .. "/.opencode/skills",
          }
          local skills = {}
          for _, dir in ipairs(skill_dirs) do
            for _, path in ipairs(vim.fn.glob(dir .. "/*/SKILL.md", false, true)) do
              local name = vim.fn.fnamemodify(path, ":h:t")
              local lines = vim.fn.readfile(path, "", 20)
              local desc = ""
              for _, line in ipairs(lines) do
                local d = line:match("^description:%s*(.+)")
                if d then
                  desc = d:gsub('^"', ""):gsub('"$', "")
                  break
                end
              end
              table.insert(skills, { name = name, path = path, desc = desc })
            end
          end
          if #skills == 0 then
            vim.notify("No skills found.\nCreate ~/.claude/skills/<name>/SKILL.md", vim.log.levels.WARN)
            return
          end
          vim.ui.select(skills, {
            prompt = "Load skill into chat:",
            format_item = function(s)
              return s.name .. (s.desc ~= "" and ("  -- " .. s.desc) or "")
            end,
          }, function(choice)
            if not choice then
              return
            end
            local cc = require("codecompanion")
            local chat = cc.last_chat and cc.last_chat()
            if not chat then
              vim.cmd("CodeCompanionChat")
              vim.defer_fn(function()
                chat = cc.last_chat and cc.last_chat()
                if chat then
                  local content = table.concat(vim.fn.readfile(choice.path), "\n")
                  chat:add_context({ role = "user", content = content }, "skill", ("<skill:%s>"):format(choice.name))
                  vim.notify("Skill loaded: " .. choice.name, vim.log.levels.INFO)
                end
              end, 300)
              return
            end
            local content = table.concat(vim.fn.readfile(choice.path), "\n")
            chat:add_context({ role = "user", content = content }, "skill", ("<skill:%s>"):format(choice.name))
            vim.notify("Skill loaded: " .. choice.name, vim.log.levels.INFO)
          end)
        end,
        mode = { "n" },
        desc = "Load skill",
      },
    },

    config = function(_, opts)
      -- Only setup vs-code-companion if inside a git repo
      local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
      if git_root and git_root ~= "" then
        require("vs-code-companion").setup({
          directories = { ".github/prompts", ".github/chatmodes" },
        })
      end

      require("code-companion-picker").setup({ picker = "snacks" })
      require("codecompanion").setup(opts)

      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({
          { "<leader>a", group = "AI / CodeCompanion", icon = "󰈸" },
          { "<leader>ap", group = "Prompts", icon = "" },
        })
      end
      vim.cmd([[
        cab cc   CodeCompanion
        cab ccc  CodeCompanionChat
        cab cca  CodeCompanionActions
        cab ccp  CodeCompanionPrompts
        cab cch  CodeCompanionHistory
      ]])

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionChatCreated",
        desc = "Register per-chat callbacks: compression, tool output truncation, picker",
        callback = function(ev)
          local chat = require("codecompanion").buf_get_chat(ev.data.bufnr)
          if not chat then
            return
          end

          -- ── Context window warning + auto-compress at 85% ────────────
          chat:add_callback("on_checkpoint", function(_, data)
            local ctx_win = data.adapter.meta and data.adapter.meta.context_window
            if not ctx_win then
              return
            end
            local pct = data.estimated_tokens / ctx_win

            -- Warn at 80%
            if pct > 0.80 then
              vim.notify(
                ("CodeCompanion: context %.0f%% full (%d / %d tokens)"):format(
                  pct * 100,
                  data.estimated_tokens,
                  ctx_win
                ),
                vim.log.levels.WARN
              )
            end

            -- Auto-compress at 85% via history extension summarisation
            if pct > 0.85 then
              local ok_ext, ext = pcall(function()
                return require("codecompanion").extensions.history
              end)
              if ok_ext and ext and ext.generate_summary then
                ext.generate_summary()
                vim.notify(
                  ("CodeCompanion: auto-summarising at %.0f%% context — start fresh chat after"):format(pct * 100),
                  vim.log.levels.INFO
                )
              else
                -- Fallback: naive in-place compression when history ext unavailable
                if data.messages and #data.messages > 8 then
                  local keep_last = 6
                  local to_compress = #data.messages - keep_last
                  if to_compress > 0 then
                    local parts = {}
                    for i = 1, to_compress do
                      local msg = data.messages[i]
                      if msg and type(msg.content) == "string" and msg.content ~= "" then
                        table.insert(parts, ("[%s]: %s"):format(msg.role or "?", msg.content:sub(1, 600)))
                      end
                    end
                    if #parts > 0 then
                      local summary = {
                        role = "system",
                        content = "## Compressed history\n\n" .. table.concat(parts, "\n\n---\n\n"),
                      }
                      local kept = { summary }
                      for i = to_compress + 1, #data.messages do
                        table.insert(kept, data.messages[i])
                      end
                      for i = #data.messages, 1, -1 do
                        data.messages[i] = nil
                      end
                      for i, msg in ipairs(kept) do
                        data.messages[i] = msg
                      end
                      vim.notify(
                        ("CodeCompanion: compressed %d messages at %.0f%% context"):format(to_compress, pct * 100),
                        vim.log.levels.INFO
                      )
                    end
                  end
                end
              end
            end
          end)

          -- ── Truncate large tool outputs ───────────────────────────────
          chat:add_callback("on_tool_output", function(_, data)
            local max_chars = 60000
            if data.for_llm and #data.for_llm > max_chars then
              data.for_llm = data.for_llm:sub(1, max_chars) .. "\n\n[Output truncated]"
              data.for_user = data.for_llm
              vim.notify(
                ("CodeCompanion: tool output from '%s' truncated"):format(data.tool or "?"),
                vim.log.levels.WARN
              )
            end
          end)

          -- ── Prompt picker slash command ───────────────────────────────
          local ok_picker, picker = pcall(require, "code-companion-picker")
          if ok_picker and chat.slash_commands then
            chat.slash_commands["prompts"] = picker.select_slash_command
          end
        end,
      })
    end,
  },
}
