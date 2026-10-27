-- Bridge Claude Code's inline images out of nvim's :terminal.
--
-- nvim's terminal (libvterm) can't draw images, but Claude Code uses kitty's
-- Unicode-placeholder mode: it transmits the picture in an APC sequence, then
-- prints U+10EEEE cells whose foreground color encodes the image id. nvim
-- keeps those cells as text and redraws them, so all that's missing is the
-- APC. We catch it with TermRequest and write it to the outer terminal
-- ourselves (wrapped for tmux passthrough when nvim runs inside tmux).
--
-- Claude encodes ids below 256 as indexed colors (38;5;N). With
-- termguicolors, nvim redraws those as 38;2;R;G;B from its terminal palette,
-- so kitty would read the RGB value as the id. We rewrite i=N to that value.
local M = {}

-- libvterm's default ANSI palette, used when terminal_color_N is unset.
local vterm_ansi = {
  { 0, 0, 0 }, { 224, 0, 0 }, { 0, 224, 0 }, { 224, 224, 0 },
  { 0, 0, 224 }, { 224, 0, 224 }, { 0, 224, 224 }, { 224, 224, 224 },
  { 128, 128, 128 }, { 255, 64, 64 }, { 64, 255, 64 }, { 255, 255, 64 },
  { 64, 64, 255 }, { 255, 64, 255 }, { 64, 255, 255 }, { 255, 255, 255 },
}
local cube = { 0, 95, 135, 175, 215, 255 }

local function rgb(r, g, b) return r * 65536 + g * 256 + b end

local function index_to_rgb(buf, n)
  if n < 16 then
    local hex = vim.b[buf]["terminal_color_" .. n] or vim.g["terminal_color_" .. n]
    if type(hex) == "string" and hex:match("^#%x%x%x%x%x%x$") then
      return tonumber(hex:sub(2), 16)
    end
    return rgb(unpack(vterm_ansi[n + 1]))
  elseif n < 232 then
    n = n - 16
    return rgb(cube[math.floor(n / 36) + 1], cube[math.floor(n / 6) % 6 + 1], cube[n % 6 + 1])
  end
  local v = 8 + 10 * (n - 232)
  return rgb(v, v, v)
end

local function rewrite(buf, seq)
  local ctrl, rest = seq:match("^\27_G([^;]*)(.*)$")
  if not ctrl then return nil end
  local keys = {}
  for kv in ctrl:gmatch("[^,]+") do
    local k, v = kv:match("^(%a)=(.*)$")
    if k == "i" and vim.o.termguicolors then
      local id = tonumber(v)
      if id and id < 256 then
        local mapped = index_to_rgb(buf, id)
        if mapped > 0 then v = tostring(mapped) end
      end
    elseif k == "q" then
      -- Replies would arrive as input to nvim's TUI, not to Claude.
      v = "2"
    end
    table.insert(keys, k and (k .. "=" .. v) or kv)
  end
  return "\27_G" .. table.concat(keys, ",") .. rest .. "\27\\"
end

local function write(data)
  if vim.env.TMUX then
    data = "\27Ptmux;" .. data:gsub("\27", "\27\27") .. "\27\\"
  end
  if vim.api.nvim_ui_send then
    vim.api.nvim_ui_send(data)
  else
    io.stdout:write(data)
  end
end

M._rewrite = rewrite
M._index_to_rgb = index_to_rgb

function M.attach(buf)
  vim.api.nvim_create_autocmd("TermRequest", {
    buffer = buf,
    callback = function(ev)
      local seq = ev.data and ev.data.sequence
      if type(seq) ~= "string" or seq:sub(1, 3) ~= "\27_G" then return end
      local out = rewrite(buf, seq)
      if out then write(out) end
    end,
  })
end

return M
