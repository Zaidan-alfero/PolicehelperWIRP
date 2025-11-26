script_author("Bayden x Zaidan")
-- Raw GitHub Link: https://raw.githubusercontent.com/Zaidan-alfero/PoliceHelperWIRP/main/PoliceHelperWIRP.lua
local http = require 'socket.http'
local imgui = require 'mimgui'
local encoding = require 'encoding'
local ffi = require 'ffi'
local faicons = require('lib.fAwesome6')

encoding.default = 'cp1251'
local samp = require("samp.events")
local u8 = encoding.UTF8

local window = imgui.new.bool(false)
local selectedTab = imgui.new.int(0)
local searchText = imgui.new.char[256]()
local isLoading = true
local loadProgress = 0
local abaSelecionada = "UMUM"
local isRPRunning = false
local isRunning = false
local perampokanLocationInput = imgui.new.char[64]()

local lastColors = {}
local dutyActive = {}
local defaultColor = 0xFFFFFFFF

local pasalList = {
    "1.1,Membawa Minuman Beralkohol,$3000,HUKUMAN SOSIAL",
    "1.2,Mengganggu ketertiban Umum / Provokator,$3500,5 BULAN",
    "1.3,Tidak Membawa Kartu Identitas (KTP),$5000,7 BULAN",
    "1.4,Penganiayaan / Melukai Warga,$10.000,15 BULAN",
    "1.5,Penghinaan Terhadap Warga,$4000,8 BULAN",
    "1.6,Telanjang / Memakai Topeng Di Area Publik,$3000,7 BULAN",
    "1.7,Penipuan / Pemberi Informasi Palsu,$15.000,13 BULAN",
    "1.8,Pencemaran Nama Baik / Perbuatan Tidak Menyenangkan,$8000,10 BULAN",
    "1.9,Mencuri / Merusak Kendaraan,$8500,10 BULAN",
    "1.10,Perjudian / Tawuran Yang Mengganggu Aktivitas,$10.000,10 BULAN",
    "1.11,Mabuk Di Area Publik,$7000,8 BULAN",
    "1.12,Pembobolan atau Mencuri (Kendaraan / Rumah ),$10000,12 BULAN",
    "1.13,Melakukan Kekerasan Berupa (Meludah | Menampar dan Perbuatan Melawan Hukum),$8000,10 BULAN",
    "1.14,Mengambil Barang Orang tersebut secara Paksa Menggunakan Kekerasan,$10000,13 BULAN",
    "1.15,Mengambil Barang Milik Orang Lain Dengan Nilai Lebih Dari $10.000,$15.000,15 BULAN",
    "1.16,Tindakan Mengekspioitasi Privasi Orang Lain,$10.000,10 BULAN",
    "1.17,Tindakan menjual Manusia Untuk Kepentingan Pribadi,$14.000,15 BULAN",
    "1.18,Penyalahgunaan Layanan /911,$7000,7 BULAN",
    "1.19,Mencoba Menyuap Petugas Untuk Kepentingan Pribadi,$14.000,15 BULAN",
    "1.20,Merusak | Mengotori atau Menghancurkan Properti Orang lain / Pemerintah,$13.000,15 BULAN",
    "1.21,Menyimpan Barang Ilegal,$10.000,10 BULAN",
    "2.1,Menghina Instansi Secara Lisan atau Tulisan,$20.000,20 BULAN",
    "2.2,Berada Di Zona Merah atau Zona Terlarang,$8000,10 BULAN",
    "2.3,Penyalahgunaan Atribut Kepolislan,$9.000,7 BULAN",
    "2.4,Pemakai / Pecandu Barang Ilegal,$9000,10 BULAN",
    "2.5,Pejabat Publik Menyalahgunakan Kepercayaan Publik,$13.000,15 BULAN",
    "2.6,Menghancurkan / Menghilangkan Barang Bukti,$15.000,17 BULAN",
    "2.7,Menyerang Petugas Dengan Sengaja Tanpa Senjata,$15.000,15 BULAN",
    "2.8,Menyamar Sebagai Staff Instansi Untuk Keuntungan Pribadi,$25.000,13 BULAN",
    "2.9,Penelpon Palsu / Penelpon Prank,$10.000,8 BULAN",
    "2.10,Menolak dan Melawan Dengan Petugas Saat Penangkapan,$10.000,8 BULAN",
    "2.11,Memberikan Informasi Paisu kepada Petugas Selama Penyelidikan,$10.000,13 BULAN",
    "2.12,Mengganggu Aparat Penegak Hukum Yang Sedang Bertugas,$11.000,15 BULAN",
    "2.13,Sengaja Mengintimidasi Petugas Penegak Hukum Selama Bertugas,$8000,10 BULAN",
    "2.14,Menyebabkan Kerugian kepada Hewan Spesies Apapun,$5000,7 BULAN",
    "2.15,Meiakukan Panggilan Telephone / Pesan Yang Melecehkan,$10.000,15 BULAN",
    "2.16,Menghakimi Diri Sendiri Tanpa Prosedur Yang SAH,$7000,9 BULAN",
    "2.17,Mendistribusikan Opini Kebencian kepada Seseorang / Kelompok,$8000,10 BULAN",
    "2.18,Menodongkan Senjata Api Di Publik,$13.000,17 BULAN",
    "2.19,Tindakan Membakar Properti Milik Orang Lain,$9000,10 BULAN",
    "2.20,Pembobolan atau Pencurian (Kendaraan / Rumah ),$12.000,15 BULAN",
    "2.21,Membawa Barang Ilegal Berupa Kanabis >8,$10.000,14 BULAN",
    "2.22,Membawa Barang Ilegal Berupa Kanabis >8,$12.000,15 BULAN",
    "2.23,Membawa Barang Ilegal Berupa Kanabis >20,$15.000,16 BULAN",
    "2.24,Membawa Barang Ilegal Berupa Kanabis >40,$17.000,20 BULAN",
    "2.25,Membawa Barang Ilegal Berupa Marijuana <8,$12.000,15 BULAN",
    "2.26,Membawa Barang Ilegal Berupa Marijuana >8,$15.000,17 BULAN",
    "2.27,Membawa Barang Ilegal Berupa Marijuana >20,$17.000,20 BULAN",
    "2.28,Membawa Barang Ilegal Berupa Marijuana >40,$20.000,25 BULAN",
    "2.29,Membawa Barang Ilegal Berupa Marijuana <100,$15.000,15 BULAN",
    "2.30,Membawa Barang Ilegal Berupa Marijuana >100,$17.000,18 BULAN",
    "2.31,Membawa Barang Ilegal Berupa Marijuana >200,$20.000,21 BULAN",
    "2.32,Membawa Barang Ilegal Berupa Marijuana >300,$25.000,25 BULAN",
    "2.33,Membawa Uang Kotor >500,$10.000,13 BULAN",
    "2.34,Membawa Uang Kotor >500,$15.000,15 BULAN",
    "2.35,Membawa Uang Kotor >3000,$17.000,16 BULAN",
    "2.36,Membawa Uang Kotor >5000,$20.000,20 BULAN",
    "2.37,Seseorang Yang Berada Di Tempat Produksi Obat Terlarang,$20.000,25 BULAN",
    "2.38,Menjual Obat Obatan Terlarang Terhadap Orang Lain,$15.000,20 BULAN",
    "2.39,Memperilhatkan Senjata Di Area Publik,$15.000,10 BULAN",
    "2.40,Melakukan Tindakan Perampokan Market:,$15.000,15 BULAN",
    "2.41,Melakukan Tindakan Perampokan ATM,$14.000,15 BULAN",
    "2.42,Melakukan Perampokan Bank Besar / Flecca,$20.000,30 BULAN",
    "2.43,Mengancam Seseorang Melalui Massage / Telephone,$20.000,30 BULAN",
    "2.44,Pecandu / Pengguna Obat – Obatan Terlarang,$15.000,15 BULAN",
    "3.1,Kepemilikan Senjata Ilegal < 20 Ammo (Rifle SLC DE ),$15.000,25 BULAN",
    "3.2,Kepemilikan Senjata Ilegal > 20 Ammo (Rifle SLC DE),$20.000,28 BULAN",
    "3.3,Kepemilikan Senjata Ilegal > 50 Ammo (Rifle SLC DE),$30.000,30 BULAN",
    "3.4,Kepemilikan Senjata Ilegal > 100 Ammo (Rifle SLC DE),$40.000,60 BULAN",
    "3.5,Kepemilikan Senjata Ilegal > 200 Ammo (Rifle SLC DE),$50.000,HUKUMAN MATI / SEUMUR HIDUP",
    "3.6,Kepemilikan Senjata Berat Ilegal < 50 (AK47 SG UZ1),$30.000,55 BULAN",
    "3.7,Kepemilikan Senjata Berat Ilegal > 50 (AK47 SG UZ1),$40.000,60 BULAN",
    "3.8,Kepemilikan Senjata Berat Ilegal > 100 (AK47 SG UZ1),$47.500,80 BULAN",
    "3.9,Kepemilikan Senjata Berat Ilegal > 200 (AK47 SG UZ1),$50.000,HUKUMAN MATI / SEUMUR HIDUP",
    "3.10,Mendistribusikan Barang Ilegal Berupa (Marijuana Kanabis Material) < 500,$50.000,60 BULAN",
    "3.11,Mendistribusikan Barang Ilegal Berupa (Marijuana Kanabis Material) > 500,$50.000,HUKUMAN MATI / SEUMUR HIDUP",
    "3.12,Membawa Barang Ilegal Berupa (Marijuana Kanabis Material) > 300,$50.000,50 BULAN",
    "3.13,Membawa Barang Ilegal Berupa (Marijuana Kanabis Material) > 400,$50.000,HUKUMAN MATI / SEUMURHIDUP",
    "3.14,Penyelundupan / Perdagangan Senjata Ilegal < 100 Ammo,$45.000,40 BULAN",
    "3.15,Penyelundupan / Perdagangan Senjata Ilegal > 100 Ammo,$50.000,60 BULAN",
    "3.16,Penyelundupan / Perdagangan Senjata Ilegal > 200 Ammo,$50.000,HUKUMAN MATI / SEUMUR HIDUP",
    "3.17,Menyimpan | Menyembunyikan Atau Melinduingi Perijahat / Narapidana (DPO ),$50.000,120 BULAN",
    "3.18,Melakukan Perbuatan Melawan Hukum Membunuh Orang Dengan Sengaja / Pembunuhan Berencana,$50.000,HUKUMAN MATI / SEUMUR HIDUP",
    "3.19,Penyanderaan Terhadap Warga,520.000,20 BULAN",
    "3.20,Penyanderaan Terhadap Instantsi,$30.000,40 BULAN",
    "3.21,Penembakan Terhadap Warga,$20.000,20 BULAN",
    "3.22,Penembakan Terhadap Instantsi,$30.000,30 BULAN",
    "3.23,Peperangan Antar Kelompok,$35.000,30 BULAN",
    "3.24,Pembegalan Terhadap Warga,$25.000,27 BULAN",
    "3.25,Pembegalan Terhadap Instantsi,$25.000,30 BULAN",
    "3.26,Menunjukkan Senjata Tajam / Tumpul Untuk Mengancam Seseorang,$30.000,35 BULAN",
    "3.27,Membantu Penjahat Untuk Keluar Darî Hukuman,$40.000,45 BULAN",
    "3.28,Melakukan Pengancaman Terhadap Warga Untuk Kepentingan Pribadi,$45.000,40 BULAN",
    "3.29,Melakukan Pengancaman Terhadap Anggota Instantsi Untuk Kepentingan Pribadi,$50.000,60 BULAN",
    "3.30,Seseorang Yang Berada Di Tempat Produksi / Crafting Persenjataan,$50.000,70 BULAN",
    "3.31,Kepemilikan Senjata Ilegal Berjenis DE < 20 Peluru,$50.000,25 BULAN",
    "3.32,Kepemilikan Senjata Ilegal Berjenis DE > 20 Peluru,$75.000,28 BULAN",
    "3.33,Kepemilikan Senjata Ilegal Berjenis DE > 50 Peluru,$90.000,30 BULAN",
    "3.34,Kepemilikan Senjata Ilegal Berjenis DE > 150 Peluru,$120.000,60 BULAN",
    "3.35,Kepemilikan Senjata Ilegal Berjenis DE > 200 Peluru,$450.000,HUKUMAN MATI / SEUMUR HIDUP",
    "4.1,Parkir Sembarangan,Tilang $10.000,-",
    "4.2,Tidak Memakai Helm Atau Seatbelt,$5.000,-",
    "4.3,Berhenti Pada Jalur Cepat Atau Bahu Jalan Tol,$8.000,-",
    "4.3,Ugal – Ugalan Dijalan Raya,$10.000,SITA SIM",
    "4.4,Berkendara Dalam Kondisi Mabuk Atau Pengaruh Obat Obatan,$7.000,-",
    "4.5,Mengikuti Balap Llar,$30.000,50 BULAN",
    "4.6,Mengemudi Di Jalur Yang Salah,-,SITA SIM",
    "4.7,Memotong Persimpangan Yang Dapat Menyebabkan Kecelakaan,$7.000,-",
    "4.8,Pengemudi Tidak Memiliki SIM,$5.000,-",
    "4.9,Mengendarai Kendaraan Dengan Keeepatan Yang Melebihi Batas,$9.000,-",
    "4.10,Berkendara Melebihi Muatan Atau Penumpang,$7.000,SITA SIM",
    "4.11,Sayap Spoller Yang Menghalangi Pandangan Belakang Pengemudi,$10.000,-",
    "4.12,Penggunaan Stiker Yang Menyinggung Atau Mengganggu,$10.000,10 BULAN",
    "4.13,Pengemudi Dengan Sengaja Menabrak Hingga Meninggalkan Bekas Luka / Tabrak Lari,$15.000,10 BULAN",
    "4.14,Pengemudi Dengan Sengaja Menghindar Dari Petugas Penegak Hukum,$15.000,15 BULAN",
    "4.15,Kendaraan Berada Di Lokasi Peperangan,Tilang $10.000,-",
    "4.16,Kendaraan Suspect Perampokan,Tilang $10.000,-",
    "4.17,Memberikan Perlawanan Pada Saat Diberhentikan Oleh Petugas Penegak Hukum,$10.000,10 BULAN",
    "4.18,Penggunaan Modshop Knalpot Yang Berlebihan,$10.000,-",
    "4.19,Penggunaan Aksesoris kepolisian,$15.000,-",
}

local filteredPasal = {}

local scale = 1.5
local columnWidth = {
    pasal_ayat = 50 * scale,
    pelanggaran = 250 * scale,
    denda = 90 * scale,
    sanksi = 300 * scale,
}

local calcInput = ""
local calcResult = "0"
local cursorPos = 1

local function parsePasal(pasalList)
    local pasal = {}
    for _, line in ipairs(pasalList) do
        local pasal_ayat, pelanggaran, denda, sanksi = string.match(line, "([^,]+),([^,]+),([^,]+),([^,]+)")
        if pasal_ayat and pelanggaran and denda and sanksi then
            table.insert(pasal, { pasal_ayat = pasal_ayat, pelanggaran = pelanggaran, denda = denda, sanksi = sanksi })
        end
    end
    return pasal
end

local pasalData = parsePasal(pasalList)

local function applyFilterPasal()
    filteredPasal = {}
    local search = string.lower(ffi.string(searchText))
    for _, pasal in ipairs(pasalData) do
        if string.find(string.lower(pasal.pasal_ayat), search) or
           string.find(string.lower(pasal.pelanggaran), search) or
           string.find(string.lower(pasal.denda), search) or
           string.find(string.lower(pasal.sanksi), search) then
            table.insert(filteredPasal, pasal)
        end
    end
end

local function runRP(actions)
    if isRPRunning then
        sampAddChatMessage("[#FF0000]Run RP sudah berjalan! Gunakan /rpstop untuk menghentikan RP sebelumnya.", -1)
        return
    end
    isRPRunning = true
    sampAddChatMessage("{FFFF00}Run RP sedang berjalan. Silahkan gunakan {FF0000}/rpstop{FFFF00} untuk menghentikan RP", -1)
    lua_thread.create(function()
        for _, action in ipairs(actions) do
            if not isRPRunning then break end
            sampSendChat(action)
            wait(2000)
        end
        if isRPRunning then
            sampAddChatMessage("{00FF00}Auto RP By Bayden x Zaidan Selesai.", -1)
        end
        isRPRunning = false
    end)
end

function stopRPCommandHandler()
    if isRPRunning then
        isRPRunning = false
        sampAddChatMessage("{FF0000}Run RP dihentikan oleh pemain.", -1)
    elseif isRunning then
        isRunning = false
        sampAddChatMessage("{FF0000}RP Action dihentikan oleh pemain.", -1)
    else
        sampAddChatMessage("{FFFF00}Tidak ada Run RP yang sedang berjalan.", -1)
    end
end
sampRegisterChatCommand("rpstop", stopRPCommandHandler)

local function runRPWithNotifications(actions)
    if isRunning then
        sampAddChatMessage("{FF0000}[INFO] RP Action sedang berjalan. Gunakan /bststop untuk menghentikan.", -1)
        return
    end

    isRunning = true
    sampAddChatMessage("{05e2ff}[INFO] RP Action dimulai. Gunakan /bststop untuk menghentikan.", -1)

    lua_thread.create(function()
        for _, action in ipairs(actions) do
            if not isRunning then break end
            sampSendChat(action)
            wait(1200)
        end
        if isRunning then
            sampAddChatMessage("{00ff00}- RP Action selesai dijalankan. Script ini dibuat oleh Bayden x Zaidan.", -1)
        end
        isRunning = false
    end)
end

function stopRPWithNotificationsCommandHandler()
    if isRunning then
        isRunning = false
        sampAddChatMessage("{FF0000}RP Action dihentikan oleh pemain.", -1)
    else
        sampAddChatMessage("{FFFF00}Tidak ada RP Action yang sedang berjalan untuk /bststop.", -1)
    end
end
sampRegisterChatCommand("bststop", stopRPWithNotificationsCommandHandler)




imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    local iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14 * scale, config, iconRanges)
    local style = imgui.GetStyle()
    style.FramePadding = imgui.ImVec2(8, 4) * scale
    style.FrameRounding = 4.0 * scale
    imgui.GetStyle():ScaleAllSizes(scale)
    style.ScrollbarSize = 20.0 * scale
end)

function samp.onServerMessage(color, text)
    local cleanText = text:gsub("{%x+}", "")
    if cleanText:find("%[info%]: Anda withdraw uang dari atm") then
        runRPWithNotifications({ "/me mengambil sejumlah uang dari mesin ATM"})
        return
    end

    if cleanText:find("%[info%]: Anda deposit uang ke atm") then
        runRPWithNotifications({ "/me menyimpan uang kedalam kedalam mesin atm"})
        return
    end

    if cleanText:find("%(Action%): (Membuka|Mengunci) pintu kendaraan") then
        local action = string.match(cleanText, "Membuka") and "membuka" or "mengunci"
        runRPWithNotifications({ string.format("/me menekan tombol Central Lock untuk %s kunci pintu kendaraan", action)})
        return
    end

    if cleanText:find("%(Action%): Mengambil handphone kemudian menyalakannya") then
        runRPWithNotifications({ "/me mengambil handphone dari saku kanan dan menyalakannya"})
        return
    end

    if cleanText:find("%(Action%): Menutup handphone dan menaruhnya di kantong") then
        runRPWithNotifications({ "/me menyimpan kembali handphone ke saku kanan menggunakan tangan kanan"})
        return
    end

    if cleanText:find("%(Action%): Mencoba menyalakan mesin") then
        runRPWithNotifications({ "/me menyalakan kendaraan dengan menekan tombol engine"})
        return
    end

    if cleanText:find("%(Action%): Mesin menyala") then
        runRPWithNotifications({ "/do kendaraan berhasil menyala"})
        return
    end

    if cleanText:find("%(Action%): Mesin mati") then
        runRPWithNotifications({ "/do mesin kendaraan telah mati"})
        return
    end
end

local pelayananIDInput = imgui.new.char[64]()
local pelayananNominalInput = imgui.new.char[64]()
local faLocationInput = imgui.new.char[64]()

local function drawGeneralTabContent(button_width, button_height, inputWidth)
    imgui.Text("Pelayanan")
    imgui.Separator()

    imgui.Columns(2, "PelayananInputColumns", false)
    imgui.SetColumnWidth(0, inputWidth + (15 * scale))
    imgui.SetColumnWidth(1, inputWidth + (15 * scale))

    imgui.Text("Input ID"); imgui.NextColumn()
    imgui.Text("Input Nominal"); imgui.NextColumn()

    imgui.SetNextItemWidth(inputWidth)
    imgui.InputText("##PelayananID", pelayananIDInput, 64, imgui.InputTextFlags.CharsDecimal + imgui.InputTextFlags.AutoSelectAll); imgui.NextColumn()
    imgui.SetNextItemWidth(inputWidth)
    imgui.InputText("##PelayananNominal", pelayananNominalInput, 64, imgui.InputTextFlags.CharsDecimal + imgui.InputTextFlags.AutoSelectAll); imgui.NextColumn()

    imgui.Columns(1)
    imgui.Spacing()

    imgui.BeginGroup()
        if imgui.Button("STOP RP", imgui.ImVec2(button_width, button_height)) then stopRPCommandHandler() end
        imgui.SameLine()
        if imgui.Button("SID", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/sid") end
        imgui.SameLine()
        if imgui.Button("DL", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/dl") end
        imgui.SameLine()
        if imgui.Button("SV", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/sv") end
        imgui.EndGroup()
        
        imgui.BeginGroup()
        if imgui.Button("Cetak SIM", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(pelayananIDInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Pelayanan) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/me mencetak kartu sim dengan bantuan komputer",
                        "/e geledah",
                        "/ame proses",
                        "/ame 1/2",
                        "/ame 2/2",
                        "/ame selesai",
                        "/e x",
                        "/me memberikan kartu sim kepada orang di depan dengan menggunakan kedua tangan",
                        string.format("/givesim %s", ffi.string(pelayananIDInput)),
                        "/do sim telah diberikan kepada orang di depan"
                 })
             end
         end
         imgui.SameLine()
        if imgui.Button("AKSES SIM", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(pelayananIDInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Pelayanan) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/me memberikan tiket akses untuk masuk ke lapangan ujian SIM",
                        string.format("/kasihakses %s", ffi.string(pelayananIDInput)),
                        "/do tiket akses telah di berikan kepada orang di depan"
                 })
             end
         end
         imgui.SameLine()
        if imgui.Button("PLAT", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(pelayananIDInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Pelayanan) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/me memeriksa plate kendaraan didepan dengan seksama",
                        "/me memperbarui plate  kendaraan didepan dengan bantuan kedua tangan dan alat yang telah dibawa",
                        "/e geledah",
                        "/do proses",
                        "/do 1/2",
                        "/do 2/2",
                        "/do done",
                        string.format("/giveplate %s", ffi.string(pelayananIDInput)),
                        "/e x",
                        "/do plat kendaraan baru telah terpasang"
                 })
             end
         end
         imgui.SameLine()
        if imgui.Button("INVOICE", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(pelayananNominalInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Nominal) harus diisi.", -1)
            else
                local command = string.format("/memberikan invoice sebesar %s kepada orang didepan", ffi.string(pelayananNominalInput))
                sampSendChat(command)
            end
        end
    imgui.EndGroup()

    imgui.BeginGroup()
    if imgui.Button("SKCK", imgui.ImVec2(button_width, button_height)) then
                runRPWithNotifications({
                        "/me mencetak surat SKCK dengan bantuan komputer",
                        "/do proses",
                        "/do 1/2",
                        "/do 2/2",
                        "/do done",
                        "/me memberikan surat SKCK kepada orang di depan dengan menggunakan kedua tangan"
                 })
    end
    imgui.SameLine()
        if imgui.Button("TILANG", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(pelayananNominalInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Nominal) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/me menempelkan surat tilang ke kaca kendaraan di depan dengan bantuan kedua tangan",
                        string.format("/tilang %s", ffi.string(pelayananNominalInput)),
                        "/do berhasil menempelkan surat tilang di kendaraan"
                 })
             end
         end
    imgui.EndGroup()

    imgui.Spacing()

    imgui.Text("Action")
        imgui.Separator()

        imgui.BeginGroup()
        if imgui.Button("GELEDAH", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me menggeledah orang didepan dengan bantuan kedua tangan",
                        "/e geledah",
                        "/ame sedang menggeledah"
                 })
         end
        imgui.SameLine()
        if imgui.Button("GENDONG", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me menggendong orang di depan dengan bantuan kedua tangan",
                        "/ame sedang menggendong seseorang"
                 }) end
        imgui.SameLine()
        if imgui.Button("HORMAT", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me memberikan hormat kepada orang di depannya",
                        "/e hormat",
                        "/ame hormat"
                 }) end
        imgui.SameLine()
        if imgui.Button("RP GUN", imgui.ImVec2(button_width, button_height)) then
            sampSendChat("/me mengeluarkan senjata dari sabuk pengaman dan siap menembak kapan saja") end
        imgui.EndGroup()
        imgui.Spacing()

        imgui.BeginGroup()
        if imgui.Button("BORGOL", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me mengeluarkan sebuah borgol dari dalam tas dengan bantuan tangan kanan",
                        "/me memborgol orang di depan menggunakan kedua tangan lalu mengunci borgolnya",
                        "/do ter borgol"
                 })
         end
        imgui.SameLine()
        if imgui.Button("TAZER", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me mengeluarkan alat tazer dari dalam tas menggunakan tangan kanan dan siap untuk menyentrum orang di depan",
                        "/do tazer telah berada di tangan",
                        "/tazer"
                 })
         end
         imgui.SameLine()
        if imgui.Button("WP DROP", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me menjatuhkan senjata ke lantai",
                        "/weapon drop",
                        "/do senjata telah tergeletak di lantai"
                 })
         end
         if imgui.Button("WP TAKE", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me mengambil senjata yang ada di bawah",
                        "/weapon pickup",
                        "/do senjata telah terambil"
                 })
         end
        imgui.EndGroup()
        imgui.Spacing()
        
        imgui.BeginGroup()
        if imgui.Button("FLARE", imgui.ImVec2(button_width, button_height)) then
            runRPWithNotifications({
                        "/me menyalakan sebuah flare lalu meletakkan di tanah secara hati hati",
                        "/do flare yang menyala telah di letakkan di tanah",
                        "/flare"
                 })
         end
         imgui.SameLine()
        if imgui.Button("GATE", imgui.ImVec2(button_width, button_height)) then sampSendChat({"/gate"}) end
        imgui.EndGroup()
        imgui.Spacing()

    imgui.Text("Megaphone")
        imgui.Separator()

        imgui.BeginGroup()
        if imgui.Button("FELONY", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/m HARAP KENDARAAN DI DEPAN MEMATIKAN MESINNYA! DAN BAGI PARA PENGEMUDI ATAUPUN PENUMPANG JANGAN TURUN DARI KENDARAAN, APABILA TIDAK, AKAN KAMI TEMBAK!")
         end
      imgui.SameLine()
      if imgui.Button("PARKIR", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/m HARAP KENDARAAN DIPARKIRKAN KEDALAM GARKOT ATAU AKAN DITILANG")
         end
      imgui.SameLine()
       if imgui.Button("MENEPI", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/m HARAP KENDARAAN DI DEPAN UNTUK MENEPIKAN KENDARAAN DAN MEMATIKAN MESIN KENDARAAN")
         end
        imgui.SameLine()
        if imgui.Button("MENJAUH", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/m WARGA YANG TIDAK BERKEPENTINGAN HARAP MENJAUH DARI AREA INI ATAU KAMI TINDAK TEGAS")
         end
        imgui.EndGroup()
        imgui.BeginGroup()
       if imgui.Button("WARN 1", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/m HARAP KENDARAAN DIDEPAN UNTUK MENEPIKAN KENDARAAN ATAU KAMI TINDAK TEGAS!")
         end
       imgui.SameLine()
       if imgui.Button("WARN 2", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/m HARAP KENDARAAN DIDEPAN UNTUK MENEPIKAN KENDARAAN ATAU KAMI TINDAK TEGAS!!")
         end
        imgui.SameLine()
       if imgui.Button("WARN 3", imgui.ImVec2(button_width, button_height)) then
                sampSendChat("/m PERINGATAN TERAKHIR - HARAP KENDARAAN DIDEPAN UNTUK MENYERAH DAN MENEPIKAN KENDARAAN ATAU AKAN KAMI TINDAK TEGAS SEKARANG!!!")
         end
        imgui.EndGroup()
        imgui.Spacing()

    imgui.Text("Fa")
        imgui.Separator()

        imgui.BeginGroup()
        imgui.SetNextItemWidth(inputWidth)
        imgui.InputText("##FaLocation", faLocationInput, 64, imgui.InputTextFlags.AutoSelectAll)
        imgui.SameLine()
        if imgui.Button("WARN ROB", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(faLocationInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Lokasi) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/fa [ MIC : ON ]",
                        string.format("/fa TELAH TERJADI PENYANDERAAN DAN PERAMPOKAN DI AREA %s", ffi.string(faLocationInput)),
                        "/fa DIHARAPKAN UNTUK WARGA MENJAUH DARI AREA PENYANDERAAN DAN PERAMPOKAN",
                        "/fa JIKALAU ADA YANG MENDEKAT MAKA AKAN KAMI TINDAK TEGAS! TERIMAKASIH.",
                        "/fa [ MIC : OFF ]"
                 })
             end
         end
        imgui.SameLine()
        if imgui.Button("ROB CLEAR", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(faLocationInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Lokasi) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/fa [ MIC : ON ]",
                        string.format("/fa PERAMPOKAN DI AREA %s TELAH DISELESAIKAN", ffi.string(faLocationInput)),
                        "/fa BAGI WARGA DIPERSILAHKAN UNTUK BERAKTIVITAS SEPERTI BIASA",
                        "/fa TETAP BERHATI-HATI DALAM BERKENDARA",
                        "/fa SEKIAN DAN TERIMAKASIH",
                        "/fa [ MIC : OFF ]"
                 })
             end
         end
        imgui.EndGroup()
        imgui.BeginGroup()
        if imgui.Button("ON SERVICE", imgui.ImVec2(button_width, button_height)) then
                 runRPWithNotifications({
                        "/fa [ MIC : ON ]",
                        "/fa DI BERITAHUKAN KEPADA WARGA BAHWA PELAYANAN KEPOLISIAN TELAH DI BUKA",
                        "/fa BAGI WARGA YANG INGIN MEMBUAT SKCK ATAU SIM SILAHKAN UNTUK DATANG KE KANPOL",
                        "/fa SEKIAN DAN TERIMAKASIH",
                        "/fa [ MIC : OFF ]"
                 })
         end
        imgui.SameLine()
        if imgui.Button("OFF SERVICE", imgui.ImVec2(button_width, button_height)) then
                runRPWithNotifications({
                        "/fa [ MIC : ON ]",
                        "/fa DIBERITAHUKAN KEPADA WARGA BAHWA PELAYANAN KEPOLISIAN TELAH DI TUTUP",
                        "/fa TERIMAKASIH TELAH DATANG KE KANTOR POLISI",
                        "/fa TETAP BERHATI-HATI DALAM BERKENDARA",
                        "/fa SEKIAN DAN TERIMAKASIH KASIH",
                        "/fa [ MIC : OFF ]"
                 })
         end
        imgui.SameLine()
        if imgui.Button("WARN WAR", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(faLocationInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Lokasi) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/fa [ MIC : ON ]",
                        string.format("/fa TELAH TERJADI PENEMBAKAN DI AREA %s ", ffi.string(faLocationInput)),
                        "/fa DIHARAPKAN AGAR WARGA TIDAK MENDEKATI KE LOKASI PENEMBAKAN",
                        "/fa AGAR TIDAK TERJADI HAL HAL YANG TIDAK DI INGINKAN",
                        "/fa [ MIC : OFF ]"
                 })
             end
         end
        imgui.SameLine()
        if imgui.Button("WAR CLEAR", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(faLocationInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Lokasi) harus diisi.", -1)
            else
                runRPWithNotifications({
                        "/fa [ MIC : ON ]",
                        string.format("/fa PENEMBAKAN DI AREA %s TELAH SELESAI", ffi.string(faLocationInput)),
                        "/fa WARGA DIPERSILAHKAN UNTUK BERAKTIVITAS KEMBALI SEPERTI BIASA",
                        "/fa TERIMKASIH ATAS KERJASAMANYA ",
                        "/fa SEKIAN DAN TERIMAKASIH KASIH",
                        "/fa [ MIC : OFF ]"
                 })
             end
         end
    imgui.EndGroup()
    imgui.Spacing()
end

local function drawPasalTabContent()
    imgui.Text("Pencarian Pasal : "); imgui.SameLine(); imgui.SetNextItemWidth(390 * scale); imgui.InputText("##PencarianPasal", searchText, 256, imgui.InputTextFlags.AutoSelectAll)
    if imgui.IsItemEdited() then applyFilterPasal() end; imgui.Separator()
    imgui.Columns(4, "PasalColumns", false); imgui.SetColumnWidth(0, columnWidth.pasal_ayat); imgui.SetColumnWidth(1, columnWidth.pelanggaran); imgui.SetColumnWidth(2, columnWidth.denda); imgui.SetColumnWidth(3, columnWidth.sanksi)
    imgui.Text("Pasal"); imgui.NextColumn(); imgui.Text("PELANGGARAN RINGAN"); imgui.NextColumn(); imgui.Text("DENDA"); imgui.NextColumn(); imgui.Text("SANKSI"); imgui.NextColumn(); imgui.Separator()
    local pasalToDisplay = (#ffi.string(searchText) > 0 and #filteredPasal > 0) or (#ffi.string(searchText) == 0 and #pasalData > 0) and pasalData or filteredPasal 
    if #pasalToDisplay == 0 then
        if #ffi.string(searchText) > 0 then
            imgui.Text("Tidak ada hasil ditemukan untuk \"" .. ffi.string(searchText) .. "\".")
        else
            imgui.Text("Daftar pasal kosong atau tidak ada yang sesuai.")
        end
    else
        for _, pasal in ipairs(pasalToDisplay) do
            imgui.Text(pasal.pasal_ayat); imgui.NextColumn()
            imgui.TextWrapped(pasal.pelanggaran); imgui.NextColumn()
            imgui.TextWrapped(pasal.denda); imgui.NextColumn()
            imgui.TextWrapped(pasal.sanksi); imgui.NextColumn()
            imgui.Separator()
        end
    end
    imgui.Columns(1)
end

local radioLocationInput = imgui.new.char[64]()
local radioDescriptionInput = imgui.new.char[64]()
local radioToInput = imgui.new.char[64]()
local radioVehicleNameInput = imgui.new.char[64]()
local radioAmountInput = imgui.new.char[64]()

local function drawRadioTabContent(windowWidth, sidebarWidth, button_width, button_height, inputWidth)
    imgui.Text("Menu Radio"); imgui.Separator(); imgui.Spacing()

    imgui.Columns(2, "RadioInputColumns", false)
    imgui.SetColumnWidth(0, inputWidth + (15 * scale))
    imgui.SetColumnWidth(1, inputWidth + (15 * scale))

    imgui.Text("Input Lokasi"); imgui.NextColumn()
    imgui.Text("Input Jumlah"); imgui.NextColumn()

    imgui.SetNextItemWidth(inputWidth)
    imgui.InputText("##LokasiRadio", radioLocationInput, 64, imgui.InputTextFlags.AutoSelectAll); imgui.NextColumn()
    imgui.SetNextItemWidth(inputWidth)
    imgui.InputText("##JumlahRadio", radioAmountInput, 64, imgui.InputTextFlags.CharsDecimal + imgui.InputTextFlags.AutoSelectAll); imgui.NextColumn()

    imgui.Columns(1)

    imgui.BeginGroup()
        imgui.Text("Deskripsi : ")
        imgui.SameLine()
        local style = imgui.GetStyle()
        imgui.SetNextItemWidth(imgui.GetContentRegionAvail().x - imgui.CalcTextSize("Deskripsi : ").x - style.ItemSpacing.x)
        imgui.InputText("##DeskripsiRadio", radioDescriptionInput, 64, imgui.InputTextFlags.AutoSelectAll)
    imgui.EndGroup(); imgui.Spacing()

    imgui.Columns(2, "RadioInputColumns2", false)
    imgui.SetColumnWidth(0, inputWidth + (15 * scale))
    imgui.SetColumnWidth(1, inputWidth + (15 * scale))

    imgui.Text("Input Kepada"); imgui.NextColumn()
    imgui.Text("Input Kendaraan"); imgui.NextColumn()

    imgui.SetNextItemWidth(inputWidth)
    imgui.InputText("##KepadaRadio", radioToInput, 64, imgui.InputTextFlags.AutoSelectAll); imgui.NextColumn()
    imgui.SetNextItemWidth(inputWidth)
    imgui.InputText("##NamaKendaraanRadio", radioVehicleNameInput, 64, imgui.InputTextFlags.AutoSelectAll); imgui.NextColumn()

    imgui.Columns(1)
    imgui.Spacing()
    imgui.BeginGroup()
        if imgui.Button("ON DUTY", imgui.ImVec2(button_width, button_height)) then
            local command = string.format("/r Officer @ Reporting S2 10-20 HQ")
            sampSendChat(command)
         end
        imgui.SameLine()
        if imgui.Button("OFF DUTY", imgui.ImVec2(button_width, button_height)) then
            local command = string.format("/r Officer @ Reporting S1 10-20 HQ")
            sampSendChat(command)
         end
        imgui.SameLine()
        if imgui.Button("ULANGI", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioToInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Kepada) harus diisi.", -1)
            else
            local command = string.format("/r Officer @ to Officer %s, 10-5 for last transmission.", ffi.string(radioToInput))
            sampSendChat(command)
           end
         end
        imgui.SameLine()
       if imgui.Button("DIPAHAMI", imgui.ImVec2(button_width, button_height)) then
            sampSendChat("/r Officer @ 10-4 for last information")
         end
    imgui.EndGroup(); imgui.Spacing()
    
    imgui.BeginGroup()
    if imgui.Button("C ORDER", imgui.ImVec2(button_width, button_height)) then
            sampSendChat("/r Officer @ 10-6 for last transmission.")
         end
    imgui.SameLine()
    if imgui.Button("SIBUK SIT", imgui.ImVec2(button_width, button_height)) then
            local isi = ffi.string(radioLocationInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Lokasi) harus diisi.", -1)
            else
            sampSendChat("/r Officer @ 10-8 for Tactical Situation, we are still on STATUS-6, 10-20 %s", ffi.string(radioLocationInput))
           end
         end
        imgui.SameLine()
    if imgui.Button("SIBUK INTEL", imgui.ImVec2(button_width, button_height)) then
            sampSendChat("/r Officer @ negative for Tactical Situation, still on 10-9")
         end
        imgui.SameLine()
    if imgui.Button("TO PRISON", imgui.ImVec2(button_width, button_height)) then
            sampSendChat("/r ~ is on 10-15 to Federal for prison procedure.")
         end
    imgui.EndGroup(); imgui.Spacing()
    imgui.BeginGroup()
    if imgui.Button("REP STATUS", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioLocationInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Lokasi) harus diisi.", -1)
            else
            local command = string.format("/r ~ is currently on STATUS-4, 10-20 %s", ffi.string(radioLocationInput))
            sampSendChat(command)
           end
         end
        imgui.SameLine()
    if imgui.Button("PINDAH UNIT", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioVehicleNameInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Kendaraan) harus diisi.", -1)
            else
            local command = string.format("/r ~ 10-27 to %s", ffi.string(radioVehicleNameInput))
            sampSendChat(command)
           end
         end
        imgui.SameLine()
    if imgui.Button("TRAFFIC STOP", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioVehicleNameInput)
        local loc = ffi.string(radioLocationInput)
            if isi == "" or loc == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Kendaraan/Lokasi) harus diisi.", -1)
            else
            local command = string.format("/r ~ is on 10-55 with %s, 10-20 %s", ffi.string(radioVehicleNameInput), ffi.string(radioLocationInput))
            sampSendChat(command)
           end
         end
        imgui.SameLine()
    if imgui.Button("PERSUIT CAR", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioDescriptionInput)
        local loc = ffi.string(radioAmountInput)
            if isi == "" or loc == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Deskripsi/Jumlah) harus diisi.", -1)
            else
            local command = string.format("/r ~ is on 10-57VICTOR with 10-60 %s and %s people, armed robbery, requesting backup on RADIO-1.", ffi.string(radioDescriptionInput), ffi.string(radioAmountInput))
            sampSendChat(command)
           end
         end
    imgui.EndGroup(); imgui.Spacing()
    imgui.BeginGroup()
    if imgui.Button("FELONY", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioDescriptionInput)
        local loc = ffi.string(radioAmountInput)
        local kas = ffi.string(radioLocationInput)
            if isi == "" or loc == "" or kas == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Deskripsi/Jumlah/Lokasi) harus diisi.", -1)
            else
            local command = string.format("/r ~ is on 10-66 with 10-60 %s and %s people, possible armed robbery 10-20 %s, requesting 10-70.", ffi.string(radioDescriptionInput), ffi.string(radioAmountInput), ffi.string(radioLocationInput))
            sampSendChat(command)
           end
         end
        imgui.SameLine()
        if imgui.Button("SWITCH CAR", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioVehicleNameInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Input Kendaraan) harus diisi.", -1)
            else
            local command = string.format("/r ~ 10-27 to %s", ffi.string(radioVehicleNameInput))
            sampSendChat(command)
           end
         end
        imgui.SameLine()
        if imgui.Button("PERSUIT FOOT", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioDescriptionInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Deskripsi) harus diisi.", -1)
            else
            local command = string.format("/r ~ is on 10-57FOXTROT with 10-61 %s, requesting backup on RADIO-1.", ffi.string(radioDescriptionInput))
            sampSendChat(command)
           end
         end
        imgui.SameLine()
        if imgui.Button("END SITUASI", imgui.ImVec2(button_width, button_height)) then
            sampSendChat("/r ~ is on 10-99 from last Tactical Situation, resuming STATUS-4")
         end
    imgui.EndGroup(); imgui.Spacing()
    
    imgui.BeginGroup()
    if imgui.Button("JEMPUT", imgui.ImVec2(button_width, button_height)) then
        local isi = ffi.string(radioLocationInput)
            if isi == "" then
                 sampAddChatMessage("{ff5100}[VALIDASI] Kolom (Lokasi) harus diisi.", -1)
            else
            local command = string.format("/r Officer @ to all units, need 10-14 at 10-20 %s", ffi.string(radioLocationInput))
            sampSendChat(command)
           end
         end
    imgui.EndGroup(); imgui.Spacing()
end

local function drawTenCodeTabContent(button_width, button_height)
    imgui.Text("TEN CODES"); imgui.Separator(); imgui.Spacing()
	imgui.Text("TEN CODES");
    imgui.Text("10 - 1 Berkumpul");
    imgui.Text("10 - 4 Dipahami");
    imgui.Text("10 - 5 Diulangi");
    imgui.Text("10 - 6 Diabaikan/Dibatalkan");
    imgui.Text("10 - 8 Sibuk/Dalam scene");
    imgui.Text("10 - 9 Sibuk/Dalam scene undercover");
    imgui.Text("10 - 14 Meminta jemputan");
    imgui.Text("10 - 15 Transporting suspect");
    imgui.Text("10 - 20 Lokasi");
    imgui.Text("10 - 21 Laporan status");
    imgui.Text("10 - 27 Berpindah unit");
    imgui.Text("10 - 55 Traffic Stop");
    imgui.Text("10 - 56 Computer Check/MDC");
    imgui.Text("10 - 57 VICTOR pursuit kendaraan");
    imgui.Text("10 - 57 FOXTROT pursuit on foot");
    imgui.Text("10 - 60 Ciri ciri kendaraan suspect");
    imgui.Text("10 - 61 Ciri ciri baju suspect");
    imgui.Text("10 - 66 Felony Stop");
    imgui.Text("10 - 70 Membutuhkan additional unit ( opsional )");
    imgui.Text("10 - 99 Clearing from last status / Selesai dari aktifitias");
    imgui.Spacing()

    imgui.Separator()
    imgui.Spacing()

    imgui.Text("STATUS");
    imgui.Text("Status 1 - Off duty");
    imgui.Text("Status 2 - On duty");
    imgui.Text("Status 3 - Istirahat");
    imgui.Text("Status 4 - Patroli");
    imgui.Text("Status 6 - Tiba di lokasi");
    imgui.Spacing()

    imgui.Separator()
    imgui.Spacing()

    imgui.Text("CODE");
    imgui.Text("Code 0 - Digunakan oleh anggota Kepolisian pada saat Perwira di lokasi Tactical Situation telah down");
    imgui.Text("Code 3 - Respon dengan wiu wiu");
    imgui.Text("Code 4 - Aman / Steril");
    imgui.Spacing()

    imgui.Separator()
    imgui.Spacing()

    imgui.Text("CALLSIGN");
    imgui.Text("Stand-by - HQ");
    imgui.Text("Sultan - Kijang");
    imgui.Text("Sanchez - Kancil");
    imgui.Text("HPV 1000 - Zebra");
    imgui.Text("Premier - Macan");
    imgui.Text("FBI Truck - Badak");
    imgui.Text("Infernus - Citah");
    imgui.Text("Derek - Kerbau");
    imgui.Text("Police Ranger - Kuda");
end

local function getDisplayStringWithCursor(input, pos)
    if pos < 1 then pos = 1 end
    if pos > #input + 1 then pos = #input + 1 end
    return string.sub(input, 1, pos - 1) .. "|" .. string.sub(input, pos)
end

local function drawCalculatorTabContent()
    imgui.Text("Kalkulator"); imgui.Separator(); imgui.Spacing()

    local button_height_calc = 60 * scale
    local display_height = 38 * scale
    local style = imgui.GetStyle()
    local available_width = imgui.GetContentRegionAvail().x

    imgui.Columns(2, "CalcDisplays", false)
    imgui.SetColumnWidth(0, available_width * 0.65)
    imgui.SetColumnWidth(1, available_width * 0.35)

    imgui.BeginChild("CalcInputFrame", imgui.ImVec2(0, display_height), true, imgui.WindowFlags.NoScrollbar)
    local textToDisplayInput = (#calcInput == 0 and cursorPos == 1) and "0|" or getDisplayStringWithCursor(calcInput, cursorPos)
    local inputWidth = imgui.CalcTextSize(textToDisplayInput).x
    local inputFrameWidth = imgui.GetContentRegionAvail().x
    local inputTextPosX = imgui.GetCursorPosX() + math.max(0, inputFrameWidth - inputWidth - style.FramePadding.x)
    imgui.SetCursorPosX(inputTextPosX)
    imgui.Text(textToDisplayInput)
    imgui.EndChild()
    imgui.NextColumn()

    imgui.BeginChild("CalcResultFrame", imgui.ImVec2(0, display_height), true, imgui.WindowFlags.NoScrollbar)
    local textToDisplayResult = calcResult
    local resultWidth = imgui.CalcTextSize(textToDisplayResult).x
    local resultFrameWidth = imgui.GetContentRegionAvail().x
    local resultTextPosX = imgui.GetCursorPosX() + math.max(0, resultFrameWidth - resultWidth - style.FramePadding.x)
    imgui.SetCursorPosX(resultTextPosX)
    imgui.Text(textToDisplayResult)
    imgui.EndChild()
    imgui.Columns(1)
    imgui.Spacing()

    local button_spacing = style.ItemSpacing.x

    local nav_btn_width_small = (available_width - button_spacing * 3) / 5.5
    local nav_btn_width_large = nav_btn_width_small * 1.75
    local nav_btn_size_small = imgui.ImVec2(nav_btn_width_small, button_height_calc)
    local nav_btn_size_large = imgui.ImVec2(nav_btn_width_large, button_height_calc)

    if imgui.Button("<", nav_btn_size_small) then cursorPos = math.max(1, cursorPos - 1) end
    imgui.SameLine()
    if imgui.Button(">", nav_btn_size_small) then cursorPos = math.min(#calcInput + 1, cursorPos + 1) end
    imgui.SameLine()
    if imgui.Button("Copy", nav_btn_size_large) then
        if calcResult ~= "" and calcResult ~= "0" and not string.find(calcResult, "Error") then
            imgui.SetClipboardText(calcResult)
        end
    end
    imgui.SameLine()
    if imgui.Button("DEL", nav_btn_size_large) then
        if cursorPos > 1 and #calcInput > 0 then
            calcInput = string.sub(calcInput, 1, cursorPos - 2) .. string.sub(calcInput, cursorPos)
            cursorPos = cursorPos - 1
        end
    end
    imgui.Spacing()

    local calcButtonsLayout = {
        {"6", "7", "8", "9", "/", "*"},
        {"2", "3", "4", "5", "+", "-"},
        {"1", "0", ".", "="}
    }

    local num_cols_row1 = #calcButtonsLayout[1]
    local num_cols_row2 = #calcButtonsLayout[2]
    local num_cols_row3 = #calcButtonsLayout[3]

    local btn_width_row1 = (available_width - button_spacing * (num_cols_row1 -1) ) / num_cols_row1
    local btn_size_row1 = imgui.ImVec2(btn_width_row1, button_height_calc)

    local btn_width_row2 = (available_width - button_spacing * (num_cols_row2 -1) ) / num_cols_row2
    local btn_size_row2 = imgui.ImVec2(btn_width_row2, button_height_calc)

    local std_buttons_in_row3 = num_cols_row3 - 1
    local equals_button_multiplier = 2
    local total_units_row3 = std_buttons_in_row3 + equals_button_multiplier
    local btn_width_row3_std = (available_width - button_spacing * (num_cols_row3 - 1)) / total_units_row3
    local btn_width_row3_equals = btn_width_row3_std * equals_button_multiplier + button_spacing * (equals_button_multiplier - 1)
    local btn_size_row3_std = imgui.ImVec2(btn_width_row3_std, button_height_calc)
    local btn_size_row3_equals = imgui.ImVec2(btn_width_row3_equals, button_height_calc)


    local function handleCalcButton(btnChar)
        if btnChar == "C" then
            calcInput = ""
            calcResult = "0"
            cursorPos = 1
        elseif btnChar == "=" then
            if calcInput ~= "" then
                local sanitizedExpression = string.gsub(calcInput, "[^%d%.%+%-%*/%%eE]", "")
                sanitizedExpression = string.gsub(sanitizedExpression, "e([%+%-])", "e%1")

                if not string.match(sanitizedExpression, "%d") then
                    calcResult = "Error: NoNum"
                    return
                end
                sanitizedExpression = string.gsub(sanitizedExpression, "^[%+%*/%%]", "")
                sanitizedExpression = string.gsub(sanitizedExpression, "[%+%-%*/%%]$", "")

                if sanitizedExpression == "" then
                    calcResult = "0"
                    return
                end

                local func, err = loadstring("return " .. sanitizedExpression)
                if func then
                    local success, result_val = pcall(func)
                    if success then
                        if type(result_val) == "number" then
                            if result_val == math.huge or result_val == -math.huge or result_val ~= result_val then
                                 calcResult = "Error: Domain"
                            elseif result_val == math.floor(result_val) then
                                calcResult = string.format("%d", result_val)
                            else
                                calcResult = string.format("%.10g", result_val)
                                 if string.len(calcResult) > 15 or string.find(calcResult, "e") then
                                    calcResult = string.format("%.4e", result_val)
                                end
                            end
                        else
                            calcResult = "Error: Type"
                        end
                    else
                        calcResult = "Error: Eval"
                    end
                else
                    calcResult = "Error: Syntax"
                end
            else
                calcResult = "0"
            end
        elseif tonumber(btnChar) or btnChar == "0" then
            calcInput = string.sub(calcInput, 1, cursorPos - 1) .. btnChar .. string.sub(calcInput, cursorPos)
            cursorPos = cursorPos + #btnChar
        elseif btnChar == "." then
            local prefix = string.sub(calcInput, 1, cursorPos - 1)
            local suffix = string.sub(calcInput, cursorPos)
            local charBeforeCursor = (cursorPos > 1) and string.sub(calcInput, cursorPos - 1, cursorPos - 1) or ""

            local itemToInsert = "."
            local cursorIncrement = 1

            if charBeforeCursor == "" or not string.match(charBeforeCursor, "%d") then
                itemToInsert = "0."
                cursorIncrement = 2
            end

            local tempInput = prefix .. itemToInsert .. suffix
            local numSegmentStart = cursorPos - 1
            while numSegmentStart > 0 and string.match(string.sub(prefix, numSegmentStart, numSegmentStart), "%d") do
                numSegmentStart = numSegmentStart - 1
            end
            numSegmentStart = numSegmentStart + 1

            local currentNumber = string.sub(prefix, numSegmentStart) .. itemToInsert
            local currentNumberSuffixPart = ""
            local k = 1
            while k <= #suffix and string.match(string.sub(suffix,k,k), "%d") do
                currentNumberSuffixPart = currentNumberSuffixPart .. string.sub(suffix,k,k)
                k = k + 1
            end
            currentNumber = currentNumber .. currentNumberSuffixPart

            local dotCount = 0
            for _ in string.gmatch(currentNumber, "%.") do dotCount = dotCount + 1 end

            if dotCount <= 1 then
                 calcInput = string.sub(calcInput, 1, cursorPos - 1) .. itemToInsert .. string.sub(calcInput, cursorPos)
                 cursorPos = cursorPos + cursorIncrement
            end

        else
            local charBeforeCursor = (cursorPos > 1) and string.sub(calcInput, cursorPos-1, cursorPos-1) or ""
            local lastCharIsOperator = string.match(charBeforeCursor, "[%+%-%*/%%]")

            if lastCharIsOperator then
                if btnChar == "-" and (charBeforeCursor ~= "-") then
                     calcInput = string.sub(calcInput, 1, cursorPos - 1) .. btnChar .. string.sub(calcInput, cursorPos)
                     cursorPos = cursorPos + 1
                elseif btnChar ~= "-" or charBeforeCursor ~= "-" then
                    calcInput = string.sub(calcInput, 1, cursorPos - 2) .. btnChar .. string.sub(calcInput, cursorPos)
                end
            elseif #calcInput == 0 and btnChar == "-" then
                calcInput = btnChar
                cursorPos = 2
            elseif #calcInput > 0 or (#calcInput == 0 and btnChar ~= "-") then
                if #calcInput > 0 or btnChar == "-" then
                    calcInput = string.sub(calcInput, 1, cursorPos - 1) .. btnChar .. string.sub(calcInput, cursorPos)
                    cursorPos = cursorPos + 1
                end
            end
        end
    end

    for i, row_buttons in ipairs(calcButtonsLayout) do
        local current_btn_size_row
        if i == 1 then current_btn_size_row = btn_size_row1
        elseif i == 2 then current_btn_size_row = btn_size_row2
        end

        for j, btnChar in ipairs(row_buttons) do
            local actual_btn_size = current_btn_size_row
            if i == 3 then
                if btnChar == "=" then
                    actual_btn_size = btn_size_row3_equals
                else
                    actual_btn_size = btn_size_row3_std
                end
            end
            if imgui.Button(btnChar, actual_btn_size) then
                handleCalcButton(btnChar)
            end
            if j < #row_buttons then
                imgui.SameLine()
            end
        end
        if i < #calcButtonsLayout then imgui.Spacing() end
    end

    local clear_button_width = available_width
    if imgui.Button("C", imgui.ImVec2(clear_button_width, button_height_calc)) then
        handleCalcButton("C")
    end
end


local function drawTabContent(windowWidth, sidebarWidth, button_width, button_height, inputWidth)
    if abaSelecionada == "UMUM" then
        drawGeneralTabContent(button_width, button_height, inputWidth)
    elseif abaSelecionada == "RADIO" then
        drawRadioTabContent(windowWidth, sidebarWidth, button_width, button_height, inputWidth)
    elseif abaSelecionada == "PASAL" then
        drawPasalTabContent()
    elseif abaSelecionada == "TEN CODE" then
        drawTenCodeTabContent(button_width, button_height)
    elseif abaSelecionada == "KALKULATOR" then
        drawCalculatorTabContent()
    end
end

local lastUpdateCheck = 0
local updateCheckInterval = 300000 -- 5 minutes in milliseconds

local function checkForUpdates(silent)
    local url = "https://raw.githubusercontent.com/Zaidan-alfero/PoliceHelperWIRP/main/PoliceHelperWIRP.lua"
    local response, status = http.request(url)
    if status == 200 and response then
        local currentScript = io.open(getWorkingDirectory() .. "\\moonloader\\PoliceHelperWIRP.lua", "r")
        if currentScript then
            local currentContent = currentScript:read("*all")
            currentScript:close()
            if currentContent ~= response then
                local newScript = io.open(getWorkingDirectory() .. "\\moonloader\\PoliceHelperWIRP.lua", "w")
                if newScript then
                    newScript:write(response)
                    newScript:close()
                    sampAddChatMessage("{00FF00}Script updated successfully! Restart the game to apply changes.", -1)
                else
                    sampAddChatMessage("{FF0000}Failed to update script: Could not write to file.", -1)
                end
            else
                if not silent then
                    sampAddChatMessage("{FFFF00}Script is up to date.", -1)
                end
            end
        else
            if not silent then
                sampAddChatMessage("{FF0000}Failed to check for updates: Could not read current script.", -1)
            end
        end
    else
        if not silent then
            sampAddChatMessage("{FF0000}Failed to check for updates: HTTP request failed.", -1)
        end
    end
end

imgui.OnFrame(function() return window[0] end, function()
    local currentTime = os.time() * 1000
    if currentTime - lastUpdateCheck > updateCheckInterval then
        checkForUpdates(true)
        lastUpdateCheck = currentTime
    end

    local resX, resY = getScreenResolution()
    local windowWidth = 650 * scale
    local windowHeight = 500 * scale
    local sidebarWidth = 120 * scale
    local button_width_main = 110 * scale
    local button_height_main = 33 * scale
    local inputWidth_main = 230 * scale

    imgui.SetNextWindowPos(imgui.ImVec2(resX/2, resY/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(windowWidth, windowHeight), imgui.Cond.Always)
    imgui.Begin("Police Menu Helper by Bayden x Zaidan", window, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize)

    if isLoading then
        imgui.Text("Loading..."); imgui.ProgressBar(loadProgress, imgui.ImVec2(windowWidth - (20*scale), 20*scale)); loadProgress = loadProgress + 0.01; if loadProgress >= 1 then isLoading = false end
    else
        imgui.BeginChild("Sidebar", imgui.ImVec2(sidebarWidth, 0), true)
        if imgui.Button("UMUM", imgui.ImVec2(sidebarWidth - (15*scale), 30 * scale)) then abaSelecionada = "UMUM" end; imgui.Spacing()
        if imgui.Button("RADIO", imgui.ImVec2(sidebarWidth - (15*scale), 30 * scale)) then abaSelecionada = "RADIO" end; imgui.Spacing()
        if imgui.Button("PASAL", imgui.ImVec2(sidebarWidth - (15*scale), 30 * scale)) then abaSelecionada = "PASAL"; if #ffi.string(searchText) == 0 then applyFilterPasal() end end; imgui.Spacing()
        if imgui.Button("TEN CODE", imgui.ImVec2(sidebarWidth - (15*scale), 30 * scale)) then abaSelecionada = "TEN CODE" end; imgui.Spacing()
        if imgui.Button("KALKULATOR", imgui.ImVec2(sidebarWidth - (15*scale), 30 * scale)) then abaSelecionada = "KALKULATOR" end; imgui.Spacing()
        imgui.EndChild()

        imgui.SameLine()
        imgui.BeginChild("MainContent", imgui.ImVec2(0, 0), true, imgui.WindowFlags.AlwaysVerticalScrollbar)
        drawTabContent(windowWidth, sidebarWidth, button_width_main, button_height_main, inputWidth_main)
        imgui.EndChild()
    end
    imgui.End()
end)

function toggleHelperMenu()
    window[0] = not window[0]
    if window[0] then
        if abaSelecionada == "PASAL" and #ffi.string(searchText) == 0 then
            applyFilterPasal()
        end
        loadProgress = 0
    end
end
sampRegisterChatCommand("pdh", toggleHelperMenu)

function updateCommandHandler()
    sampAddChatMessage("{FFFF00}Checking for updates...", -1)
    checkForUpdates(false)
end
sampRegisterChatCommand("update", updateCommandHandler)

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    sampAddChatMessage("{05e2ff}Police Menu Helper by Bayden x Zaidan Loaded! {FFFFFF}Gunakan /pdh", -1)
    applyFilterPasal()
    checkForUpdates()
    while not sampIsLocalPlayerSpawned() do wait(0) end
end

lua_thread.create(main)
