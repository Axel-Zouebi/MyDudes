local Roact = require(script.Parent.Parent.Roact)

return function(props)
	local showContext = props.showContext
	local dropdownOpen = props.dropdownOpen
	local inputText = props.input
	local loading = props.loading
	local onInputChanged = props.onInputChanged
	local onSend = props.onSend
	local response = props.response
	
	-- Function to render a single message
	local function renderMessage(message, index)
		local isUser = message.type == "user"
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = index,
		}, {
			MessageContainer = Roact.createElement("Frame", {
				Size = UDim2.new(1, -20, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Position = UDim2.new(0, 0, 0, 0),
				AnchorPoint = Vector2.new(0),
				BackgroundColor3 = isUser and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(46, 46, 46),
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
				}),
				MessageText = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Text = message.content,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 14,
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					RichText = true,
				}),
			}),
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(46, 46, 46),
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 3),
		}),
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 0, 0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		-- Chat History (only shown if there are messages)
		ChatHistory = props.response and #props.response > 0 and Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -100), -- Leave space for input
			BackgroundTransparency = 1,
			ScrollBarThickness = 6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),
			Messages = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, (function()
				local children = {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				}

				for i, message in ipairs(props.response or {}) do
					table.insert(children, renderMessage(message, i))
				end

				return children
			end)())
		}),
		InputContainerTop = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 100),
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(27, 27, 27),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 2,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Color = Color3.new(46, 46, 46),
				Thickness = 0.6,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = 0.8,
			}),
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			UIPadding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			}),
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 0, 0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			InputGridTop = Roact.createElement("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.new(0.1, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(27, 27, 27),
				BorderSizePixel = 0,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 0, 0, 0),
				}),
				ContextButton = Roact.createElement("TextButton", {
					Text = "@ Add context",
					TextColor3 = Color3.fromRGB(160, 160, 160),
					Font = Enum.Font.SourceSans,
					TextSize = 14,
					TextWrapped = true,
					BackgroundColor3 = Color3.fromRGB(20, 20, 20),
					Position = UDim2.new(0.5, 0, 0.05, 0),
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					[Roact.Event.Activated] = props.onToggleContext,
				}, {
					UIStroke = Roact.createElement("UIStroke", {
						Color = Color3.new(46, 46, 46),
						Thickness = 0.6,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Transparency = 0.8,
					}),
					UICorner = Roact.createElement("UICorner", { 
						CornerRadius = UDim.new(0, 3),
					}),
					UIPadding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, 1),
						PaddingBottom = UDim.new(0, 1),
						PaddingLeft = UDim.new(0, 3),
						PaddingRight = UDim.new(0, 3),
					}),
				}),
			}),
			InputContainer = Roact.createElement("Frame", {
				LayoutOrder = 2,
				--Size = UDim2.new(0.96, 0, 0.2, 0),
				Size = UDim2.new(1, 0, 0, 50),
				Position = UDim2.new(0.02, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(25, 25, 25),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
			}, {
				TextBox = Roact.createElement("TextBox", {
					Text = inputText,
					PlaceholderText = "Plan, search, build anything",
					ClearTextOnFocus = false,
					Font = Enum.Font.SourceSans,
					TextSize = 12,
					TextWrapped = true,
					TextColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -40, 1, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					TextXAlignment = Enum.TextXAlignment.Left,
					BorderSizePixel = 0,
					[Roact.Change.Text] = onInputChanged,
					[Roact.Event.InputBegan] = function(rbx, input)
						if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Return then
							if not input:IsModifierKeyDown(Enum.ModifierKey.Shift) then
								props.onSend()
							end
						end
					end,
				}),
			}),
			InputGridBottom = Roact.createElement("Frame", {
				LayoutOrder = 3,
				--Size = UDim2.new(0.96, 0, 0.2, 0),
				Size = UDim2.new(1, 0, 0, 15),
				Position = UDim2.new(0.02, 0, 0.7, 0),
				BackgroundColor3 = Color3.fromRGB(27, 27, 27),
				BorderSizePixel = 0,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 0, 0, 0),
					HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				}),
				ContextButton = Roact.createElement("TextButton", {
					Text = "? Agent",
					TextColor3 = Color3.fromRGB(160, 160, 160),
					Font = Enum.Font.SourceSans,
					TextSize = 14,
					TextWrapped = true,
					BackgroundColor3 = Color3.fromRGB(39, 40, 40),
					Position = UDim2.new(0.5, 0, 0.05, 0),
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					[Roact.Event.Activated] = props.onToggleContext,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 28),
					}),
					UIPadding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, 1),
						PaddingBottom = UDim.new(0, 1),
						PaddingLeft = UDim.new(0, 9),
						PaddingRight = UDim.new(0, 12),
					}),
				}),
				SendButton = Roact.createElement("ImageButton", {
					Size = UDim2.new(0, 15, 0, 15),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Image = loading and "rbxassetid://137605461556168" or "rbxassetid://80884875388988",
					ScaleType = Enum.ScaleType.Fit,
					[Roact.Event.Activated] = onSend,
				}, {
					UICorner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
				}),
			}),			
		}),
	})
end
