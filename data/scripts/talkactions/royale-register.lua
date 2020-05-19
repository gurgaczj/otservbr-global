local royaleJoin = TalkAction("!royale")

function royaleJoin.onSay(player, words, param)
	if player:getGroup():getAccess() or player:getAccountType() >= ACCOUNT_TYPE_TUTOR then
		player:sendCancelMessage("Tutors and Gamemasters can not join battle royale")
		return true
	end

	if brGame.isBattle then
		player:sendCancelMessage("There is ongoing Battle Royale game. You should try tomorrow.")
		return false
	end

	brGame:addPlayer(player)
	return false
end

royaleJoin:separator(",")
royaleJoin:register()

local royaleUnregister = TalkAction("!royale unregister")

function royaleUnregister.onSay(player, words, param)
	if not brGame.canRegister and not brGame.isBattle then
		player:sendCancelMessage("Signing up for battle royale is not open yet so you can not unregister.")
		return false
	end

	local alreadyRegistered = brGame:alreadyRegistered(player)
	
	if br.canRegister and not brGame.isBattle and alreadyRegistered then
		brGame:removePlayer(player)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You just unregistered from battle royale.")
		return false
	end
	
	if not alreadyRegistered and br.canRegister and not brGame.isBattle then
		player:sendCancelMessage("You have not registered yet.")
		return false
	end
	
	if brGame.isBattle and alreadyRegistered then
		player:sendCancelMessage("You cannot unregister from ongoing battle.")
		return false
	end	
	
	return true
end

royaleUnregister:separator(" ")
royaleUnregister:register()

if brGame.canRegister and not brGame.isBattle then
		brGame:removePlayer(player)
	end

local startBR = TalkAction("!reg")
function startBR.onSay(player, words, param)
	if not player:getGroup():getAccess() or player:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end

	brGame:startRegister()
	return false
end

startBR:separator(" ")
startBR:register()

local beginBR = TalkAction("!start")
function beginBR.onSay(player, words, param)
	if not player:getGroup():getAccess() or player:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end

	brGame:begin()
	return false
end

beginBR:separator(" ")
beginBR:register()

local resetBR = TalkAction("!clean")
function resetBR.onSay(player, words, param)
	if not player:getGroup():getAccess() or player:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end
	cleanBattleRoyaleMap()
	brGame:reset()
	return false
end

resetBR:separator(" ")
resetBR:register()
