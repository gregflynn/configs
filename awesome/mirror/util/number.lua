local number = {
    byte_units = {"B", "KiB", "MiB", "GiB", "TiB", "PiB"}
}

function number.round(num, places)
    local places = places or 0
    return tonumber(string.format("%."..places.."f", num))
end

function number.human_bytes(bytes, places)
    local places = places or 0
    local unit_idx = 1
    local human_bytes = bytes

    while human_bytes >= 1024 do
        human_bytes = human_bytes / 1024
        unit_idx = unit_idx + 1
    end

    return string.format(
        "%s %s",
        number.round(human_bytes, places),
        number.byte_units[unit_idx]
    )
end

return number
