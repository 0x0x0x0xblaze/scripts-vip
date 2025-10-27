-- =============================================================
-- LOAD RAYFIELD UI
-- =============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =============================================================
-- WINDOW SETUP
-- =============================================================
local Window = Rayfield:CreateWindow({
	Icon = "braces",
	Name = "RullzsyHUB | Script Loader | VIP",
	LoadingTitle = "Created By RullzsyHUB",
	LoadingSubtitle = "Follow Tiktok: @rullzsy99",
	Theme = "Amethyst",
})

-- =============================================================
-- TAB MENU
-- =============================================================
local ScriptTab = Window:CreateTab("List Scripts", "list")
local UpdateTab = Window:CreateTab("Update Script", "file")

-- =============================================================
-- SCRIPT LIST
-- =============================================================
ScriptTab:CreateSection("🟢 TOTAL MAP: 8")

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
	Name = "🟢 MOUNT PARGOY | VIP-KING | 14 DAYS",
	Callback = function()
		Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT PARGOY...", Duration=4})
		loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20PARGOY/main.lua"))()
	end
})

ScriptTab:CreateButton({
	Name = "🟢 MOUNT ANJ | VIP-KING | 14 DAYS",
	Callback = function()
		Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT ANJ...", Duration=4})
		loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20ANJ/main.lua"))()
	end
})

ScriptTab:CreateButton({
	Name = "🟢 MOUNT YNTKTS | VIP-KING | 14 DAYS",
	Callback = function()
		Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT YNTKTS...", Duration=4})
		loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20YNTKTS/main.lua"))()
	end
})

ScriptTab:CreateButton({
	Name = "🟢 MOUNT ARUNIKA | VIP-KING | 14 DAYS",
	Callback = function()
		Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT ARUNIKA...", Duration=4})
		loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20ARUNIKA/main.lua"))()
	end
})

ScriptTab:CreateButton({
	Name = "🟢 MOUNT ANEH (PRO) | VIP-KING | 14 DAYS",
	Callback = function()
		Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT ANEH (PRO)...", Duration=4})
		loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20ANEH%20PRO/main.lua"))()
	end
})

ScriptTab:CreateButton({
	Name = "🟢 MOUNT FUNNY | VIP-KING | 14 DAYS",
	Callback = function()
		Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT FUNNY...", Duration=4})
		loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20FUNNY/main.lua"))()
	end
})

ScriptTab:CreateButton({
	Name = "🟢 MOUNT HMMM | VIP-KING | 14 DAYS",
	Callback = function()
		Rayfield:Notify({Title="Executing", Image="file", Content="Loading MOUNT HMMM...", Duration=4})
		loadstring(game:HttpGet("https://raw.githubusercontent.com/0x0x0x0xblaze/scripts-vip/refs/heads/main/RullzsyHUB%20-%20MOUNT%20HMMM/main.lua"))()
	end
})
-- =============================================================
-- UPDATE SCRIPT
-- =============================================================
local Section = UpdateTab:CreateSection("Update Script Menu")
local Paragraph = UpdateTab:CreateParagraph({
	Title = "Keterangan !!!",
	Content = "Jalankan update script menu, untuk mengupdate ke versi terbaru." .. "\n\n" .. "Panduan Cara Update:" .. "\n" .. "1. Jalankan toggle RUN UPDATE SCRIPT" .. "\n" .. "2. Tunggu sampai selesai update script" .. "\n" .. "3. Jika sudah selesai, silahkan execute ulang script nya."
})

-- Folder target
local targetFolder = "RullzsyHUB_VIP"

-- Label status
local Label = UpdateTab:CreateLabel("📁 STATUS: ...")

-- Toggle Update Script
UpdateTab:CreateToggle({
	Name = "RUN UPDATE SCRIPT",
	CurrentValue = false,
	Callback = function(state)
		if state then
			task.spawn(function()
				Label:Set("📁 STATUS: Menghapus file cache...")
				Rayfield:Notify({
					Title = "Update Script",
					Content = "Proses menghapus cache...",
					Image = "file",
					Duration = 8
				})

				-- Hapus semua file + folder
				if isfolder(targetFolder) then
					local files = listfiles(targetFolder)
					for i, f in ipairs(files) do
						pcall(function() delfile(f) end)
						Label:Set("📁 STATUS: Proses Update ("..i.."/"..#files..")")
						task.wait(0.2)
					end

					-- Hapus folder utama setelah semua file terhapus
					task.wait(0.5)
					pcall(function() delfolder(targetFolder) end)

					Label:Set("📁 STATUS: Proses Update Selesai!...")
					Rayfield:Notify({
						Title = "Update Script",
						Content = "Proses hapus cache selesai...",
						Image = "check",
						Duration = 8
					})
				else
					Label:Set("📁 STATUS: Kamu sudah menggunakan versi terbaru!...")
					Rayfield:Notify({
						Title = "Update Script",
						Content = "Kamu sudah menggunakan versi terbaru, jadi ga usah di update lagi.",
						Image = "alert",
						Duration = 8
					})
				end

				task.wait(2)
				Rayfield:Notify({
					Title = "Proses Selesai",
					Content = "Update script selesai! Silahkan execute ulang script nya...",
					Image = "check-check",
					Duration = 8
				})
				task.wait(3)
				Rayfield:Destroy()
			end)
		end
	end
})
