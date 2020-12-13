local dataPath = "D:\\github\\dota2_lua_api_reference\\all.json" --change to your real path
local targetDir = "D:\\github\\dota2_lua_api_reference\\ForEmmyLua\\"

local json = require("dkjson")


local fullString = ""

for line in io.lines(dataPath) do
    fullString = fullString .. "\r\n";
    fullString = fullString..line
end

local allData = json.decode(fullString)

function saveClass(data)
    local path = targetDir .. "/" .. data.name .. ".lua"

    local fieldsStrings = {}
    if data.members then
        for i,v in ipairs(data.members) do
            if v.kind == "field" then
                local string = "--"..v.description.."\r\n"
                string = string .. "\t---@type " .. table.concat( v.types, "|") .. "\r\n";
                stirng = string .. "\t" .. v.name .. " = nil;\r\n"
                fieldsStrings[#fieldsStrings+1] = string;
            end
        end
    end
end

for i,v in ipairs(allData) do
    if v.kind == "class" then
        saveClass(v)
    end

end



