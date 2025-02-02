-- ------------------ --
-- NeoVim Config file --
-- ------------------ --
-- Catppuccin theme
-- Treesitter, CMP, LSP, Luasnip
-- Telescope
-- Lualine
-- Tree (file tree)
-- Menu
-- Alpha (startify)

-- ------------------ --
-- Usefull Key binds  --
-- ------------------ --
-- When in Tree
--  "a" = create file
--  "d" = delete file
--  "r" = rename file
--  "enter" = open 
--  "q" = close
--  "x" = cut file
--  "p" = paste file
--  "Ctrl+b" = toggle the tree
-- Telescope
--  "<space> ff" = find file
--  "<space> fg" = live grep



vim.cmd("set ruler")
vim.cmd("let g:loaded_perl_provider = 0")
vim.fn.setenv("CC", "gcc")
vim.cmd("set number")
vim.cmd("set showmatch")

-- vim.cmd("set keymodel=startsel,stopsel")

local opts = { noremap = true, silent = true }

-- Move in normal mode with "kloĹŻ"
vim.api.nvim_set_keymap('n', 'k', 'h', opts)
vim.api.nvim_set_keymap('n', 'l', 'j', opts)
vim.api.nvim_set_keymap('n', 'o', 'k', opts)
vim.api.nvim_set_keymap('n', 'ĹŻ', 'l', opts)
vim.api.nvim_set_keymap('v', 'k', 'h', opts)
vim.api.nvim_set_keymap('v', 'l', 'j', opts)
vim.api.nvim_set_keymap('v', 'o', 'k', opts)
vim.api.nvim_set_keymap('v', 'ĹŻ', 'l', opts)

-- Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.diagnostic.config({
	update_in_insert = true
})

-- ---------------- --
-- Download plugins --
-- ---------------- --
local plugins = {
	{"catppuccin/nvim", name = "catppuccin", priority = 1000},
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	{'hrsh7th/nvim-cmp'},
	{"williamboman/nvim-lsp-installer"},
	{'neovim/nvim-lspconfig',dependencies = {{'hrsh7th/nvim-cmp'},{'j-hui/fidget.nvim', opts = {} }}},
	{"hrsh7th/cmp-nvim-lsp"},
	{"saadparwaiz1/cmp_luasnip"},
	{'L3MON4D3/LuaSnip'},
	{'nvim-telescope/telescope.nvim', tag = '0.1.8',dependencies = { 'nvim-lua/plenary.nvim' }},
	{'nvim-lualine/lualine.nvim',dependencies = { 'nvim-tree/nvim-web-devicons' }},
	{"nvim-tree/nvim-tree.lua",version = "*",lazy = false,dependencies = {"nvim-tree/nvim-web-devicons"}},
	{"nvzone/volt" , lazy = true },
	{"nvzone/menu" , lazy = true },
	{'goolord/alpha-nvim', dependencies = { 'echasnovski/mini.icons' }}
}
local opts = {}


-- ------------- --
-- Setup plugins --
-- ------------- --
require("lazy").setup(plugins, opts)
require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"
local ts_configs = require("nvim-treesitter.configs")
ts_configs.setup({
          ensure_installed = {"python", "c", "lua"},
	  sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  
        })
require("nvim-lsp-installer").setup {
	automatic_installation = true,
	ui = {
        icons = {
            server_installed = "G",
            server_pending = ".",
            server_uninstalled = "X"
        }
    }
}
-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = {'pyright'}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
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
  },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })


require('lualine').setup()
require("nvim-tree").setup()
vim.api.nvim_set_keymap('n', '<C-b>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Keyboard users
vim.keymap.set("n", "<C-t>", function()
  require("menu").open("default")
end, {})

-- mouse users + nvimtree users!
vim.keymap.set("n", "<RightMouse>", function()
  vim.cmd.exec '"normal! \\<RightMouse>"'

  local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options, { mouse = true })
end, {})

require'alpha'.setup(require'alpha.themes.startify'.config)
