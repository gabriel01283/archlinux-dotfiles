vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes'
vim.opt.wrap = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 6
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = 'Salvar' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Sair' })

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local result = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath })
  if vim.v.shell_error ~= 0 then error('Não foi possível instalar lazy.nvim: ' .. result) end
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000, config = function()
    require('catppuccin').setup({ flavour = 'mocha', color_overrides = { mocha = { mauve = '#b48cf2' } } })
    vim.cmd.colorscheme('catppuccin')
  end },
  { 'nvim-tree/nvim-web-devicons', opts = {} },
  { 'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = { theme = 'auto' },
      sections = {
        lualine_x = {
          {
            function() return '󰣇' end,
            color = { fg = '#38BDF8' }
          },
          'encoding'
        }
      }
    }
  },
  { 'nvim-tree/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' }, opts = { view = { width = 32 }, renderer = { group_empty = true } }, keys = { { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'Arquivos' } } },
  { 'nvim-treesitter/nvim-treesitter', branch = 'main', build = ':TSUpdate', config = function()
    local ts = require('nvim-treesitter')
    ts.install({ 'lua', 'vim', 'vimdoc', 'bash', 'css', 'html', 'json', 'python', 'cpp', 'c', 'java', 'javascript', 'typescript' })
    vim.api.nvim_create_autocmd('FileType', { callback = function(args) pcall(vim.treesitter.start, args.buf) end })
  end },
  { 'neovim/nvim-lspconfig', config = function()
    local servers = { 'lua_ls', 'pyright', 'clangd', 'jdtls', 'ts_ls', 'cssls', 'html', 'jsonls', 'bashls' }
    for _, server in ipairs(servers) do vim.lsp.enable(server) end
    vim.diagnostic.config({ virtual_text = true, underline = true, signs = true })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Definição' })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Documentação' })
  end },
  { 'saghen/blink.cmp', version = '1.*', opts = { keymap = { preset = 'default' }, appearance = { nerd_font_variant = 'mono' }, sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } } } },
  { 'folke/which-key.nvim', event = 'VeryLazy', opts = {} },
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, keys = {
    { '<leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Buscar arquivos' },
    { '<leader>fg', function() require('telescope.builtin').live_grep() end, desc = 'Buscar texto' },
    { '<leader>fb', function() require('telescope.builtin').buffers() end, desc = 'Buffers' },
  } },
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  { 'numToStr/Comment.nvim', opts = {} },
  { 'lewis6991/gitsigns.nvim', opts = {} },
}, { install = { colorscheme = { 'catppuccin' } }, checker = { enabled = false } })
