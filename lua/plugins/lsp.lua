return {

  -- {
  --
  --   -- for lsp features in code cells / embedded code
  --   'jmbuhr/otter.nvim',
  --   dev = false,
  --   dependencies = {
  --     {
  --       'neovim/nvim-lspconfig',
  --       'nvim-treesitter/nvim-treesitter',
  --     },
  --   },
  --   opts = {
  --     verbose = {
  --       no_code_found = false,
  --     },
  --   },
  -- },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { 'saghen/blink.cmp' },
      { -- nice loading notifications
        -- PERF: but can slow down startup
        'j-hui/fidget.nvim',
        enabled = false,
        opts = {},
      },
      {
        {
          'folke/lazydev.nvim',
          ft = 'lua', -- only load on lua files
          opts = {
            library = {
              -- See the configuration section for more details
              -- Load luvit types when the `vim.uv` word is found
              { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
          },
        },
        { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
        -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
      },
      { 'folke/neoconf.nvim', opts = {}, enabled = false },
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local util = require 'lspconfig.util'

      require('mason').setup()
      require('mason-lspconfig').setup {
        automatic_enable = true,
      }
      require('mason-tool-installer').setup {
        ensure_installed = {
          'black',
          'stylua',
          'shfmt',
          'isort',
          'tree-sitter-cli',
          'jupytext',
        },
      }

      vim.lsp.config('lua_ls', { capabilities = capabilities })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local function vmap(keys, func, desc)
            vim.keymap.set('v', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, 'LSP client not found')

          ---@diagnostic disable-next-line: inject-field
          client.server_capabilities.document_formatting = true

          map('gS', vim.lsp.buf.document_symbol, '[g]o so [S]ymbols')
          map('gD', vim.lsp.buf.type_definition, '[g]o to type [D]efinition')
          map('gd', vim.lsp.buf.definition, '[g]o to [d]efinition')
          map('K', vim.lsp.buf.hover, '[K] hover documentation')
          map('gh', vim.lsp.buf.signature_help, '[g]o to signature [h]elp')
          map('gI', vim.lsp.buf.implementation, '[g]o to [I]mplementation')
          map('gr', vim.lsp.buf.references, '[g]o to [r]eferences')
          map('[d', function()
            vim.diagnostic.jump { count = 1 }
          end, 'previous [d]iagnostic ')
          map(']d', function()
            vim.diagnostic.jump { count = -1 }
          end, 'next [d]iagnostic ')
          map('<leader>ll', vim.lsp.codelens.run, '[l]ens run')
          map('<leader>lR', vim.lsp.buf.rename, '[l]sp [R]ename')
          map('<leader>lf', vim.lsp.buf.format, '[l]sp [f]ormat')
          vmap('<leader>lf', vim.lsp.buf.format, '[l]sp [f]ormat')
          map('<leader>lq', vim.diagnostic.setqflist, '[l]sp diagnostic [q]uickfix')
        end,
      })

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }

      -- vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = require('misc.style').border })
      -- vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = require('misc.style').border })
      vim.lsp.buf.hover()
      vim.lsp.buf.signature_help()
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- old: capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- also needs:
      -- $home/.config/marksman/config.toml :
      -- [core]
      -- markdown.file_extensions = ["md", "markdown", "qmd"]
      vim.lsp.config('marksman', {
        capabilities = capabilities,
        filetypes = { 'markdown', 'quarto' },
        root_dir = util.root_pattern('.git', '.marksman.toml', '_quarto.yml'),
      })

      vim.lsp.config('r_language_server', {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          r = {
            lsp = {
              rich_documentation = false,
            },
          },
        },
      })

      vim.lsp.config('cssls', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.config('html', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.config('emmet_language_server', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.config('yamlls', {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = '',
            },
          },
        },
      })

      vim.lsp.config('jsonls', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.config('zls', {
        -- Server-specific settings. See `:help lspconfig-setup`

        -- omit the following line if `zls` is in your PATH
        cmd = { '~/Downloads/zls-macos-aarch64-0.14.0/zls' },
        -- There are two ways to set config options:
        --   - edit your `zls.json` that applies to any editor that uses ZLS
        --   - set in-editor config options with the `settings` field below.
        --
        -- Further information on how to configure ZLS:
        -- https://zigtools.org/zls/configure/
        settings = {
          zls = {
            -- Whether to enable build-on-save diagnostics
            --
            -- Further information about build-on save:
            -- https://zigtools.org/zls/guides/build-on-save/
            -- enable_build_on_save = true,

            -- Neovim already provides basic syntax highlighting
            semantic_tokens = 'partial',

            -- omit the following line if `zig` is in your PATH
            zig_exe_path = '/path/to/zig_executable',
          },
        },
      })

      vim.lsp.config('dotls', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.config('ts_ls', {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'js', 'javascript', 'typescript', 'ojs' },
      })

      local function get_quarto_resource_path()
        local function strsplit(s, delimiter)
          local result = {}
          for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
            table.insert(result, match)
          end
          return result
        end

        local f = assert(io.popen('quarto --paths', 'r'))
        local s = assert(f:read '*a')
        f:close()
        return strsplit(s, '\n')[2]
      end

      local lua_library_files = vim.api.nvim_get_runtime_file('', true)
      local lua_plugin_paths = {}
      local resource_path = get_quarto_resource_path()
      if resource_path == nil then
        vim.notify_once 'quarto not found, lua library files not loaded'
      else
        table.insert(lua_library_files, resource_path .. '/lua-types')
        table.insert(lua_plugin_paths, resource_path .. '/lua-plugin/plugin.lua')
      end

      vim.lsp.config('lua_ls', {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            runtime = {
              version = 'LuaJIT',
              -- plugin = lua_plugin_paths, -- handled by lazydev
            },
            diagnostics = {
              disable = { 'trailing-space' },
            },
            workspace = {
              -- library = lua_library_files, -- handled by lazydev
              checkThirdParty = false,
            },
            doc = {
              privateName = { '^_' },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      vim.lsp.config('vimls', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.config('julials', {
        capabilities = capabilities,
        flags = lsp_flags,
      })

      vim.lsp.config('bashls', {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'sh', 'bash' },
      })

      -- Add additional languages here.
      -- See `:h lspconfig-all` for the configuration.
      -- Like e.g. Haskell:
      -- lspconfig.hls.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags
      -- }

      -- lspconfig.clangd.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }

      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
        settings = {
          ['rust-analyzer'] = {
            diagnostics = {
              enable = false,
            },
          },
        },
      })

      -- lspconfig.ruff_lsp.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }

      -- See https://github.com/neovim/neovim/issues/23291
      -- disable lsp watcher.
      -- Too lags on linux for python projects
      -- because pyright and nvim both create too many watchers otherwise
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      vim.lsp.config('basedpyright', {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace',
            },
          },
        },
        root_dir = function(fname)
          return util.root_pattern('.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt')(fname) or util.path.dirname(fname)
        end,
      })
    end,
  },
}
