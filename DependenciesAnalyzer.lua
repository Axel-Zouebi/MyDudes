local module = {}

local StudioService = game:GetService("StudioService")

local function resolve(pathString, scriptInstance)
	local context = {
		script = scriptInstance,
	}

	-- Step 1: Replace :WaitForChild("Name") with .Name
	pathString = pathString:gsub(":WaitForChild%([\"']([%w_]+)[\"']%)", ".%1")

	-- Step 2: Remove leading 'game.'
	pathString = pathString:gsub("^game%.", "")

	-- Step 3: Split and resolve
	local current = game
	local parts = {}

	-- Check if it's relative to script (e.g. script.Parent.Module)
	if pathString:match("^script") then
		current = context["script"]
		pathString = pathString:gsub("^script%.?", "") -- remove 'script' prefix
	end

	for part in string.gmatch(pathString, "[%w_]+") do
		if part == "Parent" then
			current = current and current.Parent
		else
			current = current and current:FindFirstChild(part)
		end
		if not current then return nil end
	end

	return current
end

local function analyzeFromEditor(scriptInstance)
	if not scriptInstance:IsA("LuaSourceContainer") then
		warn("Only works on Lua scripts")
		return
	end
	
	-- Optionally find the one most recently interacted with
	local code = scriptInstance.Source

	for path in string.gmatch(code, "require%((.-)%)") do
		path = path:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[\"']", "")
		print("?? Found require path:", path)

		local resolved = resolve(path, scriptInstance)
		if resolved and resolved:IsA("LuaSourceContainer") then
			print("? Resolved:", resolved:GetFullName())
			print("?? Source:\n" .. resolved.Source)
		else
			warn("? Could not resolve dependency or not a script:", path)
		end
	end
end


function module.Analyze()
	local activeScript = StudioService.ActiveScript
	analyzeFromEditor(activeScript)
end

return module