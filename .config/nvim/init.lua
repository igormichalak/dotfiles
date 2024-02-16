vim.o.encoding = 'utf-8'
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 5
vim.o.hlsearch = false

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.smartindent = true

local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'tpope/vim-fugitive'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug('nvim-treesitter/nvim-treesitter', { ["do"] = ':TSUpdate' })

Plug 'neovim/nvim-lspconfig'

vim.call('plug#end')

local lspconfig = require'lspconfig'

lspconfig['lua_ls'].setup{}
lspconfig['clangd'].setup{}

