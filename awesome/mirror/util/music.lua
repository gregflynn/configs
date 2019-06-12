local awful     = require('awful')
local beautiful = require('beautiful')

local lain = require('lain')

local text = require('util/text')


gpmdp_file_location = beautiful.home..'/.config/Google Play Music Desktop Player/json_store/playback.json'
local music = {
    last_response = nil,
    running_counter = 0,
    album_art_fmt = "/tmp/gpmcover-%s"
}

function maybe_not_running()
    music.running_counter = music.running_counter + 1
    if music.running_counter > 3 then
        music.last_response = nil
    end
end

function get_lines(file)
    local f = io.open(file)
    if not f then return
    else f:close() end

    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

function read_current_track()
    local current = { playing = false }
    local filelines = get_lines(gpmdp_file_location)
    
    -- exit early if gpmdp isn't running
    if not filelines then
        return current
    end
    
    -- parse the json file
    local json = lain.util.dkjson
    local dict, _, _ = json.decode(table.concat(filelines), 1, nil)
    
    -- sometimes dict doesn't parse
    if not dict then
        return current
    end
    
    -- pull out all them datas
    if dict.song.artist then
        current.artist = text.trim(dict.song.artist)
    end
    if dict.song.album then
        current.album = text.trim(dict.song.album)
    end
    if dict.song.title then
        current.title = text.trim(dict.song.title)
    end
    current.cover_url = dict.song.albumArt
    current.playing = dict.playing
    return current
end

function music.get_current_track(callback)
    awful.spawn.easy_async(
        {'pidof', 'Google Play Music Desktop Player'},
        function(stdout)
            local is_running = stdout ~= ''

            if not is_running then
                maybe_not_running()
            end
    
            local current = read_current_track()
            
            
            if current.title then
                music.running_counter = 0
                music.last_response = current
            else
                maybe_not_running()
            end
            
            callback(music.last_response)
        end
    )
end

function music.get_album_art(current, callback)
    local new_album_art = string.format(music.album_art_fmt, math.random(0, 3894732897))
    awful.spawn.easy_async(
        {'curl', current.cover_url, '-o', new_album_art}, function()
            callback(new_album_art)
        end
    )
end

return music
