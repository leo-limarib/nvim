return {
	'neovim/nvim-lspconfig',
	dependencies = {
		'williamboman/mason.nvim',
		'williamboman/mason-lspconfig.nvim',
		-- Autocompletion
		'hrsh7th/nvim-cmp',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
		'saadparwaiz1/cmp_luasnip',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-nvim-lua',
		-- Snippets
		'L3MON4D3/LuaSnip',
		'rafamadriz/friendly-snippets',
	},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
			},
		})

		-- format on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})

		-- Add borders to floating windows
		vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
			vim.lsp.handlers.hover,
			{ border = 'rounded' }
		)
		vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
			vim.lsp.handlers.signature_help,
			{ border = 'rounded' }
		)

		-- Configure error/warnings interface
		vim.diagnostic.config({
			virtual_text = true,
			severity_sort = true,
			float = {
				style = 'minimal',
				border = 'rounded',
				header = '',
				prefix = '',
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = '✘',
					[vim.diagnostic.severity.WARN] = '▲',
					[vim.diagnostic.severity.HINT] = '⚑',
					[vim.diagnostic.severity.INFO] = '»',
				},
			},
		})

		local lspconfig = require("lspconfig")

		local lspconfig_defaults = lspconfig.util.default_config
		lspconfig_defaults.capabilities = vim.tbl_deep_extend(
			'force',
			lspconfig_defaults.capabilities,
			require('cmp_nvim_lsp').default_capabilities()
		)

		-- Keymaps when an LSP attaches
		vim.api.nvim_create_autocmd('LspAttach', {
			callback = function(event)
				local opts = { buffer = event.buf }
				local map = vim.keymap.set

				map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
				map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
				map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
				map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
				map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
				map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
				map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
				map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
				map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
				map({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
				map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
			end,
		})

		require('mason').setup({})
		require('mason-lspconfig').setup({
			ensure_installed = {
				"lua_ls",
				"intelephense",
				"ts_ls",
				"eslint",
				"pyright",
			},
			handlers = {
				function(server_name)
					if server_name == "luals" then return end
					lspconfig[server_name].setup({})
				end,

				-- Lua
				lua_ls = function()
					lspconfig.lua_ls.setup({
						settings = {
							Lua = {
								runtime = { version = 'LuaJIT' },
								diagnostics = { globals = { 'vim' } },
								workspace = {
									library = { vim.env.VIMRUNTIME },
								},
							},
						},
					})
				end,

				-- TypeScript/JavaScript
				ts_ls = function()
					lspconfig.ts_ls.setup({
						settings = {
							javascript = {
								format = {
									indentSize = 2,
									convertTabsToSpaces = true,
								},
								suggest = { autoImports = true },
								validate = { enable = true },
							},
							typescript = {
								format = {
									indentSize = 2,
									convertTabsToSpaces = true,
								},
								inlayHints = {
									includeInlayParameterNameHints = "all",
									includeInlayParameterNameHintsWhenArgumentMatchesName = false,
									includeInlayFunctionParameterTypeHints = true,
									includeInlayVariableTypeHints = true,
									includeInlayPropertyDeclarationTypeHints = true,
									includeInlayFunctionLikeReturnTypeHints = true,
									includeInlayEnumMemberValueHints = true,
								},
								suggest = { autoImports = true },
								validate = { enable = true },
							},
						},
						init_options = {
							hostInfo = "neovim",
						},
					})
				end,

				-- ESLint
				eslint = function()
					lspconfig.eslint.setup({
						settings = {
							format = true,
						},
						on_attach = function(client, bufnr)
							vim.api.nvim_create_autocmd("BufWritePre", {
								buffer = bufnr,
								command = "EslintFixAll",
							})
						end,
					})
				end,
			},
		})

		-- Autocompletion setup
		local cmp = require('cmp')
		require('luasnip.loaders.from_vscode').lazy_load()

		vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

		cmp.setup({
			preselect = 'item',
			completion = {
				completeopt = 'menu,menuone,noinsert'
			},
			window = {
				documentation = cmp.config.window.bordered(),
			},
			sources = {
				{ name = 'path' },
				{ name = 'nvim_lsp' },
				{ name = 'buffer',  keyword_length = 3 },
				{ name = 'luasnip', keyword_length = 2 },
			},
			snippet = {
				expand = function(args)
					require('luasnip').lsp_expand(args.body)
				end,
			},
			formatting = {
				fields = { 'abbr', 'menu', 'kind' },
				format = function(entry, item)
					local n = entry.source.name
					if n == 'nvim_lsp' then
						item.menu = '[LSP]'
					else
						item.menu = string.format('[%s]', n)
					end
					return item
				end,
			},
			mapping = cmp.mapping.preset.insert({
				['<CR>'] = cmp.mapping.confirm({ select = false }),
				['<C-f>'] = cmp.mapping.scroll_docs(5),
				['<C-u>'] = cmp.mapping.scroll_docs(-5),
				['<C-e>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.abort()
					else
						cmp.complete()
					end
				end),
				['<Tab>'] = cmp.mapping(function(fallback)
					local col = vim.fn.col('.') - 1
					if cmp.visible() then
						cmp.select_next_item({ behavior = 'select' })
					elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
						fallback()
					else
						cmp.complete()
					end
				end, { 'i', 's' }),
				['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
				['<C-d>'] = cmp.mapping(function(fallback)
					local luasnip = require('luasnip')
					if luasnip.jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { 'i', 's' }),
				['<C-b>'] = cmp.mapping(function(fallback)
					local luasnip = require('luasnip')
					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { 'i', 's' }),
			}),
		})
	end
}
