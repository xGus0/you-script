--=============================================================
--  GussScripterX — EDICAO FREE (BloxFruits ONLY)
--  Keyless | BloxFruits only | Executor-agnostico
--  v2.0 GUS-X  |  design novo: ciano + magenta
--=============================================================

local PALETTE = {
	BG       = Color3.fromRGB(9, 12, 21),
	PANEL    = Color3.fromRGB(13, 18, 30),
	ACC_A    = Color3.fromRGB(0, 245, 255),
	ACC_B    = Color3.fromRGB(255, 45, 149),
	ACC_C    = Color3.fromRGB(255, 176, 42),
	SUCCESS  = Color3.fromRGB(92, 255, 165),
	ERROR    = Color3.fromRGB(255, 80, 120),
	WARN     = Color3.fromRGB(255, 210, 60),
	TEXT     = Color3.fromRGB(232, 240, 255),
	TEXT_DIM = Color3.fromRGB(128, 142, 170),
}

local API = {
	VERSION  = "v2.0 GUS-X",
	BLOXFRUITS = 994732206,
	BLOXFRUITS_URL = "https://raw.githubusercontent.com/flazhy/QuantumOnyx/main/Games/BloxFruits.lua",
	COPY_TEXT = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/xGus0/you-script/main/GussScripterX.lua"))()]],
	FEATURES = {
		"Elite Hunter (multiplicador de XP)",
		"Auto-coleta de frutas",
		"Velocidade + Voo",
		"Invencibilidade",
		"Revive / revidar",
		"Multi-fruto",
		"Boost de XP",
		"Auto-colheita de frutas",
	},
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local GameId = game.GameId

local function GetExecutorName()
	if identifyexecutor then return identifyexecutor() end
	if syn then return "Synapse X" end
	if KRNL_LOADED then return "Krnl" end
	if fluxus then return "Fluxus" end
	if is_sirhurt_closure then return "SirHurt" end
	if XENO_LOADED or game:GetService("ContextActionService") then return "XENO" end
	return "Executor desconhecido"
end

local function GetHWID()
	local hwid
	if gethwid then pcall(function() hwid = gethwid() end) end
	if get_hwid then pcall(function() hwid = get_hwid() end) end
	if not hwid or tostring(hwid) == "" then
		pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
	end
	if not hwid or tostring(hwid) == "" then
		hwid = "FALLBACK-" .. tostring(LocalPlayer.UserId) .. "-" .. tostring(game.PlaceId)
	end
	return tostring(hwid)
end

local function GetGameName()
	local name = "Desconhecido"
	local ok, info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
	end)
	if ok and info then name = info end
	return name
end

local function Tween(obj, props, t, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	pcall(function() TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play() end)
end

local function Protect(gui)
	gui.Parent = game:GetService("CoreGui")
	if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
end

local function New(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Children" and k ~= "Parent" then
			pcall(function() inst[k] = v end)
		end
	end
	if props.Children then
		for _, c in ipairs(props.Children) do pcall(function() c.Parent = inst end) end
	end
	inst.Parent = props.Parent or parent
	return inst
end

local function CircleRipple(btn, mx, my)
	task.spawn(function()
		if not btn then return end
		pcall(function() btn.ClipsDescendants = true end)
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
		Tween(c, { Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(0.5, -sz/2, 0.5, -sz/2) }, 0.45, Enum.EasingStyle.Quad)
		Tween(c, { ImageTransparency = 1 }, 0.45, Enum.EasingStyle.Linear)
		task.wait(0.46)
		c:Destroy()
	end)
end

local function Notify(title, desc, accent, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title or "GussScripterX",
			Text = desc or "",
			Duration = duration or 5,
		})
	end)
end

local ConfigStore = {
	get = function(k)
		if getdata then
			local ok, v = pcall(function() return getdata(k) end)
			if ok and v ~= nil then return v end
		end
		return _G["__gusx_" .. tostring(k)]
	end,
	set = function(k, v)
		if getdata then pcall(function() getdata(k, v) end) end
		_G["__gusx_" .. tostring(k)] = v
	end,
}

local loaded = false
local function LoadBloxFruits(onComplete)
	if loaded then return true end
	local url = API.BLOXFRUITS_URL
	local lastErr
	for i = 1, 5 do
		local ok, err = pcall(function()
			local raw = game:HttpGet(url)
			if type(raw) ~= "string" or #raw < 100 then
				error("resposta invalida (len=" .. tostring(raw) .. ")")
			end
			local fn = loadstring(raw)
			fn()
		end)
		if ok then
			loaded = true
			Notify("GUS X", "BloxFruits FREE carregado! ✅", PALETTE.SUCCESS)
			if onComplete then onComplete(true, "ok") end
			return true, "ok"
		end
		lastErr = tostring(err)
		if i < 5 then
			Notify("GUS X", "Tentando de novo... (" .. i .. "/5)", PALETTE.WARN, 2)
			task.wait(0.6)
		end
	end
	loaded = true
	if not ok then
		if onComplete then onComplete(false, lastErr) end
		Notify("GUS X", "Fechado: script nao carregou (5 tentativas).", PALETTE.ERROR, 4)
	end
	return false, lastErr
end

--=============================================================
--  UI — GUS X Edition (free only, cyan + magenta)
--=============================================================
local function ShowKeyUI()
	local W, H = 460, 476
	local CX = W/2
	local CY = H/2
	local gameName = GetGameName()
	local executorName = GetExecutorName()
	local hwid = GetHWID()
	local autoLoadOn = (ConfigStore.get("autoload") == true)
	local featureText = ""
	for i, f in ipairs(API.FEATURES) do
		featureText = featureText .. ("▸ %s\n"):format(f)
	end
	featureText = featureText .. "▸ Mais funcionalidades da edicao free"

	local SG = Instance.new("ScreenGui")
	SG.Name = "GX_" .. tostring(math.random(1e6))
	SG.ZIndexBehavior = Enum.ZIndexBehavior.Global
	SG.ResetOnSpawn = false
	SG.IgnoreGuiInset = true
	Protect(SG)

	local Backdrop = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(0,0,0), BackgroundTransparency = 0.45,
		BorderSizePixel = 0, Size = UDim2.new(1,0,1,0), ZIndex = 200, Parent = SG,
	})

	local Card = New("Frame", {
		BackgroundColor3 = Color3.fromRGB(13,18,30), BackgroundTransparency = 0,
		BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0.5,-CX,0.5,-CY), Size = UDim2.new(0,W,0,H),
		ZIndex = 201, ClipsDescendants = true, Parent = SG,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,14) }),
			New("UIStroke", { Color = Color3.fromRGB(90,240,250), Transparency = 0.35, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})

	-- HEADER (52px)
	New("Frame", { BackgroundColor3 = Color3.fromRGB(9,12,21), BackgroundTransparency = 0, BorderSizePixel = 0, Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,52), ZIndex = 202, Parent = Card })
	New("Frame", { BackgroundColor3 = Color3.fromRGB(15,40,80), BackgroundTransparency = 0.65, BorderSizePixel = 0, Position = UDim2.new(0,0,0,0), Size = UDim2.new(0.55,0,0,52), ZIndex = 202, Parent = Card })
	New("ImageLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,13,0.5,-8), Size = UDim2.new(0,18,0,18), Image = "rbxassetid://7733992528", ImageColor3 = Color3.fromRGB(0,245,255), ZIndex = 203, Parent = Card })
	New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,38,0,0), Size = UDim2.new(1,-180,1,0), Font = Enum.Font.FredokaOne, Text = "GussScripterX", TextColor3 = Color3.fromRGB(232,240,255), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 203, Parent = Card })
	New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0,38,0.5,-3), Size = UDim2.new(1,-180,0,14), Font = Enum.Font.Gotham, Text = "BloxFruits — FREE • KEYLESS", TextColor3 = Color3.fromRGB(0,245,255), TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 203, Parent = Card })
	New("Frame", {
		AnchorPoint = Vector2.new(1,0.5),
		BackgroundColor3 = Color3.fromRGB(14,40,20), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(1,-40,0.5,0), Size = UDim2.new(0,72,0,20),
		ZIndex = 203, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,5) }),
			New("UIStroke", { Color = Color3.fromRGB(90,240,150), Transparency = 0.3, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
			New("TextLabel", {
				BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
				Font = Enum.Font.GothamBold, Text = "NO KEY",
				TextColor3 = Color3.fromRGB(150,255,175), TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 204,
			}),
		}
	})
	local CloseBtn = New("ImageButton", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-8,0.5,0), Size = UDim2.new(0,20,0,20),
		Image = "rbxassetid://79324227570635", ImageColor3 = Color3.fromRGB(200,80,120),
		ZIndex = 203, Parent = Card,
	})
	New("Frame", { BackgroundColor3 = Color3.fromRGB(0,245,255), BackgroundTransparency = 0.35, BorderSizePixel = 0, Position = UDim2.new(0,0,0,52), Size = UDim2.new(1,0,0,2), ZIndex = 202, Parent = Card })

	-- NOTICE (56, h=30)
	local NoticeText = ("BloxFruits — GameId %d | %s"):format(GameId, gameName)
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(17,23,39), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0,8,0,56), Size = UDim2.new(1,-16,0,30),
		ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,7) }),
			New("UIStroke", { Color = Color3.fromRGB(0,245,255), Transparency = 0.45, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,12,0,0),
		Size = UDim2.new(1,-18,1,0), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(140,230,250), TextSize = 10, Text = NoticeText,
		Parent = Card
	})

	-- INFO (88, h=52)
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(13,18,30), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0,8,0,88), Size = UDim2.new(1,-16,0,52),
		ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,8) }),
			New("UIStroke", { Color = Color3.fromRGB(75,92,130), Transparency = 0.5, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,6),
		Size = UDim2.new(1,-16,0,12), Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(200,90,200), TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = Card
	})
	New("Frame", { BackgroundColor3 = Color3.fromRGB(90,110,150), BackgroundTransparency = 0.7, BorderSizePixel = 0, Position = UDim2.new(0,8,0,20), Size = UDim2.new(1,-16,0,1), ZIndex = 203, Parent = Card })
	local InfoText = "Jogo: " .. gameName .. "  |  Executor: " .. executorName .. "\nHWID: " .. hwid
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,26),
		Size = UDim2.new(1,-18,0,14), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(200,210,235), TextSize = 9,
		Text = InfoText, TextWrapped = true, Parent = Card
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,42),
		Size = UDim2.new(1,-18,0,14), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(200,210,235), TextSize = 9,
		Text = "Build: " .. API.VERSION, Parent = Card
	})

	-- FEATURES BOX (152, h=130)
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(13,18,30), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0,8,0,152), Size = UDim2.new(1,-16,0,130),
		ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,8) }),
			New("UIStroke", { Color = Color3.fromRGB(75,92,130), Transparency = 0.5, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,8),
		Size = UDim2.new(1,-16,0,14), Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(0,245,255), TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = Card
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,28),
		Size = UDim2.new(1,-18,0,100), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(150,165,195), TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = featureText, Parent = Card
	})

	-- PROGRESS BAR (300, h=12)
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(13,18,30), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0,8,0,300), Size = UDim2.new(1,-16,0,12),
		ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,6) }),
			New("UICorner", { CornerRadius = UDim.new(0,6) }),
		}
	})

	-- STATUS TEXT (316, h=16)
	local StatusLabel = New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,316),
		Size = UDim2.new(1,-18,0,16), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(150,165,195), TextSize = 9, Parent = Card
	})
	StatusLabel.Text = "Pronto. Press START para carregar BloxFruits FREE."

	-- START BUTTON (332, h=50)
	local StartBtn = New("TextButton", {
		BackgroundColor3 = Color3.fromRGB(9,12,21), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0,8,0,332), Size = UDim2.new(1,-16,0,50),
		AutoButtonColor = false, Text = "START — BLOXFRUITS FREE",
		Font = Enum.Font.FredokaOne, TextColor3 = Color3.fromRGB(232,240,255),
		TextSize = 16, Border = 0, ClipsDescendants = true, ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,9) }),
			New("UIStroke", { Color = Color3.fromRGB(0,245,255), Transparency = 0.25, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})

	-- COPY + AUTOLOAD (388, h=28)
	local CopyBtn = New("TextButton", {
		BackgroundColor3 = Color3.fromRGB(13,18,30), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0,8,0,388),
		Size = UDim2.new(0.5,-10,0,28), AutoButtonColor = false, Border = 0,
		Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(150,165,195),
		TextSize = 11, ClipsDescendants = true, ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,5) }),
			New("UIStroke", { Color = Color3.fromRGB(0,245,255), Transparency = 0.35, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	CopyBtn.Text = "COPY COMMAND"
	local AutoBtn = New("TextButton", {
		BackgroundColor3 = Color3.fromRGB(13,18,30), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0.5,4,0,388),
		Size = UDim2.new(0.5,-10,0,28), AutoButtonColor = false, Border = 0,
		Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(150,165,195),
		TextSize = 11, ClipsDescendants = true, ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,5) }),
			New("UIStroke", { Color = Color3.fromRGB(75,92,130), Transparency = 0.5, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	AutoBtn.Text = "AUTO-LOAD: " .. (autoLoadOn and "ON" or "OFF")

	-- ERROR (424, h=40)
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(13,18,30), BackgroundTransparency = 0,
		BorderSizePixel = 0, Position = UDim2.new(0,8,0,424), Size = UDim2.new(1,-16,0,40),
		ZIndex = 202, Parent = Card,
		Children = {
			New("UICorner", { CornerRadius = UDim.new(0,8) }),
			New("UIStroke", { Color = Color3.fromRGB(255,80,120), Transparency = 0.55, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
		}
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,4),
		Size = UDim2.new(1,-16,1,0), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255,150,170), TextSize = 9,
		Text = "Erro: script de BloxFruits nao carregou.", Parent = Card
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0,9,0,24),
		Size = UDim2.new(1,-16,0,14), Font = Enum.Font.Gotham,
		TextColor3 = Color3.fromRGB(255,150,170), TextSize = 9,
		Text = "Tente de novo (5 tentativas automaticas).", Parent = Card
	})

	-- Events
	CircleRipple(CopyBtn, Mouse.X, Mouse.Y)
	CircleRipple(AutoBtn, Mouse.X, Mouse.Y)
	CircleRipple(StartBtn, Mouse.X, Mouse.Y)
	CircleRipple(CloseBtn, Mouse.X, Mouse.Y)

	-- Copy command
	CopyBtn.MouseButton1Click:Connect(function()
		CircleRipple(CopyBtn, Mouse.X, Mouse.Y)
		pcall(function() game:GetService("User"):Clipboard:Text = API.COPY_TEXT end)
		Notify("GUS X", "Comando copiado para clipboard! ✅", PALETTE.SUCCESS)
		CopyBtn.Text = "COPIADO!"
		task.delay(1.5, function() CopyBtn.Text = "COPY COMMAND" end)
	end)

	-- Auto-load toggle
	AutoBtn.MouseButton1Click:Connect(function()
		local v = (autoLoadOn ~= true)
		autoLoadOn = v
		ConfigStore.set("autoload", v)
		AutoBtn.Text = "AUTO-LOAD: " .. (v and "ON" or "OFF")
		AutoBtn.BackgroundTransparency = v and 0.1 or 0
		AutoBtn.BackgroundColor3 = v and Color3.fromRGB(9,40,22) or Color3.fromRGB(13,18,30)
		if v then Notify("GUS X", "Auto-load ATIVADO.", PALETTE.SUCCESS) else Notify("GUS X", "Auto-load desativado.", PALETTE.WARN) end
	end)

	-- Start
	StartBtn.MouseButton1Click:Connect(function()
		CircleRipple(StartBtn, Mouse.X, Mouse.Y)
		LoadBloxFruits()
		task.delay(2.0, function()
			pcall(function()
				Tween(Card, { Size = UDim2.new(0,W*0.65,0,H*0.65) }, 0.3)
				Tween(Card, { BackgroundTransparency = 1 }, 0.3)
				Tween(Backdrop, { BackgroundTransparency = 1 }, 0.3)
				task.delay(0.3, function() pcall(function() SG:Destroy() end) end)
			end)
		end)
	end)

	-- Close
	CloseBtn.MouseButton1Click:Connect(function()
		CircleRipple(CloseBtn, Mouse.X, Mouse.Y)
		task.delay(0.15, function()
			Tween(Card, { Size = UDim2.new(0,W*0.65,0,H*0.65), BackgroundTransparency = 1 }, 0.2)
			Tween(Backdrop, { BackgroundTransparency = 1 }, 0.2)
			task.delay(0.22, function() pcall(function() SG:Destroy() end) end)
		end)
	end)

	-- Notifications
	Notify("GUS X", "BloxFruits FREE — sem key (nada pra digitar). Press START.", PALETTE.ACC_A, 4)
	Notify("GUS X", "Executor detectado: " .. executorName, PALETTE.WARN, 3)
	Notify("GUS X", "Build: " .. API.VERSION .. " | GameId: " .. tostring(GameId), PALETTE.TEXT_DIM, 3)
	Notify("GUS X", "Game: " .. gameName .. " | Auto-load: " .. (autoLoadOn and "ON" or "OFF"), PALETTE.ERROR, 3)
	end


--=============================================================
--  MAIN — game check + auto-load (free only)
--=============================================================
local function Main()
	if GameId ~= API.BLOXFRUITS then
		Notify("GUS X", "OBS: voce nao esta em BloxFruits (GameId " .. tostring(GameId) .. ").", PALETTE.WARN, 4)
	end
	ShowKeyUI()
	local autoLoad = (ConfigStore.get("autoload") == true)
	if GameId == API.BLOXFRUITS and autoLoad then
		Notify("GUS X", "Auto-load: carregando BloxFruits FREE automaticamente...", PALETTE.SUCCESS, 4)
		loaded = false
		task.delay(0.3, LoadBloxFruits)
	end
	-- auto-load on place change
	game.PlaceChangedEvent:Connect(function()
		task.delay(0.8, function()
			local gId = game.GameId
			loaded = false
			if gId == API.BLOXFRUITS and ConfigStore.get("autoload") == true then
				Notify("GUS X", "Novo BloxFruits — auto-load ativando script FREE...", PALETTE.SUCCESS, 3)
				LoadBloxFruits()
			end
		end)
	end)
end

if not _G.__gusx_inited then
	_G.__gusx_inited = true
	Main()
end
Notify("GUS X", "GussScripterX v2.0 GUS-X inicializado. BloxFruits FREE • KEYLESS ✅", PALETTE.SUCCESS)
