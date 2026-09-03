local Icons = {}

local IconMap = {
	["home"] = "rbxassetid://10723407389",
	["settings"] = "rbxassetid://10734950309",
	["user"] = "rbxassetid://10747373176",
	["users"] = "rbxassetid://10747373426",
	["shield"] = "rbxassetid://10734951847",
	["sword"] = "rbxassetid://10734975692",
	["crosshair"] = "rbxassetid://10709769841",
	["eye"] = "rbxassetid://10723346959",
	["eye-off"] = "rbxassetid://10723347128",
	["terminal"] = "rbxassetid://10734982144",
	["code"] = "rbxassetid://10709810463",
	["cpu"] = "rbxassetid://10709772223",
	["zap"] = "rbxassetid://10709819149",
	["flame"] = "rbxassetid://10709782497",
	["sparkles"] = "rbxassetid://10734969248",
	["info"] = "rbxassetid://10723415903",
	["alert"] = "rbxassetid://10709752935",
	["bell"] = "rbxassetid://10709756041",
	["check"] = "rbxassetid://10709790644",
	["x"] = "rbxassetid://10709791437",
	["minus"] = "rbxassetid://10734896206",
	["minimize"] = "rbxassetid://10734896206",
	["maximize"] = "rbxassetid://10734895856",
	["chevron-down"] = "rbxassetid://10709790948",
	["chevron-up"] = "rbxassetid://10709791176",
	["chevron-right"] = "rbxassetid://10709791053",
	["search"] = "rbxassetid://10734943674",
	["copy"] = "rbxassetid://10709771143",
	["sliders"] = "rbxassetid://10734966600",
	["palette"] = "rbxassetid://10734919597",
	["lock"] = "rbxassetid://10723434791",
	["unlock"] = "rbxassetid://10723434938",
	["key"] = "rbxassetid://10723424505",
	["folder"] = "rbxassetid://10723387841",
	["file"] = "rbxassetid://10723374641",
	["download"] = "rbxassetid://10709767827",
	["upload"] = "rbxassetid://10734983377",
	["refresh"] = "rbxassetid://10734940376",
	["trash"] = "rbxassetid://10747362393",
	["globe"] = "rbxassetid://10723404337",
	["link"] = "rbxassetid://10723434557",
	["sun"] = "rbxassetid://10734974297",
	["moon"] = "rbxassetid://10734913867",
	["menu"] = "rbxassetid://10734898592",
	["mouse-pointer"] = "rbxassetid://10734915632",
}

function Icons.Get(name: string?): string
	if not name or name == "" then return "" end
	if string.find(name, "rbxassetid://") or string.find(name, "http") then
		return name
	end
	if tonumber(name) then
		return "rbxassetid://" .. name
	end
	local key = string.lower(string.gsub(name, "lucide%-", ""))
	return IconMap[key] or IconMap["sparkles"]
end

return Icons
