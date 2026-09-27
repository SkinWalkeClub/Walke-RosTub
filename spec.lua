-- spec: tiny test runner. describe / it / expect / beforeEach, then spec.run().

local S = {}
local st = { stk = {}, pass = 0, fail = 0, fails = {}, bef = {} }

local function deq(a, b)
	if a == b then return true end
	if type(a) ~= "table" or type(b) ~= "table" then return false end
	local m = getmetatable(a)
	if m and m.__eq then return a == b end
	for k, v in pairs(a) do if not deq(v, b[k]) then return false end end
	for k in pairs(b) do if a[k] == nil then return false end end
	return true
end

local function fm(v) if type(v) == "string" then return '"' .. v .. '"' end return tostring(v) end

local function mm(val, neg)
	local m = {}
	local function ck(c, msg) if neg then c = not c end if not c then error({ _s = true, msg = msg }, 2) end end
	function m.toBe(x) ck(val == x, "expected " .. fm(val) .. (neg and " to not be " or " to be ") .. fm(x)) end
	function m.toEqual(x) ck(deq(val, x), "expected " .. fm(val) .. (neg and " to not equal " or " to equal ") .. fm(x)) end
	function m.toBeTruthy() ck(val and true or false, "expected " .. fm(val) .. " to be truthy") end
	function m.toBeFalsy() ck(not val, "expected " .. fm(val) .. " to be falsy") end
	function m.toBeNil() ck(val == nil, "expected " .. fm(val) .. " to be nil") end
	function m.toBeCloseTo(x, e) ck(math.abs(val - x) < (e or 1e-6), "expected " .. fm(val) .. " ~= " .. fm(x)) end
	function m.toContain(x)
		local f = false
		for _, v in ipairs(val) do if v == x then f = true break end end
		ck(f, "expected table to contain " .. fm(x))
	end
	function m.toThrow(sub)
		local ok, e = pcall(val)
		if sub and not ok and type(e) == "string" then
			ck(e:find(sub, 1, true) ~= nil, "error missing " .. fm(sub) .. ", got " .. fm(e))
		else
			ck(not ok, "expected function to throw")
		end
	end
	return m
end

function S.expect(v)
	local m = mm(v, false)
	m.never = mm(v, true)
	return m
end

function S.describe(n, fn)
	st.stk[#st.stk + 1] = n
	fn()
	st.bef[#st.stk] = nil
	st.stk[#st.stk] = nil
end

function S.beforeEach(fn) st.bef[#st.stk] = fn end

function S.it(n, fn)
	local path = table.concat(st.stk, " > ")
	for i = 1, #st.stk do local b = st.bef[i] if b then b() end end
	local ok, e = pcall(fn)
	if ok then
		st.pass = st.pass + 1
		print("  \27[32mok\27[0m " .. n)
	else
		st.fail = st.fail + 1
		local msg = (type(e) == "table" and e._s) and e.msg or tostring(e)
		st.fails[#st.fails + 1] = { w = path .. " > " .. n, m = msg }
		print("  \27[31mX  " .. n .. "\27[0m")
		print("     " .. msg)
	end
end

function S.run()
	print("")
	if #st.fails > 0 then
		print("\27[31mfailures:\27[0m")
		for _, f in ipairs(st.fails) do print("  " .. f.w) print("    " .. f.m) end
		print("")
	end
	local total = st.pass + st.fail
	local col = st.fail == 0 and "\27[32m" or "\27[31m"
	print(col .. st.pass .. "/" .. total .. " passed\27[0m")
	if os and os.exit then os.exit(st.fail == 0 and 0 or 1) end
end

function S.install(target)
	target = target or _G
	target.describe = S.describe
	target.it = S.it
	target.expect = S.expect
	target.beforeEach = S.beforeEach
	return S
end

return S
