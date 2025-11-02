-- ChatInterfaceScript.lua
local ChatInterface = {}

local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local Roact = require(script.Parent.Roact)
local Session = require(script.Parent.SharedState.Session)
local ChatPage = require(script.Parent.Pages.ChatPage)
local CodeAnalysisPage = require(script.Parent.Pages.CodeAnalysisPage)
local WebhookRouter = require(script.Parent.WebhookRouter)
local ExporterFolderStructure = require(script.Parent.ExportFolderStructureScript)



local handle = nil

local ChatInterface = Roact.Component:extend("ChatInterface")

local function formatRichText(input)
	-- Escape HTML characters
	input = input:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")

	-- Handle code blocks (```lua ... ``` or ``` ... ```)
	input = input:gsub("```lua(.-)```", function(code)
		return '<font color="#00ff00">' .. code:gsub("\n", "<br/>") .. '</font>'
	end)
	input = input:gsub("```(.-)```", function(code)
		return '<font color="#cccccc">' .. code:gsub("\n", "<br/>") .. '</font>'
	end)

	-- Handle bold (**bold text**)
	input = input:gsub("%*%*(.-)%*%*", "<b>%1</b>")

	-- Handle titles (### Title => <font size="20"><b>Title</b></font>)
	input = input:gsub("### (.-)\n", '<font size="20"><b>%1</b></font><br/>')
	input = input:gsub("## (.-)\n", '<font size="18"><b>%1</b></font><br/>')
	input = input:gsub("# (.-)\n", '<font size="22"><b>%1</b></font><br/>')

	-- Handle remaining newlines
	input = input:gsub("\n", "<br/>")

	return input
end

function ChatInterface:init()
	self:setState({
		input = "",
		messages = {},
		loading = false,
		isNarrow = self.props.isNarrow or false,
		currentPage = "CodeAnalysis", -- Default page
	})

	self.onInputChanged = function(rbx)
		self:setState({ input = rbx.Text })
	end

	self.onSend = function()
		local input = self.state.input
		if input == "" then return end

		local page = self.state.currentPage
		local route = WebhookRouter.getRoute(page)
		if not route then
			warn("No webhook route found for page: " .. page)
			return
		end

		local sessionKey = route.sessionKey
		if not Session[sessionKey] then
			Session[sessionKey] = tostring(math.floor(os.time())) .. "_" .. math.random(0, 100)
		end

		-- Add the user message to the history
		local newMessages = table.clone(self.state.messages or {})
		table.insert(newMessages, { type = "user", content = input })
		-- Add a "typing" placeholder for assistant
		table.insert(newMessages, { type = "assistant", content = "<i>Assistant is typing...</i>" })

		self:setState({
			input = "",
			messages = newMessages,
			loading = true,
		})

		-- Prepare payload
		local payload
		if page == "CodeAnalysis" then
			local activeScript = StudioService.ActiveScript and StudioService.ActiveScript.Source or ""
			local filePath = StudioService.ActiveScript and StudioService.ActiveScript:GetFullName() or ""
			local folderStructure = ExporterFolderStructure.Export()

			payload = {
				scriptCode = activeScript,
				errorMessage = input,
				filePath = filePath,
				folderStructure = folderStructure,
				sessionId = Session[sessionKey]
			}
		else -- fallback for "Chat"
			payload = {
				question = input,
				sessionId = Session[sessionKey]
			}
		end

		task.spawn(function()
			local success, result = pcall(function()
				return HttpService:PostAsync(
					route.url,
					HttpService:JSONEncode(payload),
					Enum.HttpContentType.ApplicationJson
				)
			end)

			-- Remove "typing" placeholder
			table.remove(newMessages) -- remove last assistant entry

			if success then
				local decoded = HttpService:JSONDecode(result)
				local content = decoded.message and decoded.message.content or decoded.output or "Pas de réponse."
				table.insert(newMessages, { type = "assistant", content = formatRichText(content) })
			else
				table.insert(newMessages, { type = "assistant", content = "? Erreur : " .. tostring(result) })
			end

			self:setState({
				messages = newMessages,
				loading = false,
			})
		end)
	end
end

function ChatInterface:setPage(pageName)
	self:setState({
		currentPage = pageName,
	})
end

function ChatInterface:renderNav()
	local isNarrow = self.state.isNarrow

	local props = {
		Size = isNarrow and UDim2.new(0, 0, 0, 0)--[[UDim2.new(1, 0, 0.07, 0)]] or UDim2.new(0.25, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(23, 23, 23),
	}

	local children
	if isNarrow then
		--[[children = {
			Title = Roact.createElement("TextLabel", {
				Text = "?? Rblx Assistant",
				Font = Enum.Font.GothamBold,
				TextSize = 20,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
			}),
		}]]
	else
		children = {
			Title = Roact.createElement("TextLabel", {
				Text = "?? Rblx Assistant",
				Font = Enum.Font.GothamBold,
				TextSize = 20,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0.07, 0),
			}),
			NewChatBtn = Roact.createElement("TextButton", {
				Text = "+ Nouveau chat",
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Size = UDim2.new(0.9, 0, 0.05, 0),
				Position = UDim2.new(0, 10, 0, 60),
				[Roact.Event.Activated] = function()
					self:setState({ currentPage = "Chat" })
				end,
			}),
			SearchBar = Roact.createElement("TextBox", {
				PlaceholderText = "?? Rechercher",
				Text = "",
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Size = UDim2.new(0.9, 0, 0.05, 0),
				Position = UDim2.new(0, 10, 0, 100),
			}),
		}
	end

	return Roact.createElement("Frame", props, children)
end


function ChatInterface:renderPage()
	local page = self.state.currentPage

	if page == "Chat" then
		return ChatPage({
			isNarrow = self.state.isNarrow,
			input = self.state.input,
			response = self.state.messages, -- changed to use full message history
			loading = self.state.loading,
			onInputChanged = self.onInputChanged,
			onSend = self.onSend,
			setPage = function(pageName)
				self:setState({ currentPage = pageName })
			end,
		})
	elseif page == "CodeAnalysis" then
		return CodeAnalysisPage({
			input = self.state.input,
			response = self.state.messages, -- changed to use full message history
			loading = self.state.loading,
			onInputChanged = self.onInputChanged,
			onSend = self.onSend,
			onToggleContext = function()
				self:setState({ showContext = not self.state.showContext })
			end,
			dropdownOpen = self.state.dropdownOpen,
			showContext = self.state.showContext,
		})
	end
end

function ChatInterface:render()
	local isNarrow = self.state.isNarrow

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
		BorderSizePixel = 0,
	}, {
		Nav = self:renderNav(),

		MainPanel = Roact.createElement("Frame", {
			Position = isNarrow and UDim2.new(0, 0, 0, 0.07) or UDim2.new(0.25, 0, 0, 0),
			Size = isNarrow and UDim2.new(1, 0, 0.93, 0) or UDim2.new(0.75, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(33, 33, 33),
		}, {
			Content = self:renderPage(),
		}),
	})
end

return ChatInterface