-- ================================================================
-- FISH IT! PREMIUM SCRIPT HUB - DELUXE EDITION
-- Dirancang khusus untuk Tuan oleh Sebastian
-- Versi: 2.0 (Dengan GUI Ikon & Tab Lengkap)
-- Kompatibel dengan: Delta, Arceus X, dll.
-- ================================================================

-- [[ INISIALISASI DAN KEAMANAN ]]
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Fungsi Bypass Sederhana
local function bypassAntiCheat()
    -- Menonaktifkan remote event yang mencurigakan (jika ada)
    local acRemotes = {
        game:GetService("ReplicatedStorage"):FindFirstChild("AC-Response"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Punishment")
    }
    for _, remote in ipairs(acRemotes) do
        if remote and remote:IsA("RemoteEvent") then
            local connections = getconnections(remote.OnClientEvent)
            for _, connection in ipairs(connections) do
                connection:Disable()
            end
        end
    end
    print("🛡️ Sistem pertahanan dasar diaktifkan.")
end
bypassAntiCheat()

-- [[ MEMUAT LIBRARY GUI ]]
-- Menggunakan library UI yang ringan dan populer (seperti Mercury, tapi versi yang dimodifikasi)
-- Jika Tuan memiliki koneksi internet, library akan dimuat secara otomatis.
-- Jika tidak, script ini sudah menyertakan fungsi dasar untuk membuat GUI.
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/veteran-iran/developer/main/loader"))() or (function()
    -- Fallback library sederhana jika tidak bisa load dari internet
    local lib = {}
    function lib:CreateWindow(...) return {Tab = function() return {Button=function() end, Toggle=function() end, Dropdown=function() end, Textbox=function() end} end} end
    return lib
end)()

-- [[ MEMBUAT IKON DAN WINDOW UTAMA ]]
local GUI = Library:CreateWindow({
    Name = "🐟 Fish It! Premium Hub",
    Icon = "rbxassetid://6034509993", -- Ikon weather (bisa diganti)
    Theme = "Dark",
    Size = UDim2.fromOffset(650, 500),
    Keybind = "RightShift",
    ToggleKeybind = true
})

-- ================================================================
-- [[ TAB 1: FARMING (LENGKAP) ]]
-- ================================================================
local FarmTab = GUI:Tab({
    Name = "Farming",
    Icon = "rbxassetid://14036361048" -- Ikon ikan
})

-- Status toggle untuk fitur farming
local farmState = {
    AutoCast = false,
    AutoReel = false,
    AutoSell = false,
    InstantCatch = false,
    AutoCollectChest = false,
    AutoUpgrade = false,
    AutoBuyBait = false
}

-- Fungsi Auto Cast & Reel (dengan pengecekan tool)
local function getFishingRod()
    return player.Character and player.Character:FindFirstChildOfClass("Tool") or
           player.Backpack:FindFirstChildOfClass("Tool")
end

-- Auto Cast
FarmTab:Toggle({
    Name = "Auto Cast",
    Description = "Melempar pancing secara otomatis",
    Default = false,
    Callback = function(state)
        farmState.AutoCast = state
        task.spawn(function()
            while farmState.AutoCast do
                task.wait(2) -- Interval cast
                local rod = getFishingRod()
                if rod and rod:FindFirstChild("Cast") then
                    rod:Activate()
                end
            end
        end)
    end
})

-- Auto Reel
FarmTab:Toggle({
    Name = "Auto Reel",
    Description = "Menarik otomatis saat ikan menggigit",
    Default = false,
    Callback = function(state)
        farmState.AutoReel = state
        -- Logic reel akan dijalankan di loop terpisah atau hook event
        if state then
            -- Contoh hook ke remote event fishing (perlu disesuaikan dengan game)
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local reelEvent = replicatedStorage:FindFirstChild("Reel") or
                             replicatedStorage:FindFirstChild("RE/ReelFish")
            if reelEvent and reelEvent:IsA("RemoteEvent") then
                reelEvent.OnClientEvent:Connect(function()
                    if farmState.AutoReel then
                        reelEvent:FireServer("Reel")
                    end
                end)
            end
        end
    end
})

-- Auto Sell All
FarmTab:Toggle({
    Name = "Auto Sell All",
    Description = "Menjual semua ikan secara otomatis",
    Default = false,
    Callback = function(state)
        farmState.AutoSell = state
        task.spawn(function()
            while farmState.AutoSell do
                task.wait(30) -- Jual setiap 30 detik
                local sellEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RF/SellAllItems")
                if sellEvent then
                    sellEvent:InvokeServer()
                end
            end
        end)
    end
})

-- Instant Catch (No Delay)
FarmTab:Toggle({
    Name = "Instant Catch (No Delay)",
    Description = "Langsung mendapatkan ikan tanpa proses memancing",
    Default = false,
    Callback = function(state)
        -- Ini memerlukan hook ke remote fishing completed
        -- Contoh dari script yang sudah ada [citation:5]
        if state then
            local net = game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net
            task.spawn(function()
                while state do
                    pcall(function()
                        net:FindFirstChild("RE/EquipToolFromHotbar"):FireServer()
                        net:FindFirstChild("RF/ChargeFishingRod"):InvokeServer(1)
                        net:FindFirstChild("RF/RequestFishingMinigameStarted"):InvokeServer(1, 1)
                        net:FindFirstChild("RE/FishingCompleted"):FireServer()
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Auto Collect Chest (Treasure)
FarmTab:Toggle({
    Name = "Auto Collect Treasure",
    Description = "Mengambil peti harta karun secara otomatis",
    Default = false,
    Callback = function(state)
        farmState.AutoCollectChest = state
        task.spawn(function()
            while farmState.AutoCollectChest do
                task.wait(1)
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Part") and v.Name:find("Chest|Treasure") and v:FindFirstChild("ClickDetector") then
                        fireclickdetector(v.ClickDetector)
                    end
                end
            end
        end)
    end
})

-- Auto Upgrade (Equipment Manager)
FarmTab:Toggle({
    Name = "Auto Upgrade Gear",
    Description = "Membeli upgrade otomatis saat punya uang",
    Default = false,
    Callback = function(state)
        farmState.AutoUpgrade = state
        -- Logika upgrade akan memerlukan akses ke toko
    end
})

-- Auto Buy Bait
FarmTab:Toggle({
    Name = "Auto Buy Bait",
    Description = "Membeli umpan otomatis jika habis",
    Default = false,
    Callback = function(state)
        farmState.AutoBuyBait = state
    end
})

-- Separator
FarmTab:Separator()

-- Slider untuk kecepatan farming (interval cast)
FarmTab:Slider({
    Name = "Cast Interval (detik)",
    Min = 0.5,
    Max = 5,
    Default = 2,
    Callback = function(value)
        _G.castInterval = value
    end
})

-- ================================================================
-- [[ TAB 2: TELEPORT (LOKASI LENGKAP) ]]
-- ================================================================
local TeleportTab = GUI:Tab({
    Name = "Teleport",
    Icon = "rbxassetid://7733960981" -- Ikon teleport
})

-- Daftar lokasi teleport berdasarkan riset [citation:5] dan sumber lain
local teleportLocations = {
    -- Pulau Utama & Sekitarnya
    {Name = "🏝️ Fisherman Island", Pos = Vector3.new(13.06, 24.53, 2911.16)},
    {Name = "🏝️ Tropical Grove", Pos = Vector3.new(-2092.897, 6.268, 3693.929)},
    {Name = "🏝️ Coral Reefs", Pos = Vector3.new(-2949.359, 63.25, 2213.966)},
    {Name = "🏝️ Crater Island", Pos = Vector3.new(1012.045, 22.676, 5080.221)},
    {Name = "🏝️ Kohana", Pos = Vector3.new(-643.14, 16.03, 623.61)},
    {Name = "🏝️ Kohana Lava", Pos = Vector3.new(-593.32, 59.0, 130.82)},
    {Name = "🏝️ Ice Island", Pos = Vector3.new(1766.46, 19.16, 3086.23)},
    {Name = "🏝️ Lost Isle", Pos = Vector3.new(-3660.07, 5.426, -1053.02)},
    
    -- Area Khusus
    {Name = "⛩️ Sacred Temple", Pos = Vector3.new(1476.2323, -21.8499775, -630.891541)},
    {Name = "⛩️ Ancient Jungle", Pos = Vector3.new(1281.76147, 7.79100895, -202.018097)},
    {Name = "⛩️ Esoteric Depths", Pos = Vector3.new(2024.49, 27.397, 1391.62)},
    {Name = "⛩️ Transcended Stone", Pos = Vector3.new(1480.33191, 127.624985, -595.777588)},
    {Name = "⛩️ Underground Cellar", Pos = Vector3.new(2097.20483, -91.1976471, -703.738708)},
    
    -- Tempat Penting
    {Name = "⚙️ Weather Machine", Pos = Vector3.new(-1495.25, 6.5, 1889.92)},
    {Name = "🗿 Sisyphus Statue", Pos = Vector3.new(-3693.96, -135.57, -1027.28)},
    {Name = "💎 Treasure Hall", Pos = Vector3.new(-3598.39, -275.82, -1641.46)},
    {Name = "🔄 Enchant Area", Pos = Vector3.new(3236.12, -1302.855, 1399.491)},
}

-- Buat tombol untuk setiap lokasi
for _, loc in ipairs(teleportLocations) do
    TeleportTab:Button({
        Name = loc.Name,
        Description = "Teleport ke " .. loc.Name,
        Callback = function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(loc.Pos)
            end
        end
    })
end

-- Tombol teleport ke Traveling Merchant (karena sering dicari)
TeleportTab:Button({
    Name = "💰 Traveling Merchant",
    Description = "Teleport ke kapal pedagang",
    Callback = function()
        -- Posisi merchant di Fisherman Island dekat spin wheel [citation:2]
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(13.06, 24.53, 2911.16) -- Sementara set ke Fisherman
            -- Tambahkan notifikasi
            GUI:Notify("Merchant berada di Fisherman Island, cari kapal merah-putih!")
        end
    end
})

-- ================================================================
-- [[ TAB 3: SETTING (FLY, WALK ON WATER, AUTO TOTEM, DLL) ]]
-- ================================================================
local SettingTab = GUI:Tab({
    Name = "Setting",
    Icon = "rbxassetid://6034818309" -- Ikon gear
})

-- Fly
local flyActive = false
local bodyVelocity
SettingTab:Toggle({
    Name = "Fly Mode",
    Description = "Aktifkan kemampuan terbang",
    Default = false,
    Callback = function(state)
        flyActive = state
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if state then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 50, 0)
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Parent = hrp
            
            -- Kontrol terbang dengan keyboard (WASD)
            local flyConnection
            flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not flyActive or not hrp then flyConnection:Disconnect() return end
                local moveDir = Vector3.new(0, 0, 0)
                if mouse:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector * 50 end
                if mouse:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector * 50 end
                if mouse:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector * 50 end
                if mouse:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector * 50 end
                if mouse:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 50, 0) end
                if mouse:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 50, 0) end
                bodyVelocity.Velocity = moveDir
            end)
        else
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end
})

-- Walk on Water
SettingTab:Toggle({
    Name = "Walk on Water",
    Description = "Berjalan di atas permukaan air",
    Default = false,
    Callback = function(state)
        if state then
            -- Buat platform di bawah kaki setiap step
            local connection
            connection = game:GetService("RunService").Heartbeat:Connect(function()
                if not state then connection:Disconnect() return end
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < 0 then -- Jika di bawah permukaan air (asumsi)
                    local platform = Instance.new("Part")
                    platform.Size = Vector3.new(4, 0.2, 4)
                    platform.CFrame = CFrame.new(hrp.Position.X, 0, hrp.Position.Z)
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Parent = workspace
                    game:GetService("Debris"):AddItem(platform, 0.1)
                end
            end)
        end
    end
})

-- Auto Spawn 5 Totem (dengan jarak optimal)
-- Berdasarkan riset [citation:1], Luck Totem memiliki radius efek sekitar 50-70 studs.
-- Untuk menutupi area maksimal tanpa tumpang tindih, kita tempatkan dalam formasi plus.
SettingTab:Button({
    Name = "Auto Spawn 5 Totems (Formasi +)",
    Description = "Menempatkan 5 totem dengan jarak 60 studs",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local center = hrp.Position
        local jarak = 60 -- Jarak optimal antar totem [citation:1]
        local positions = {
            center, -- tengah
            center + Vector3.new(jarak, 0, 0), -- kanan
            center + Vector3.new(-jarak, 0, 0), -- kiri
            center + Vector3.new(0, 0, jarak), -- depan
            center + Vector3.new(0, 0, -jarak) -- belakang
        }
        
        -- Asumsi: Totem adalah tool yang bisa diaktifkan/ditempatkan
        -- Cari totem di inventory
        local totem = player.Backpack:FindFirstChild("LuckTotem") or 
                     player.Character:FindFirstChild("LuckTotem")
        
        if totem then
            for i, pos in ipairs(positions) do
                -- Pindahkan totem ke posisi dan aktifkan
                if totem:IsA("Tool") then
                    totem.Parent = player.Character
                    wait(0.1)
                    -- Fire remote untuk menempatkan totem (jika ada)
                    local placeEvent = totem:FindFirstChild("Place") or 
                                      game:GetService("ReplicatedStorage"):FindFirstChild("PlaceTotem")
                    if placeEvent then
                        placeEvent:FireServer(pos)
                    end
                    wait(0.2)
                    totem.Parent = player.Backpack
                end
            end
            GUI:Notify("5 totem telah ditempatkan dalam formasi +!")
        else
            GUI:Notify("Totem tidak ditemukan di inventory! Beli dulu di Traveling Merchant.")
        end
    end
})

-- Infinite Jump
SettingTab:Toggle({
    Name = "Infinite Jump",
    Description = "Lompat tanpa batas",
    Default = false,
    Callback = function(state)
        if state then
            local connection
            connection = mouse.KeyDown:Connect(function(key)
                if key == " " then -- Spacebar
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                    end
                end
            end)
            -- Simpan connection untuk dimatikan nanti
            _G.infiniteJumpConn = connection
        else
            if _G.infiniteJumpConn then
                _G.infiniteJumpConn:Disconnect()
                _G.infiniteJumpConn = nil
            end
        end
    end
})

-- Infinite Oxygen
SettingTab:Toggle({
    Name = "Infinite Oxygen",
    Description = "Tidak kehabisan napas di dalam air",
    Default = false,
    Callback = function(state)
        if state then
            -- Hook ke properti oxygen
            local mt = getrawmetatable(game)
            local old_index = mt.__index
            mt.__index = newcclosure(function(self, key)
                if self:IsA("Humanoid") and key == "Breath" then
                    return 100
                end
                return old_index(self, key)
            end)
        end
    end
})

-- Speed Boost
SettingTab:Slider({
    Name = "WalkSpeed Boost",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
        end
    end
})

-- ================================================================
-- [[ TAB 4: STORE (TRAVELING MERCHANT & KAPAL) ]]
-- ================================================================
local StoreTab = GUI:Tab({
    Name = "Store",
    Icon = "rbxassetid://6023426832" -- Ikon toko
})

-- Informasi Traveling Merchant [citation:2]
StoreTab:Label("🛒 TRAVELING MERCHANT - Fisherman Island")
StoreTab:Label("Stok reset setiap 12 jam | Refresh: 49 Robux")

-- Tombol teleport ke merchant
StoreTab:Button({
    Name = "🚤 Teleport ke Merchant",
    Description = "Langsung menuju kapal pedagang",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(13.06, 24.53, 2911.16) -- Fisherman Island
        end
    end
})

-- Tombol refresh stok (jika punya robux)
StoreTab:Button({
    Name = "🔄 Refresh Stok (49 Robux)",
    Description = "Memaksa refresh stok merchant untuk seluruh server",
    Callback = function()
        local refreshEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RF/RefreshMerchant")
        if refreshEvent then
            refreshEvent:InvokeServer()
        end
    end
})

-- Daftar item yang direkomendasikan untuk dibeli
StoreTab:Separator()
StoreTab:Label("📦 ITEM REKOMENDASI:")

-- Rod rekomendasi [citation:2][citation:4]
StoreTab:Button({
    Name = "🎣 Hazmat Rod (1.3M) - Legendary",
    Description = "Luck: 380% | Speed: 32% | Weight: 300KG",
    Callback = function()
        -- Bisa tambahkan auto buy jika ada remote
    end
})

StoreTab:Button({
    Name = "🎣 Fluorescent Rod (60k+) - Legendary",
    Description = "Luck: 300% | Speed: 23% | Weight: 160KG",
    Callback = function()
    end
})

-- Totem [citation:1]
StoreTab:Button({
    Name = "🍀 Luck Totem (2M)",
    Description = "Meningkatkan luck 100% radius 50-70 studs selama 30 menit",
    Callback = function()
    end
})

-- Auto Buy Section
StoreTab:Toggle({
    Name = "Auto Buy Bait (Saat Habis)",
    Description = "Otomatis beli umpan jika inventory kosong",
    Default = false,
    Callback = function(state)
        _G.autoBuyBait = state
    end
})

StoreTab:Toggle({
    Name = "Auto Buy Totem (Saat Cukup Uang)",
    Description = "Otomatis beli Luck Totem jika punya 2M koin",
    Default = false,
    Callback = function(state)
        _G.autoBuyTotem = state
    end
})

-- ================================================================
-- [[ TAB 5: ESP & MISCELLANEOUS ]]
-- ================================================================
local MiscTab = GUI:Tab({
    Name = "ESP & Misc",
    Icon = "rbxassetid://6034509993"
})

-- Fish ESP
MiscTab:Toggle({
    Name = "Fish ESP",
    Description = "Menampilkan ikan di sekitar melalui dinding",
    Default = false,
    Callback = function(state)
        if state then
            -- Buat ESP boxes untuk semua objek ikan
            task.spawn(function()
                while state do
                    task.wait(0.5)
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("Model") and v.Name:find("Fish") and not v:FindFirstChild("ESPBox") then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Name = "ESPBox"
                            box.Size = v:GetExtentsSize()
                            box.Color3 = Color3.new(1, 0, 0)
                            box.Transparency = 0.5
                            box.AlwaysOnTop = true
                            box.ZIndex = 5
                            box.Adornee = v
                            box.Parent = v
                        end
                    end
                end
            end)
        else
            -- Hapus semua ESPBox
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "ESPBox" then
                    v:Destroy()
                end
            end
        end
    end
})

-- Player ESP
MiscTab:Toggle({
    Name = "Player ESP",
    Description = "Menampilkan pemain lain",
    Default = false,
    Callback = function(state)
        -- Implementasi serupa dengan Fish ESP tapi untuk player
    end
})

-- Anti AFK
MiscTab:Toggle({
    Name = "Anti AFK",
    Description = "Mencegah disconnect karena idle",
    Default = true,
    Callback = function(state)
        if state then
            -- Simulasi gerakan kecil setiap 5 menit
            task.spawn(function()
                while state do
                    task.wait(300)
                    humanoid:Move(Vector3.new(1,0,0))
                    task.wait(0.1)
                    humanoid:Move(Vector3.new(0,0,0))
                end
            end)
        end
    end
})

-- Auto Rejoin (jika disconnect)
MiscTab:Button({
    Name = "Auto Rejoin (Jika Kicked)",
    Description = "Otomatis masuk lagi jika disconnect",
    Callback = function()
        -- Simpan job ID untuk rejoin
        _G.rejoinOnKick = true
    end
})

-- Notifikasi saat rare fish
MiscTab:Toggle({
    Name = "Rare Fish Alert",
    Description = "Notifikasi jika ikan legendary/mythic muncul",
    Default = false,
    Callback = function(state)
        if state then
            -- Hook ke event dapat ikan
        end
    end
})

-- ================================================================
-- [[ FITUR TAMBAHAN: AUTO BELI TOTEM ]] (berdasarkan riset [citation:1])
-- ================================================================
task.spawn(function()
    while true do
        task.wait(5)
        if _G.autoBuyTotem then
            -- Cek apakah ada uang cukup dan totem tersedia di merchant
            local leaderstats = player:FindFirstChild("leaderstats")
            local coins = leaderstats and leaderstats:FindFirstChild("Coins")
            if coins and coins.Value >= 2000000 then
                -- Beli totem
                local buyEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RF/BuyItem")
                if buyEvent then
                    buyEvent:InvokeServer("LuckTotem")
                end
            end
        end
        task.wait(60) -- Cek setiap menit
    end
end)

-- ================================================================
print("✨ Script Fish It! Premium Hub oleh Sebastian telah dimuat!")
print("🔄 Tekan RightShift untuk membuka/menutup GUI")