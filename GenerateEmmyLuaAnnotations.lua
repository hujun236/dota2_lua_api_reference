local dataPath = "D:\\github\\dota2_lua_api_reference\\all.json" --change to your real path
local targetDir = "D:\\github\\dota2_lua_api_reference\\ForEmmyLua\\"

local json = require("dkjson")


local fullString = ""

for line in io.lines(dataPath) do
    fullString = fullString .. "\r\n";
    fullString = fullString..line
end

local allData = json.decode(fullString)

for i,v in ipairs(allData) do
    if v.kind == "class" then
        
    end


end

