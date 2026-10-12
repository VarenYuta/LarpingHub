--[[
    ============================================================
            LarpingHub  •  By Varen
            Shortcut : tombol  Y   (buka / tutup hub)
    ============================================================
    Fitur:
      - Floating ball (gambar bulat, bisa digeser)
      - Tab Credit / Avatar / Automatic
      - Headless & Korblox (visual asli via HumanoidDescription)
      - Equip puluhan aksesoris katalog (8-Bit, Horns, dll)
      - Auto Equip (re-apply otomatis setiap respawn)
    ============================================================
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local InsertService = game:GetService("InsertService")

local LP = Players.LocalPlayer

local VERSION = "v13"

------------------------------------------------------------
-- BERSIHKAN INSTANCE LAMA
------------------------------------------------------------
if _G.__LarpingHub and _G.__LarpingHub.Destroy then
    pcall(function() _G.__LarpingHub:Destroy() end)
end
_G.__LarpingHub = nil

if _G.__LarpingHubConns then
    for _, c in ipairs(_G.__LarpingHubConns) do
        pcall(function() c:Disconnect() end)
    end
end
_G.__LarpingHubConns = {}
local conns = _G.__LarpingHubConns
local function track(c)
    table.insert(conns, c)
    return c
end

------------------------------------------------------------
-- TEMA
------------------------------------------------------------
local COL = {
    bg      = Color3.fromRGB(0, 0, 0),
    panel   = Color3.fromRGB(12, 12, 12),
    panel2  = Color3.fromRGB(20, 20, 20),
    row     = Color3.fromRGB(26, 26, 26),
    accent  = Color3.fromRGB(235, 235, 235),
    accent2 = Color3.fromRGB(190, 190, 190),
    text    = Color3.fromRGB(240, 240, 240),
    sub     = Color3.fromRGB(150, 150, 150),
    stroke  = Color3.fromRGB(50, 50, 50),
    rail    = Color3.fromRGB(70, 70, 70),
    white   = Color3.fromRGB(255, 255, 255),
    transp  = 0.15,
}
local FONT  = Enum.Font.GothamMedium
local FONTB = Enum.Font.GothamBold

------------------------------------------------------------
-- HELPER
------------------------------------------------------------
local function new(class, parent, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(obj, r)
    return new("UICorner", obj, { CornerRadius = UDim.new(0, r or 8) })
end

local function stroke(obj, col, th)
    return new("UIStroke", obj, {
        Color = col or COL.stroke,
        Thickness = th or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

------------------------------------------------------------
-- PARENT GUI
------------------------------------------------------------
local guiParent
pcall(function()
    if gethui then guiParent = gethui() end
end)
if not guiParent then
    pcall(function() guiParent = game:GetService("CoreGui") end)
end
if not guiParent then
    guiParent = LP:WaitForChild("PlayerGui")
end

local gui = new("ScreenGui", guiParent, {
    Name = "LarpingHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 1000,
})
_G.__LarpingHub = gui

------------------------------------------------------------
-- NOTIFIKASI
------------------------------------------------------------
local notifLayer = new("Frame", gui, {
    Name = "NotifLayer",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.new(0, 320, 0, 420),
    BackgroundTransparency = 1,
})
new("UIListLayout", notifLayer, {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
})

local notifCounter = 0
local function notify(title, text)
    notifCounter = notifCounter + 1
    local card = new("CanvasGroup", notifLayer, {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = COL.panel2,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = notifCounter,
        GroupTransparency = 1,
    })
    corner(card, 10)
    stroke(card, COL.stroke, 1)

    new("Frame", card, {
        Size = UDim2.new(0, 3, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = COL.accent,
        BorderSizePixel = 0,
    }).Parent = card

    new("TextLabel", card, {
        Name = "T",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 20),
        Position = UDim2.new(0, 20, 0, 9),
        Font = FONTB,
        TextSize = 14,
        TextColor3 = COL.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
    })
    new("TextLabel", card, {
        Name = "S",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 0, 18),
        Position = UDim2.new(0, 20, 0, 28),
        Font = FONT,
        TextSize = 12,
        TextColor3 = COL.sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = text or "",
    })

    TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
    }):Play()

    task.delay(3, function()
        if card and card.Parent then
            local t = TweenService:Create(card, TweenInfo.new(0.22), { GroupTransparency = 1 })
            t:Play()
            t.Completed:Connect(function() card:Destroy() end)
        end
    end)
end

------------------------------------------------------------
-- DATA AVATAR
------------------------------------------------------------
local AVATAR_ITEMS = {
    { key = "headless", name = "Headless",                      mode = "headless" },
    { key = "korblox",  name = "Korblox",                       mode = "korblox" },
    { key = "hpbar",    name = "8-Bit HP Bar",                  asset = 10159610478,    slot = "HatAccessory" },
    { key = "tabby",    name = "8-Bit Tabby Cat",               asset = 10159617728,    slot = "ShouldersAccessory" },
    { key = "crown",    name = "8-Bit Royal Crown",             asset = 10159600649,    slot = "HatAccessory" },
    { key = "fiery",    name = "Fiery Horns of the Netherworld",asset = 215718515,      slot = "HatAccessory" },
    { key = "frigid",   name = "Horns of the Frigid Planes",    asset = 74891470,       slot = "HatAccessory" },
    { key = "poison",   name = "Poisoned Horns",                asset = 18748455332,    slot = "HatAccessory" },
    { key = "silver",   name = "Silver King of the Night",      asset = 439945661,      slot = "HatAccessory" },
    { key = "lord",     name = "Lord of the Federation",        asset = 88885069,       slot = "HatAccessory" },
    { key = "hearts",   name = "Heart Shades Bobux Cloud",      asset = 83672858218486, slot = "HatAccessory" },
    { key = "ufo",      name = "Hovering UFO",                  asset = 18508833635,    slot = "HatAccessory" },
}

local state = {
    headless  = false,
    korblox   = false,
    autoEquip = false,
    items     = {},
}

------------------------------------------------------------
-- LOGIKA AVATAR
------------------------------------------------------------
local function getCharacter()
    local char = LP.Character
    if char and char.Parent then
        return char
    end
    local alt = workspace:FindFirstChild(LP.Name)
    if alt and alt:FindFirstChildOfClass("Humanoid") then
        return alt
    end
    for _, d in ipairs(workspace:GetChildren()) do
        if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then
            local n = d.Name:lower()
            if n == LP.Name:lower() or n:find(LP.Name:lower(), 1, true) then
                return d
            end
        end
    end
    local cam = workspace.CurrentCamera
    local subj = cam and cam.CameraSubject
    if subj and subj:IsA("Humanoid") and subj.Parent then
        return subj.Parent
    end
    return nil
end

local function getHumanoid()
    local char = getCharacter()
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local HEADLESS_MESH = "rbxassetid://1095708"
local headLocks = setmetatable({}, { __mode = "k" })

local function setHidden(part, on)
    if not part then return end
    pcall(function()
        part.Transparency = on and 1 or 0
        part.LocalTransparencyModifier = on and 1 or 0
    end)
end

local korbloxLocks = setmetatable({}, { __mode = "k" })

local function lockHidden(part)
    if not part or korbloxLocks[part] then return end
    pcall(function()
        korbloxLocks[part] = part:GetPropertyChangedSignal("Transparency"):Connect(function()
            if state.korblox and part.Transparency < 1 then
                part.Transparency = 1
            end
        end)
        part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
            if state.korblox and part.LocalTransparencyModifier < 1 then
                part.LocalTransparencyModifier = 1
            end
        end)
    end)
end

local function setHeadAccessories(on)
    local char = getCharacter()
    if not char then return end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") and not acc:GetAttribute("LarpingHubItem") then
            local handle = acc:FindFirstChildWhichIsA("BasePart")
            if handle then
                pcall(function()
                    local t = acc.AccessoryType.Name
                    if t == "Hair" or t == "Face" or t == "Eyebrow" or t == "Eyelash" then
                        if on then
                            acc:SetAttribute("LarpHeadAcc", true)
                            handle.Transparency = 1
                        elseif acc:GetAttribute("LarpHeadAcc") then
                            handle.Transparency = 0
                            acc:SetAttribute("LarpHeadAcc", nil)
                        end
                    end
                end)
            end
        end
    end
end

local function setHeadlessVisual(on)
    local char = getCharacter()
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("Head", true)
    if not head then return end

    if on then
        setHidden(head, true)
        for _, d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") then pcall(function() d.Transparency = 1 end) end
        end
        setHeadAccessories(true)
        if not head:FindFirstChild("LarpHeadless") then
            local m = Instance.new("SpecialMesh")
            m.Name = "LarpHeadless"
            m.MeshType = Enum.MeshType.FileMesh
            m.MeshId = HEADLESS_MESH
            m.Scale = Vector3.new(0.001, 0.001, 0.001)
            m.Parent = head
        end
        if not headLocks[head] then
            pcall(function()
                headLocks[head] = head:GetPropertyChangedSignal("Transparency"):Connect(function()
                    if state.headless and head.Transparency < 1 then
                        head.Transparency = 1
                    end
                end)
            end)
        end
    else
        local m = head:FindFirstChild("LarpHeadless")
        if m then m:Destroy() end
        setHidden(head, false)
        for _, d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") then pcall(function() d.Transparency = 0 end) end
        end
        setHeadAccessories(false)
    end
end

-- Mesh korblox: R6 -> ganti "Right Leg"; R15 -> mesh kaki kanan penuh
local KORBLOX_MESH      = "rbxassetid://902942096"
local KORBLOX_TEXTURE   = "rbxassetid://902843398"
local KORBLOX_R15_UPPER = "rbxassetid://9598310133"

-- Part bantuan dipakai hanya kalau executor tidak bisa menulis MeshId.
local KORBLOX_FALLBACK = {
    size  = Vector3.new(1, 2, 1),
    color = Color3.fromRGB(30, 30, 30),
}

local KORBLOX_PARTS = { "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" }

-- Cari part berdasarkan nama, termasuk di dalam sub-model (rig Evade kadang nested)
local function findPart(char, ...)
    for _, n in ipairs({ ... }) do
        local p = char:FindFirstChild(n) or char:FindFirstChild(n, true)
        if p and p:IsA("BasePart") then return p end
    end
    return nil
end

-- Hapus sisa "hack" korblox (part bantuan + mesh) tanpa mengubah transparency
local function clearKorbloxHack()
    local char = getCharacter()
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") and d:GetAttribute("LarpKorbloxLeg") then
            d:Destroy()
        end
        if d:IsA("SpecialMesh") and d.Name == "LarpKorbloxMesh" then
            d:Destroy()
        end
    end
end

local function setKorbloxVisual(on)
    local char = getCharacter()
    if not char then return end

    clearKorbloxHack()

    if not on then
        for _, n in ipairs(KORBLOX_PARTS) do
            local p = findPart(char, n)
            if p then
                pcall(function() p.Transparency = 0 end)
                local orig = p:GetAttribute("LarpOrigMesh")
                if orig and p:IsA("MeshPart") then
                    pcall(function() p.MeshId = orig end)
                end
            end
        end
        return
    end

    -- R6 : "Right Leg" adalah Part biasa -> pasang SpecialMesh korblox
    local r6 = findPart(char, "Right Leg")
    if r6 and not r6:IsA("MeshPart") then
        local mesh = Instance.new("SpecialMesh")
        mesh.Name = "LarpKorbloxMesh"
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = KORBLOX_MESH
        mesh.TextureId = KORBLOX_TEXTURE
        mesh.Parent = r6
        pcall(function() r6.Color = KORBLOX_FALLBACK.color end)
        return
    end

    -- R15 : tulis MeshId langsung (executor umumnya mengizinkan)
    local upper = findPart(char, "RightUpperLeg")
    if not upper then return end
    local lower = findPart(char, "RightLowerLeg")
    local foot = findPart(char, "RightFoot")

    local applied = false
    if upper:IsA("MeshPart") then
        pcall(function() upper:SetAttribute("LarpOrigMesh", upper.MeshId) end)
        pcall(function()
            upper.MeshId = KORBLOX_R15_UPPER
            upper.TextureID = KORBLOX_TEXTURE
        end)
        applied = upper.MeshId == KORBLOX_R15_UPPER
    end

    if applied then
        setHidden(upper, false)
        setHidden(lower, true)
        setHidden(foot, true)
        lockHidden(lower)
        lockHidden(foot)
        return
    end

    -- Fallback : sembunyikan kaki asli, buat part korblox lalu weld
    local hack = Instance.new("Part")
    hack.Name = "LarpKorbloxLeg"
    hack.Size = KORBLOX_FALLBACK.size
    hack.CanCollide = false
    hack.CanTouch = false
    hack.Massless = true
    hack.Color = KORBLOX_FALLBACK.color
    hack.TopSurface = Enum.SurfaceType.Smooth
    hack.BottomSurface = Enum.SurfaceType.Smooth
    hack:SetAttribute("LarpKorbloxLeg", true)

    local hip = upper.CFrame * CFrame.new(0, upper.Size.Y / 2, 0)
    hack.CFrame = hip * CFrame.new(0, -KORBLOX_FALLBACK.size.Y / 2, 0)

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = KORBLOX_MESH
    mesh.TextureId = KORBLOX_TEXTURE
    mesh.Parent = hack

    hack.Parent = char
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = upper
    weld.Part1 = hack
    weld.Parent = hack

    for _, p in ipairs({ upper, lower, foot }) do
        setHidden(p, true)
        lockHidden(p)
    end
end

local function clearAccessories()
    local char = getCharacter()
    if not char then return end
    for _, d in ipairs(char:GetChildren()) do
        if d:IsA("Accessory") and d:GetAttribute("LarpingHubItem") then
            d:Destroy()
        end
    end
end

local function loadAccessoryModel(id)
    local tries = {
        function() return game:GetObjects("rbxassetid://" .. tostring(id)) end,
        function() return { InsertService:LoadAsset(id) } end,
    }
    for _, fn in ipairs(tries) do
        local ok, res = pcall(fn)
        if ok and type(res) == "table" and res[1] then
            local obj = res[1]
            local acc = obj:IsA("Accessory") and obj or obj:FindFirstChildWhichIsA("Accessory", true)
            if acc then return acc end
        end
    end
    return nil
end

local function applyAccessories()
    local hum = getHumanoid()
    if not hum then return 0, 0 end
    clearAccessories()
    local okCount, failCount = 0, 0
    for _, it in ipairs(AVATAR_ITEMS) do
        if it.asset and it.slot and state.items[it.key] then
            local acc = loadAccessoryModel(it.asset)
            if acc then
                acc:SetAttribute("LarpingHubItem", true)
                local ok = pcall(function() hum:AddAccessory(acc) end)
                if ok then
                    okCount = okCount + 1
                else
                    acc:Destroy()
                    failCount = failCount + 1
                end
            else
                failCount = failCount + 1
            end
        end
    end
    return okCount, failCount
end

local function applyAvatar()
    local function run()
        local ok, err = pcall(function()
            setHeadlessVisual(state.headless)
            setKorbloxVisual(state.korblox)
            applyAccessories()
        end)
        if not ok then
            warn("[LarpingHub] " .. tostring(err))
            notify("Error", tostring(err):sub(1, 70))
        end
    end

    if getHumanoid() then
        run()
        return
    end

    task.spawn(function()
        for _ = 1, 24 do
            task.wait(0.5)
            if getHumanoid() then
                run()
                return
            end
        end
        notify("Avatar", "Karakter tidak ditemukan")
    end)
end

local function hasKorbloxHack()
    local char = getCharacter()
    if not char then return false end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") and d:GetAttribute("LarpKorbloxLeg") then
            return true
        end
    end
    return false
end

local function korbloxApplied()
    local char = getCharacter()
    if not char then return false end
    local r6 = findPart(char, "Right Leg")
    if r6 and not r6:IsA("MeshPart") then
        return r6:FindFirstChild("LarpKorbloxMesh") ~= nil
    end
    local upper = findPart(char, "RightUpperLeg")
    if not upper then return false end
    if upper:IsA("MeshPart") and upper.MeshId == KORBLOX_R15_UPPER then
        return true
    end
    return hasKorbloxHack()
end

------------------------------------------------------------
-- LOAD GAMBAR BALL
--  1) gambar larphub (lokal / Downloads) lewat getcustomasset
--  2) gambar bawaan (base64) ditulis otomatis ke workspace
--  3) fallback: thumbnail avatar (selalu muncul)
------------------------------------------------------------
local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64decode(s)
    s = s:gsub("%s+", "")
    local lookup = {}
    for i = 1, 64 do lookup[B64_CHARS:sub(i, i)] = i - 1 end
    local out, buffer, bits = {}, 0, 0
    for i = 1, #s do
        local c = s:sub(i, i)
        if c == "=" then break end
        local v = lookup[c]
        if v then
            buffer = buffer * 64 + v
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                out[#out + 1] = string.char(math.floor(buffer / (2 ^ bits)) % 256)
                buffer = buffer % (2 ^ bits)
            end
        end
    end
    return table.concat(out)
end

local EMBEDDED_BALL_B64 = "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"

local function ensureBallFile()
    if not (writefile and isfile) then return end
    local fname = "larphub_ball.jpg"
    local ok, exists = pcall(isfile, fname)
    if ok and exists then return end
    pcall(function()
        writefile(fname, b64decode(EMBEDDED_BALL_B64))
    end)
end

local function loadBallImage()
    local candidates = {
        "larphub_round.png", "larphub.png", "larphub.jpg", "larphub.jpeg",
        "C:/Users/User/Downloads/larphub_round.png",
        "C:/Users/User/Downloads/larphub.jpg",
        "C:/Users/User/Downloads/larphub.png",
    }
    if getcustomasset then
        ensureBallFile()
        table.insert(candidates, 1, "larphub_ball.jpg")
        for _, n in ipairs(candidates) do
            local ok, res = pcall(function() return getcustomasset(n) end)
            if ok and res and res ~= "" then
                return res
            end
        end
    end
    return ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(LP.UserId)
end
local BALL_IMG = loadBallImage()

------------------------------------------------------------
-- FLOATING BALL
------------------------------------------------------------
local ballHolder = new("Frame", gui, {
    Name = "FloatingBall",
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.new(0, 24, 0.5, -28),
    BackgroundColor3 = COL.panel2,
    BackgroundTransparency = 0,
    ClipsDescendants = true,
    BorderSizePixel = 0,
    Active = true,
})
corner(ballHolder, 28)
stroke(ballHolder, COL.accent, 1.5)

local ballImg = new("ImageButton", ballHolder, {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Image = BALL_IMG or "",
    ScaleType = Enum.ScaleType.Crop,
    AutoButtonColor = false,
    ZIndex = 2,
})
corner(ballImg, 28)
if not BALL_IMG then
    new("TextLabel", ballHolder, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "V",
        Font = FONTB,
        TextSize = 24,
        TextColor3 = COL.accent,
        ZIndex = 1,
    })
end

------------------------------------------------------------
-- WINDOW
------------------------------------------------------------
local W, H = 620, 440

local win = new("Frame", gui, {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(W, H),
    BackgroundColor3 = COL.bg,
    BackgroundTransparency = COL.transp,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
})
corner(win, 14)
stroke(win, COL.stroke, 1)
new("UIGradient", win, {
    Rotation = 90,
    Color = ColorSequence.new(Color3.fromRGB(22, 22, 22), Color3.fromRGB(0, 0, 0)),
})

-- HEADER
local header = new("Frame", win, {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = COL.panel2,
    BackgroundTransparency = COL.transp,
    BorderSizePixel = 0,
    Active = true,
})
new("UIGradient", header, {
    Rotation = 90,
    Color = ColorSequence.new(Color3.fromRGB(28, 28, 28), Color3.fromRGB(6, 6, 6)),
})
new("Frame", header, {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = COL.accent,
    BorderSizePixel = 0,
})
new("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 8),
    Size = UDim2.new(0, 320, 0, 20),
    Font = FONTB,
    TextSize = 17,
    TextColor3 = COL.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "LarpingHub",
})
new("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 27),
    Size = UDim2.new(0, 320, 0, 14),
    Font = FONT,
    TextSize = 11,
    TextColor3 = COL.accent,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "By Varen • " .. VERSION,
})

local minimizeBtn = new("TextButton", header, {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -50, 0.5, 0),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = COL.panel2,
    Text = "-",
    Font = FONTB,
    TextSize = 16,
    TextColor3 = COL.sub,
    AutoButtonColor = true,
    BorderSizePixel = 0,
})
corner(minimizeBtn, 7)

local closeBtn = new("TextButton", header, {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -16, 0.5, 0),
    Size = UDim2.fromOffset(26, 26),
    BackgroundColor3 = COL.panel2,
    Text = "X",
    Font = FONTB,
    TextSize = 13,
    TextColor3 = COL.sub,
    AutoButtonColor = true,
    BorderSizePixel = 0,
})
corner(closeBtn, 7)

-- BODY
local body = new("Frame", win, {
    Position = UDim2.new(0, 0, 0, 48),
    Size = UDim2.new(1, 0, 1, -48),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})

-- SIDEBAR
local sidebar = new("Frame", body, {
    Size = UDim2.new(0, 176, 1, 0),
    BackgroundColor3 = COL.panel,
    BackgroundTransparency = COL.transp,
    BorderSizePixel = 0,
})
new("TextLabel", sidebar, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 14),
    Size = UDim2.new(1, -36, 0, 14),
    Font = FONTB,
    TextSize = 10,
    TextColor3 = COL.sub,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "MENU",
})

local statusLabel = new("TextLabel", sidebar, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 1, -76),
    Size = UDim2.new(1, -24, 0, 66),
    Font = FONT,
    TextSize = 11,
    TextColor3 = COL.sub,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Text = "status...",
})

-- CONTENT
local content = new("Frame", body, {
    Position = UDim2.new(0, 176, 0, 0),
    Size = UDim2.new(1, -176, 1, 0),
    BackgroundColor3 = COL.bg,
    BorderSizePixel = 0,
})

local pages = {}
local tabButtons = {}
local activeTab = 0

local function makePage()
    local scf = new("ScrollingFrame", content, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = COL.rail,
        Visible = false,
    })
    new("UIPadding", scf, {
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
    })
    new("UIListLayout", scf, {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    return scf
end

local function pageHeader(scf, title, subtitle)
    local holder = new("Frame", scf, {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = 0,
    })
    new("TextLabel", holder, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        Font = FONTB,
        TextSize = 18,
        TextColor3 = COL.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
    })
    new("TextLabel", holder, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 14),
        Font = FONT,
        TextSize = 12,
        TextColor3 = COL.sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = subtitle or "",
    })
end

local function selectTab(i)
    if activeTab == i then return end
    activeTab = i
    for idx, page in ipairs(pages) do
        page.Visible = (idx == i)
    end
    for idx, btn in ipairs(tabButtons) do
        local on = (idx == i)
        btn.bar.Visible = on
        TweenService:Create(btn.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and COL.panel2 or COL.panel,
        }):Play()
        btn.label.TextColor3 = on and COL.text or COL.sub
    end
end

local function addTab(name, icon, order)
    local btn = new("TextButton", sidebar, {
        Size = UDim2.new(1, -20, 0, 42),
        Position = UDim2.new(0, 10, 0, 40 + (order - 1) * 48),
        BackgroundColor3 = COL.panel,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    corner(btn, 9)

    local bar = new("Frame", btn, {
        Size = UDim2.new(0, 3, 1, -18),
        Position = UDim2.new(0, 8, 0, 9),
        BackgroundColor3 = COL.accent,
        BorderSizePixel = 0,
        Visible = false,
    })
    corner(bar, 2)

    local label = new("TextLabel", btn, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = FONTB,
        TextSize = 14,
        TextColor3 = COL.sub,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = name,
    })

    btn.MouseButton1Click:Connect(function() selectTab(order) end)
    tabButtons[order] = { btn = btn, bar = bar, label = label }
    pages[order] = makePage()
    return pages[order], btn
end

------------------------------------------------------------
-- TOGGLE WIDGET
------------------------------------------------------------
local function makeToggle(parent, label, default, callback, order)
    local on = default and true or false

    local row = new("TextButton", parent, {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = COL.row,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        LayoutOrder = order or 1,
    })
    corner(row, 10)
    stroke(row, COL.stroke, 1)

    new("TextLabel", row, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -74, 1, 0),
        Font = FONT,
        TextSize = 14,
        TextColor3 = COL.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
    })

    local track = new("Frame", row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(44, 22),
        BackgroundColor3 = COL.rail,
        BorderSizePixel = 0,
    })
    corner(track, 11)

    local knob = new("Frame", track, {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = COL.white,
        BorderSizePixel = 0,
    })
    corner(knob, 8)

    local function render(animate)
        local ti = TweenInfo.new(animate and 0.15 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(track, ti, { BackgroundColor3 = on and COL.accent or COL.rail }):Play()
        TweenService:Create(knob, ti, {
            Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        }):Play()
    end

    local function set(v, fire)
        on = v and true or false
        render(true)
        if fire and callback then callback(on) end
    end

    row.MouseButton1Click:Connect(function() set(not on, true) end)
    render(false)

    return { Set = set, Get = function() return on end }
end

------------------------------------------------------------
-- TAB 1 : CREDIT
------------------------------------------------------------
local creditPage = addTab("Credit", nil, 1)
pageHeader(creditPage, "Credit", "Terima kasih sudah memakai LarpingHub")

local creditCard = new("Frame", creditPage, {
    Size = UDim2.new(1, 0, 0, 128),
    BackgroundColor3 = COL.panel2,
    BorderSizePixel = 0,
    LayoutOrder = 1,
})
corner(creditCard, 12)
stroke(creditCard, COL.stroke, 1)

new("TextLabel", creditCard, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 12),
    Size = UDim2.new(1, -32, 0, 46),
    Font = FONTB,
    TextSize = 22,
    TextColor3 = COL.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "LarpingHub\nBy Varen",
})
new("TextLabel", creditCard, {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 62),
    Size = UDim2.new(1, -32, 0, 16),
    Font = FONT,
    TextSize = 12,
    TextColor3 = COL.sub,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "Script avatar hub - Headless, Korblox & katalog.",
})

local function copyButton(parent, label, value, order)
    local b = new("TextButton", parent, {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = COL.row,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        LayoutOrder = order,
    })
    corner(b, 10)
    stroke(b, COL.stroke, 1)
    new("TextLabel", b, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = FONT,
        TextSize = 13,
        TextColor3 = COL.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
    })
    new("TextLabel", b, {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 60, 1, 0),
        Font = FONTB,
        TextSize = 11,
        TextColor3 = COL.accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = "COPY",
    })
    b.MouseButton1Click:Connect(function()
        local ok = pcall(function()
            if setclipboard then setclipboard(value) end
        end)
        notify("Copied", ok and value or "Clipboard tidak didukung")
    end)
    return b
end

copyButton(creditPage, "TikTok : varentelu", "varentelu", 2)
copyButton(creditPage, "Discord Server : discord.gg/ZsUkBXqc6", "https://discord.gg/ZsUkBXqc6", 3)

------------------------------------------------------------
-- TAB 2 : AVATAR
------------------------------------------------------------
local avatarPage = addTab("Avatar", nil, 2)
pageHeader(avatarPage, "Avatar", "Aktifkan untuk memakai visual di karakter")

for i, item in ipairs(AVATAR_ITEMS) do
    makeToggle(avatarPage, item.name, false, function(on)
        if item.mode == "headless" then
            state.headless = on
        elseif item.mode == "korblox" then
            state.korblox = on
        else
            state.items[item.key] = on
        end
        applyAvatar()
        notify(item.name, on and "Aktif" or "Dimatikan")
    end, i)
end

------------------------------------------------------------
-- TAB 3 : AUTOMATIC
------------------------------------------------------------
local autoPage = addTab("Automatic", nil, 3)
pageHeader(autoPage, "Automatic", "Pengaturan otomatis untuk karakter")

makeToggle(autoPage, "Auto Equip", false, function(on)
    state.autoEquip = on
    if on then
        applyAvatar()
    end
    notify("Auto Equip", on and "Aktif - item di-equip ulang saat respawn" or "Dimatikan")
end, 1)

------------------------------------------------------------
-- TAMPILKAN / SEMBUNYIKAN WINDOW
------------------------------------------------------------
local winVisible = false
local animating = false

local function openHub()
    if animating or winVisible then return end
    animating = true
    win.Visible = true
    selectTab(1)
    win.Size = UDim2.fromOffset(W * 0.92, H * 0.92)
    local t = TweenService:Create(win, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(W, H),
    })
    t:Play()
    t.Completed:Wait()
    winVisible = true
    animating = false
end

local function closeHub()
    if animating or not winVisible then return end
    animating = true
    local t = TweenService:Create(win, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(W * 0.92, H * 0.92),
    })
    t:Play()
    t.Completed:Wait()
    win.Visible = false
    winVisible = false
    animating = false
end

local function toggleHub()
    if winVisible then closeHub() else openHub() end
end

closeBtn.MouseButton1Click:Connect(closeHub)
minimizeBtn.MouseButton1Click:Connect(closeHub)

------------------------------------------------------------
-- BALL DRAG + CLICK
------------------------------------------------------------
local dragging = false
local dragMoved = false
local dragStart, startPos

track(ballImg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragMoved = false
        dragStart = input.Position
        startPos = ballHolder.Position
    end
end))

track(UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
            dragMoved = true
        end
        ballHolder.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end))

track(UIS.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
        if not dragMoved then
            toggleHub()
        end
    end
end))

------------------------------------------------------------
-- WINDOW DRAG (geser hub lewat header)
------------------------------------------------------------
local winDragging = false
local winDragStart, winStartPos

track(header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        winDragging = true
        winDragStart = input.Position
        winStartPos = win.AbsolutePosition
        win.AnchorPoint = Vector2.new(0, 0)
        win.Position = UDim2.fromOffset(winStartPos.X, winStartPos.Y)
    end
end))

track(UIS.InputChanged:Connect(function(input)
    if winDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - winDragStart
        win.Position = UDim2.fromOffset(winStartPos.X + delta.X, winStartPos.Y + delta.Y)
    end
end))

track(UIS.InputEnded:Connect(function(input)
    if winDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        winDragging = false
    end
end))

------------------------------------------------------------
-- KEYBIND : Y
------------------------------------------------------------
track(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Y then
        toggleHub()
    end
end))

------------------------------------------------------------
-- AUTO EQUIP PADA RESPAWN
------------------------------------------------------------
track(LP.CharacterAdded:Connect(function()
    task.wait(1)
    if state.autoEquip or state.headless or state.korblox or next(state.items) then
        applyAvatar()
    end
end))

------------------------------------------------------------
-- MONITOR : pastikan headless/korblox tidak ke-reset oleh game
------------------------------------------------------------
task.spawn(function()
    while _G.__LarpingHub == gui and gui.Parent do
        task.wait(1)
        local char = getCharacter()
        if char and char:FindFirstChildOfClass("Humanoid") then
            if state.headless then
                local head = findPart(char, "Head")
                if head and (head.Transparency < 1 or head.LocalTransparencyModifier < 1) then
                    setHeadlessVisual(true)
                end
                setHeadAccessories(true)
            end
            if state.korblox then
                if not korbloxApplied() then
                    setKorbloxVisual(true)
                end
                local upper = findPart(char, "RightUpperLeg")
                if upper and upper:IsA("MeshPart") then
                    setHidden(findPart(char, "RightLowerLeg"), true)
                    setHidden(findPart(char, "RightFoot"), true)
                    if upper.MeshId ~= KORBLOX_R15_UPPER then
                        setKorbloxVisual(true)
                    end
                end
            end
            if next(state.items) then
                local applied = false
                for _, d in ipairs(char:GetChildren()) do
                    if d:IsA("Accessory") and d:GetAttribute("LarpingHubItem") then
                        applied = true
                        break
                    end
                end
                if not applied then
                    applyAccessories()
                end
            end
        end
    end
end)

------------------------------------------------------------
-- DIAGNOSTIK (detail di console F9)
------------------------------------------------------------
task.spawn(function()
    local char, tries = nil, 0
    repeat
        char = getCharacter()
        if char and char:FindFirstChildOfClass("Humanoid") then break end
        tries = tries + 1
        task.wait(0.5)
    until tries >= 120
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local rig = "?"
    if hum then
        rig = (hum.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
    end
    local head = char and findPart(char, "Head")
    local leg  = char and findPart(char, "RightUpperLeg", "Right Leg")
    local hasHead = head and "ada" or "tidak"
    local hasLeg  = leg and "ada" or "tidak"
    local names = {}
    if char then
        for _, c in ipairs(char:GetChildren()) do
            table.insert(names, c.Name)
        end
    end
    local wnames = {}
    for _, c in ipairs(workspace:GetChildren()) do
        table.insert(wnames, c.Name)
    end
    local lvl = "?"
    pcall(function() lvl = tostring(getidentity()) end)
    local cap = {}
    if getcustomasset then table.insert(cap, "customasset") end
    if game.GetObjects then table.insert(cap, "GetObjects") end
    print(("[LarpingHub %s] player=%s char=%s rig=%s head=%s kaki=%s identity=%s cap=%s anak=%s ws=%s"):format(
        VERSION, LP.Name, tostring(char ~= nil), rig, hasHead, hasLeg, lvl,
        table.concat(cap, ","), table.concat(names, "/"), table.concat(wnames, "/")))
    notify("Diagnostik " .. VERSION, ("char %s | %s | kepala %s | kaki %s"):format(
        tostring(char ~= nil), rig, hasHead, hasLeg))
end)

------------------------------------------------------------
-- STATUS LIVE (tampil di sidebar)
------------------------------------------------------------
task.spawn(function()
    while _G.__LarpingHub == gui and gui.Parent do
        local char = getCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local rig = "?"
        if hum then
            rig = (hum.RigType == Enum.HumanoidRigType.R15) and "R15" or "R6"
        end
        local head = char and findPart(char, "Head")
        local leg  = char and findPart(char, "RightUpperLeg", "Right Leg")
        local lvl = "?"
        pcall(function() lvl = tostring(getidentity()) end)
        local headTxt = "TIDAK"
        if head then headTxt = (head.Transparency >= 1) and "hilang" or "kelihatan" end
        local kxTxt = "-"
        if state.korblox then kxTxt = korbloxApplied() and "OK" or "GAGAL" end
        statusLabel.Text = ("char: %s\nrig: %s\nkepala: %s\nkaki: %s\nkorblox: %s\nlvl: %s"):format(
            char and "ada" or "TIDAK", rig, headTxt,
            leg and "ada" or "TIDAK", kxTxt, lvl)
        task.wait(1)
    end
end)

------------------------------------------------------------
-- START
------------------------------------------------------------
selectTab(1)
notify("LarpingHub", "Tekan Y untuk membuka hub")
