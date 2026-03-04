-- Loader untuk Fish It! Premium Hub
-- Dibuat oleh [Nama Tuan]

-- Ganti URL di bawah dengan URL RAW script utama Tuan!
local scriptUrl = "https://raw.githubusercontent.com/younm-12/FishItScript/main/fishit_premium.lua"

-- Fungsi untuk mengambil dan menjalankan script
local success, result = pcall(function()
    -- Ambil konten script dari URL [citation:7]
    local content = game:HttpGet(scriptUrl, true)  -- parameter 'true' untuk hindari cache
    
    -- Konversi ke fungsi dan jalankan
    local func = loadstring(content)
    if func then
        func()
        print("✅ Script Fish It! berhasil dimuat!")
    else
        warn("❌ Gagal mengkompilasi script. Cek URL atau koneksi.")
    end
end)

if not success then
    warn("❌ Error: " .. tostring(result))
end

