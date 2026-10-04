-- Quantum Onyx Hub — Keyless Edition
-- (systema de chave / validacao Luarmor removido)

local API_CONFIG = {
	DISCORD_INVITE = "https://discord.gg/quantumonyx",
	KEY_LINKS = {
		Lootlabs = "https://ads.luarmor.net/get_key?for=Quantum_Onyx_Keysytem-kHpMaTAIVYzX",
		Linkvertise = "https://ads.luarmor.net/get_key?for=Quantum_Onyx_Key_Sytem-BlvCDdtfIvfJ",
	}
}

local Directory = "https://raw.githubusercontent.com/flazhy/QuantumOnyx/refs/heads/main/Games"
local Scripts = {
	Free = {
		[994732206] = Directory .. "/BloxFruits.lua",
	},
}

local STOCK_LOADER_URL = "https://api.luarmor.net/files/v4/loaders/0ae9fe4cf963e3a13d25eed0e2ce5940.lua"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GameId = game.GameId
local gameId = GameId

local IsFileFunc = isfile or function() return false end
local ReadFileFunc = readfile or function() return "" end
local WriteFileFunc = writefile or function() end
local MakeFolderFunc = makefolder or function() end
local IsFolderFunc = isfolder or function() return false end

local function GetExecutorName()
	if identifyexecutor then return identifyexecutor() end
	if syn then return "Synapse X" end
	if KRNL_LOADED then return "Krnl" end
	if fluxus then return "Fluxus" end
	if is_sirhurt_closure then return "SirHurt" end
	return "Unknown Executor"
end

local function GetHWID()
	local hwid
	if gethwid then pcall(function() hwid = gethwid() end) end
	if get_hwid then pcall(function() hwid = get_hwid() end) end
	if not hwid or tostring(hwid) == "" then
		pcall(function()
			hwid = game:GetService("RbxAnalyticsService"):GetClientId()
		end)
	end
	if not hwid or tostring(hwid) == "" then
		hwid = "FALLBACK-" .. tostring(LocalPlayer.UserId) .. "-" .. tostring(game.PlaceId)
	end
	return tostring(hwid)
end

local function Tween(obj, props, t, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
end

local function Protect(gui)
	local env = (getgenv and getgenv()) or _G
	if env.HIDEUI then
		gui.Parent = env.HIDEUI
	elseif gethui then
		gui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(gui)
		gui.Parent = game:GetService("CoreGui")
	else
		gui.Parent = game:GetService("CoreGui")
	end
end

local function New(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Children" and k ~= "Parent" then
			pcall(function() inst[k] = v end)
		end
	end
	if props.Children then
		for _, c in ipairs(props.Children) do
			pcall(function() c.Parent = inst end)
		end
	end
	inst.Parent = props.Parent or parent
	return inst
end

local function CircleRipple(btn, mx, my)
	task.spawn(function()
		btn.ClipsDescendants = true
		local nx = mx - btn.AbsolutePosition.X
		local ny = my - btn.AbsolutePosition.Y
		local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.6
		local c = New("ImageLabel", {
			Name = "Ripple",
			Image = "rbxassetid://266543268",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0.82,
			BackgroundTransparency = 1,
			ZIndex = btn.ZIndex + 5,
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0, nx, 0, ny),
		}, btn)
		Tween(c, { Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(0.5, -sz / 2, 0.5, -sz / 2) }, 0.45, Enum.EasingStyle.Quad)
		Tween(c, { ImageTransparency = 1 }, 0.45, Enum.EasingStyle.Linear)
		task.wait(0.46)
		c:Destroy()
	end)
end

local function Notify(title, desc, accent, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title or "Quantum Onyx",
			Text = desc or "",
			Duration = duration or 5,
		})
	end)
end


local function LoadScript(tier)
	if tier == "Free" then
		local url = Scripts.Free[GameId]
		if url then
			Notify("Loading", "Running free version of this game...")
			task.wait(0.15)
			pcall(function() loadstring(game:HttpGet(url))() end)
		else
			Notify("No free version", "This game doesn't have a free script yet.", Color3.fromRGB(255, 150, 80))
			warn("[Quantum Onyx] No free script for GameId: " .. tostring(GameId))
		end
	elseif tier == "Premium" then
		Notify("Loading", "Loading premium script via Luarmor...")
		task.wait(0.15)
		LoadStockLoader()
	end
end

local function LoadStockLoader()
	pcall(function()
		loadstring(game:HttpGet(STOCK_LOADER_URL))()
	end)
end

local function ShowKeyUI()
	local submitting = false

	local supportInfo = {
		{ label = "Discord", value = "discord.gg/quantumonyx" },
		{ label = "Game", value = (pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
		end) and game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
			or "Unknown" },
		{ label = "Version", value = "v.Keyless" },
	}

	local SG = Instance.new("ScreenGui")
	SG.Name = "KL_" .. tostring(math.random(1e6))
	SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
	SG.ResetOnSpawn = false
	SG.IgnoreGuiInset = true
	Protect(SG)

	local Backdrop = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 200,
		Parent = SG,
	})

	local W, H = 450, 310
	local Card = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, W, 0, H),
		BackgroundColor3 = Color3.fromRGB(15, 12, 24),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 201,
		ClipsDescendants = true,
		Parent = SG,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 14) }),
			New("UIStroke", {
				Color = Color3.fromRGB(120, 60, 220),
				Transparency = 0.3,
				Thickness = 1.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
		}
	})

	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(80, 20, 160),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Position = UDim2.new(0, -60, 0, -60),
		Size = UDim2.new(0, 220, 0, 220),
		ZIndex = 201,
		Parent = Card,
		Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
	})
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(40, 10, 110),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -100, 1, -100),
		Size = UDim2.new(0, 180, 0, 180),
		ZIndex = 201,
		Parent = Card,
		Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
	})

	local Header = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 16, 36),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 44),
		ZIndex = 202,
		Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 14) }),
			New("Frame", {
				BackgroundColor3 = Color3.fromRGB(22, 16, 36),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0.5, 0),
				ZIndex = 202
			}),
		}
	})

	New("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 13, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16),
		Image = "rbxassetid://7733992528",
		ImageColor3 = Color3.fromRGB(155, 90, 255),
		ZIndex = 203,
		Parent = Header
	})

	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 35, 0, 0),
		Size = UDim2.new(1, -130, 1, 0),
		Font = Enum.Font.FredokaOne,
		Text = "Quantum Onyx Hub",
		TextColor3 = Color3.fromRGB(220, 200, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 203,
		Parent = Header
	})

	New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(30, 60, 20),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -40, 0.5, 0),
		Size = UDim2.new(0, 72, 0, 20),
		ZIndex = 203,
		Parent = Header,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 5) }),
			New("UIStroke", { Color = Color3.fromRGB(80, 200, 110), Transparency = 0.3, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
			New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = "Keyless",
				TextColor3 = Color3.fromRGB(130, 235, 160),
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Center,
				ZIndex = 204
			}),
		}
	})

	local CloseBtn = New("ImageButton", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		Image = "rbxassetid://79324227570635",
		ImageColor3 = Color3.fromRGB(200, 80, 80),
		ZIndex = 203,
		Parent = Header
	})
	CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(120, 60, 220),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 44),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 202,
		Parent = Card,
	})

	local LW = 180
	local RX = LW + 18
	local RW = W - RX - 10

	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(100, 50, 200),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(0, LW + 8, 0, 52),
		Size = UDim2.new(0, 1, 0, H - 60),
		ZIndex = 202,
		Parent = Card,
	})

	local InfoBox = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 16, 36),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0, 52),
		Size = UDim2.new(0, LW, 0, 112),
		ZIndex = 202,
		Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			New("UIStroke", { Color = Color3.fromRGB(100, 50, 190), Transparency = 0.4, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 9, 0, 5),
		Size = UDim2.new(1, -14, 0, 13),
		Font = Enum.Font.GothamBold,
		Text = "Information",
		TextColor3 = Color3.fromRGB(160, 110, 240),
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 203,
		Parent = InfoBox
	})
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(110, 60, 200),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 7, 0, 20),
		Size = UDim2.new(1, -14, 0, 1),
		ZIndex = 203,
		Parent = InfoBox,
	})

	local rowY = 26
	for _, info in ipairs(supportInfo) do
		New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 9, 0, rowY),
			Size = UDim2.new(0, 55, 0, 12),
			Font = Enum.Font.GothamBold,
			Text = (info.label or "") .. ":",
			TextColor3 = Color3.fromRGB(140, 110, 190),
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 203,
			Parent = InfoBox
		})
		New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 64, 0, rowY),
			Size = UDim2.new(1, -70, 0, 12),
			Font = Enum.Font.Gotham,
			Text = tostring(info.value or ""),
			TextColor3 = Color3.fromRGB(200, 180, 240),
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 203,
			Parent = InfoBox
		})
		rowY = rowY + 16
		if rowY > 96 then break end
	end

	local ProfileBox = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 16, 36),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0, 170),
		Size = UDim2.new(0, LW, 0, 128),
		ZIndex = 202,
		Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 8) }),
			New("UIStroke", { Color = Color3.fromRGB(100, 50, 190), Transparency = 0.4, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 9, 0, 5),
		Size = UDim2.new(1, -14, 0, 13),
		Font = Enum.Font.GothamBold,
		Text = "User Profile",
		TextColor3 = Color3.fromRGB(160, 110, 240),
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 203,
		Parent = ProfileBox
	})
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(110, 60, 200),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 7, 0, 20),
		Size = UDim2.new(1, -14, 0, 1),
		ZIndex = 203,
		Parent = ProfileBox,
	})

	local AvatarRing = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(110, 55, 210),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 28),
		Size = UDim2.new(0, 52, 0, 52),
		ZIndex = 203,
		Parent = ProfileBox,
		Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
	})
	local AvatarImg = New("ImageLabel", {
		BackgroundColor3 = Color3.fromRGB(30, 15, 55),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 46, 0, 46),
		Image = "",
		ZIndex = 204,
		Parent = AvatarRing,
		Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
	})
	local DisplayNameLbl = New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 86),
		Size = UDim2.new(1, -12, 0, 14),
		Font = Enum.Font.GothamBold,
		Text = LocalPlayer.DisplayName,
		TextColor3 = Color3.fromRGB(220, 205, 255),
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 203,
		Parent = ProfileBox
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 102),
		Size = UDim2.new(1, -12, 0, 12),
		Font = Enum.Font.Gotham,
		Text = "@" .. LocalPlayer.Name,
		TextColor3 = Color3.fromRGB(145, 125, 185),
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 203,
		Parent = ProfileBox
	})

	task.spawn(function()
		local ok, img = pcall(function()
			return game:GetService("Players"):GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
		end)
		if ok and img then AvatarImg.Image = img end
	end)

	local NoticeBg = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 16, 36),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0, RX, 0, 52),
		Size = UDim2.new(0, RW, 0, 50),
		ZIndex = 202,
		Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 7) }),
			New("UIStroke", { Color = Color3.fromRGB(80, 200, 110), Transparency = 0.4, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
			New("Frame", {
				BackgroundColor3 = Color3.fromRGB(80, 200, 110),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, -10),
				Size = UDim2.new(0, 3, 0, 20),
				ZIndex = 203,
				Children = { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }
			}),
		}
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -16, 1, 0),
		Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(140, 230, 170),
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 203,
		Parent = NoticeBg
	})

	local LRMBar = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(22, 16, 36),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0, RX, 0, 110),
		Size = UDim2.new(0, RW, 0, 28),
		ZIndex = 202,
		Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", { Color = Color3.fromRGB(100, 50, 190), Transparency = 0.4, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0.5, -6),
		Size = UDim2.new(0, 12, 0, 12),
		Image = "rbxassetid://7733992528",
		ImageColor3 = Color3.fromRGB(150, 95, 225),
		ZIndex = 203,
		Parent = LRMBar
	})
	local LRMStatusLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 25, 0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "Keyless — load anytime",
		TextColor3 = Color3.fromRGB(180, 160, 225),
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 203,
		Parent = LRMBar
	})

	local InputBg = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(10, 8, 18),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0, RX, 0, 146),
		Size = UDim2.new(0, RW, 0, 34),
		ZIndex = 202,
		Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 7) }),
			New("UIStroke", { Color = Color3.fromRGB(120, 60, 220), Transparency = 0.3, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, -7),
		Size = UDim2.new(0, 14, 0, 14),
		Image = "rbxassetid://7733992528",
		ImageColor3 = Color3.fromRGB(140, 90, 215),
		ZIndex = 203,
		Parent = InputBg
	})
	local KeyInput = New("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(1, -38, 1, 0),
		Font = Enum.Font.GothamBold,
		PlaceholderText = "Optional key (if you have one)...",
		PlaceholderColor3 = Color3.fromRGB(110, 85, 155),
		-- Text = LoadSavedKey(),
		TextColor3 = Color3.fromRGB(225, 205, 255),
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 203,
		Parent = InputBg
	})

	local StatusLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, RX, 0, 185),
		Size = UDim2.new(0, RW, 0, 13),
		Font = Enum.Font.GothamBold,
		Text = "HWID: " .. GetHWID():sub(1, 12) .. "...",
		TextColor3 = Color3.fromRGB(175, 155, 210),
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 202,
		Parent = Card
	})

	local function SetStatus(msg, col)
		StatusLabel.Text = msg
		StatusLabel.TextColor3 = col or Color3.fromRGB(175, 155, 210)
	end

	local function AnimateClose()
		Tween(Card, { Size = UDim2.new(0, W * 0.65, 0, H * 0.65), BackgroundTransparency = 1 }, 0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		Tween(Backdrop, { BackgroundTransparency = 1 }, 0.20, Enum.EasingStyle.Quint)
		task.delay(0.22, function() SG:Destroy() end)
	end)

	local function LoadGame(tier)
		tier = tier or "Premium"
		if submitting then return end
		submitting = true

		SetStatus("Loading game script...", Color3.fromRGB(175, 150, 255))

		task.spawn(function()
			-- deixa o status renderizar antes de bloquear
			task.wait(0.05)
			local ok = pcall(function()
				LoadScript(tier)
			end)
			if ok then
				SetStatus("Ready! ", Color3.fromRGB(80, 230, 130))
				Notify("Game Loaded", "Script de " .. (tier == "Free" and "versao gratuita" or "premium") .. " em executacao.", Color3.fromRGB(80, 230, 130))
			else
				SetStatus("Load failed — check connection.", Color3.fromRGB(255, 90, 110))
				Notify("Load Failed", "Couldn't reach the game script.", Color3.fromRGB(255, 90, 110))
			end
			task.wait(0.4)
			AnimateClose()
			submitting = false
		end)
	end)

	local BtnY = 202
	local BtnH = 30
	local BtnGap = 6
	local BtnW = math.floor((RW - BtnGap * 2) / 3)

	local function MakeBtn(label, px, w, bg, tc, cb)
		local btn = New("TextButton", {
			BackgroundColor3 = bg,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(0, px, 0, BtnY),
			Size = UDim2.new(0, w, 0, BtnH),
			AutoButtonColor = false,
			Text = "",
			ClipsDescendants = true,
			ZIndex = 202,
			Parent = Card,
			Children = {
				New("UICorner", { CornerRadius = UDim.new(0, 7) }),
				New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Font = Enum.Font.FredokaOne,
					Text = label,
					TextColor3 = tc,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = 203
				})
			}
		})
		btn.MouseEnter:Connect(function()
			Tween(btn, { BackgroundColor3 = bg:Lerp(Color3.fromRGB(255, 255, 255), 0.15) }, 0.12)
		end)
		btn.MouseLeave:Connect(function()
			Tween(btn, { BackgroundColor3 = bg }, 0.16)
		end)
		btn.MouseButton1Click:Connect(function()
			CircleRipple(btn, Mouse.X, Mouse.Y)
			cb()
		end)
		return btn
	end)

	MakeBtn("Free Version", RX, BtnW, Color3.fromRGB(45, 20, 85), Color3.fromRGB(200, 165, 255), function()
		LoadGame("Free")
	end)

	local panelOpen = false
	local OptionPanel = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(15, 12, 24),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.new(0, RX + BtnW + BtnGap, 0, BtnY - 78),
		Size = UDim2.new(0, BtnW, 0, 72),
		ZIndex = 215,
		Visible = false,
		ClipsDescendants = false,
		Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0, 7) }),
			New("UIStroke", {
				Color = Color3.fromRGB(120, 60, 220),
				Transparency = 0.3,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
		}
	})

	local function MakeOptionBtn(label, yPos, link, statusMsg)
		local btn = New("TextButton", {
			BackgroundColor3 = Color3.fromRGB(40, 20, 80),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 4, 0, yPos),
			Size = UDim2.new(1, -8, 0, 30),
			AutoButtonColor = false,
			Text = label,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(210, 185, 255),
			TextSize = 11,
			ZIndex = 216,
			Parent = OptionPanel,
			Children = { New("UICorner", { CornerRadius = UDim.new(0, 5) }) }
		})
		btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = Color3.fromRGB(60, 30, 110) }, 0.10) end)
		btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = Color3.fromRGB(40, 20, 80) }, 0.12) end)
		btn.MouseButton1Click:Connect(function()
			CircleRipple(btn, Mouse.X, Mouse.Y)
			pcall(function() (setclipboard or toclipboard)(link) end)
			SetStatus(statusMsg, Color3.fromRGB(105, 195, 255))
			task.delay(0.12, function()
				panelOpen = false
				OptionPanel.Visible = false
			end)
		end)
		return btn
	end)

	MakeOptionBtn("Lootlabs", 4, API_CONFIG.KEY_LINKS.Lootlabs, "Copied link!")
	MakeOptionBtn("Linkvertise", 38, API_CONFIG.KEY_LINKS.Linkvertise, "Copied link!")

	local getKeyBtn = MakeBtn("Get Key", RX + BtnW + BtnGap, BtnW, Color3.fromRGB(20, 45, 90), Color3.fromRGB(130, 195, 255), function()
		panelOpen = not panelOpen
		OptionPanel.Visible = panelOpen
	end)

	UserInputService.InputBegan:Connect(function(input)
		if not panelOpen then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and
			input.UserInputType ~= Enum.UserInputType.Touch then return end
		local pos = input.Position
		local ap, as = OptionPanel.AbsolutePosition, OptionPanel.AbsoluteSize
		local gkp, gks = getKeyBtn.AbsolutePosition, getKeyBtn.AbsoluteSize
		local onPanel = pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
		local onBtn = pos.X >= gkp.X and pos.X <= gkp.X + gks.X and pos.Y >= gkp.Y and pos.Y <= gkp.Y + gks.Y
		if not onPanel and not onBtn then
			panelOpen = false
			OptionPanel.Visible = false
		end
	end)

	MakeBtn("Load Game", RX + (BtnW + BtnGap) * 2, BtnW, Color3.fromRGB(65, 25, 130), Color3.fromRGB(225, 180, 255), function()
		LoadGame("Premium")
	end)

	KeyInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then LoadGame("Premium") end
	end)

	Notify("Hub", "Modo keyless ativo. Press Load Game para carregar.", Color3.fromRGB(130, 235, 160))
	-- Auto-abre a UI
	-- (ou o player pode carregar manualmente)
end

-- Abre a UI ao carregar o script
ShowKeyUI()
