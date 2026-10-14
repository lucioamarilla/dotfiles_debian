-- =============================================================
-- nvim init.lua — dotfiles Debian BSPWM (minimal, sin plugin manager)
-- nvim 0.10/0.11 (apt trixie). LSP nativo disponible bajo demanda.
-- =============================================================

-- Apariencia
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("colorscheme default")

-- UX base
local o = vim.opt
o.number = true
o.relativenumber = true
o.clipboard = "unnamedplus"
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

-- ripgrep como grep (si está)
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

-- Keybinds útiles
local k = vim.keymap.set
k("n", "<C-h>", "<C-w>h")
k("n", "<C-j>", "<C-w>j")
k("n", "<C-k>", "<C-w>k")
k("n", "<C-l>", "<C-w>l")
k("n", "<leader>w", vim.cmd.write)
k("n", "<leader>q", vim.cmd.quit)
k("i", "jk", "<Esc>")
k("t", "<Esc><Esc>", [[<C-\><C-n>]])

-- Diagnósticos LSP visuales (si algún día activás vim.lsp.start)
vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

-- Dir de undo
vim.cmd([[silent! call mkdir(stdpath('data') .. '/undo', 'p')]])

-- Aviso: para NvChad/LSP completo, mirá README.md (sección "Editor avanzado").
