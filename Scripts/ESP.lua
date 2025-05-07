local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Camera = game:GetService("Workspace").CurrentCamera
                local RunService = game:GetService("RunService")

                -- Bảng lưu trữ ESP và trạng thái toggle
                local ESPs = {}
                local isESPEnabled = false

                -- Hàm tạo màu cầu vồng
                local function getRainbowColor()
                    local time = tick()
                    local r = (math.sin(time) + 1) / 2
                    local g = (math.sin(time + 2) + 1) / 2
                    local b = (math.sin(time + 4) + 1) / 2
                    return Color3.new(r, g, b)
                end

                -- Hàm tạo ESP và Tracer cho người chơi
                local function createESP(player)
                    if
                        player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Humanoid") or
                            not player.Character:FindFirstChild("HumanoidRootPart")
                     then
                        return
                    end

                    -- Xóa ESP cũ nếu tồn tại
                    if ESPs[player] then
                        ESPs[player]:Destroy()
                        ESPs[player] = nil
                    end

                    local humanoid = player.Character.Humanoid
                    local rootPart = player.Character.HumanoidRootPart

                    -- Tạo BillboardGui để hiển thị thông tin
                    local billboard = Instance.new("BillboardGui")
                    billboard.Adornee = rootPart
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Name = "ESP"
                    billboard.Parent = player.Character

                    -- Tạo Frame để chứa text
                    local frame = Instance.new("Frame", billboard)
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundTransparency = 1

                    -- Tạo TextLabel để hiển thị thông tin
                    local textLabel = Instance.new("TextLabel", frame)
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.TextColor3 = Color3.new(1, 1, 1)
                    textLabel.TextStrokeTransparency = 0.5
                    textLabel.TextSize = 14
                    textLabel.Font = Enum.Font.SourceSansBold

                    -- Tạo Highlight
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = player.Character
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character

                    -- Tạo Drawing Line cho Tracer
                    local tracer = Drawing.new("Line")
                    tracer.Visible = true
                    tracer.Thickness = 2
                    tracer.Transparency = 1

                    -- Lưu trữ ESP và Tracer
                    ESPs[player] = {
                        Billboard = billboard,
                        Highlight = highlight,
                        TextLabel = textLabel,
                        Tracer = tracer,
                        Connection = nil -- Để lưu kết nối RenderStepped
                    }

                    -- Cập nhật màu Highlight dựa trên team
                    local function updateHighlight()
                        if player.Team == LocalPlayer.Team then
                            highlight.FillColor = Color3.new(0, 1, 0) -- Xanh lá cho cùng team
                        else
                            highlight.FillColor = Color3.new(1, 1, 1) -- Trắng cho khác team
                        end
                    end

                    -- Cập nhật thông tin ESP và Tracer
                    local function updateESP()
                        if
                            player.Character and player.Character:FindFirstChild("Humanoid") and
                                player.Character:FindFirstChild("HumanoidRootPart") and
                                ESPs[player]
                         then
                            local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                            textLabel.Text =
                                string.format(
                                "Name: %s\nHealth: %d\nDistance: %.1f",
                                player.Name,
                                humanoid.Health,
                                distance
                            )
                            updateHighlight()

                            -- Cập nhật Tracer từ giữa phía dưới màn hình đến giữa nhân vật
                            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                            if onScreen then
                                tracer.Visible = true
                                local screenSize = Camera.ViewportSize
                                tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y) -- Giữa phía dưới màn hình
                                tracer.To = Vector2.new(screenPos.X, screenPos.Y) -- Giữa nhân vật
                                tracer.Color = getRainbowColor()
                            else
                                tracer.Visible = false
                            end
                        else
                            -- Xóa ESP nếu nhân vật không hợp lệ
                            if ESPs[player] then
                                ESPs[player]:Destroy()
                                ESPs[player] = nil
                            end
                        end
                    end

                    -- Kết nối cập nhật liên tục
                    local connection = RunService.RenderStepped:Connect(updateESP)
                    ESPs[player].Connection = connection

                    -- Xóa ESP khi nhân vật chết
                    humanoid.Died:Connect(
                        function()
                            if ESPs[player] then
                                ESPs[player]:Destroy()
                                ESPs[player] = nil
                            end
                        end
                    )
                end

                -- Hàm xóa ESP và Tracer
                function ESPs:Destroy()
                    for _, esp in pairs(self) do
                        if esp.Billboard then
                            esp.Billboard:Destroy()
                        end
                        if esp.Highlight then
                            esp.Highlight:Destroy()
                        end
                        if esp.Tracer then
                            esp.Tracer:Remove()
                        end
                        if esp.Connection then
                            esp.Connection:Disconnect()
                        end
                    end
                    for k in pairs(self) do
                        self[k] = nil
                    end
                end

                -- Hàm xử lý khi nhân vật được thêm
                local function onCharacterAdded(player)
                    if isESPEnabled and player.Character then
                        createESP(player)
                    end
                    player.CharacterAdded:Connect(
                        function()
                            if isESPEnabled then
                                wait(0.5) -- Đợi nhân vật tải hoàn toàn
                                createESP(player)
                            end
                        end
                    )
                end

                -- Hàm xử lý người chơi mới
                local function onPlayerAdded(player)
                    onCharacterAdded(player)
                end

                -- Toggle ESP
                isESPEnabled = not isESPEnabled
                if isESPEnabled then
                    -- Kích hoạt ESP cho tất cả người chơi hiện tại
                    for _, player in pairs(Players:GetPlayers()) do
                        onPlayerAdded(player)
                    end
                    -- Theo dõi người chơi mới
                    Players.PlayerAdded:Connect(onPlayerAdded)
                    -- Xóa ESP khi người chơi rời game
                    Players.PlayerRemoving:Connect(
                        function(player)
                            if ESPs[player] then
                                ESPs[player]:Destroy()
                                ESPs[player] = nil
                            end
                        end
                    )
                    print("ESP Enabled")
                else
                    -- Vô hiệu hóa ESP
                    ESPs:Destroy()
                    print("ESP Disabled")
end
