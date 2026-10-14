-- =============================================================
-- nvim init.lua — dotfiles Debian (MÍNIMO y estable)
-- Sin plugin manager: native LSP + treesitter incluidos nvim 0.10.
-- Pares de líneas: máximo performance bajo 8GB RAM.
--   NOTA: para LSP real usá :MasonPlugin etc. En nuestro caso: nativos.
-- =============================================================

-- Apariencia
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.colorscheme "habamax"

-- UX esenciales
local o = vim.opt
o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus"       -- portapapeles integrado (X11)
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.smartindent = true
o.hlsearch = false
o.incsearch = true
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.undodir = os.getenv("HOME") .. "/.config/nvim/undo"
o.undolevels = 1000            -- moderado por RAM
o.scrolloff = 5
o.sidescrolloff = 5
o.mouse = "a"
o.updatetime = 250
o.timeoutlen = 400
o.splitright = true
o.splitbelow = true
o.colorcolumn = "80"
o.signcolumn = "yes"
o.list = true
o.listchars = "tab:> ,trail:·,nbsp:␣"
o.guifont = "JetBrains Mono:h10.5"

-- Ripgrep en :grep y :vimgrep
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

-- Keybinds básicos
local k = vim.keymap.set
k("n", "<leader>w", vim.cmd.write)
k("n", "<leader>q", vim.cmd.quit)
k("n", "jk", "<Esc>")
k("i", "jk", "<Esc>")
k("n", "<leader>s", vim.cmd.split)
k("n", "<leader>v", vim.cmd.vsplit)
k("n", "<C-h>", "<C-w>h")
k("n", "<C-j>", "<C-w>j")
k("n", "<C-k>", "<C-w>k")
k("n", "<C-l>", "<C-w>l")
k("t", "<Esc><Esc>", [[<C-\><C-n>]])

-- Diagnósticos con Tracking visual esencial de LSP
vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

-- LSP NATIVA — sin plugins. Config por ft bajo demanda:
-- vim.lsp.start({ name = 'lua', cmd = {'lua-language-server'}, ... })

-- Undo dir auto-creación
vim.cmd([[silent! call mkdir(&undodir, 'p')]])
