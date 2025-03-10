vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', vim.cmd['nohlsearch'], {})  -- cancel current search result highlighting with Esc

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.showmode = false
vim.opt.fixendofline = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 10

-- navigating through buffer list
vim.keymap.set('n', 'th', '<cmd>:bprev<CR>', { desc = "previous buffer" })
vim.keymap.set('n', 'tl', '<cmd>:bnext<CR>', { desc = "next buffer" })
vim.keymap.set('n', 'td', '<cmd>:bdelete<CR>', { desc = "delete buffer" })
-- quicker way to bring up telescope buffer picker (quicker than <leader>fb)
vim.keymap.set('n', 'te', '<cmd>:Telescope buffers<CR>', { desc = "telescope find buffer" })

-- navigating through quickfix list
vim.keymap.set('n', '<M-j>', '<cmd>:cnext<CR>', { desc = "quickfix next" })
vim.keymap.set('n', '<M-k>', '<cmd>:cprev<CR>', { desc = "quickfix previous" })

-- open Oil (directory editor) on parent directory of current file
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

if vim.g.vscode then
    -- https://github.com/vscode-neovim/vscode-neovim/wiki/Version-Compatibility-Notes
    vim.opt.shortmess:append('s')
end

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- initialize lazy package manager; clone it first if it hasn't been yet
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- concatenate arrays
local function concat(...)
    local res = {}
    for _, arr in pairs({...}) do
        for _,v in pairs(arr) do
            table.insert(res, v)
        end
    end
    return res
end

-- create a no-args function that calls fn with some args
local function fn_with_args(fn, ...)
    local args = { ... }
    local arg_count = select("#", ...)
    return function()
        return fn(unpack(args, 1, arg_count))
    end
end

require("lazy").setup({

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.opt.timeout = true
            vim.opt.timeoutlen = 500
        end,
        opts = {
            triggers_nowait = {}
        },
    },
    -- TODO look into https://github.com/folke/which-key.nvim/issues/243 => https://github.com/mrjones2014/legendary.nvim

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
        },
        config = function(plugin, opts)
            require('catppuccin').setup(opts)
            vim.cmd.colorscheme "catppuccin"
        end
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            options = {
                icons_enabled = false,
                theme = 'dracula',
                -- empty separators instead of the default special glyphs that would require font installations
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
            },
            sections = {
                lualine_a = { { 'mode', fmt = function(str) return str:sub(1,1) end } },
                lualine_c = { {
                    'buffers',
                    buffers_color = {
                        active = { bg = '#33aa88' },
                    },
                } },
            },
        },
    },

    {
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                dpelete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },

    'tpope/vim-fugitive',

    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function(plugin, opts)
            require('telescope').setup({
                pickers = {
                    find_files = {
                        hidden = true
                    }
                }
            })

            local vimgrep_std_args = require("telescope.config").values.vimgrep_arguments

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "telescope find files" })
            vim.keymap.set('n', '<leader>fg',
                fn_with_args(builtin.live_grep, { vimgrep_arguments = concat(vimgrep_std_args, {"--hidden", "--no-ignore"}) }),
                { desc = "telescope grep" })
            vim.keymap.set('n', '<leader>fi', builtin.live_grep, { desc = "telescope git grep" })
            vim.keymap.set('n', '<leader>fd',
                fn_with_args(builtin.live_grep, { search_dirs = {vim.env.HOME .. "/doc/mydocs"} }),
                { desc = "telescope grep through ~/doc/mydocs" })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "telescope find buffers" })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "telescope find tags" })
            vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols, { desc = "telescope find workspace symbols" })
            vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = "telescope find commands" })
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "telescope find keymaps" })
        end
    },

    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",
        config = function()
            require('nvim-treesitter').setup()
            local configs = require('nvim-treesitter.configs')
            configs.setup {
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "go", "bash", "java", "javascript", "json", "jsonnet", "html", "gotmpl", "typescript" },
                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,
                highlight = {
                    enable = true,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn", -- set to `false` to disable one of the mappings
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
            }
        end
    },

    {
        'numToStr/Comment.nvim',
        lazy = false,
        opts = {}
    },

    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
    },

    'saadparwaiz1/cmp_luasnip',

    'rafamadriz/friendly-snippets',

    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {},
        config = function(_, opts) require'lsp_signature'.setup(opts) end
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            'williamboman/mason.nvim',
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-buffer",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local function on_attach(client, bufnr)
                -- Set up buffer-local keymaps (vim.api.nvim_buf_set_keymap()), etc.
                local opts = { noremap = true, silent = true }
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "v", "<C-k>", "<cmd>lua vim.lsp.buf.range_code_action()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>s", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "single" })<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "single" })<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
                vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
                -- nvim also has some builtin "jump to tag" functionality that predates LSPs (was using ctags originally),
                -- and it uses the vim option "tagfunc" which must be a function that jumps to the tag under the cursor.
                -- It's mapped to Ctrl-].
                -- nvim's LSP support sets tagfunc to point to lua.vim.lsp.tagfunc, which is glue code that ends up calling
                -- lua vim.lsp.buf.definition() I think. So Ctrl-] will also jump to definition just like gd does.
                -- see https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#configuration

                -- indent file on save -- TODO too intrusive rn; try to restrict it to added & changed lines from the git diff
                -- if client.supports_method('textDocument/formatting') then
                --     vim.api.nvim_create_autocmd('BufWritePre', {
                --         desc = 'indent file on save',
                --         buffer = bufnr,
                --         callback = function()
                --             vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
                --         end,
                --     })
                -- end

                require 'lsp_signature'.on_attach({
                    bind = true,
                    floating_window_above_cur_line = true,
                    max_width = 120,
                    hi_parameter = 'Cursor',
                    hint_enable = false,
                    handler_opts = {
                        border = 'single'
                    }
                }, bufnr)
            end

            -- just set all dependencies up in here as well
            -- require('nvim-lspconfig')  -- nvim-lspconfig itself doesn't have a module?
            require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'ansiblels',
                    'bashls',
                    'clangd',
                    'cssls',
                    'dockerls',
                    'docker_compose_language_service',
                    'gopls',
                    'gitlab_ci_ls',
                    'html',
                    'lua_ls',
                    'rust_analyzer',
                    'tsserver',
                    'autotools_ls',
                    'terraformls',
                    'pyright',
                    'marksman',
                },
                automatic_installation = true,

                -- handlers - define what to do when any of the above (ensure_installed) LSs needs to be set up
                -- see :h mason-lspconfig.setup_handlers()
                handlers = {
                    -- default (fallback) handler
                    function(server_name)
                        require('lspconfig')[server_name].setup({
                            on_attach = on_attach,
                        })
                    end,

                    ['lua_ls'] = function()
                        require('lspconfig').lua_ls.setup {
                            on_attach = on_attach,

                            -- from :help lspconfig-all /lua_ls
                            -- TODO investigate https://github.com/folke/neodev.nvim
                            on_init = function(client)
                                -- local path = client.workspace_folders[1].name
                                -- if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
                                --     return
                                -- end

                                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                                    runtime = {
                                        -- Tell the language server which version of Lua you're using
                                        -- (most likely LuaJIT in the case of Neovim)
                                        version = 'LuaJIT'
                                    },
                                    -- Make the server aware of Neovim runtime files
                                    workspace = {
                                        checkThirdParty = false,
                                        library = {
                                            vim.env.VIMRUNTIME,
                                            vim.env.HOME .. '/.local/share/nvim',
                                            -- Depending on the usage, you might want to add additional paths here.
                                            -- "${3rd}/luv/library"
                                            -- "${3rd}/busted/library",
                                        }
                                        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                                        -- library = vim.api.nvim_get_runtime_file("", true)
                                    }
                                })
                            end,
                            settings = {
                                Lua = {}
                            }

                        }
                    end
                },
            })

            require("luasnip.loaders.from_vscode").lazy_load()

            local cmp = require('cmp')

            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup {
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                -- the cmp.config.sources() adds a group_index field to each source,
                -- which is then used by cmp for prioritizing. See :h cmp-config.sources\[n\].group_index
                sources = cmp.config.sources({
                    {
                        name = 'nvim_lsp'
                    },
                }, {
                    {
                        name = 'buffer',
                        option = {
                            get_bufnrs = function()
                                local buf = vim.api.nvim_get_current_buf()
                                local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                                if byte_size > 1024 * 1024 then -- 1 Megabyte max
                                    return {}
                                end
                                return { buf }
                            end
                        },
                    },
                    {
                        name = "path"
                    },
                    {
                        name = "luasnip"
                    },
                }),

                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
                    end,
                }
            }

            vim.diagnostic.config({
                -- update_in_insert = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end
    },

    'dhruvasagar/vim-table-mode',

    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            view_options = {
                -- Show files and directories that start with "."
                show_hidden = true,
            },
            git = {
                -- Return true to automatically git add/mv/rm files
                add = function(path)
                    return true
                end,
                mv = function(src_path, dest_path)
                    return true
                end,
                rm = function(path)
                    return true
                end,
            },
        },
        -- Optional dependencies
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
    },

    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'theHamsta/nvim-dap-virtual-text',
            'nvim-neotest/nvim-nio',
            'rcarriga/nvim-dap-ui',
        },
        config = function ()
            local dap = require('dap')
            local ui = require('dapui')

            ui.setup()

            -- TODO I don't fully understand what's happening here. The adapter must really be named "pwa-node"
            -- to enable the dap adapter with that name, which is provided by dapDebugServer.js.
            -- I always thought this name was just a freely chosen name to connect the adapters to the configurations.
            -- TODO use dap-vscode-js to create the adapters rather than doing it manually
            -- see https://github.com/anasrar/.dotfiles/blob/fdf4b88dfd2255b90f03c62dfc0f3f9458dc99a9/neovim/.config/nvim/lua/rin/DAP/languages/typescript.lua
            -- TODO look into https://github.com/jay-babu/mason-nvim-dap.nvim which should automate the setup even more
            -- also see https://www.youtube.com/watch?v=Ul_WPhS2bis
            -- TODO better UI and icons etc. see https://www.lazyvim.org/extras/dap/core#nvim-dap
            -- TODO maybe different keymaps with <leader>d.. and which-key integration
            dap.adapters['pwa-node'] = {
                type = "server",
                host = 'localhost',
                port = "${port}",
                executable = {
                    command = "node",
                    args = {"/home/olaf/Downloads/js-debug/src/dapDebugServer.js", "${port}"}, -- TODO download/clone automatically using lazy
                }
            }

            dap.configurations.javascript = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach to node.js processs",
                    processId = require('dap.utils').pick_process,  -- TODO find the process listening on localhost:9229 (a node run with --inspect-wait)
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                },
            }

            vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
            vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

            -- Eval var under cursor
            vim.keymap.set("n", "<leader>?", function()
                ---@diagnostic disable-next-line: missing-fields
                ui.eval(nil, { enter = true })
            end)

            vim.keymap.set("n", "<F1>", dap.continue)
            vim.keymap.set("n", "<F7>", dap.step_into)
            vim.keymap.set("n", "<F8>", dap.step_over)
            vim.keymap.set("n", "<F4>", dap.step_out)
            vim.keymap.set("n", "<F5>", dap.step_back)
            vim.keymap.set("n", "<F12>", dap.restart)

            dap.listeners.before.attach.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                ui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                ui.close()
            end
        end
    },

})

vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = {"markdown"},
    command = "TableModeEnable",
})
