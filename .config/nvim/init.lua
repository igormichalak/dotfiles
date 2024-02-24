--[[

Simple, yet powerful Neovim config.
Partly based on the great "kickstart.nvim".

--------------------------------------

Language/format support:

Full (with LSP):
C, C++, CSS, Dart, Go, HTML, JavaScript, JSDoc, Lua, OCaml, Odin, Templ, TypeScript, TSX

Syntax (only Treesitter):
Astro, Bash, Dockerfile, GLSL, HCL, Nix, Regex, SQL, Terraform, WGSL

--]]

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_material_better_performance = 1

vim.o.encoding = 'utf-8'
vim.o.number = true
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
vim.o.updatetime = 500
vim.o.timeoutlen = 800
vim.o.termguicolors = true
vim.o.background = 'light'
vim.o.completeopt = 'menuone,noselect'
vim.o.tabstop = 4

local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.5' })
Plug 'nvim-telescope/telescope-file-browser.nvim'

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'

Plug('L3MON4D3/LuaSnip', { tag = 'v2.*' })
Plug 'saadparwaiz1/cmp_luasnip'

Plug 'windwp/nvim-autopairs'
Plug 'windwp/nvim-ts-autotag'
Plug 'tpope/vim-surround'
Plug 'numToStr/Comment.nvim'

Plug 'tpope/vim-sleuth'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

Plug 'sainnhe/gruvbox-material'

vim.call('plug#end')

vim.cmd('colorscheme gruvbox-material')

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.api.nvim_set_keymap(
    'n',
    '<leader>fb',
    ':Telescope file_browser<CR>',
    { noremap = true }
)
vim.api.nvim_set_keymap(
    'n',
    '<leader>fc',
    ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
    { noremap = true }
)

require('telescope').setup {
    extensions = {
        file_browser = {
            hijack_netrw = true,
        },
    },
}

require('telescope').load_extension "file_browser"

local function find_git_root()
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir
    local cwd = vim.fn.getcwd()
    if current_file == '' then
        current_dir = cwd
    else
        current_dir = vim.fn.fnamemodify(current_file, ':h')
    end

    local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
    if vim.v.shell_error ~= 0 then
        print 'Not a git repository. Searching on current working directory'
        return cwd
    end
    return git_root
end

local function live_grep_git_root()
    local git_root = find_git_root()
    if git_root then
        require('telescope.builtin').live_grep {
            search_dirs = { git_root },
        }
    end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>?', builtin.oldfiles, {})
vim.keymap.set('n', '<leader><space>', builtin.buffers, {})
vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, {})

local function telescope_live_grep_open_files()
    builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files'
    }
end

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, {})
vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fw', builtin.grep_string, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fG', ':LiveGrepGitRoot<CR>', {})
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>fr', builtin.resume, {})

vim.defer_fn(function()
    require('nvim-treesitter.configs').setup {
        ensure_installed = {
            'astro', 'bash', 'c', 'cpp', 'css', 'dart',
            'dockerfile', 'glsl', 'go', 'hcl', 'html', 'javascript',
            'jsdoc', 'lua', 'nix', 'ocaml', 'odin', 'regex',
            'sql', 'templ', 'terraform', 'typescript', 'tsx', 'wgsl',
        },
        sync_install = false,
        auto_install = false,
        ignore_install = {},
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<C-space>',
                node_incremental = '<C-space>',
                scope_incremental = '<C-s>',
                node_decremental = '<M-space>',
            },
        },
        indent = {
            enable = true,
        },
        textobjects = {
            select = {
                enable = true,
                lookahead = true,
                keymaps = {
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    ['ic'] = '@class.inner',
                },
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    [']]'] = '@function.outer',
                },
                goto_next_end = {
                    [']['] = '@function.outer',
                },
                goto_previous_start = {
                    ['[['] = '@function.outer',
                },
                goto_previous_end = {
                    ['[]'] = '@function.outer',
                },
            },
            swap = {
                enable = true,
                swap_next = {
                    ['<leader>a'] = '@parameter.inner',
                },
                swap_previous = {
                    ['<leader>A'] = '@parameter.inner',
                },
            },
            lsp_interop = {
                enable = true,
                border = 'none',
                floating_preview_opts = {},
                peek_definition_code = {
                    ['<leader>df'] = '@function.outer',
                    ['<leader>dF'] = '@class.outer',
                },
            },
        },
    }
end, 0)

require('treesitter-context').setup {}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local lspconfig = require('lspconfig')

lspconfig.clangd.setup { capabilities = capabilities }
lspconfig.cssls.setup { capabilities = capabilities }
lspconfig.dartls.setup { capabilities = capabilities }

lspconfig.eslint.setup {
    capabilities = capabilities,
    on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            command = 'EslintFixAll',
        })
    end,
}

lspconfig.gopls.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.tsserver.setup { capabilities = capabilities }

lspconfig.lua_ls.setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            workspace = { checkThirdParty = 'Disable' },
            telemetry = { enable = false },
            diagnostics = {
                globals = { 'vim' },
            },
        },
    },
}

lspconfig.ocamllsp.setup { capabilities = capabilities }
lspconfig.ols.setup { capabilities = capabilities }
lspconfig.templ.setup { capabilities = capabilities }

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>fm', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})

local cmp = require('cmp')
local luasnip = require('luasnip')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    completion = {
        completeopt = 'menu,menuone,noinsert',
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
    },
}

require('luasnip.loaders.from_snipmate').lazy_load()

require('nvim-autopairs').setup {}
require('nvim-ts-autotag').setup {}
require('Comment').setup()
