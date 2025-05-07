for i, v in pairs(game:GetObjects("rbxassetid://14759368201")[1]:GetChildren()) do
    v.Parent = game.Workspace.Map
    v:MoveTo(game.Players.LocalPlayer.Character.PrimaryPart.Position + Vector3.new(math.random(-50, 50), 100, math.random(-50, 50)))
    if v.Fruit:FindFirstChild("AnimationController") then
        v.Fruit:FindFirstChild("AnimationController"):LoadAnimation(v.Fruit:FindFirstChild("Idle")):Play()
    end
    v.Handle.Touched:Connect(function(otherPart)
        if otherPart.Parent == game.Players.LocalPlayer.Character then
            v.Parent = game.Players.LocalPlayer.Backpack
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
        end
    end)
end