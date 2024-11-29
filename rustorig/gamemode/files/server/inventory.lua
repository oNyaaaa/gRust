util.AddNetworkString("SendInventory")
util.AddNetworkString("ForgiveMeInventory")
util.AddNetworkString("Craft_BP")
local MaxInventory = 42
function IsInventoryFull(ply)
    local yup = 0
    for k, v in pairs(ply.inv) do
        yup = yup + 1
    end
    return yup >= MaxInventory
end

local meta = FindMetaTable("Player")
function meta:FirstCreateInv(b_Alive)
    b_Alive = b_Alive or ""
    if not file.IsDir("ginv", "DATA") then file.CreateDir("ginv") end
    if not file.Exists("ginv/inventory_" .. self:SteamID64() .. ".txt", "DATA") then file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON({})) end
    if b_Alive == "b_dead" then file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON({})) end
    local inv = util.JSONToTable(file.Read("ginv/inventory_" .. self:SteamID64() .. ".txt", "DATA"))
    net.Start("SendInventory")
    net.WriteTable(inv)
    net.Send(self)
    return inv
end

function GetAmmoForCurrentWeapon(ply)
    if not IsValid(ply) then return -1 end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return -1 end
    return ply:GetAmmoCount(wep:GetPrimaryAmmoType())
end

function meta:GetInventory()
    local inv = NULL
    if file.Exists("ginv/inventory_" .. self:SteamID64() .. ".txt", "DATA") then inv = util.JSONToTable(file.Read("ginv/inventory_" .. self:SteamID64() .. ".txt", "DATA")) end
    return inv
end

function meta:GetItem(item)
    local inv = self:GetInventory()
    if inv == NULL then return 0 end
    for k, v in pairs(inv) do
        if v.Name == item then return v end
    end
end

net.Receive("Craft_BP", function(l, ply)
    local str = net.ReadString()
    local plymeta = ply:GetItem("Wood")
    ply.bp = BluePrint_Get(str)
    if type(plymeta) == "table" then
        for k, v in pairs(ply.bp.need) do
            if plymeta.Amount >= v.amt then
                if v.txt == "Stone" then ply:RemoveInventoryRocks(v.amt) end
                if v.txt == "Wood" then ply:RemoveInventoryWood(v.amt) end
            end
        end

        timer.Create("Create" .. tostring(str), ply.bp.timers, 0, function()
            ply:Give(ply.bp.Class)
            timer.Remove("Create" .. tostring(str))
        end)
    end
end)

function meta:AddToInventory(item)
    -- Cooldown check to prevent spamming
    if cd_iZz >= CurTime() then return end
    cd_iZz = CurTime() + 1
    -- Initializing inventory and variables
    local inv = self.inv or {}
    local tbl = {}
    local amount = 0
    local altered = false
    local ammo1 = GetAmmoForCurrentWeapon(self)
    local t2 = {}
    t2.Slot = {}
    local chooseSlot = 1
    local t = 0
    -- Find an available slot for the item
    for i = 1, 30 do
        -- Check for a slot that is either empty or can be filled with the same item
        if inv[i] == nil or inv[i].Class == item:GetClass() then
            if t > 30 then continue end
            t = t + 1
            t2.Slot[t] = i
        end
    end

    -- If no slot is available, return without adding item
    if #t2.Slot == 0 then
        print("No available slots.")
        return
    end

    -- Choose the first available slot
    chooseSlot = t2.Slot[1]
    -- Check if the item already exists in the inventory
    for k, v in pairs(inv) do
        if v.Class == item:GetClass() then
            amount = v.Amount + math.random(3, 5) -- Increase the amount
            tbl.Name = item.Name
            tbl.Class = item:GetClass() or ""
            tbl.WepClass = item:GetClass() or ""
            tbl.Mdl = item:GetModel() or ""
            tbl.Ammo_New = ammo1 or 0
            tbl.Amount = amount or 0
            altered = true
        end
    end

    -- If the item is not found, create a new entry in the inventory
    if not altered then
        amount = math.random(3, 5)
        tbl.Name = item.Name
        tbl.Class = item:GetClass() or ""
        tbl.WepClass = item:GetClass() or ""
        tbl.Mdl = item:GetModel() or ""
        tbl.Ammo_New = ammo1 or 0
        tbl.Amount = amount or 0
    end

    -- Add or update the item in the chosen slot
    inv[chooseSlot] = tbl
    -- Save the updated inventory to file
    file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON(inv))
end

local cd_iZ = 0
function meta:AddWepInventory(item)
    if cd_iZ >= CurTime() then return end
    cd_iZ = CurTime() + 1
    local inv = self.inv or {}
    local tbl = {}
    local amount = 0
    local altered = false
    local ammo1 = GetAmmoForCurrentWeapon(self)
    local t2 = {}
    t2.Slot = {}
    local chooseSlot = 1
    local t = 0
    -- Find an available slot for the item
    for i = 1, 30 do
        -- Check for a slot that is either empty or can be filled with the same item
        if inv[i] == nil or inv[i].Class == item:GetClass() then
            if t > 30 then continue end
            t = t + 1
            t2.Slot[t] = i
        end
    end

    -- If no slot is available, return without adding item
    if #t2.Slot == 0 then
        print("No available slots.")
        return
    end

    tbl.Name = item.PrintName
    tbl.Class = item:GetClass() or ""
    tbl.WepClass = item:GetClass() or ""
    tbl.Mdl = item:GetModel() or ""
    tbl.Ammo_New = ammo1 or 0
    tbl.Amount = 1 or 0
    inv[chooseSlot] = tbl
    --net.Start("SendInventory")
    --net.WriteTable(inv)
    --net.Send(self)
    file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON(inv))
end

function meta:RemoveWepInventory(item)
    local inv = self.inv or {}
    for k, v in pairs(inv) do
        if v.Class == item:GetClass() then inv[k] = nil end
    end

    self.inv = inv
    --net.Start("SendInventory")
    --net.WriteTable(inv)
    --net.Send(self)
    file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON(inv))
end

local meta = FindMetaTable("Player")
local oldGive = meta.Give
function meta:Give(item, bAmmo)
    if iZ == nil then iZ = 0 end
    bAmmo = bAmmo or false
    item = item or ""
    if item == "" then return end
    oldGive(self, item, ammo)
    if iZ >= CurTime() then return end
    iZ = CurTime() + 1
    local wep = self:GetWeapon(item)
    self:AddWepInventory(self:GetWeapon(item))
end

hook.Add("PlayerDroppedWeapon", "RemoveWepFromInv", function(owner, wep) owner:RemoveWepInventory(wep) end)
function meta:AddToInventoryWood(amt)
    local inv = self.inv or {}
    local tbl = {}
    local amount = 0
    local altered = false
    local ammo1 = GetAmmoForCurrentWeapon(self)
    for k, v in pairs(inv) do
        if v.Class == "rust_wood" then
            amount = v.Amount + amt
            tbl.Name = "Wood"
            tbl.Class = "rust_wood" or ""
            tbl.WepClass = "rust_wood" or ""
            tbl.Mdl = "models/props_debris/wood_board04a.mdl" or ""
            tbl.Ammo_New = ammo1 or 0
            tbl.Amount = amount or 0
            self:SetNWFloat("wood", amount)
            inv[k] = tbl
            altered = true
        end
    end

    if altered == false then
        amount = amt
        tbl.Name = "Wood"
        tbl.Class = "rust_wood" or ""
        tbl.WepClass = "rust_wood" or ""
        tbl.Mdl = "models/props_debris/wood_board04a.mdl" or ""
        tbl.Ammo_New = ammo1 or 0
        tbl.Amount = amount or 0
        self:SetNWFloat("wood", amount)
        inv[#inv + 1] = tbl
    end

    self.inv = inv
    --net.Start("SendInventory")
    --/net.WriteTable(inv)
    -- n/et.Send(self)
    file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON(inv))
end

function meta:RemoveInventoryWood(amt)
    local inv = self.inv or {}
    local tbl = {}
    local amount = 0
    local ammo1 = GetAmmoForCurrentWeapon(self)
    for k, v in pairs(inv) do
        if v.Class == "rust_wood" then
            amount = v.Amount - amt
            if amount > 0 then
                tbl.Name = "Wood"
                tbl.Class = "rust_wood" or ""
                tbl.WepClass = "rust_wood" or ""
                tbl.Mdl = "models/props_debris/wood_board04a.mdl" or ""
                tbl.Ammo_New = ammo1 or 0
                tbl.Amount = amount or 0
                self:SetNWFloat("wood", amount)
                inv[k] = tbl
            else
                inv[k] = nil
            end
        end
    end

    self.inv = inv
    --net.Start("SendInventory")
    --/net.WriteTable(inv)
    -- n/et.Send(self)
    file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON(inv))
end

local function WhatRock(ply, inv, skins)
    local tbl = {}
    local amount = math.random(25, 30)
    local ammo1 = GetAmmoForCurrentWeapon(ply)
    -- 1 metal, 2 sulfur, 3 Rock
    local gRust_Rocks = ""
    if skins == 1 then
        gRust_Rocks = "Metal"
    elseif skins == 2 then
        gRust_Rocks = "Sulfur"
    elseif skins == 3 then
        gRust_Rocks = "Rock"
    end

    tbl.Name = gRust_Rocks
    tbl.Class = "sent_rocks" or ""
    tbl.WepClass = "sent_rocks" or ""
    tbl.Mdl = "models/environment/ores/ore_node_stage1.mdl" or ""
    tbl.Ammo_New = ammo1 or 0
    tbl.Amount = amount or 0
    tbl.Skins = skins
    inv[#inv + 1] = tbl
    return inv
end

function meta:AddToInventoryRocks(skins)
    local inv = self.inv or {}
    local tbl = {}
    local amount = 0
    local altered = false
    local ammo1 = GetAmmoForCurrentWeapon(self)
    for k, v in pairs(inv) do
        if v.Class == "sent_rocks" and v.Skins == skins then
            amount = v.Amount + math.random(25, 30)
            local gRust_Rocks = "Metal"
            if skins == 2 then
                gRust_Rocks = "Sulfur"
            elseif skins == 3 then
                gRust_Rocks = "Rock"
            end

            tbl.Name = gRust_Rocks
            tbl.Class = "sent_rocks" or ""
            tbl.WepClass = "sent_rocks" or ""
            tbl.Mdl = "models/environment/ores/ore_node_stage1.mdl" or ""
            tbl.Ammo_New = ammo1 or 0
            tbl.Amount = amount or 0
            tbl.Skins = v.Skins
            inv[k] = tbl
            altered = true
        end
    end

    if altered == false then inv = WhatRock(self, inv, skins) end
    self.inv = inv
    --net.Start("SendInventory")
    -- net.WriteTable(inv)
    -- net.Send(self)
    file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON(inv))
end

function meta:RemoveInventoryRocks(skins, amt)
    local inv = self.inv or {}
    local tbl = {}
    local amount = 0
    local altered = false
    local ammo1 = GetAmmoForCurrentWeapon(self)
    for k, v in pairs(inv) do
        if v.Class == "sent_rocks" and v.Skins == 3 then
            amount = v.Amount - amt -- math.random(25, 30)
            tbl.Name = "Rock"
            tbl.Class = "sent_rocks" or ""
            tbl.WepClass = "sent_rocks" or ""
            tbl.Mdl = "models/environment/ores/ore_node_stage1.mdl" or ""
            tbl.Ammo_New = ammo1 or 0
            tbl.Amount = amount or 0
            tbl.Skins = v.Skins
            inv[k] = tbl
            altered = true
        end
    end

    if altered == false then inv = WhatRock(self, inv, skins) end
    self.inv = inv
    --net.Start("SendInventory")
    -- net.WriteTable(inv)
    -- net.Send(self)
    file.Write("ginv/inventory_" .. self:SteamID64() .. ".txt", util.TableToJSON(inv))
end

local function BackwardsEnums(enumname)
    local backenums = {}
    for k, v in pairs(_G) do
        if isstring(k) and string.find(k, "^" .. enumname) then backenums[v] = k end
    end
    return backenums
end

hook.Add("EntityTakeDamage", "EntityDamageExample", function(ent, dmginfo)
    local MAT = BackwardsEnums("MAT_")
    local ply = dmginfo:GetAttacker()
    if not IsValid(ply) then return end
    local wep = ply:GetActiveWeapon()
    if not string.find(wep:GetClass(), "hachet") and string.find(wep:GetClass(), "pickaxe") and string.find(wep:GetClass(), "rock") then return end
    if MAT[ent:GetMaterialType()] == "MAT_WOOD" and not string.find(ent:GetClass(), "sent_") then
        if not IsValid(ply) then return end
        if ply:GetActiveWeapon():GetClass() == "rust_rock" then ply:AddToInventoryWood(5) end
    end

    if ent:GetClass() == "sent_rocks" then ply:AddToInventoryRocks(ent:GetSkin()) end
end)

hook.Add("PlayerInitialSpawn", "InventoryLoadout", function(ply)
    ply.inv = ply:FirstCreateInv()
    timer.Simple(3, function() ply:Give("rust_rock") end)
    for k, v in pairs(ents.FindByClass("rust_sleepingbag")) do
        if v.Owner == ply then ply:SetPos(v.GetPosz + Vector(0, 0, 10)) end
    end

    --ply:Give("weapon_torch")
    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 10)) do
        if v:GetClass() == "sent_rocks" then ply:SetPos(v:GetPos() + Vector(v:OBBMins().x, v:OBBMins().y, v:OBBMins().z + 12)) end
    end

    ply:SetModel("models/player/Spike/RustGuy.mdl")
    local plymeta = ply:GetItem("Wood")
    if plymeta == nil then return end
    ply:SetNWFloat("wood", plymeta.Amount)
end)

hook.Add("PlayerSpawn", "GiveITems", function(ply)
    ply.inv = ply:FirstCreateInv()
    for k, v in pairs(ents.FindByClass("rust_sleepingbag")) do
        if v.Owner == ply then ply:SetPos(v.GetPosz + Vector(0, 0, 10)) end
    end

    ply:Give("rust_rock")
    --ply:Give("weapon_torch")
    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 10)) do
        if v:GetClass() == "sent_rocks" then ply:SetPos(v:GetPos() + Vector(v:OBBMins().x, v:OBBMins().y, v:OBBMins().z + 12)) end
    end

    ply:SetModel("models/player/Spike/RustGuy.mdl")
    local plymeta = ply:GetItem("Wood")
    if plymeta == nil then return end
    ply:SetNWFloat("wood", plymeta.Amount)
end)

hook.Add("PlayerDeath", "RemoveItems", function(ply) ply.inv = ply:FirstCreateInv("b_dead") end)
hook.Add("PlayerUse", "USeInventory", function(ply, ent)
    if ent.IsItem == true then
        ply:AddToInventory(ent)
        ent:Remove()
    end
end)

net.Receive("SendInventory", function(len, ply)
    if ply.CoolDowngrust == nil then ply.CoolDowngrust = 0 end
    if ply.CoolDowngrust >= CurTime() then return end
    ply.CoolDowngrust = CurTime() + 1
    net.Start("ForgiveMeInventory")
    net.WriteTable(ply.inv)
    net.Send(ply)
end)

hook.Add("GetFallDamage", "CSSFallDamage", function(ply, speed) return math.max(0, math.ceil(0.2418 * speed - 141.75)) end)