vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.encoding = 'utf-8'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.breakindent = true
vim.opt.scrolloff = 10

vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
end)
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split'
vim.opt.cursorline = true

vim.opt.termguicolors = true
vim.opt.background = 'light'
vim.opt.completeopt = 'menuone,noselect'

vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_material_better_performance = 1

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'Makefile', 'go' },
    callback = function()
        vim.bo.expandtab = false
    end,
});

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true, noremap = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { silent = true, noremap = true })

vim.keymap.set('n', '<C-h>',  '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>',  '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>',  '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>',  '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({
        'git', 'clone', '--filter=blob:none', '--branch=stable',
        lazyrepo, lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
            { out, 'WarningMsg' },
            { '\nPress any key to exit...' },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    { 'windwp/nvim-autopairs', opts = {} },
    { 'windwp/nvim-ts-autotag', opts = {} },
    'tpope/vim-surround',
    { 'numToStr/Comment.nvim', opts = {} },
    'tpope/vim-sleuth',
    {
        'sainnhe/gruvbox-material',
        priority = 1000,
        init = function()
            vim.cmd.colorscheme 'gruvbox-material'
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
        config = function()
            require('telescope').setup {}

            pcall(require('telescope').load_extension, 'fzf')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>?', builtin.oldfiles, {
                desc = 'Search Recent Files',
            })
            vim.keymap.set('n', '<leader><space>', builtin.buffers, {
                desc = 'Find existing buffers'
            })
            vim.keymap.set('n', '<leader>/', function()
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, { desc = 'Fuzzily search in current buffer' })

            local function live_grep_git_root()
                local git_root = find_git_root()
                if git_root then
                    require('telescope.builtin').live_grep {
                        search_dirs = { git_root },
                    }
                end
            end
            vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

            local function telescope_live_grep_open_files()
                builtin.live_grep {
                    grep_open_files = true,
                    prompt_title = 'Live Grep in Open Files',
                }
            end
            vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, {
                desc = 'Search in Open Files',
            })

            vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search Help' })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search Keymaps' })
            vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search Files' })
            vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Search current Word' })
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search by Grep' })
            vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search Git Files' })
            vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<CR>', { desc = 'Search Git Root' })
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search Diagnostics' })
            vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search Resume' })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs',
        opts = {
            ensure_installed = {
                'bash', 'c', 'cpp', 'dockerfile', 'glsl', 'go',
                'lua', 'ocaml', 'sql', 
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
            },
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
    },
    {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {},
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
    },
})
