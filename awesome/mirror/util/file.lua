local os = os


local file = {}

-- shameless
-- https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua/21637668#21637668
function file.exists(name)
    if type(name) ~= "string" then
        return false
    end
    return os.rename(name, name) and true or false
end


return file
