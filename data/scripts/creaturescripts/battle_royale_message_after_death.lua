local brMessage = CreatureEvent("BattleRoyaleMessageAfterDeath")

function brMessage.onLogin(player)
	local resultId = db.storeQuery("SELECT `id`, `message`, `message_type` FROM `battle_royale_reward_msg` WHERE `player_id` = " .. db.escapeString(player:getGuid()) .. " AND `unreaded` = 1")

	if resultId ~= false then
		repeat
			local message = result.getString(resultId, "message")
			local messageType = result.getNumber(resultId, "message_type")
		
			player:sendTextMessage(messageType, message)
			
			local messageId = result.getNumber(resultId, "id")
			
			db.asyncQuery("DELETE FROM `battle_royale_reward_msg` WHERE `id` = " .. db.escapeString(messageId))
		until not result.next(resultId)
		result.free(resultId) -- Free memory
	end

	return true
end

brMessage:register()