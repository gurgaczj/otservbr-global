local BRPlayerDeath = CreatureEvent("BattleRoyaleDeath")

function BRPlayerDeath.onDeath(player, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	if lasthitkiller and lasthitkiller:isPlayer() then
		local targetID = player:getGuid()
		lasthitkiller:removeUnjustifiedKill(targetID)
		db.asyncQuery("UPDATE `player_deaths` SET `unjustified` = 0 and `mostdamage_unjustified` = 0 WHERE `player_id` = " .. db.escapeString(targetID) .. " AND `mostdamage_by` LIKE " .. db.escapeString(lasthitkiller:getName()))
	end
	for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local item = player:getSlotItem(i)
        if item ~= nil then
			item:moveTo(corpse)
        end
	end

	brGame:playerDied(player)
	teleportToTemple(player)
	player:remove()
	return true
end

BRPlayerDeath:register()