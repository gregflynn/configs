local text = {}

-- Trim whitespace from the given string
-- @returns the trimmed string
function text.trim(s)
   return s:match("^%s*(.-)%s*$"):gsub('&', '&amp;')
end

function text.find(str, char)
    return string.find(str, char, 1, true)
end

-- Trim after the first occurance of a certain character
function text.trim_after(str, trim_char, max_len)
    local trim_loc = text.find(str, trim_char)

    if trim_loc and (max_len == nil or trim_loc <= max_len) then
        return text.trim(string.sub(str, 1, trim_loc - 1))
    else
        return str
    end
end

-- Trim a string before the first occurance of a certain character
-- @returns the truncated string
function text.trim_before(str, trim_char)
    local trim_loc = text.find(str, trim_char)

    if trim_loc then
        return text.trim(string.sub(str, trim_loc + 1))
    else
        return str
    end
end

-- Select the text between enclosing characters
function text.select(str, enclosing_char)
    return text.trim_after(text.trim_before(str, enclosing_char), enclosing_char)
end

-- Truncate the given string, by length, trim after character, and ellipsis
-- @returns the truncated string
function text.trunc(str, max_len, trim_char, use_ellipsis)
    if string.len(str) < max_len then
        return str
    else
        if trim_char then
            local trimmed_str = text.trim_after(str, trim_char, max_len)
            if string.len(trimmed_str) <= max_len then
                return trimmed_str
            end
        end

        if use_ellipsis then
            return string.sub(str, 0, max_len - 3)..'...'
        else
            return stromg.sub(str, 0, max_len)
        end
    end
end

function text.split(str, delimiter)
    local delimiter = delimiter or " "
    local result = {};
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function text.pad(str, width, right, char)
    local str = tostring(str) or ""
    local pad = width - str:len()
    local char = char or " "

    if pad > 0 then
        local padding = string.rep(char, pad)
        if right then
            return str..padding
        else
            return padding..str
        end
    end

    return str
end

return text
