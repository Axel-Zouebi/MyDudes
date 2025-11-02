local Toolbar = plugin:CreateToolbar("My Dude")

local ChatButton = Toolbar:CreateButton("My AI Dudes", "Poser une question sur le code", "")

-- Charger Roact & ton module UI
local Roact = require(script.Parent.Roact)
local ChatInterface = require(script.Parent.ChatInterfaceScript)

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	true,
	false,
	600, -- width
	400, -- height
	300,
	300
)

local widget = plugin:CreateDockWidgetPluginGui("MyDudes", widgetInfo)
widget.Title = "My Dudes"

local handle = nil
local currentIsNarrow = nil

ChatButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled

	if widget.Enabled and not handle then
		local function getIsNarrow()
			return widget.AbsoluteSize.X < 600
		end

		handle = Roact.mount(Roact.createElement(ChatInterface, {
			isNarrow = getIsNarrow()
		}), widget)

		currentIsNarrow = getIsNarrow()
		widget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			local newIsNarrow = getIsNarrow()
			if newIsNarrow ~= currentIsNarrow then
				currentIsNarrow = newIsNarrow
				-- remonter un nouveau composant avec la nouvelle valeur
				Roact.unmount(handle)
				handle = Roact.mount(Roact.createElement(ChatInterface, {
					isNarrow = newIsNarrow
				}), widget)
			end
		end)
	elseif not widget.Enabled and handle then
		Roact.unmount(handle)
		handle = nil
	end
end)
