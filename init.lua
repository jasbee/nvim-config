--------------------------------------------------------------------------------
-- Steps to install on Linux:
--------------------------------------------------------------------------------
-- 1) In your home dir `git clone https://github.com/jasbee/nvim-config.git`
-- 2) `mkdir -p ~/.config && ln -s ~/nvim-config ~/.config/nvim`
--    (if ~/.config/nvim already exists, move it aside first:
--    `mv ~/.config/nvim ~/.config/nvim.bak`)
-- 3) Start nvim. lazy.nvim and the plugins install on first launch.
-- 4) Language servers install automatically, but Mason and clipboard need these dependencies:
--    `sudo dnf install nodejs npm wl-clipboard`
--    For extra shell script checks, also run `:MasonInstall shellcheck`
--
-- Extras: to edit root-owned files with this config, run
--   `sudoedit example.file` instead of `sudo nvim example.file`
-- (add `export EDITOR=nvim` to ~/.bashrc so sudoedit uses nvim)

--------------------------------------------------------------------------------
-- Suggested top of lua file changes from nvim-tree
--------------------------------------------------------------------------------
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--------------------------------------------------------------------------------
-- Plugin manager: lazy.nvim
-- Installs itself on first run and auto-installs any missing plugins.
-- Run :Lazy to update, clean, or check plugin status.
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
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

-- setting up indent helpers
vim.opt.list = true
vim.opt.listchars = { tab = "┊ ", leadmultispace = "┊   " }

-- Add new plugins to this list to auto install and load them
require("lazy").setup({
  -- file tree explorer added via ctrl+q in keymaps
  { "nvim-tree/nvim-tree.lua", opts = {} },
  -- next key helper pop-up menu
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  -- adds git change markers in the left margin
  { "lewis6991/gitsigns.nvim", opts = {} },
  -- mason allows you to use :Mason to install language servers from inside of nvim
  -- nvim-lspconfig is ready-made settings for language servers
  -- installs and starts language servers you can add to ensure_installed to add more later
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "pyright",  -- Python: types, definitions, navigation
        "ruff",     -- Python: style checks and formatting
        "lua_ls",   -- Lua (your init.lua)
        "bashls",   -- shell scripts
        "yamlls",   -- YAML
        "jsonls",   -- JSON
      },
    },
  },
  -- makes the Lua language server understand Neovim config files
  { "folke/lazydev.nvim", ft = "lua", opts = {} },
  -- completion menu for language servers (While typing pressing up/down will allow you to pick and tab will accept and move on)
  { "saghen/blink.cmp", version = "1.*",
    opts = {
      keymap = {
        preset = 'default',
        ['<C-y>'] = false,
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
      }
    }
  },
  -- replaces nvim bar with a more informative one
  { "nvim-lualine/lualine.nvim",opts = {}},
  -- file-type icons used by nvim-tree and lualine (needs a Nerd Font)
  { "nvim-tree/nvim-web-devicons", opts = {} },
})

--------------------------------------------------------------------------------
-- Language Servers
-- Servers in ensure_installed (plugin list above) install and start
-- automatically. Run :Mason to see their status.
--------------------------------------------------------------------------------
-- show error messages at the end of the line
vim.diagnostic.config({ virtual_text = true })

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------
vim.keymap.set("n", "<C-q>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
vim.keymap.set("n", "<C-e>", "<cmd>set list!<CR>", { desc = "Toggle indent guides" })

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
-- turn line numbers on
vim.opt.number = true

-- mouse in all modes (Neovim default is "nvi")
vim.opt.mouse = "a"

-- wrap at word boundaries, not mid-word
vim.opt.linebreak = true

-- searching ignores case unless you type a capital letter
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- y and p use the system clipboard
vim.opt.clipboard = "unnamedplus"

-- lualine already shows the mode
vim.opt.showmode = false

-- undo history survives closing the file
vim.opt.undofile = true

-- keep 5 lines visible above/below the cursor
vim.opt.scrolloff = 5

-- PEP 8 style indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function() (vim.hl or vim.highlight).on_yank() end,
})

-- highlight trailing whitespace in blue
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("ExtraWhitespace", { clear = true }),
  callback = function()
    vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "blue", ctermbg = "blue" })
    vim.cmd([[match ExtraWhitespace /\s\+$/]])
  end,
})
