# RoStub

Run and test your Roblox/executor Lua on your PC. No Roblox, no injecting.

It fakes the stuff your scripts touch — `Instance`, `game`, `workspace`, `typeof`, the datatypes, `task`, signals, and the usual executor globals — so you can run a script in a normal `lua`/`luau` terminal and actually unit test its logic instead of injecting every time you change a line.

## Setup

Grab the files (or clone the repo):

```
rostub.lua      the mock
spec.lua        test runner (optional)
examples/       an example test
```

## Quick start

```lua
local RoStub = require("rostub")
RoStub.install()

local m = Instance.new("Model")
local p = Instance.new("Part", m)
p.Size = Vector3.new(2, 3, 4)

print(#m:GetChildren())     -- 1
print(p:IsA("BasePart"))    -- true
print(typeof(p.Size))       -- Vector3
```

With the runner:

```lua
local RoStub = require("rostub"); RoStub.install()
local spec = require("spec"); spec.install()

describe("map", function()
    it("has a floor", function()
        local map = Instance.new("Model")
        Instance.new("Part", map).Name = "Floor"
        expect(map:FindFirstChild("Floor")).never.toBeNil()
    end)
end)

spec.run()
```

## Running it

RoStub is plain Lua so it loads anywhere. Pick whatever matches your script:

- `lua examples/example.spec.lua` if your code is plain Lua
- `luau examples/example.spec.lua` if it uses Luau syntax (`+=`, `continue`, backtick strings, types)
- `lune run examples/example.spec.lua` if you want a full Luau stdlib

Luau-only syntax won't parse under plain `lua`, so use `luau`/`lune` for real scripts.

## What's covered

Datatypes: Vector3, Vector2, CFrame, Color3, UDim, UDim2, Rect, NumberRange, BrickColor, Enum. Vector3 has real math and `.Magnitude`.

`typeof` returns the right name for all of them and `"Instance"` for instances.

Instances: `Instance.new`, Parent (reparents properly), name access like `workspace.Part`, GetChildren/GetDescendants/FindFirstChild(OfClass/WhichIsA)/WaitForChild, IsA over a real class tree, Clone, Destroy, GetFullName, attributes, tags.

`game:GetService()` gives singletons; workspace/Players/Lighting/ReplicatedStorage/StarterGui/SoundService exist already.

Signals: RemoteEvent, BindableEvent, .Changed, GetPropertyChangedSignal — all return working signals (Connect/Once/Wait/Fire/FireAllClients/FireServer).

Scheduler: task.wait/spawn/delay/defer, wait/spawn/delay, tick/time. Call `RoStub.run()` to drain queued work.

Executor globals: getgenv, getrenv, identifyexecutor, request, hookfunction, checkcaller, getrawmetatable, decompile, gethiddenproperty and more, stubbed so scripts referencing them don't blow up.

## API

```
RoStub.install(target?)       inject globals (default _G) -> env, game
RoStub.new()                  fresh env table, doesn't touch _G
RoStub.run(max?)              drain the scheduler
RoStub.enableGetProperties()  opt-in getproperties() over a mock's props
RoStub.CLASSES                className -> parent, extend it
RoStub.Enum                   add enums here
```

Runner: describe, it, beforeEach, expect(v) with toBe, toEqual (deep), toBeTruthy, toBeFalsy, toBeNil, toBeCloseTo, toThrow, toContain, and .never to flip any of them.

## Extending

It's all plain tables, add what you need:

```lua
RoStub.CLASSES.ProximityPrompt = "Instance"
RoStub.Enum.ProximityPromptStyle = { Default = { Name = "Default", Value = 0, EnumType = "ProximityPromptStyle" } }
```

## Notes

It mocks the API and object model, not the engine — no rendering, physics or real networking. FireServer/FireAllClients just fire the same signal locally so you can test both sides in one process. Defaults are approximate. Built for testing logic; extend the tables when a script needs something that isn't there.

MIT.
