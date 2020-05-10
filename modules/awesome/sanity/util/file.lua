local os, type = os, type

local rename = os.rename

local file        = {}
local string_type = 'string'

-- shameless
-- https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua/21637668#21637668
function file.exists(name)
    if type(name) ~= string_type then
        return false
    end
    return rename(name, name) and true or false
end


return file
