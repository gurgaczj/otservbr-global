local BRPlayerDeath = CreatureEvent("BattleRoyaleDeath")

function BRPlayerDeath.onDeath(player, corpse, lasthitkiller, mostdamagekiller, lasthitunjustified, mostdamageunjustified)
	local targetID = player:getGuid()
	lasthitkiller:removeUnjustifiedKill(targetID)
	if lasthitkiller:isPlayer() then
		db.asyncQuery("UPDATE `player_deaths` SET `unjustified` = 0 and `mostdamage_unjustified` = 0 WHERE `player_id` = " .. db.escapeString(targetID) .. " AND `mostdamage_by` LIKE " .. db.escapeString(lasthitkiller:getName()))
	end
	for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local item = player:getSlotItem(i)
        if item ~= nil then
			item:moveTo(corpse)
        end
	end
	-- TODO: add bag
	brGame:playerDied(player)
	teleportToTemple(player)
	player:remove()
	return true
end

BRPlayerDeath:register()