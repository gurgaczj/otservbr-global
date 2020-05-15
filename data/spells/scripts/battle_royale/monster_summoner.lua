local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYHIT)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGYBALL)
combat:setArea(createCombatArea(AREA_SQUARE1X1))

local COMMON_MONSTERS = {
	"rat",
	"bug",
	"troll"
}

local LESS_COMMON_MONSTERS = {
	"minotaur",
	"orc"
}

local RARE_MONSTERS = {
	"fire elemental br"
}

function onCastSpell(creature, variant, isHotkey)
	local monsterType = math.random(1, 10)
	if monsterType <= 6 then -- 60% for COMMON MONSTER
		local monster = math.random(1, #COMMON_MONSTERS)
		Game.createMonster(COMMON_MONSTERS[monster], variant:getPosition(), false, true)
	elseif monsterType > 6 and monsterType <= 9 then -- 30% for LESS COMMON MONSTER
		local monster = math.random(1, #LESS_COMMON_MONSTERS)
		Game.createMonster(LESS_COMMON_MONSTERS[monster], variant:getPosition(), false, true)
	else -- 10% for RARE MONSTER
		local monster = math.random(1, #RARE_MONSTERS)
		Game.createMonster(RARE_MONSTERS[monster], variant:getPosition(), false, true)
	end
	return combat:execute(creature, variant)
end
