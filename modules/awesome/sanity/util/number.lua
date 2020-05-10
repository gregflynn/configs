local math, string, tonumber = math, string, tonumber

local number = {
    byte_units = {'B', 'K', 'M', 'G', 'T', 'P'},
}

function number.round(num, places)
    local m = (10 ^ (places or 0))
    return math.floor(num * m) / m
end

local human_bytes_fmt = '%s %s'

function number.human_bytes(bytes, places, floor_unit_idx)
    local human_bytes = tonumber(bytes)

    local unit_idx = 1
    while human_bytes >= 1024 or unit_idx < (floor_unit_idx or 1) do
        human_bytes = human_bytes / 1024
        unit_idx = unit_idx + 1
    end

    return string.format(
        human_bytes_fmt,
        number.round(human_bytes, places or 0),
        number.byte_units[unit_idx]
    )
end

return number
