local images = require("scrawl.images")

describe("images", function()
  local buf, saved_tgc, saved_tmux, saved_send

  before_each(function()
    buf = vim.api.nvim_create_buf(false, true)
    saved_tgc = vim.o.termguicolors
    saved_tmux = vim.env.TMUX
    saved_send = vim.api.nvim_ui_send
    vim.o.termguicolors = true
    vim.g.terminal_color_1 = nil
  end)

  after_each(function()
    vim.o.termguicolors = saved_tgc
    vim.env.TMUX = saved_tmux
    vim.api.nvim_ui_send = saved_send
    vim.g.terminal_color_1 = nil
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  describe("index_to_rgb", function()
    it("uses terminal_color_N for the 16 ANSI colors", function()
      vim.g.terminal_color_1 = "#f38ba8"
      assert.are.equal(0xf38ba8, images._index_to_rgb(buf, 1))
    end)

    it("prefers the buffer-local terminal color", function()
      vim.g.terminal_color_1 = "#f38ba8"
      vim.b[buf].terminal_color_1 = "#010203"
      assert.are.equal(0x010203, images._index_to_rgb(buf, 1))
    end)

    it("falls back to libvterm's palette when unset", function()
      assert.are.equal(0xe00000, images._index_to_rgb(buf, 1))
    end)

    it("ignores malformed terminal colors", function()
      vim.g.terminal_color_1 = "red"
      assert.are.equal(0xe00000, images._index_to_rgb(buf, 1))
    end)

    it("maps the 6x6x6 color cube", function()
      assert.are.equal(0x000000, images._index_to_rgb(buf, 16))
      assert.are.equal(0xff00d7, images._index_to_rgb(buf, 200))
      assert.are.equal(0xffffff, images._index_to_rgb(buf, 231))
    end)

    it("maps the grayscale ramp", function()
      assert.are.equal(0x080808, images._index_to_rgb(buf, 232))
      assert.are.equal(0xeeeeee, images._index_to_rgb(buf, 255))
    end)
  end)

  describe("rewrite", function()
    it("maps an 8-bit image id to the RGB nvim will redraw", function()
      vim.g.terminal_color_1 = "#f38ba8"
      local out = images._rewrite(buf, "\27_Ga=T,U=1,f=100,i=1,c=2,r=1;QUJD")
      assert.are.equal("\27_Ga=T,U=1,f=100,i=" .. 0xf38ba8 .. ",c=2,r=1;QUJD\27\\", out)
    end)

    it("leaves ids of 256 and above alone", function()
      local out = images._rewrite(buf, "\27_Ga=T,i=70000;QUJD")
      assert.are.equal("\27_Ga=T,i=70000;QUJD\27\\", out)
    end)

    it("leaves ids alone without termguicolors", function()
      vim.o.termguicolors = false
      local out = images._rewrite(buf, "\27_Ga=d,d=I,i=7")
      assert.are.equal("\27_Ga=d,d=I,i=7\27\\", out)
    end)

    it("does not map an id to the invalid id 0", function()
      local out = images._rewrite(buf, "\27_Ga=d,d=I,i=16")
      assert.are.equal("\27_Ga=d,d=I,i=16\27\\", out)
    end)

    it("forces quiet mode", function()
      local out = images._rewrite(buf, "\27_Ga=T,q=1,i=300;QUJD")
      assert.are.equal("\27_Ga=T,q=2,i=300;QUJD\27\\", out)
    end)

    it("passes continuation chunks through", function()
      assert.are.equal("\27_Gm=0;REVG\27\\", images._rewrite(buf, "\27_Gm=0;REVG"))
    end)

    it("returns nil for non-graphics sequences", function()
      assert.is_nil(images._rewrite(buf, "\27]1337;x"))
    end)
  end)

  describe("attach", function()
    local function run(script, n)
      local out = {}
      vim.api.nvim_ui_send = function(d) table.insert(out, d) end
      vim.api.nvim_set_current_buf(buf)
      images.attach(buf)
      vim.fn.termopen({ "sh", "-c", script .. "; sleep 0.2" })
      vim.wait(1000, function() return #out >= n end)
      return out
    end

    it("forwards graphics sequences to the outer terminal", function()
      vim.env.TMUX = nil
      local out = run([[printf '\033_Ga=T,i=300;QUJD\033\\']], 1)
      assert.are.same({ "\27_Ga=T,i=300;QUJD\27\\" }, out)
    end)

    it("wraps sequences for tmux passthrough inside tmux", function()
      vim.env.TMUX = "/tmp/tmux-1/default,1,0"
      local out = run([[printf '\033_Ga=T,i=300;QUJD\033\\']], 1)
      assert.are.same({ "\27Ptmux;\27\27_Ga=T,i=300;QUJD\27\27\\\27\\" }, out)
    end)

    it("ignores OSC and DCS sequences", function()
      vim.env.TMUX = nil
      local out = run([[printf '\033]1337;x\007\033P+q544e\033\\\033_Gi=300;QUJD\033\\']], 1)
      assert.are.same({ "\27_Gi=300;QUJD\27\\" }, out)
    end)
  end)
end)
