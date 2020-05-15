local brHealthChange = CreatureEvent("BattleRoyaleHealthChange")

function brHealthChange.onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType)
	if attacker and attacker:isPlayer() then
		resetSkull(attacker)
	end
	
	return primaryDamage, primaryType, -secondaryDamage, secondaryType
end

brHealthChange:register()