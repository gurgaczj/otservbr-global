local brPlayerOnLogout = CreatureEvent("BattleRoyaleLogout")

function brPlayerOnLogout.onLogout(player)
	if brGame.canRegister and not brGame.isBattle then
		brGame:removePlayer(player:getName())
	end

	if brGame.isBattle then
		if brPlayersStats[player:getName()] ~= nil then
			player:sendCancelMessage("You can not logout from battle royale.")
			return false
		end
	end
	return true
end

brPlayerOnLogout:register()
