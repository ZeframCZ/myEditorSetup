vim.cmd("set ruler")
vim.cmd("let g:loaded_perl_provider = 0")
vim.fn.setenv("CC", "gcc")

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


local plugins = {
	{"catppuccin/nvim", name = "catppuccin", priority = 1000},
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
	{'hrsh7th/nvim-cmp'},
	{"williamboman/nvim-lsp-installer"},
	{'neovim/nvim-lspconfig',dependencies = {{'hrsh7th/nvim-cmp'},{'j-hui/fidget.nvim', opts = {} }}},
	{"hrsh7th/cmp-nvim-lsp"},
	{"saadparwaiz1/cmp_luasnip"},
	{'L3MON4D3/LuaSnip'}
		
}
local opts = {}

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



--require('lspconfig').pyright.setup({})

--require('cmp').setup({})





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
