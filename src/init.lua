--[[
	blackferrari2 hitbox system

	last updated: Jan 12, 2024
	needs more documentation. ill work on that eventually :P
]]

local RunService = game:GetService("RunService")

local Factory = require(script.Factory)
local Query = require(script.Query)
local Signal = require(script.Parent.Signal)

local BlackFerrariBox = {
    Factory = Factory,
	HitboxAttribute = "IsHitbox",
	HitboxPriorityAttribute = "HitboxPriority",
}

BlackFerrariBox.__index = BlackFerrariBox

------------

type Label = string | BasePart

type HitboxMeta = {
	part: BasePart,
	label: Label,
	priority: number,
}

type Hits = {
	[BasePart]: BasePart,
}

type self = {
    overlapParams: OverlapParams,
    hitboxes: {[Label]: HitboxMeta},
    hitboxQueue: {BasePart},
    hitscanConnection: RBXScriptConnection?,
	pastQuery: Hits?,
	touched: Signal.Signal<Hits>,
	touchEnded: Signal.Signal<Hits>,
}

export type BlackFerrariBox = typeof(setmetatable({} :: self, BlackFerrariBox))

------------

local ERROR_CANT_FIND_PART = "cant find part %s"
local ERROR_ARG_ISNT_PART = "expected BasePart, got %s"

------------

function BlackFerrariBox.new(overlapParams: OverlapParams?): BlackFerrariBox
    local self = {
        overlapParams = overlapParams,
		hitboxes = {},
		hitboxQueue = {},
		touched = Signal.new(),
		touchEnded = Signal.new(),
    }

    setmetatable(self, BlackFerrariBox)

    return self
end

-- priority: if low, will be hitscanned last. if high, will be hitscanned first.
-- label: name used to identify `part`
function BlackFerrariBox.add(self: BlackFerrariBox, part: BasePart, priority: number?, label: Label?)
	local key = label or part

	local meta = {
		part = part,
		label = key,
		priority = priority or 0,
	}

	self.hitboxes[key] = meta
	part:SetAttribute(BlackFerrariBox.HitboxAttribute, true)
	part:SetAttribute(BlackFerrariBox.HitboxPriorityAttribute, meta.priority)

	table.insert(self.hitboxQueue, part)

	table.sort(self.hitboxQueue, function(part1, part2)
		local priority1 = part1:GetAttribute(BlackFerrariBox.HitboxPriorityAttribute)
		local priority2 = part2:GetAttribute(BlackFerrariBox.HitboxPriorityAttribute)

		return priority1 > priority2
	end)
end

function BlackFerrariBox.remove(self: BlackFerrariBox, label: Label)
	local meta = self.hitboxes[label]

	if not meta then
		error(string.format(ERROR_CANT_FIND_PART, label))
	end

	local index = table.find(self.hitboxQueue, meta.part)

	table.remove(self.hitboxQueue, index)

	meta.part:Destroy()
	self.hitboxes[label] = nil
end

-- customOverlapParams: override for the default overlapParams
-- Hits: {
-- 		[part that was hit] = hitbox that hit it
-- }
function BlackFerrariBox.query(self: BlackFerrariBox, customOverlapParams: OverlapParams?): (Hits, boolean)
	local hits = {}
	local isEmpty = true
	local overlapParams = customOverlapParams or self.overlapParams

	for _, hitbox in ipairs(self.hitboxQueue) do
		local finds = Query.get(hitbox, overlapParams)

		for _, hit in pairs(finds) do
			if hit:GetAttribute(BlackFerrariBox.HitboxAttribute) then
				continue
			end

			if hits[hit] then
				continue
			end

			hits[hit] = hitbox
			isEmpty = false
		end
	end

	return hits, isEmpty
end

function BlackFerrariBox.startHitscan(self: BlackFerrariBox)
	if self.hitscanConnection then
		return
	end

	self.hitscanConnection = RunService.Heartbeat:Connect(function()
		local newHits, isEmpty = self:query()
		local pastHits = self.pastQuery

		if pastHits then
			local touchEndedHits = {}
			local hasTouchEndedHits = false

			for oldHit, hitbox in pairs(pastHits) do
				if not newHits[oldHit] then
					touchEndedHits[oldHit] = hitbox
					hasTouchEndedHits = true
				end
			end

			if hasTouchEndedHits then
				self.touchEnded:Fire(touchEndedHits)
			end
		end

		if isEmpty then
			self.pastQuery = nil
		else
			self.touched:Fire(newHits)
			self.pastQuery = newHits
		end
	end)
end

function BlackFerrariBox.stopHitscan(self: BlackFerrariBox)
	if not self.hitscanConnection then
		return
	end

	self.hitscanConnection:Disconnect()
	self.hitscanConnection = nil
end

function BlackFerrariBox.destroy(self: BlackFerrariBox)
	self:stopHitscan()

	for label in pairs(self.hitboxes) do
		self:remove(label)
	end

	-- FIXME: luau lsp workaround
	local setmetatable : any = setmetatable
	setmetatable(self, nil)
end

--

-- convenience functions
-- use in cooperation with `.query()` or the hit lists returned by the .touch signals

function BlackFerrariBox.isPartInList(part: BasePart, list: Hits)
	if not part:IsA("BasePart") then
		error(string.format(ERROR_ARG_ISNT_PART, part.ClassName))
	end
	
	return list[part] and true or false
end

function BlackFerrariBox.isOnePartInList(parts: {BasePart}, list: Hits)
	for _, part in pairs(parts) do
		if not part:IsA("BasePart") then
			error(string.format(ERROR_ARG_ISNT_PART, part.ClassName))
		end

		if list[part] then
			return true
		end
	end

	return false
end

function BlackFerrariBox.areAllPartsInList(parts: {BasePart}, list: Hits)
	for _, part in pairs(parts) do
		if not part:IsA("BasePart") then
			error(string.format(ERROR_ARG_ISNT_PART, part.ClassName))
		end
		
		if not list[part] then
			return false
		end
	end

	return true
end

------------

return BlackFerrariBox