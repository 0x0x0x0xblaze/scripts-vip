-- Load Liblary UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Window Process
local Window = Rayfield:CreateWindow({
	Icon = "braces",
    Name = "RullzsyHUB | Script Loader",
    LoadingTitle = "Created By RullzsyHUB",
    LoadingSubtitle = "Follow Tiktok: @rullzsy99",
})

-- Tab Menu
local ScriptTab = Window:CreateTab("List Scripts", 4483362458)

-- Section
ScriptTab:CreateSection("🟢 TOTAL MAP: 2")

ScriptTab:CreateButton({
    Name = "🟢 MOUNT YAHAYUK | VIP-KING | 14 DAYS",
    Callback = function()
        Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT YAHAYUK...", Duration=4})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20YAHAYUK/main.lua"))()
    end
})

ScriptTab:CreateButton({
    Name = "🟢 MOUNT AGE | VIP-KING | 14 DAYS",
    Callback = function()
        Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT AGE...", Duration=4})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20AGE/main.lua"))()
    end
})

ScriptTab:CreateButton({
    Name = "🟢 MOUNT ARUNIKA | VIP-KING | 14 DAYS",
    Callback = function()
        Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT ARUNIKA...", Duration=4})
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20ARUNIKA/main.lua"))()
    end
})