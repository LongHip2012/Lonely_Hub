getgenv().config = {
                    Setting = {
                        ["Team"] = "Marines", --Pirates\Marines
                        ["Disabled Notify"] = true,
                        ["Boots FPS"] = true,
                        ["White Screen"] = false,
                        ["No Stuck Chair"] = true,
                        ["Auto Rejoin"] = true
                    },
                    ChestFarm = {
                        ["Start Farm Chest"] = true,
                        ["Stop When Have Item"] = true
                    },
                    Webhook = {
                        ["Webhook Url"] = "",
                        ["Send Webhook"] = true
                    }
                }
                loadstring(
                    game:HttpGet(
                        "https://raw.githubusercontent.com/Dex-Bear/Vxezehub/refs/heads/main/VxezeHubAutoChest.lua"
                    )
                )()
