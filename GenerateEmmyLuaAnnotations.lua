local sourcePath = debug.getinfo(1).source;

sourcePath = string.gsub(sourcePath, "\\", "/")
sourcePath = string.gsub(sourcePath, "@", "")
sourcePath = string.gsub(sourcePath, "[^/]+$", "ClassAndFunction.json")

local targetDir = string.gsub(sourcePath, "[^/]+$", "EmmyLuaAnnotations/")



local json = require("dkjson")


local fullString = io.open(sourcePath,"r"):read("*a")
local allData = json.decode(fullString)

function typesToStringArray(t)
    local stringArray = {}
    
    for i, singleType in ipairs(t) do
       
        if type(singleType) == "table" then
            if singleType.kind == "array" then
                table.insert(stringArray, table.concat(typesToStringArray(singleType.types), "|") .. "[]");
            elseif singleType.kind == "table" then
                table.insert(stringArray, "table");
            elseif singleType.kind == "function" then
                table.insert(stringArray, "function");
            elseif singleType.kind == "literal" then
                table.insert(stringArray, "number");
            else
                fff =abc+def+sss 
            end
        elseif type(singleType)=="string" then
            table.insert(stringArray, singleType);
        end

    end

    return stringArray;
end

local ReservedWords = {
}
ReservedWords['function'] = true;
ReservedWords['end'] = true;
ReservedWords['for'] = true;
ReservedWords['while'] = true;
ReservedWords['local'] = true;
ReservedWords['and'] = true;
ReservedWords['or'] = true;

function fixReservedWord(name)
    if ReservedWords[name] then
        return "_"..name;
    end
    return name
end

function saveClass(data)
    local savePath = targetDir .. "/" .. data.name .. ".lua"

    local fieldsStrings = {}
    local functionStrings = {}
    if data.members then
        for i,v in ipairs(data.members) do
            if v.kind == "field" then
                local string = "--"..v.description.."\n"
                string = string .. "\t---@type " .. table.concat( typesToStringArray(v.types), "|") .. "\n";
                string = string .. "\t" .. v.name .. " = nil;\n\n"
                table.insert(fieldsStrings, string)
            elseif v.kind == "function" then
                local string = "--"..(v.description or "").."\n"
                string = string .. "--available:" .. v.available .. "\n";
                local argNames = {}
                for i, arg in ipairs(v.args) do
                    arg.name = fixReservedWord(arg.name);
                    string = string .. "---@param " .. arg.name .. " "  .. table.concat(typesToStringArray(arg.types),"|") .. "\n"
                    table.insert(argNames, arg.name)
                end
                string = string .. "---@return " .. table.concat(typesToStringArray(v.returns),",") .. "\n"


            string = string .. "function " .. data.name .. ":" .. v.name .. "(" ..table.concat(argNames,",") .. ")end\n\n"
                table.insert(functionStrings, string)
            end
        end
    end

    local file = io.open(savePath, "w");
    file:write("---@class " .. data.name .. (data.extend and (" : " .. data.extend) or "").. "\n") ;
    file:write(data.name .. " = \n{\n")
    for i, field in ipairs(fieldsStrings) do
        -- body
        file:write("\t" .. field)
    end
    file:write("}\n")

    for index, func in ipairs(functionStrings) do
        -- body
        file:write(  func)
    end

    file:close()


end
local fileSaveFunction = io.open(targetDir .. "/a_GlobalFunctions.lua", "w")
for i,v in ipairs(allData) do
    if v.kind == "class" then
        saveClass(v)
    elseif v.kind == "function" then
        fileSaveFunction:write("--"..(v.description or "").."\n"); 
        fileSaveFunction:write("--available:" .. v.available .. "\n")

        local argNames = {}
        for i, arg in ipairs(v.args) do
            fileSaveFunction:write("---@param " .. arg.name .. " "  .. table.concat(typesToStringArray(arg.types),"|") .. "\n")
            table.insert(argNames, arg.name)
        end
        fileSaveFunction:write("---@return " .. table.concat(typesToStringArray(v.returns),",") .. "\n")


        fileSaveFunction:write("function " .. v.name .. "(" ..table.concat(argNames,",") .. ")end\n\n")

    end

end
fileSaveFunction:close();






--then fetch all constants and enum
fileSaveFunction = io.open(targetDir .. "/a_ConstantsAndEnum.lua", "w");

sourcePath = string.gsub(sourcePath, "[^/]+$", "ConstantAndEnum.json")
fullString = io.open(sourcePath,"r"):read("*a")
allData = json.decode(fullString)

for index, v in ipairs(allData) do
    -- body
    if v.kind == "constant" then
        fileSaveFunction:write("--available:" .. v.available .. "\n")
        fileSaveFunction:write(v.name .. " = " .. v.value ..  "\n\n")
    elseif v.kind == "enum" then
        fileSaveFunction:write("--available:" .. v.available .. "\n")
        fileSaveFunction:write(v.name .. " = \n{\n")

        for index, enum in ipairs(v.members) do
            -- body
            if enum.description then
                fileSaveFunction:write("\t--" .. enum.description .. "\n")
            end
            fileSaveFunction:write("\t" .. enum.name .. " = " .. tostring(enum.value) ..  ";\n\n")

        end
        fileSaveFunction:write("}\n\n")
    end
end



fileSaveFunction:close()


