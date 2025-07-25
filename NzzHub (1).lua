--[[
🔥 Nzz HUB Final Version 🔥
Author: NzzDenn
All features optimized and organized.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 Nzz HUB 🔥",
    LoadingTitle = "Nzz HUB",
    LoadingSubtitle = "Powerful ScriptHub",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local PlayerTab = Window:CreateTab("Player Tools", 4483362458)
local CombatTab = Window:CreateTab("Combat & Visual", 4483362458)
local UtilityTab = Window:CreateTab("Utility", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)

-- WalkSpeed
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 1000},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end,
})

-- Fly (WASD)
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local flyToggle = false
PlayerTab:CreateToggle({
    Name = "Fly (WASD)",
    CurrentValue = false,
    Callback = function(state)
        flyToggle = state
        local lp = game.Players.LocalPlayer
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local bg = Instance.new("BodyGyro", hrp)
        local bv = Instance.new("BodyVelocity", hrp)
        bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local control = {F=0,B=0,L=0,R=0}
        UIS.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            local k = i.KeyCode
            if k == Enum.KeyCode.W then control.F = 1
            elseif k == Enum.KeyCode.S then control.B = -1
            elseif k == Enum.KeyCode.A then control.L = -1
            elseif k == Enum.KeyCode.D then control.R = 1 end
        end)
        UIS.InputEnded:Connect(function(i)
            local k = i.KeyCode
            if k == Enum.KeyCode.W then control.F = 0
            elseif k == Enum.KeyCode.S then control.B = 0
            elseif k == Enum.KeyCode.A then control.L = 0
            elseif k == Enum.KeyCode.D then control.R = 0 end
        end)
        RunService:BindToRenderStep("Fly", Enum.RenderPriority.Camera.Value, function()
            if not flyToggle then RunService:UnbindFromRenderStep("Fly") bg:Destroy() bv:Destroy() return end
            bg.CFrame = workspace.CurrentCamera.CFrame
            local move = Vector3.new(control.L + control.R, 0, control.F + control.B)
            bv.Velocity = workspace.CurrentCamera.CFrame:VectorToWorldSpace(move * 60)
        end)
    end,
})

-- Infinite Jump
local infiniteJump = false
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        infiniteJump = v
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if infiniteJump then
                local hum = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end,
})

-- Noclip
local noclip = false
PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclip = v
        game:GetService("RunService").Stepped:Connect(function()
            if noclip then
                for _, p in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end,
})

-- ESP
local function createESP(player)
    if not player.Character or player.Character:FindFirstChild("ESPBox") then return end
    local esp = Instance.new("BillboardGui", player.Character)
    esp.Name = "ESPBox"
    esp.Size = UDim2.new(6,0,3,0)
    esp.AlwaysOnTop = true
    esp.Adornee = player.Character:FindFirstChild("Head")
    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1,0,1,0)
    label.Text = player.Name
    label.TextColor3 = Color3.new(1,0,0)
    label.BackgroundTransparency = 1
end

CombatTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(enabled)
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer then
                if enabled then createESP(p)
                elseif p.Character and p.Character:FindFirstChild("ESPBox") then
                    p.Character.ESPBox:Destroy()
                end
            end
        end
    end,
})

-- Aimbot
CombatTab:CreateToggle({
    Name = "Aimbot (Hold Right Click)",
    CurrentValue = false,
    Callback = function(enabled)
        local RunService = game:GetService("RunService")
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()

        local function getClosest()
            local closest, dist = nil, math.huge
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                    local mag = (v.Character.Head.Position - player.Character.Head.Position).Magnitude
                    if mag < dist then closest, dist = v, mag end
                end
            end
            return closest
        end

        if enabled then
            RunService:BindToRenderStep("Aim", Enum.RenderPriority.Camera.Value, function()
                if mouse and mouse.Button2Down then
                    local target = getClosest()
                    if target then
                        local cam = workspace.CurrentCamera
                        cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Character.Head.Position), 0.15)
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("Aim")
        end
    end,
})

-- Kill Aura
local killAura = false
CombatTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(state)
        killAura = state
        local debounce = {}
        game:GetService("RunService").RenderStepped:Connect(function()
            if not killAura then return end
            local player = game.Players.LocalPlayer
            local char = player.Character
            for _, other in pairs(game.Players:GetPlayers()) do
                if other ~= player and other.Character and other.Character:FindFirstChild("Humanoid") then
                    local dist = (char.HumanoidRootPart.Position - other.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 15 and not debounce[other] then
                        debounce[other] = true
                        other.Character.Humanoid:TakeDamage(10)
                        task.delay(1, function() debounce[other] = nil end)
                    end
                end
            end
        end)
    end,
})

-- Fling All
CombatTab:CreateButton({
    Name = "Fling All",
    Callback = function()
        local lp = game.Players.LocalPlayer
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local bv = Instance.new("BodyVelocity", p.Character.HumanoidRootPart)
                bv.Velocity = Vector3.new(math.random(-5000,5000), math.random(3000,6000), math.random(-5000,5000))
                bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                game:GetService("Debris"):AddItem(bv, 0.2)
            end
        end
    end,
})

-- Anti-AFK
UtilityTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        for _,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
            v:Disable()
        end
        Rayfield:Notify({Title = "Anti-AFK", Content = "AFK dilindungi", Duration = 3})
    end
})

-- Server Hop
UtilityTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        local PlaceId = game.PlaceId
        local Servers = Api..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local req = (syn and syn.request) or request
        local data = Http:JSONDecode(req({Url = Servers}).Body)
        for _, v in pairs(data.data) do
            if v.playing < v.maxPlayers then
                TPS:TeleportToPlaceInstance(PlaceId, v.id, game.Players.LocalPlayer)
                break
            end
        end
    end
})

-- Teleport to Player (Input)
UtilityTab:CreateInput({
    Name = "Teleport ke Pemain",
    PlaceholderText = "Nama Pemain",
    RemoveTextAfterFocusLost = false,
    Callback = function(name)
        local plr = game.Players:FindFirstChild(name)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character:MoveTo(plr.Character.HumanoidRootPart.Position + Vector3.new(3,0,0))
        end
    end,
})

-- Credits
CreditsTab:CreateParagraph({
    Title = "Created by",
    Content = "🔥 NzzDenn 🔥
ScriptHub Final Version"
})
