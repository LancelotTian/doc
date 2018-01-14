local rank = ngx.shared.rank
-- Step is the number of servers
local step = 1
-- todo load init value from redis
local initval = 0
local country_code = ngx.var.geoip2_data_country_code
local country_name = ngx.var.geoip2_data_country_name
local subdivision_name = ngx.var.geoip2_data_subdivision_name
local city_name = ngx.var.geoip2_data_city_name
local city_geoname_id = ngx.var.geoip2_data_city_geoname_id


local function get_area_rank(area_key) -- Should get it from redis
    local areaRank, err = rank:incr(area_key, 1)
    return areaRank, err
end

local function get_rank (area_name, area_key)
    local globalRank, err = rank:incr("global", step, initval)
    local areaRank, err = get_area_rank(area_key)
    globalRank = globalRank or 0
    areaRank = areaRank or 0
    ngx.say('{"global_rank":' .. tostring(globalRank) .. ',"area_name":"' .. area_name .. '","area_rank":' .. tostring(areaRank)  .. '}')
end

if string.upper(country_code) == "CN" then -- China
    if geoname_id ~= 0 then
        local area_name = subdivision_name .. city_name
        local area_key = "city_" .. city_geoname_id
        get_rank(area_name, area_key)
    else
        get_rank("unknown", nil)
    end
else -- Other countries,only use country name
    if country_code then -- Find a country
        local area_name = country_name
        local area_key = "country_" .. country_code
        get_rank(area_name, area_key)
    else -- Can not find location?
        get_rank("unknown", nil)
    end
end
