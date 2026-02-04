local Cache = {}

MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS abdiez_playtime (
            identifier VARCHAR(64) PRIMARY KEY,
            playtime_minutes INT NOT NULL DEFAULT 0
        )
    ]])
end)

local function GetIdentifier(src)
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == 'license:' then
            return id
        end
    end
end

local function SetCache(src, minutes)
    Cache[src] = {
        minutes = minutes,
        expires = os.time() + Config.CacheTTL
    }
end

local function GetCache(src)
    local data = Cache[src]
    if data and data.expires > os.time() then
        return data.minutes
    end
    Cache[src] = nil
end

AddEventHandler('playerConnecting', function()
    local src = source
    local identifier = GetIdentifier(src)
    if not identifier then return end

    MySQL.prepare([[
        INSERT INTO abdiez_playtime (identifier)
        VALUES (?)
        ON DUPLICATE KEY UPDATE identifier = identifier
    ]], { identifier })

    Cache[src] = nil
end)

AddEventHandler('playerDropped', function()
    Cache[source] = nil
end)

CreateThread(function()
    while true do
        Wait(Config.PlaytimeTick * 1000)

        for _, src in ipairs(GetPlayers()) do
            local identifier = GetIdentifier(src)
            if identifier then
                MySQL.prepare(
                    'UPDATE abdiez_playtime SET playtime_minutes = playtime_minutes + 1 WHERE identifier = ?',
                    { identifier }
                )
                Cache[src] = nil
            end
        end
    end
end)

local function FetchMinutes(src)
    local cached = GetCache(src)
    if cached then return cached end

    local identifier = GetIdentifier(src)
    if not identifier then return 0 end

    local minutes = MySQL.scalar.await(
        'SELECT playtime_minutes FROM abdiez_playtime WHERE identifier = ?',
        { identifier }
    ) or 0

    SetCache(src, minutes)
    return minutes
end

exports('GetMinutes', function(src)
    return FetchMinutes(src)
end)

exports('GetHours', function(src)
    return math.floor(FetchMinutes(src) / 60)
end)

exports('HasMinutes', function(src, minutes)
    return FetchMinutes(src) >= minutes
end)

exports('HasHours', function(src, hours)
    return math.floor(FetchMinutes(src) / 60) >= hours
end)

RegisterCommand('playtime', function(source)
    local src = source

    local minutes = FetchMinutes(src)
    if not minutes then return end

    local hours = math.floor(minutes / 60)
    local mins = minutes % 60

    local text = ""

    if hours > 0 then
        text = hours .. " timme"
        if hours > 1 then
            text = text .. "r"
        end
    end

    if mins > 0 then
        if text ~= "" then
            text = text .. " och "
        end

        text = text .. mins .. " minut"
        if mins > 1 then
            text = text .. "er"
        end
    end

    if text == "" then
        text = "0 minuter"
    end

    TriggerClientEvent('QBCore:Notify', src, "Du har spelat: " .. text, "success", 7500)
end)
