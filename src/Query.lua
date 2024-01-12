local Query = {
    Methods = {}
}

------------

local QueryMethods = Query.Methods

QueryMethods.other = function(part: Part, overlapParams: OverlapParams): {BasePart}
    return workspace:GetPartsInPart(part, overlapParams)
end

QueryMethods[Enum.PartType.Block] = function(part: Part, overlapParams: OverlapParams): {BasePart}
    return workspace:GetPartBoundsInBox(part.CFrame, part.Size, overlapParams)
end

QueryMethods[Enum.PartType.Ball] = function(part: Part, overlapParams: OverlapParams): {BasePart}
    local diameter = (part.Size.X + part.Size.Z) / 2

    return workspace:GetPartBoundsInRadius(part.Position, diameter / 2, overlapParams)
end

--

function Query.get(part: Part, overlapParams: OverlapParams): {BasePart}
    local shape = part.Shape
    local method = QueryMethods[shape]

    if not method then
        method = QueryMethods.other
    end

    return method(part, overlapParams)
end

------------

return Query