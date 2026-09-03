local Services = require(script.Parent.Parent.Services)
local HttpService = Services.HttpService

local Config = {
	Flags = {},
	Folder = "CastUI_Configs",
	File = "default.json"
}

local hasFs = rawget(getfenv(), "writefile") ~= nil and rawget(getfenv(), "readfile") ~= nil

function Config.SetFolder(folder: string)
	Config.Folder = folder
	if hasFs and rawget(getfenv(), "isfolder") and rawget(getfenv(), "makefolder") then
		if not isfolder(folder) then
			makefolder(folder)
		end
	end
end

function Config.SetFlag(flag: string, value: any)
	if flag and flag ~= "" then
		Config.Flags[flag] = value
	end
end

function Config.GetFlag(flag: string): any
	return Config.Flags[flag]
end

function Config.Save(name: string?)
	local fileName = name or Config.File
	if not string.find(fileName, "%.json$") then
		fileName = fileName .. ".json"
	end

	local path = Config.Folder .. "/" .. fileName
	local data = {}

	for k, v in pairs(Config.Flags) do
		if typeof(v) == "Color3" then
			data[k] = { __type = "Color3", r = v.R, g = v.G, b = v.B }
		elseif typeof(v) == "EnumItem" then
			data[k] = { __type = "EnumItem", enum = tostring(v) }
		else
			data[k] = v
		end
	end

	local encoded = HttpService:JSONEncode(data)

	if hasFs then
		local ok, err = pcall(function() writefile(path, encoded) end)
		return ok, err
	end

	return false, "Filesystem not available"
end

function Config.Load(name: string?): (boolean, any)
	local fileName = name or Config.File
	if not string.find(fileName, "%.json$") then
		fileName = fileName .. ".json"
	end

	local path = Config.Folder .. "/" .. fileName

	if hasFs and rawget(getfenv(), "isfile") and isfile(path) then
		local ok, content = pcall(readfile, path)
		if ok and content then
			local decOk, decoded = pcall(function() return HttpService:JSONDecode(content) end)
			if decOk and type(decoded) == "table" then
				for k, v in pairs(decoded) do
					if type(v) == "table" and v.__type == "Color3" then
						Config.Flags[k] = Color3.new(v.r, v.g, v.b)
					else
						Config.Flags[k] = v
					end
				end
				return true, Config.Flags
			end
		end
	end

	return false, "Config file not found"
end

return Config
