# abdiez_playtime

A secure, server-side playtime tracker for FiveM built with txAdmin-style architecture.  
Automatically tracks player playtime using server-only logic and stores it safely in SQL.

---

## Features

- Automatic playtime tracking (minute-based)
- Server-authoritative logic (no client trust)
- SQL-backed persistence
- Automatic database table creation
- Optimized in-memory caching
- Read-only server exports
- Supports 128+ concurrent players
- No client scripts

---

## How It Works

The server runs a timer every minute.  
Each online player receives +1 playtime minute.  
All data is stored in MySQL and fetched through server-side exports.  
This is the same core principle used by txAdmin.

---

## Installation

1. Place the resource in your resources folder:
   abdiez_playtime
2. Add the following to server.cfg:
   ensure abdiez_playtime
3. Ensure oxmysql is installed and configured

No manual SQL import is required.

---

## Database

The database table is created automatically on resource start.

Table: abdiez_playtime  
Columns:
- identifier (PRIMARY KEY)
- playtime_minutes

---

## Exports

All exports are server-side only and read-only.

Get total playtime in minutes:
```lua
exports.abdiez_playtime:GetMinutes(source)
exports.abdiez_playtime:GetHours(source)
exports.abdiez_playtime:HasMinutes(source, 10)
exports.abdiez_playtime:HasHours(source, 24)

QBCore.Commands.Add("example", "Example command", {}, false, function(source)
    if not exports.abdiez_playtime:HasMinutes(source, 10) then
        TriggerClientEvent('QBCore:Notify', source, 'You need at least 10 minutes of playtime.', 'error')
        return
    end

    print("Command executed")
end)
```
