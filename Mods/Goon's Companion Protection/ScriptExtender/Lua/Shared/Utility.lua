local U = {}

function U.IsGuid(value)
	if type(value) ~= "string" then
		return false
	end
	return value:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

U.NULL_UUID = "00000000-0000-0000-0000-000000000000"

function U.Guid(uuid)
	return uuid:sub(-36)
end

function U.GetEntity(raw)
	return Ext.Entity.Get(raw:sub(-36))
end

function U.GetObject(entity)
	if entity.ServerCharacter then return entity.ServerCharacter end
	if entity.ServerItem then return entity.ServerItem.Item end
end

function U.CreateUuid()
	return string.gsub("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx", "[xy]", function(c)
		return string.format("%x", c == "x" and Ext.Math.Random(0, 0xf) or Ext.Math.Random(8, 0xb))
	end)
end

function U.ResolveDisplayName(handle, fallback)
	local translated = Ext.Loca.GetTranslatedString(handle, fallback)
	return (translated ~= "" and translated ~= handle) and translated or fallback
end

function U.GetDisplayName(uuid, fallback)
	local handle = Osi.GetDisplayName(uuid)
	return U.ResolveDisplayName(handle, fallback or uuid)
end

function U.GetStatusDuration(target, statusId)
	local entity = Ext.Entity.Get(target)
	if not entity or not entity.ServerCharacter then return nil end
	for _, s in pairs(entity.ServerCharacter.StatusManager.Statuses) do
		if s.StatusId == statusId then return math.floor(s.CurrentLifeTime) end
	end
	return nil
end

function U.IsWithinRange(entityA, entityB, rangeM)
	local posA = entityA.Transform.Transform.Translate
	local posB = entityB.Transform.Transform.Translate
	local dx = posA[1] - posB[1]
	local dy = posA[2] - posB[2]
	local dz = posA[3] - posB[3]
	return dx * dx + dy * dy + dz * dz <= rangeM * rangeM
end

function U.Timer(n, callback)
	n = (n or 13) * 1000
	local startTime = Ext.Timer.MonotonicTime()
	local eventId
	eventId = Ext.Events.Tick:Subscribe(function()
		if Ext.Timer.MonotonicTime() - startTime >= n then
			if callback then callback() end
			Ext.Events.Tick:Unsubscribe(eventId)
		end
	end)
	return eventId, function()
		return Ext.Timer.MonotonicTime()
	end
end

U.FUNCTOR_ACTION_ID = 99999

function U.ExecuteFunctor(functorStr, source, target)
	local statName = "NZW_DummyFunctor"
	local stat = Ext.Stats.Get(statName) or Ext.Stats.Create(statName, "SpellData", "Target_Bless")
	stat:SetRawAttribute("SpellProperties", functorStr)
	stat:Sync()
	local ctx                       = Ext.Stats.PrepareFunctorParams("AttackTarget")
	ctx.Caster                      = source
	ctx.Target                      = target
	ctx.Position                    = target.Transform.Transform.Translate
	ctx.SpellId.OriginatorPrototype = statName
	ctx.SpellId.Prototype           = statName
	ctx.StoryActionId               = U.FUNCTOR_ACTION_ID
	for _, prop in ipairs(stat.SpellProperties) do
		for _, functor in ipairs(prop.Functors) do
			ctx.PropertyContext = functor.PropertyContext
			Ext.Stats.ExecuteFunctor(functor, ctx)
		end
	end
end

return U
