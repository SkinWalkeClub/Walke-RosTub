-- RoStub: offline roblox mock for testing scripts in plain lua/luau. mit.

local M = {}
M._VERSION = "0.1.0"

local ins, rem, cat = table.insert, table.remove, table.concat
local unpk = table.unpack or unpack
local abs, sqrt = math.abs, math.sqrt
local cr = coroutine

local tt = setmetatable({}, { __mode = "k" })
local function tag(n) local m = {} tt[m] = n return m end

local function typeof(v)
	local t = type(v)
	if t ~= "table" and t ~= "userdata" then return t end
	local m = getmetatable(v)
	if m and tt[m] then return tt[m] end
	if t == "table" and rawget(v, "__i") then return "Instance" end
	return t
end
M.typeof = typeof

local function af(a, b) return abs(a - b) < 1e-6 end

local v3 = tag("Vector3")
v3.__index = v3
v3.__eq = function(a, b) return af(a.X, b.X) and af(a.Y, b.Y) and af(a.Z, b.Z) end
v3.__add = function(a, b) return M.Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
v3.__sub = function(a, b) return M.Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
v3.__unm = function(a) return M.Vector3.new(-a.X, -a.Y, -a.Z) end
v3.__mul = function(a, b)
	if type(b) == "number" then return M.Vector3.new(a.X * b, a.Y * b, a.Z * b) end
	return M.Vector3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
v3.__tostring = function(v) return v.X .. ", " .. v.Y .. ", " .. v.Z end
function v3:Lerp(o, a) return M.Vector3.new(self.X + (o.X - self.X) * a, self.Y + (o.Y - self.Y) * a, self.Z + (o.Z - self.Z) * a) end

M.Vector3 = { new = function(x, y, z)
	local v = setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, v3)
	v.Magnitude = sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
	return v
end }
M.Vector3.zero = M.Vector3.new(0, 0, 0)
M.Vector3.one = M.Vector3.new(1, 1, 1)

local v2 = tag("Vector2")
v2.__index = v2
v2.__eq = function(a, b) return af(a.X, b.X) and af(a.Y, b.Y) end
v2.__tostring = function(v) return v.X .. ", " .. v.Y end
M.Vector2 = { new = function(x, y) return setmetatable({ X = x or 0, Y = y or 0 }, v2) end }

local c3 = tag("Color3")
c3.__index = c3
c3.__eq = function(a, b) return af(a.R, b.R) and af(a.G, b.G) and af(a.B, b.B) end
c3.__tostring = function(c) return c.R .. ", " .. c.G .. ", " .. c.B end
M.Color3 = {
	new = function(r, g, b) return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, c3) end,
	fromRGB = function(r, g, b) return setmetatable({ R = (r or 0) / 255, G = (g or 0) / 255, B = (b or 0) / 255 }, c3) end,
}

local cf = tag("CFrame")
cf.__index = cf
cf.__tostring = function(c) local t = {} for _, n in ipairs(c._c) do t[#t + 1] = tostring(n) end return cat(t, ", ") end
function cf:GetComponents() return unpk(self._c) end
M.CFrame = { new = function(x, y, z)
	local c = { x or 0, y or 0, z or 0, 1, 0, 0, 0, 1, 0, 0, 0, 1 }
	return setmetatable({ _c = c, X = c[1], Y = c[2], Z = c[3], Position = M.Vector3.new(c[1], c[2], c[3]) }, cf)
end }
M.CFrame.identity = M.CFrame.new(0, 0, 0)

local ud = tag("UDim")
ud.__index = ud
ud.__eq = function(a, b) return af(a.Scale, b.Scale) and a.Offset == b.Offset end
M.UDim = { new = function(s, o) return setmetatable({ Scale = s or 0, Offset = o or 0 }, ud) end }

local u2 = tag("UDim2")
u2.__index = u2
u2.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
M.UDim2 = {
	new = function(xs, xo, ys, yo)
		return setmetatable({ X = M.UDim.new(xs, xo), Y = M.UDim.new(ys, yo) }, u2)
	end,
	fromScale = function(x, y) return M.UDim2.new(x, 0, y, 0) end,
	fromOffset = function(x, y) return M.UDim2.new(0, x, 0, y) end,
}

local rc = tag("Rect")
rc.__index = rc
M.Rect = { new = function(a, b, c, d) return setmetatable({ Min = M.Vector2.new(a, b), Max = M.Vector2.new(c, d) }, rc) end }

local nr = tag("NumberRange")
nr.__index = nr
M.NumberRange = { new = function(a, b) return setmetatable({ Min = a, Max = b or a }, nr) end }

local bc = tag("BrickColor")
bc.__index = bc
bc.__tostring = function(b) return b.Name end
M.BrickColor = { new = function(v)
	if type(v) == "string" then return setmetatable({ Number = 1, Name = v }, bc) end
	return setmetatable({ Number = v or 1, Name = "Medium stone grey" }, bc)
end }

local edefs = {
	Material = { "Plastic", "Wood", "Slate", "Concrete", "Metal", "Glass", "Neon", "Air", "Water" },
	PartType = { "Ball", "Block", "Cylinder", "Wedge", "CornerWedge" },
	NormalId = { "Right", "Top", "Back", "Left", "Bottom", "Front" },
	Font = { "Legacy", "Arial", "SourceSans", "Gotham", "GothamBold" },
	HumanoidRigType = { "R6", "R15" },
	EasingStyle = { "Linear", "Sine", "Quad", "Cubic", "Bounce", "Elastic" },
	KeyCode = { "Unknown", "E", "F", "Q", "Space", "LeftShift" },
	RaycastFilterType = { "Exclude", "Include" },
}
local ei = tag("EnumItem")
ei.__index = ei
ei.__tostring = function(e) return "Enum." .. e.EnumType .. "." .. e.Name end
local Enum = {}
for en, items in pairs(edefs) do
	local g = { _i = {} }
	for i, nm in ipairs(items) do
		local it = setmetatable({ Name = nm, Value = i - 1, EnumType = en }, ei)
		g[nm] = it
		g._i[#g._i + 1] = it
	end
	function g:GetEnumItems() return self._i end
	Enum[en] = g
end
M.Enum = Enum

local Sig = {}
Sig.__index = Sig
tt[Sig] = "RBXScriptSignal"

function Sig.new() return setmetatable({ _c = {}, _w = {} }, Sig) end

function Sig:Connect(fn)
	local c = self._c
	c[#c + 1] = fn
	local h = { Connected = true }
	function h:Disconnect()
		self.Connected = false
		for i, f in ipairs(c) do if f == fn then rem(c, i) break end end
	end
	h.Destroy = h.Disconnect
	return h
end
Sig.connect = Sig.Connect

function Sig:Once(fn)
	local h
	h = self:Connect(function(...) h:Disconnect() fn(...) end)
	return h
end

function Sig:Fire(...)
	local s = {}
	for i, f in ipairs(self._c) do s[i] = f end
	for _, fn in ipairs(s) do
		local co = cr.create(fn)
		local ok, e = cr.resume(co, ...)
		if not ok then M._err("signal: " .. tostring(e)) end
	end
	local w = self._w
	self._w = {}
	for _, co in ipairs(w) do
		local ok, e = cr.resume(co, ...)
		if not ok then M._err("wait: " .. tostring(e)) end
	end
end

function Sig:Wait()
	if not cr.isyieldable() then error("Signal:Wait needs a coroutine (task.spawn)", 2) end
	self._w[#self._w + 1] = cr.running()
	return cr.yield()
end
M.Signal = Sig

local sch = { q = {}, clk = 0 }
M._scheduler = sch
local function add(d, fn, ...) sch.q[#sch.q + 1] = { at = sch.clk + (d or 0), fn = fn, a = { ... } } end

M.task = {
	wait = function(t)
		if not cr.isyieldable() then return t or 0 end
		local co = cr.running()
		add(t or 0, function() cr.resume(co) end)
		cr.yield()
		return t or 0
	end,
	spawn = function(fn, ...)
		local co = cr.create(fn)
		local ok, e = cr.resume(co, ...)
		if not ok then M._err("spawn: " .. tostring(e)) end
		return co
	end,
	defer = function(fn, ...) add(0, fn, ...) end,
	delay = function(t, fn, ...) add(t, fn, ...) end,
	cancel = function() end,
}

function M.run(max)
	max = max or 100000
	local n = 0
	while #sch.q > 0 and n < max do
		table.sort(sch.q, function(a, b) return a.at < b.at end)
		local j = rem(sch.q, 1)
		sch.clk = math.max(sch.clk, j.at)
		local co = cr.create(j.fn)
		local ok, e = cr.resume(co, unpk(j.a))
		if not ok then M._err("run: " .. tostring(e)) end
		n = n + 1
	end
	return n
end

M._err = function(m) io.stderr:write("[RoStub] " .. m .. "\n") end

local cls = {
	PVInstance = "Instance", BasePart = "PVInstance", Part = "BasePart",
	MeshPart = "BasePart", UnionOperation = "BasePart", Model = "PVInstance",
	Folder = "Instance", Configuration = "Instance", ValueBase = "Instance",
	IntValue = "ValueBase", StringValue = "ValueBase", BoolValue = "ValueBase",
	NumberValue = "ValueBase", ObjectValue = "ValueBase", Vector3Value = "ValueBase",
	CFrameValue = "ValueBase", Color3Value = "ValueBase",
	LuaSourceContainer = "Instance", BaseScript = "LuaSourceContainer",
	Script = "BaseScript", LocalScript = "BaseScript", ModuleScript = "LuaSourceContainer",
	GuiBase = "Instance", GuiBase2d = "GuiBase", GuiObject = "GuiBase2d",
	Frame = "GuiObject", TextLabel = "GuiObject", TextButton = "GuiObject",
	TextBox = "GuiObject", ImageLabel = "GuiObject", ImageButton = "GuiObject",
	ScrollingFrame = "GuiObject", LayerCollector = "GuiBase2d", ScreenGui = "LayerCollector",
	Humanoid = "Instance", Accessory = "Model", Tool = "Model",
	Attachment = "Instance", Decal = "Instance", Texture = "Decal",
	Sound = "Instance", Light = "Instance", PointLight = "Light",
	SpotLight = "Light", SurfaceLight = "Light", Camera = "Instance", Terrain = "BasePart",
	RemoteEvent = "Instance", RemoteFunction = "Instance",
	BindableEvent = "Instance", BindableFunction = "Instance",
	UIListLayout = "Instance", UIPadding = "Instance", UICorner = "Instance",
	Workspace = "Model", Players = "Instance", Lighting = "Instance",
	ReplicatedStorage = "Instance", ServerStorage = "Instance", StarterGui = "Instance",
	StarterPack = "Instance", ReplicatedFirst = "Instance", SoundService = "Instance",
	CollectionService = "Instance", Player = "Instance", DataModel = "Instance",
}
M.CLASSES = cls

local function isa(c, t)
	while c do if c == t then return true end c = cls[c] end
	return false
end

local im = {}

local function sig(o, n)
	local s = rawget(o, "_s")
	if not s[n] then s[n] = Sig.new() end
	return s[n]
end

local function mk(cn)
	local o = setmetatable({}, im)
	rawset(o, "__i", true)
	rawset(o, "_cn", cn)
	rawset(o, "_ch", {})
	rawset(o, "_at", {})
	rawset(o, "_tg", {})
	rawset(o, "_s", {})
	local p = { Name = cn, ClassName = cn, Parent = nil, Archivable = true }
	rawset(o, "_p", p)
	if isa(cn, "BasePart") then
		p.Size = M.Vector3.new(4, 1, 2)
		p.Position = M.Vector3.new(0, 0, 0)
		p.CFrame = M.CFrame.new(0, 0, 0)
		p.Anchored = false
		p.CanCollide = true
		p.Transparency = 0
		p.Color = M.Color3.fromRGB(163, 162, 165)
		p.Material = Enum.Material.Plastic
	end
	if isa(cn, "ValueBase") then p.Value = 0 end
	if isa(cn, "GuiObject") then
		p.Visible = true
		p.Position = M.UDim2.new(0, 0, 0, 0)
		p.Size = M.UDim2.new(0, 100, 0, 100)
	end
	if isa(cn, "LuaSourceContainer") then p.Source = "" end
	return o
end
M._newInstance = mk

function im:IsA(t) return isa(rawget(self, "_cn"), t) end

function im:GetChildren()
	local o = {}
	for i, c in ipairs(rawget(self, "_ch")) do o[i] = c end
	return o
end

function im:GetDescendants()
	local o = {}
	local function r(x) for _, c in ipairs(rawget(x, "_ch")) do o[#o + 1] = c r(c) end end
	r(self)
	return o
end

function im:FindFirstChild(n, deep)
	for _, c in ipairs(rawget(self, "_ch")) do if rawget(c, "_p").Name == n then return c end end
	if deep then
		for _, c in ipairs(rawget(self, "_ch")) do local f = c:FindFirstChild(n, true) if f then return f end end
	end
	return nil
end

function im:FindFirstChildOfClass(k)
	for _, c in ipairs(rawget(self, "_ch")) do if rawget(c, "_cn") == k then return c end end
	return nil
end

function im:FindFirstChildWhichIsA(k)
	for _, c in ipairs(rawget(self, "_ch")) do if c:IsA(k) then return c end end
	return nil
end

function im:WaitForChild(n) return self:FindFirstChild(n) end

function im:GetFullName()
	local t, o = {}, self
	while o do
		ins(t, 1, rawget(o, "_p").Name)
		o = rawget(o, "_p").Parent
		if o and rawget(o, "_cn") == "DataModel" then break end
	end
	return cat(t, ".")
end

function im:Clone()
	local c = mk(rawget(self, "_cn"))
	for k, v in pairs(rawget(self, "_p")) do if k ~= "Parent" then rawget(c, "_p")[k] = v end end
	for k, v in pairs(rawget(self, "_at")) do rawget(c, "_at")[k] = v end
	for _, ch in ipairs(rawget(self, "_ch")) do ch:Clone().Parent = c end
	return c
end

function im:Destroy()
	self.Parent = nil
	for _, c in ipairs(self:GetChildren()) do c:Destroy() end
	rawset(self, "_dead", true)
end

function im:GetAttribute(n) return rawget(self, "_at")[n] end
function im:SetAttribute(n, v) rawget(self, "_at")[n] = v end
function im:GetAttributes()
	local t = {}
	for k, v in pairs(rawget(self, "_at")) do t[k] = v end
	return t
end

function im:AddTag(t) rawget(self, "_tg")[t] = true end
function im:RemoveTag(t) rawget(self, "_tg")[t] = nil end
function im:HasTag(t) return rawget(self, "_tg")[t] == true end
function im:GetTags()
	local o = {}
	for t in pairs(rawget(self, "_tg")) do o[#o + 1] = t end
	return o
end

function im:GetPropertyChangedSignal() return sig(self, "_prop") end
function im:FireServer(...) sig(self, "OnServerEvent"):Fire(...) end
function im:FireClient(_, ...) sig(self, "OnClientEvent"):Fire(...) end
function im:FireAllClients(...) sig(self, "OnClientEvent"):Fire(...) end
function im:Fire(...) sig(self, "Event"):Fire(...) end
function im:Invoke(...) return end

local evs = { OnServerEvent = 1, OnClientEvent = 1, Event = 1, Changed = 1, ChildAdded = 1, ChildRemoved = 1, DescendantAdded = 1, Touched = 1 }

im.__index = function(self, k)
	local fn = rawget(im, k)
	if fn ~= nil then return fn end
	local p = rawget(self, "_p")
	if p[k] ~= nil then return p[k] end
	if evs[k] then return sig(self, k) end
	for _, c in ipairs(rawget(self, "_ch")) do if rawget(c, "_p").Name == k then return c end end
	return nil
end

im.__newindex = function(self, k, v)
	local p = rawget(self, "_p")
	if k == "Parent" then
		local old = p.Parent
		if old then
			local oc = rawget(old, "_ch")
			for i, c in ipairs(oc) do if c == self then rem(oc, i) break end end
		end
		p.Parent = v
		if v then
			ins(rawget(v, "_ch"), self)
			local a = rawget(v, "_s").ChildAdded
			if a then a:Fire(self) end
		end
		return
	end
	p[k] = v
	local ch = rawget(self, "_s").Changed
	if ch then ch:Fire(k) end
	local pc = rawget(self, "_s")._prop
	if pc then pc:Fire() end
end

M.Instance = { new = function(cn, par)
	if not cls[cn] and cn ~= "DataModel" then cls[cn] = "Instance" end
	local o = mk(cn)
	if par then o.Parent = par end
	return o
end }

local function mkgame()
	local g = mk("DataModel")
	local gp = rawget(g, "_p")
	gp.Name = "Ugc"
	gp.PlaceId = 0
	gp.JobId = ""
	gp.HttpGet = function() return "" end
	gp.HttpGetAsync = function() return "" end
	local svcs = {}
	local function get(n)
		if svcs[n] then return svcs[n] end
		local s = mk(n)
		s.Parent = g
		svcs[n] = s
		return s
	end
	rawset(g, "_svc", svcs)
	function im.GetService(_, n) return get(n) end
	function im.FindService(_, n) return svcs[n] end
	local ws = get("Workspace")
	get("Players") get("Lighting") get("ReplicatedStorage") get("StarterGui") get("SoundService")
	return g, ws
end

local function stubs(g)
	local s = {}
	s.getgenv = function() return g end
	s.getrenv = function() return g end
	s.getfenv = getfenv or function() return g end
	s.setfenv = setfenv or function() end
	s.identifyexecutor = function() return "RoStub", M._VERSION end
	s.getexecutorname = s.identifyexecutor
	s.request = function() return { StatusCode = 200, Body = "" } end
	s.hookfunction = function(o) return o end
	s.hookmetamethod = function() return function() end end
	s.getnamecallmethod = function() return "" end
	s.checkcaller = function() return true end
	s.setclipboard = function() end
	s.setreadonly = function() end
	s.getrawmetatable = getmetatable
	s.make_writeable = function() end
	s.getgc = function() return {} end
	s.getreg = function() return {} end
	s.getloadedmodules = function() return {} end
	s.getconnections = function() return {} end
	s.fireclickdetector = function() end
	s.firetouchinterest = function() end
	s.fireproximityprompt = function() end
	s.gethiddenproperty = function(o, p) local ok = pcall(function() return o[p] end) return ok and o[p] or nil, false end
	s.setscriptable = function() return false end
	s.getcustomasset = function() return "" end
	s.decompile = function() return "-- decompile unavailable in RoStub" end
	return s
end

function M.new()
	local g, ws = mkgame()
	local e = {
		game = g, Game = g, workspace = ws, Workspace = ws,
		Instance = M.Instance, Vector3 = M.Vector3, Vector2 = M.Vector2,
		CFrame = M.CFrame, Color3 = M.Color3, UDim = M.UDim, UDim2 = M.UDim2,
		Rect = M.Rect, NumberRange = M.NumberRange, BrickColor = M.BrickColor,
		Enum = M.Enum, typeof = M.typeof, task = M.task,
		wait = M.task.wait, spawn = M.task.spawn, delay = M.task.delay,
		tick = function() return sch.clk end, time = function() return sch.clk end,
	}
	for k, v in pairs(stubs(e)) do e[k] = v end
	M._env = e
	M._game = g
	return e
end

function M.install(target)
	target = target or _G
	local e = M.new()
	for k, v in pairs(e) do target[k] = v end
	target.getgenv = function() return target end
	target.getrenv = function() return target end
	e.getgenv, e.getrenv = target.getgenv, target.getrenv
	return e, M._game
end

function M.enableGetProperties(target)
	target = target or _G
	local gp = function(o)
		local t = {}
		for k in pairs(rawget(o, "_p")) do t[#t + 1] = k end
		return t
	end
	target.getproperties = gp
	if M._env then M._env.getproperties = gp end
	return gp
end

return M
