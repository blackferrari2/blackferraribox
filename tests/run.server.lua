local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

-------------

local tests = script.Parent:GetChildren()

-------------

TestEZ.TestBootstrap:run(tests)