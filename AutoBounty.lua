getgenv().Setting = {
    ["Team"] = "Pirates",--Marines
    ["Chat"] = {},
    ["Skip Race V4"] = true,
    ["Misc"] = {
        ["Enable Lock Bounty"] = false,
        ["Lock Bounty"] = {0, 300000000},
        ["Hide Health"] = {4500,5000},
        ["Lock Camera"] = false,
        ["Enable Cam Farm"] = false,
        ["White Screen"] = false,
        ["Auto Enable Race V4"] = true,
        ["FPS Boost"] = false,
        ["Bypass TP"] = true, 
        ["Random & Store Fruit"] = false
    },
    ["Item"] = {
        ["Melee"] = {["Enable"] = true,
            ["Z"] = {["Enable"] = true, ["Hold Time"] = 1.5},
            ["X"] = {["Enable"] = true, ["Hold Time"] = 0.2},
            ["C"] = {["Enable"] = true, ["Hold Time"] = 0.2}
        },
        ["Blox Fruit"] = {["Enable"] = false,
            ["Z"] = {["Enable"] = true, ["Hold Time"] = 1.5},
            ["X"] = {["Enable"] = true, ["Hold Time"] = 0},
            ["C"] = {["Enable"] = true, ["Hold Time"] = 0},
            ["V"] = {["Enable"] = true, ["Hold Time"] = 0},
            ["F"] = {["Enable"] = true, ["Hold Time"] = 0}
        },
        ["Sword"] = {["Enable"] = true,
            ["Z"] = {["Enable"] = true, ["Hold Time"] = 0.18},
            ["X"] = {["Enable"] = true, ["Hold Time"] = 0.25}
        },
        ["Gun"] = {["Enable"] = false,
            ["Z"] = {["Enable"] = true, ["Hold Time"] = 0.1},
            ["X"] = {["Enable"] = true, ["Hold Time"] = 0.1}
        } 
    }
}
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("Main");
--// Join Team
if game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam") then
    repeat task.wait()
        if game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("Main").ChooseTeam.Visible == true then
            if getgenv().Setting.Team == "Marines" then
                for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container["Marines"].Frame.TextButton.Activated)) do
                    for a, b in pairs(getconnections(game:GetService("UserInputService").TouchTapInWorld)) do
                        b:Fire() 
                    end
                    v.Function()
                end 
            else
                for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container["Pirates"].Frame.TextButton.Activated)) do
                    for a, b in pairs(getconnections(game:GetService("UserInputService").TouchTapInWorld)) do
                        b:Fire() 
                    end
                    v.Function()
                end 
            end
        end
    until game.Players.LocalPlayer.Team ~= nil and game:IsLoaded()
end
--// Local
local plrs = game.Players
local lp = plrs.LocalPlayer
--// Random Fruit
if getgenv().Setting.Misc["Random & Store Fruit"] then
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin","Buy")
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and string.find(v.Name, "Fruit") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit",v:GetAttribute("OriginalName"),v)
        end
    end
    for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and string.find(v.Name, "Fruit") then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit",v:GetAttribute("OriginalName"),v)
        end
    end
end
--// Lock Bounty
if getgenv().Setting.Misc["Enable Lock Bounty"] and not (lp.leaderstats["Bounty/Honor"].Value > tonumber(getgenv().Setting.Misc["Lock Bounty"][1])) or not (lp.leaderstats["Bounty/Honor"].Value < tonumber(getgenv().Setting.Misc["Lock Bounty"][2])) then 
    lp:Kick("Lock Bounty")
end

function equip(tooltip)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
if getgenv().Setting.Misc["Auto Enable Race V4"] and tostring(item) == "Awakening" then
    item.Parent = character
end
if tostring(item.ToolTip) == "Awakening" then
    item.Parent = character
end

if item:IsA("Tool") and item.ToolTip == tooltip then
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and not humanoid:IsDescendantOf(item) then
        if not game.Players.LocalPlayer.Character:FindFirstChild(item.Name) then
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(item)
        end
        return item
    end
end
end

--// Tween / Bypass
local Workspace = game:GetService("Workspace")
--// Tween / Bypass
NpcList = {}
for i, v in pairs(Workspace.NPCs:GetChildren()) do 
    if string.find(string.lower(v.Name), "home point") then
        table.insert(NpcList, v:GetModelCFrame())
    end
end
for i, v in pairs(getnilinstances()) do 
    if string.find(string.lower(v.Name), "home point") then
        table.insert(NpcList, v:GetModelCFrame())
    end
end
local w = game.PlaceId
if w == 2753915549 then
    World1 = true
    gQ = {
        Vector3.new(-7894.6201171875, 5545.49169921875, -380.246346191406),
        Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625),
        Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
        Vector3.new(3876.280517578125, 35.10614013671875, -1939.3201904296875)
    }
elseif w == 4442272183 then
    World2 = true
    gQ = {
        Vector3.new(-288.46246337890625, 306.130615234375, 597.9988403320312),
        Vector3.new(2284.912109375, 15.152046203613281, 905.48291015625),
        Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
        Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)
    }
elseif w == 7449423635 then
    World3 = true
    gQ = {
        Vector3.new(-5058.77490234375, 314.5155029296875, -3155.88330078125),
        Vector3.new(5756.83740234375, 610.4240112304688, -253.9253692626953),
        Vector3.new(-12463.8740234375, 374.9144592285156, -7523.77392578125),
        Vector3.new(28282.5703125, 14896.8505859375, 105.1042709350586),
        Vector3.new(-11993.580078125, 334.7812805175781, -8844.1826171875),
        Vector3.new(5314.58203125, 25.419387817382812, -125.94227600097656)
    }
end
function GetPortal(check2)
    local check3 = check2.Position
    local aM, aN = Vector3.new(0,0,0), math.huge
    for _, aL in pairs(gQ) do
        if (aL-check3).Magnitude < aN and aM ~= aL then
            aM, aN = aL, (aL-check3).Magnitude
        end
    end
    return aM
end 
function BypassTeleport(is)
    if lp.Character:FindFirstChild("PartTele") then
        lp.Character.PartTele.CFrame = CFrame.new(lp.Character.PartTele.CFrame.X, 1000, lp.Character.PartTele.CFrame.Z)
        task.wait(0.5)
        if CheckInComBat() then
            return
        end
        lp.Character.PartTele.CFrame = is
        task.wait(0.1)
        lp.Character.PrimaryPart.CFrame = is   
        lp.Character:WaitForChild("Humanoid"):ChangeState(15)
        task.wait(0.5)
        repeat task.wait() until lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health <= 0
        repeat task.wait()
            if lp.Character:FindFirstChild("PartTele") then
                lp.Character.PartTele.CFrame = is  
            end
            if lp.Character:FindFirstChild("PrimaryPart") then
                lp.Character.PrimaryPart.CFrame = is  
            end
        until lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0
    end
end
function GetBypassPos(pos)
    pos = Vector3.new(pos.X, pos.Y, pos.Z)
    local lll, mmm = nil, math.huge
    for i, v in pairs(NpcList) do
        if (v.p - pos).Magnitude < mmm then
            lll = v
            mmm = (v.p - pos).Magnitude
        end
    end
    return lll
end
function RequestEntrance(check1)
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack({"requestEntrance", check1}))
    if lp.Character:FindFirstChild("PartTele") then
        lp.Character.PartTele.CFrame = WaitHRP(lp).CFrame 
    end
    task.wait(0.01)
end
function WaitHRP(q0) 
    if not q0 then return end
    return q0.Character:WaitForChild("HumanoidRootPart", 9) 
end 
function CalcDistance(I, II) 
    if not II then 
        II = lp.Character.PrimaryPart.CFrame 
    end 
    return (Vector3.new(I.X, 0, I.Z)-Vector3.new(II.X, 0, II.Z)).Magnitude 
end 
function CheckInComBat()
    return lp.PlayerGui.Main.InCombat.Visible and lp.PlayerGui.Main.InCombat.Text and (string.find(string.lower(lp.PlayerGui.Main.InCombat.Text),"risk"))
end 
function to(Pos)
    if not Pos then return end 
    lp.Character:WaitForChild("HumanoidRootPart", 9)
    lp.Character:WaitForChild("Head", 9)
    if not lp.Character.HumanoidRootPart:FindFirstChild("Hold") then
        local Hold = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
        Hold.Name = "Hold"
        Hold.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        Hold.Velocity = Vector3.new(0, 0, 0)
    end
    if not lp.Character:FindFirstChild("PartTele") then
        local PartTele = Instance.new("Part", lp.Character) -- Create part
        PartTele.Size = Vector3.new(10,1,10)
        PartTele.Name = "PartTele"
        PartTele.Anchored = true
        PartTele.Transparency = 1
        PartTele.CanCollide = false
        PartTele.CFrame = WaitHRP(lp).CFrame 
        PartTele:GetPropertyChangedSignal("CFrame"):Connect(function()
            task.wait(0.01)
            WaitHRP(lp).CFrame = PartTele.CFrame
        end)
    end
    Portal = GetPortal(Pos) 
    Spawn = GetBypassPos(Pos) 
    MyCFrame = WaitHRP(lp).CFrame
    Distance = CalcDistance(MyCFrame, Pos)
    if CalcDistance(Portal, Pos) < CalcDistance(Pos) and CalcDistance(Portal) > 500 then
        return RequestEntrance(Portal)
    end
    if not CheckInComBat() and CalcDistance(Pos) - CalcDistance(Spawn, Pos) > 1000 and CalcDistance(Spawn) > 1000 then
        return BypassTeleport(Spawn)
    end
    if lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid:FindFirstChild("Sit") and lp.Character.Humanoid.Sit == true then
        lp.Character.Humanoid.Sit = false
    end 
    if Distance <= 150 then
        lp.Character.PartTele.CFrame = Pos
    else
        Tween = game:GetService("TweenService"):Create(lp.Character.PartTele, TweenInfo.new(Distance / 350, Enum.EasingStyle.Linear),{CFrame = Pos})
        Tween:Play() 
    end
end
--// Equip
function equip(tooltip)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    for _, item in pairs(player.Backpack:GetChildren()) do 
        if tostring(item.ToolTip) == "" then 
            item.Parent = character
        end 
        if item:IsA("Tool") and item.ToolTip == tooltip then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and not humanoid:IsDescendantOf(item) then
                if not game.Players.LocalPlayer.Character:FindFirstChild(item.Name) then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(item)
                    return item
                end
            end
        end 
    end 
end
--// Attack
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
CameraShaker:Stop()
CombatFrameworkR = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
y = debug.getupvalues(CombatFrameworkR)[2]
spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if typeof(y) == "table" then
            pcall(function()
                local targetPlayer = enemy
                if targetPlayer and getgenv().Setting.Misc["Lock Camera"] then
                    local targetCharacter = targetPlayer.Character
                    if targetCharacter then
                        game.Workspace.CurrentCamera.CFrame = CFrame.new(game.Workspace.CurrentCamera.CFrame.Position, targetCharacter.HumanoidRootPart.Position)
                    end
                end
                CameraShaker:Stop()
                y.activeController.hitboxMagnitude = 60
                y.activeController.active = false
                y.activeController.timeToNextBlock = 0
                y.activeController.focusStart = 1655503339.0980349
                y.activeController.increment = 1
                y.activeController.blocking = false
                y.activeController.attacking = false
                y.activeController.humanoid.AutoRotate = true
            end)
        end
    end)
end)
function GetCurrentBlade()
    local CombatFrameworkLib = debug.getupvalues(require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework))
    local CmrFwLib = CombatFrameworkLib[2]
    local p13 = CmrFwLib.activeController
    local weapon = p13.blades[1]
    if not weapon then 
        return weapon
    end
    while weapon ~= nil and weapon.Parent ~= game.Players.LocalPlayer.Character do
        weapon = weapon.Parent 
    end
    return weapon
end
function Attack()
    local CbFw = debug.getupvalues(require(lp.PlayerScripts.CombatFramework))
    local CbFw2 = CbFw[2]
    local AC = CbFw2.activeController
    for i = 1, 1 do 
        if AC ~= nil then
            local bladehit = require(game.ReplicatedStorage.CombatFramework.RigLib).getBladeHits(
            lp.Character,
            {lp.Character.HumanoidRootPart},
            60
            )
            local cac = {}
            local hash = {}
            for k, v in pairs(bladehit) do
                if v.Parent:FindFirstChild("HumanoidRootPart") and not hash[v.Parent] then
                    table.insert(cac, v.Parent.HumanoidRootPart)
                    hash[v.Parent] = true
                end
            end
            bladehit = cac
            if #bladehit > 0 then
                local u8 = debug.getupvalue(AC.attack, 5)
                local u9 = debug.getupvalue(AC.attack, 6)
                local u7 = debug.getupvalue(AC.attack, 4)
                local u10 = debug.getupvalue(AC.attack, 7)
                local u12 = (u8 * 798405 + u7 * 727595) % u9
                local u13 = u7 * 798405
                (function()
                    u12 = (u12 * u9 + u13) % 1099511627776
                    u8 = math.floor(u12 / u9)
                    u7 = u12 - u8 * u9
                end)()
                u10 = u10 + 1
                debug.setupvalue(AC.attack, 5, u8)
                debug.setupvalue(AC.attack, 6, u9)
                debug.setupvalue(AC.attack, 4, u7)
                debug.setupvalue(AC.attack, 7, u10)
                pcall(function()
                    for k, v in pairs(AC.animator.anims.basic) do
                        v:Play()
                    end                  
                end)
                if lp.Character:FindFirstChildOfClass("Tool") and AC.blades and AC.blades[1] then 
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(GetCurrentBlade()))
                    game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(u12 / 1099511627776 * 16777215), u10)
                    game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, i, "")
                end
            end
        end
    end
end
--// Use Skill
function down(use, cooldown)
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true,use,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
        task.wait(cooldown)
        game:GetService("VirtualInputManager"):SendKeyEvent(false,use,false,game.Players.LocalPlayer.Character.HumanoidRootPart)
    end)
end
--// Click
function Click()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,1,0,1))
end
function getAvailableSkills(Setting) 
    local V = game.Players.LocalPlayer.PlayerGui.Main.Skills
    local Cache = {}
    for i, v in pairs(lp.Character:GetChildren()) do 
        if v:IsA("Tool") then 
            table.insert(Cache, v)
        end 
    end 
    for i, v in pairs(lp.Backpack:GetChildren()) do 
        if v:IsA("Tool") then 
            table.insert(Cache, v)
        end 
    end 
    for i, v in pairs(Cache) do 
        -- warn(v, v.ToolTip , Setting.Item[v.ToolTip]    )
        if v.ToolTip and Setting.Item[v.ToolTip] and Setting.Item[v.ToolTip].Enable then
            -- warn(1)
            for i2, v2 in pairs(Setting.Item[v.ToolTip]) do
                if i2 ~= "Enable" and v2.Enable then 
                    if V:FindFirstChild(v.Name) and V[v.Name]:FindFirstChild(i2) then 
                        local GuiData = V[v.Name][i2]
                        if GuiData.Cooldown.AbsoluteSize.X <= 0 then
                            return {i2, v2, v.ToolTip}
                        end
                    else
                        equip(v.ToolTip)
                    end
                end
            end 
        end 
    end
    return false
end
--// Fps Boost
if getgenv().Setting.Misc["FPS Boost"] then
    for i,v in pairs(game:GetService("Workspace"):GetDescendants()) do
        pcall(function()
            if v.Transparency and v.Parent ~= game.Players.LocalPlayer.Character then
                v.Transparency = 1
            end
        end)
    end
end
--// Aim
aim = true
spawn(function()
    local gg = getrawmetatable(game)
    local old = gg.__namecall
    setreadonly(gg,false)
    gg.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local args = {...}
        if tostring(method) == "FireServer" then
            if tostring(args[1]) == "RemoteEvent" then
                if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                    if aim and CFrameHunt ~= nil then
                        args[2] = CFrameHunt.Position
                        return old(unpack(args))
                    end
                end
            end
        end
        return old(...)
    end)
end)
--// Main Target
function HopServer(bO)
    pcall(function()
        if not bO then
            bO = 10
        end
        ticklon = tick()
        repeat
            task.wait()
        until tick() - ticklon >= 1
        local function Hop()
            if not CheckInComBat() then
                for r = 1, math.huge do
                    if ChooseRegion == nil or ChooseRegion == "" then
                        ChooseRegion = "Singapore"
                    else
                        game:GetService("Players").LocalPlayer.PlayerGui.ServerBrowser.Frame.Filters.SearchRegion.TextBox.Text = ChooseRegion
                    end
                    local bP = game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer(r)
                    for k, v in pairs(bP) do
                        if k ~= game.JobId and v["Count"] < bO then
                            game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport", k)
                        end
                    end
                end
            end
            return false
        end
        if not getgenv().Loaded then
            local function bQ(v)
                if v.Name == "ErrorPrompt" then
                    if v.Visible then
                        if v.TitleFrame.ErrorTitle.Text == "Teleport Failed" then
                            HopServer()
                            v.Visible = false
                        end
                    end
                    v:GetPropertyChangedSignal("Visible"):Connect(
                        function()
                            if v.Visible then
                                if v.TitleFrame.ErrorTitle.Text == "Teleport Failed" then
                                    HopServer()
                                    v.Visible = false
                                end
                            end
                        end
                    )
                end
            end
            for k, v in pairs(game.CoreGui.RobloxPromptGui.promptOverlay:GetChildren()) do
                bQ(v)
            end
            game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(bQ)
            getgenv().Loaded = true
        end
        while task.wait(0.1) do
            Hop()
        end
    end)
end
usedEnemy = {} 
table.insert(usedEnemy, lp)
function findvalidlistplayer()
    validplayerlist = {}
    for i, v in pairs(game.Players:GetPlayers()) do
        if v and v.Team and v.Character and v.Character:FindFirstChild("Head") and string.find(string.lower(tostring(v.Team)), "es") 
            and (tostring(lp.Team) == "Pirates" or tostring(v.Team) == "Pirates") and lp.Data.Level.Value - v.Data.Level.Value < 300 and CalcDistance(GetBypassPos(v.Character.HumanoidRootPart.CFrame), v.Character.HumanoidRootPart.CFrame) < 3500
            and not ({["Portal-Portal"] = true, ["Leopard-Leopard"] = false, ["Buddha-Buddha"] = false, ["Kitsune-Kitsune"] = false})[tostring(v.Data.DevilFruit.Value)]
            and not table.find(usedEnemy, v) and not table.find(validplayerlist, v)
            and ((getgenv().Setting["Skip Race V4"] and not (v.Backpack:FindFirstChild("Awakening") or v.Character:FindFirstChild("Awakening"))) or not getgenv().Setting["Skip Race V4"]) then 
            table.insert(validplayerlist, v)
        end
    end
    return validplayerlist
end
function findtarget()
    dist = math.huge
    returnenemy = nil
    for i, v in pairs(findvalidlistplayer()) do
        if v and v.Parent and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if lp and lp.Parent and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                if CalcDistance(v.Character.HumanoidRootPart.CFrame, lp.Character.HumanoidRootPart.CFrame) < dist then
                    returnenemy = v
                    dist = CalcDistance(v.Character.HumanoidRootPart.CFrame, lp.Character.HumanoidRootPart.CFrame)
                end
            end
        end
    end
    if returnenemy ~= nil then
        table.insert(usedEnemy, returnenemy)
        enemy = returnenemy
    else
        hopserver = true
        HopServer()
    end
end
function CheckRaidTarget(q0) 
    for a=1,5,1 do 
        local a0 = game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island"..a) 
        if a0 and WaitHRP(q0, a0:GetModelCFrame()) < 3000 then 
            return true 
        end 
    end 
    return false
end 
NotifyList = {}
function checkNotify(msg)
    for r, k in pairs(game.Players.LocalPlayer.PlayerGui.Notifications:GetChildren()) do
        if k and k.Text and string.find(string.lower(k.Text), msg) and not table.find(NotifyList, k) then
            table.insert(NotifyList, k)
            return true
        end
    end
    return false
end
fromtime = 0
function checktarget() 
    if not enemy then 
        return findtarget() 
    end 
    if not enemy.Parent then 
        return findtarget() 
    end 
    if not enemy.Character then 
        return findtarget() 
    end   
    if enemy.Character.Humanoid.Health <= 0 then
        return findtarget() 
    end
    if (checkNotify("died") or checkNotify("tử trận") or checkNotify("safe") or checkNotify("an toàn")) and enemy:DistanceFromCharacter(lp.Character:WaitForChild("Head", 9).Position) <= 15 then
        return findtarget() 
    end 
    if CheckRaidTarget(enemy) then
        return findtarget() 
    end
    if lp.PlayerGui.Main.BottomHUDList.SafeZone.Visible and enemy:DistanceFromCharacter(lp.Character:WaitForChild("Head", 9).Position) <= 15 then
        return findtarget()
    end
    if enemy:DistanceFromCharacter(lp.Character:WaitForChild("Head").Position) < 300 then 
        if os.time() - fromtime > 100 then 
            if not CheckInComBat() then
                return findtarget()
            end
        end
    else 
        fromtime = os.time() 
    end
    return true
end
--// Gui

local sitinklib = loadstring(game:HttpGet("https://github.com/ErutTheTeru/uilibrary/blob/main/Sitink%20Lib/Source.lua?raw=true"))()

getgenv().alert = function(title, desc) 

    sitinklib:Notify({




	["Title"] = "BluePray.",
	["Description"] = title or "       AutoBounty",
	["Color"] = Color3.fromRGB(127.00000002980232, 146.00000649690628, 242.00000077486038),
	["Content"] = desc or "",
	["Time"] = 1,
	["Delay"] = 10
 
        
    })
end 
local sitinkgui = sitinklib:Start({

    ["Name"] = "BluePray Hub",
    ["Description"] = " Made by : @ghosst",
    ["Info Color"] = Color3.fromRGB(5.000000176951289, 59.00000028312206, 113.00000086426735),
    ["Logo Info"] = "",
    ["Logo Player"] = "",
    ["Name Info"] = "Player Info ",
    ["Name Player"] = "nil",
    ["Info Description"] = "Type: ".. "nil"..", Time Left: ".. "nil",
    ["Tab Width"] = 75,
    ["Color"] = Color3.fromRGB(127.00000002980232, 146.00000649690628, 242.00000077486038),
    ["CloseCallBack"] = function() end
})
local MainTab = sitinkgui:MakeTab("Main")
local Section = MainTab:Section({
    ["Title"] = "Script Configuration",
    ["Content"] = "Watch / Config What Script Will Do"
})

local Seperator = Section:Seperator("Hello User ")
local ScriptTask1= Section:Paragraph({
    ["Title"] = "Copy Discord Link",
    ["Content"] = "Loading..."
})
local MainTab = sitinkgui:MakeTab("Main")
local ScriptTask2 = Section:Button({
    ["Title"] = "Hop Server",
    ["Content"] = "Get New Sever",
    ["Callback"] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Minhnhatz/HopSever/main/HopSever.lua"))()
         HopSever()
    end
})
local MainTab = sitinkgui:MakeTab("Discord")
local ScriptTask3 = Section:Button({
    ["Title"] = "Discord",
    ["Content"] = "Join For Get Notification Update",
    ["Callback"] = function()
    AlchemyNotifyNotify("Copy Discord Link!",5)
    setclipboard("https://discord.gg/")
end)

         Copylink()
    end
})
--// Edit Gui
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local foldername = "Synergy Hub"
local filename = foldername.."/Config.json"
function saveSettings()
    local HttpService = game:GetService("HttpService")
    local json = HttpService:JSONEncode(_G)
    if true then
        if isfolder(foldername) then
            if isfile(filename) then
                writefile(filename, json)
            else
                writefile(filename, json)
            end
        else
            makefolder(foldername)
        end
    end
end
function loadSettings()
    local HttpService = game:GetService("HttpService")
    if isfolder(foldername) then
        if isfile(filename) then
            _G = HttpService:JSONDecode(readfile(filename))
        end
    end
end
_G.Total = 0
_G.Time = 0
loadSettings()
Bounty = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value
Earned = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value - Bounty
Earned2 = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value - Bounty
startTime = tick() - _G.Time
OldTotalEarned = _G.Total 
TotalEarned = _G.Total
function GetAccountElapsedTime(startTime)
    local elapsedTime = tick() - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = math.floor(elapsedTime % 60)
    _G.Time = elapsedTime
    local formattedTime = string.format("%dh:%dm:%ds", hours, minutes, seconds)
    return formattedTime
end
startTime2 = tick()
function GetAccountElapsedTime(startTime)
    local elapsedTime = tick() - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = math.floor(elapsedTime % 60)
    local formattedTime = string.format("%dh:%dm:%ds", hours, minutes, seconds)
    return formattedTime
end
spawn(function()
    while task.wait() do 
        if checktarget() then
            if enemy:DistanceFromCharacter(WaitHRP(lp).Position) <= 30 then
                local skills = getAvailableSkills(getgenv().Setting)
                if skills then
                    equip(skills[3])
                    down(skills[1], skills[2]["Hold Time"])
                end
            end
        end
    end
end)
spawn(function()
    while task.wait() do 
        Current = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value
        Earned = Current - Bounty
        TotalEarned = OldTotalEarned + Earned
        _G.Total = TotalEarned
        task.wait(0.5)
        CrentBounty.Text = "Current Bounty: "..tostring(Current).."$"
        BountyEarned.Text = "Bounty Earned: "..tostring(Current).."$"
        TotalBountyEarned.Text = "Total Bounty Earned: "..tostring(TotalEarned).."$"
        CilentTimeElapsed.Text = "Cilent Time Elapsed: "..tostring(GetCilentElapsedTime(startTime2))
        AccountTimeElapsed.Text = "Account Time Elapsed: "..tostring(GetAccountElapsedTime(startTime))
        saveSettings()
        task.wait(0.5)
    end
end)
CamFarm = getgenv().Setting.Misc["Enable Cam Farm"]
if CamFarm == false then
    game.Players.LocalPlayer.CameraMinZoomDistance = 127
    game.Players.LocalPlayer.CameraMaxZoomDistance = 127
    game.Players.LocalPlayer.CameraMaxZoomDistance = 127
    game.Players.LocalPlayer.CameraMinZoomDistance = 0
else
    CamFarm = true
    game.Players.LocalPlayer.CameraMinZoomDistance = 0
    game.Players.LocalPlayer.CameraMaxZoomDistance = 0
    game.Players.LocalPlayer.CameraMaxZoomDistance = 127
    game.Players.LocalPlayer.CameraMinZoomDistance = 0
end
--// Counter
local foldername = "BluePray AutoBounty"
local filename = foldername.."/Config.json"
function saveSettings()
    local HttpService = game:GetService("HttpService")
    local json = HttpService:JSONEncode(_G)
    if true then
        if isfolder(foldername) then
            if isfile(filename) then
                writefile(filename, json)
            else
                writefile(filename, json)
            end
        else
            makefolder(foldername)
        end
    end
end
function loadSettings()
    local HttpService = game:GetService("HttpService")
    if isfolder(foldername) then
        if isfile(filename) then
            _G = HttpService:JSONDecode(readfile(filename))
        end
    end
end
_G.Total = 0
_G.Time = 0
loadSettings()
Bounty = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value
Earned = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value - Bounty
Earned2 = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value - Bounty
startTime = tick() - _G.Time
OldTotalEarned = _G.Total 
TotalEarned = _G.Total
function GetAccountElapsedTime(startTime)
    local elapsedTime = tick() - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = math.floor(elapsedTime % 60)
    _G.Time = elapsedTime
    local formattedTime = string.format("%dh:%dm:%ds", hours, minutes, seconds)
    return formattedTime
end
startTime2 = tick()
function GetAccountElapsedTime(startTime)
    local elapsedTime = tick() - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = math.floor(elapsedTime % 60)
    local formattedTime = string.format("%dh:%dm:%ds", hours, minutes, seconds)
    return formattedTime
end
spawn(function()
    while task.wait() do 
        if checktarget() then
            if enemy:DistanceFromCharacter(WaitHRP(lp).Position) <= 30 then
                local skills = getAvailableSkills(getgenv().Setting)
                if skills then
                    equip(skills[3])
                    down(skills[1], skills[2]["Hold Time"])
                end
            end
        end
    end
end)
spawn(function()
    while task.wait() do 
        Current = game:GetService("Players").LocalPlayer.leaderstats["Bounty/Honor"].value
        Earned = Current - Bounty
        TotalEarned = OldTotalEarned + Earned
        _G.Total = TotalEarned
        task.wait(0.5)
        CrentBounty.Text = "Current Bounty: "..tostring(Current).."$"
        BountyEarned.Text = "Bounty Earned: "..tostring(Earned).."$"
        TotalBountyEarned.Text = "Total Bounty Earned: "..tostring(TotalEarned).."$"
        CilentTimeElapsed.Text = "Cilent Time Elapsed: "..tostring(GetCilentElapsedTime(startTime2))
        AccountTimeElapsed.Text = "Account Time Elapsed: "..tostring(GetAccountElapsedTime(startTime))
        saveSettings()
        task.wait(0.5)
    end
end)
local radius = 15
local angle = 0
function getNextPosition(center)
    angle = angle + 20
    return center + Vector3.new(math.sin(math.rad(angle)) * radius, 20, math.cos(math.rad(angle)) * radius)
end
function CheckAntiCheatBypass()
    for i,v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
        if v:IsA("LocalScript") then
            if v.Name == "General" or v.Name == "Shiftlock" or v.Name == "FallDamage" or v.Name == "4444" or v.Name == "CamBob" or v.Name == "JumpCD" or v.Name == "Looking" or v.Name == "Run" then
                v:Destroy()
            end
        end
    end
    for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:GetDescendants()) do
        if v:IsA("LocalScript") then
            if v.Name == "RobloxMotor6DBugFix" or v.Name == "Clans" or v.Name == "Codes" or v.Name == "CustomForceField" or v.Name == "MenuBloodSp"  or v.Name == "PlayerList" then
                v:Destroy()
            end
        end
    end
end
CheckAntiCheatBypass()
while task.wait() do 
    if hopserver then 
        to(CFrame.new(0,9000,0))
    else
        if enemy and enemy.Character and enemy.Character:FindFirstChild("Humanoid") and enemy.Character.Humanoid.Health > 4 then
            if game:GetService("Players").LocalPlayer.PlayerGui.Main.PvpDisabled.Visible == true then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("EnablePvp")
            end
            if (not (game.Players.LocalPlayer.Character:FindFirstChild("HasBuso"))) then
                local rel = game.ReplicatedStorage
                rel.Remotes.CommF_:InvokeServer("Buso")
            end
            if game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") and game.Players.LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("ImageLabel") then
                buoi = true
            else
                game:service("VirtualUser"):CaptureController()
                game:service("VirtualUser"):SetKeyDown("0x65")
                game:service("VirtualUser"):SetKeyUp("0x65")
            end 
            if tonumber(lp.Character.Humanoid.Health) > 0 and (tonumber(lp.Character.Humanoid.Health) < getgenv().Setting.Misc["Hide Health"][1] or (hide and tonumber(lp.Character.Humanoid.Health) < getgenv().Setting.Misc["Hide Health"][2])) then 
                hide = true 
                to(WaitHRP(enemy).CFrame+Vector3.new(0,math.random(9999,99999), 0)) 
            else
                hide = false
                local digit = WaitHRP(enemy).CFrame + (WaitHRP(enemy).Velocity/2)
                if digit.Y < 10 then 
                    digit = CFrame.new(digit.X, 10, digit.Z) 
                end 
                CFrameHunt = WaitHRP(enemy).CFrame
                if enemy.Character:FindFirstChild("Busy") and enemy.Character.Busy.Value then
                    to(getNextPosition(CFrameHunt))
                else
                    if enemy.Character:FindFirstChild("Humanoid") and enemy.Character.Humanoid.MoveDirection.Magnitude > 0 then
                        to(digit+Vector3.new(1,4,1))
                        if (not lp.Character:FindFirstChild("Busy") or not lp.Character.Busy.Value) and not game:GetService("Players").LocalPlayer.PlayerGui.Main.InCombat.Visible then
                            Click()
                        end
                    else
                        to(CFrameHunt+Vector3.new(1,4,1))
                    end
                    task.wait(0.1)
                end
            end
        end
    end
end
