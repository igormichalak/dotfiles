vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.encoding = 'utf-8'
vim.o.relativenumber = true
vim.o.scrolloff = 5
vim.o.hlsearch = false
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.termguicolors = true
vim.o.completeopt = 'menuone,noselect'
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.smartindent = true

local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'

Plug('nvim-treesitter/nvim-treesitter', { ["do"] = ':TSUpdate' })
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'

Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

Plug 'windwp/nvim-autopairs'
Plug 'numToStr/Comment.nvim'

Plug 'tpope/vim-sleuth'
Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'lewis6991/gitsigns.nvim'

Plug 'shaunsingh/solarized.nvim'
Plug 'nvim-lualine/lualine.nvim'

vim.call('plug#end')

require('solarized').set()
