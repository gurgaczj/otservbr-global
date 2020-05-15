local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
combat:setParameter(COMBAT_PARAM_CREATEITEM, ITEM_POISONFIELD_PVP)

function onCastSpell(creature, variant, isHotkey)
	Game.createItem(1496, 1, variant:getPosition())
	return combat:execute(creature, variant)
end
