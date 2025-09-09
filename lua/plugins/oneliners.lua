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
}
