return {
     {
	'tpope/vim-fugitive',
     },
     {
	'stevearc/conform.nvim',
	opts = {},
     },
     { "nvim-tree/nvim-web-devicons", opts = {} },
     {
        "prichrd/netrw.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("netrw").setup({
                use_devicons = true,
            })
        end,
    },
    {
	'windwp/nvim-autopairs',
	event = "InsertEnter",
	config = true
	-- use opts = {} for passing setup options
	-- this is equivalent to setup({}) function
    },
    {
	"github/copilot.vim",
    }
}
