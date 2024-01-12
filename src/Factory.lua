local Factory = {
    GlobalDump = Instance.new("Folder", workspace),
    KindAttribute = "FactoryKind",
}

Factory.Kinds = {
    Red = {
        Name = "Red",
        Dump = Instance.new("Folder", Factory.GlobalDump),
        Color = Color3.new(1, 0, 0),
        Transparency = 0.5,
    },

    Blue = {
        Name = "Blue",
        Dump = Instance.new("Folder", Factory.GlobalDump),
        Color = Color3.new(0, 0, 1),
        Transparency = 0.25,
    },
}

------------

export type Kind = {
    Name: string,
    Color: Color3,
    Transparency: number,
    Dump: Folder,
}

------------

function Factory.new(cframe: CFrame, size: Vector3, kind: Kind?, shape: Enum.PartType?): BasePart
    shape = shape or Enum.PartType.Block

    local part = Instance.new("Part")

    part.Size = size
    part.Shape = shape
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = Factory.GlobalDump

    if kind then
        part:SetAttribute(Factory.KindAttribute, kind.Name)
        part.Color = kind.Color
        part.Transparency = kind.Transparency
        part.Parent = kind.Dump
    end

    return part
end

function Factory.setTransparencyOf(kind: Kind, to: number)
    for _, part in pairs(kind.Dump:GetChildren()) do
        part.Transparency = to
    end
end

function Factory.setColorOf(kind: Kind, to: Color3)
    for _, part in pairs(kind.Dump:GetChildren()) do
        part.Color = to
    end
end

function Factory.setGlobalTransparency(to: number)
    for _, kind in pairs(Factory.Kinds) do
        Factory.setTransparencyOf(kind, to)
    end
end

function Factory.setGlobalColor(to: Color3)
    for _, kind in pairs(Factory.Kinds) do
        Factory.setColorOf(kind, to)
    end
end

------------

-- NAME THE DUMPS!
Factory.GlobalDump.Name = "blackferraribox.dump"

for _, attributes in pairs(Factory.Kinds) do
    attributes.Dump.Name = attributes.Name
end

------------

return Factory