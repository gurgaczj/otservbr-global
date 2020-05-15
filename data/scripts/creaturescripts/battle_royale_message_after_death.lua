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
			
			
			-- local offerType = result.getString(resultId, "offer_type")
			-- if offerType then
			-- local offerHistoryID = result.getNumber(resultId, "id")
			-- local isRealized = false
				-- if offerType == "item" then
					-- local itemID = result.getNumber(resultId, "itemid1")
					-- local count = result.getNumber(resultId, "count1")
					-- player:addItem(itemID, count, true, 1, CONST_SLOT_WHEREEVER)
					-- setOrderRealized(offerHistoryID)
				-- elseif offerType == "addon" then
					-- local outfitID = 0
					-- local addon = 0
					-- if player:getSex() == PLAYERSEX_FEMALE then
						-- outfitID = result.getNumber(resultId, "itemid1")
						-- addon = result.getNumber(resultId, "count1")
					-- else
						-- outfitID = result.getNumber(resultId, "itemid2")
						-- addon = result.getNumber(resultId, "count2")
					-- end
					-- if not player:hasOutfit(outfitID, 0) then
						-- player:addOutfit(outfitID)
					-- end
					-- if not player:hasOutfit(outfitID, addon) then
						-- player:addOutfitAddon(outfitID, addon)
					-- end
					-- setOrderRealized(offerHistoryID)
				-- elseif offerType == "mount" then
				-- local mountID = result.getNumber(resultId, "itemid1")
					-- if not player:hasMount(mountID) then
						-- player:addMount(mountID)
						-- setOrderRealized(offerHistoryID)
					-- end
				-- else
					-- player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Could not add order from item shop. Contact Admin and let him know about this.")
					-- print("Unknown offer type " .. offerType)
				-- end
			-- end
		until not result.next(resultId)
		result.free(resultId) -- Free memory
	end

	return true
end

brMessage:register()