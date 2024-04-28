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

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 10

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
            require('telescope').setup(opts)
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end
    },

    {
        'nvim-treesitter/nvim-treesitter',
        config = function(plugin, opts)
            require('nvim-treesitter').setup(opts)
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
        config = function(plugin, opts)
            -- if opts isn't set for the plugin, the default config implementation does nothing.
            require('Comment').setup(opts)
        end
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            'williamboman/mason.nvim',
            "williamboman/mason-lspconfig.nvim"
        },
        config = function(plugin, opts)
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
                    'lua_ls',
                    'rust_analyzer',
                    'tsserver',
                    'autotools_ls',
                    'terraformls',
                    -- TODO python
                    'pyright',
                },
                -- automatic_installation = true,
            })
        end
    },

})

