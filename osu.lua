local osu = {}

function osu.parse(text)
	local map = {}

	local header
	local key = 0

	for line in text:gmatch("[^\r\n]+") do
		key = key + 1
		if key == 1 and line ~= "osu file format v14" then error("Wrong file format.") end

		local header_value = line:match("^%[(.-)%]$")
		if header_value then header = header_value map[header] = {} goto continue end

		local IsEvent = header == "Events"
		local IsTimingPoint = header == "TimingPoints"
		local IsHitObject = header == "HitObjects"

		if (not IsEvent and not IsTimingPoint and not IsHitObject) then
			local key, value = line:match("^(.+):(.+)$")
			if not key then goto continue end
			if value:sub(1, 1) == " " then value = value:sub(2) end

			map[header][key] = value
		elseif (IsEvent or IsTimingPoint or IsHitObject) then
			local struct

			local val = {}
			for value in line:gmatch("[^,]+") do table.insert(val, value) end

			if header == "TimingPoints" then struct = {time = val[1], beatLength = val[2], meter = val[3], sampleSet = val[4], sampleIndex = val[5], volume = val[6], uninherited = val[7], effects = val[7]} end
			if header == "HitObjects" then struct = {x = val[1], y = val[2], time = val[3], type = val[4]} end
			if header == "Events" then struct = {eventType = val[1], startTime = val[2], eventParams = val[3]} end

			table.insert(map[header], struct)
		end

		::continue::
	end

	return map
end

function osu.parseFile(filename)
	local file = io.open(filename)
		local text = file:read("*a")
	file:close()

	return osu.parse(text)
end

return osu