local number = {
    byte_units = {"B", "K", "M", "G", "T", "P"},
}

function number.round(num, places)
    local places = places or 0
    return tonumber(string.format("%."..places.."f", num))
end

function number.human_bytes(bytes, places, floor_unit_idx)
    local human_bytes = tonumber(bytes)
    local places = places or 0
    local floor_unit_idx = floor_unit_idx or 1

    local unit_idx = 1
    while human_bytes >= 1024 or unit_idx < floor_unit_idx do
        human_bytes = human_bytes / 1024
        unit_idx = unit_idx + 1
    end

    return string.format(
        "%s %s", number.round(human_bytes, places), number.byte_units[unit_idx]
    )
end

return number
