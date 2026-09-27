-- run from the RoStub folder:  lua examples/example.spec.lua   (or luau / lune)
package.path = "./?.lua;../?.lua;" .. package.path

local RoStub = require("rostub")
local spec = require("spec")
RoStub.install()
spec.install()

local function baseParts(root)
	local o = {}
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BasePart") then o[#o + 1] = d end
	end
	return o
end

local function volume(model)
	local v = 0
	for _, p in ipairs(baseParts(model)) do
		v = v + p.Size.X * p.Size.Y * p.Size.Z
	end
	return v
end

local function counter(re)
	local n = 0
	re.OnClientEvent:Connect(function(x) n = n + x end)
	return function() return n end
end

describe("baseParts", function()
	local model
	beforeEach(function()
		model = Instance.new("Model")
		local a = Instance.new("Part", model)
		local b = Instance.new("Part", a)
		Instance.new("Decal", b)
		Instance.new("Folder", model)
	end)

	it("finds every descendant BasePart", function()
		expect(#baseParts(model)).toBe(2)
	end)

	it("ignores non-parts", function()
		for _, p in ipairs(baseParts(model)) do
			expect(p:IsA("BasePart")).toBeTruthy()
		end
	end)
end)

describe("volume", function()
	it("sums X*Y*Z", function()
		local m = Instance.new("Model")
		Instance.new("Part", m).Size = Vector3.new(2, 3, 4)
		Instance.new("Part", m).Size = Vector3.new(1, 1, 1)
		expect(volume(m)).toBe(25)
	end)
	it("is zero when empty", function()
		expect(volume(Instance.new("Model"))).toBe(0)
	end)
end)

describe("datatypes", function()
	it("vector math", function()
		expect(Vector3.new(1, 2, 3) + Vector3.new(1, 1, 1)).toEqual(Vector3.new(2, 3, 4))
	end)
	it("typeof", function()
		expect(typeof(CFrame.new())).toBe("CFrame")
		expect(typeof(Color3.new())).toBe("Color3")
	end)
	it("fromRGB", function()
		expect(Color3.fromRGB(255, 0, 0).R).toBeCloseTo(1)
	end)
end)

describe("remote counter", function()
	it("adds up fired values", function()
		local re = Instance.new("RemoteEvent")
		local get = counter(re)
		re:FireAllClients(5)
		re:FireAllClients(3)
		expect(get()).toBe(8)
	end)
end)

describe("scheduler", function()
	it("runs in time order", function()
		local log = {}
		task.spawn(function() task.wait(2) log[#log + 1] = "late" end)
		task.delay(1, function() log[#log + 1] = "early" end)
		RoStub.run()
		expect(table.concat(log, ",")).toBe("early,late")
	end)
end)

describe("misc", function()
	it("never", function() expect(1).never.toBe(2) end)
	it("throws", function() expect(function() error("boom") end).toThrow("boom") end)
end)

spec.run()
