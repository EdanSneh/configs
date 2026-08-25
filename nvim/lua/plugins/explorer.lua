return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            win = {
              list = {
                cwd = function()
                  return vim.fn.getcwd()
                end,
              },
            },
          },
        },
      },
    },
  },
}
