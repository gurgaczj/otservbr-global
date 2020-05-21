BattleRoyale = {players = {}, canRegister = false, isBattle = false, goldPool = 0}

function BattleRoyale:new (o, players, canReg, battle, pool)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   table = table or {}
   self.players = players;
   self.canRegister = canReg;
   self.isBattle = battle;
   self.goldPool = pool;
   return o
end

brGame = BattleRoyale:new(nil, {}, false, false, 1000000)
brPlayersStats = {} -- players stats, global becouse used in onDeath event, I know, should have use getter
local totalPlayerCount = 0 -- need to calculate gold reward for each player

-- everything starts here
function BattleRoyale:begin()
	totalPlayerCount = #self.players
	if totalPlayerCount <= 1 then
		broadcastMessage("Not enough players for BattleRoyale. Need at least 2. No match today :/", MESSAGE_STATUS_CONSOLE_BLUE)
		self:reset()
		return
	end
	
	print(totalPlayerCount .. " players registered for Battle Royale.")

	self.isBattle = true
	spawnChests()

	-- for each registered player
	for playerNum = 1, totalPlayerCount do
		local actualPlayer = self.players[playerNum]
		actualPlayer:save()
		local playerID = actualPlayer:getName()
		brPlayersStats[playerID] = getPlayerStatsInfo(actualPlayer)
		removeAllConditions(actualPlayer)
		local playerParty = actualPlayer:getParty()
		if playerParty ~= nil then
			playerParty:removeMember(actualPlayer)
		end
		actualPlayer:setSkullTime(0)
		actualPlayer:setVocation(4)
		setHPAndMana(actualPlayer)
		actualPlayer:setSkillLoss(false)
		actualPlayer:resetSkills() -- remove player skills
		actualPlayer:setSkillValues(1, 70, 0, 0)
		actualPlayer:setSkillValues(2, 70, 0, 0)
		actualPlayer:setSkillValues(3, 70, 0, 0)
		actualPlayer:setBaseMagicLevel(3)
		actualPlayer:setManaSpent(1)
		teleportPlayerToRoyale(actualPlayer)
		actualPlayer:setBattleRoyalePlayer(true);
		moveItemsToDepot(actualPlayer)
		actualPlayer:addItem(1987, 1, false, 1, CONST_SLOT_WHEREEVER)
		registerEvent(actualPlayer, "BattleRoyaleDeath")
		registerEvent(actualPlayer, "BattleRoyaleHealthChange")
		actualPlayer:sendTextMessage(MESSAGE_STATUS_WARNING, "Beware of fire. Island will start burning in 2 minutes!")
	end

	addEvent(spawnFire, FIRE_SPAWN_TIME, 0, 1494)
end

-- after player death
function BattleRoyale:playerDied(deadPlayer)
	self:returnPlayerStats(deadPlayer)
	local actualPlayersCount = #self.players
	self:removePlayer(deadPlayer)
	deadPlayer:addItem(1988, 1, INDEX_WHEREEVER, 0)
	if actualPlayersCount ~= 1 then
		rewardPlayer(deadPlayer, totalPlayerCount, actualPlayersCount, self.goldPool)
	end
	return true
end

-- return stats for player
function BattleRoyale:returnPlayerStats(player)
	unregisterEvent(player, "BattleRoyaleDeath")
	unregisterEvent(player, "BattleRoyaleHealthChange")
	removeAllConditions(player)
	local playerID = player:getName()
	setPlayerStatsBack(player, brPlayersStats[playerID])
	print(player:getName() .. " stats returned")
	--brPlayersStats[playerID] = nil
	giveBlessing(player)
	player:setBattleRoyalePlayer(false);
	player:save()
end

-- reward winner
function BattleRoyale:rewardWinner()
	local player = self.players[1]
	if player ~= nil then
		print(player:getName() .. " won battle royale ")
		moveItemsToPosition(player)
		broadcastMessage("Player " .. player:getName() .. " won battle royale! Congratulations!", MESSAGE_STATUS_CONSOLE_BLUE)
		self:returnPlayerStats(player)
		local message = "You have earned " .. tostring(self.goldPool) .. " gold. Check your bank balance\n"
		local bankBalance = player:getBankBalance()
		bankBalance = bankBalance + self.goldPool
		player:setBankBalance(bankBalance)
		local playerId = player:getGuid()
		addPremiumPointsForPlayer(playerId, 150)
		message = message .. "Outstanding, you have earned yourself 150 tibia coins and 24 hours of 50% bonus experience.\n" .. thanks
		player:sendTextMessage(MESSAGE_INFO_DESCR, message)
		teleportToTemple(player)
		player:setSkillLoss(true)
		giveBonusExp(player, 24)
		player:addItem(1988, 1, false, 1, CONST_SLOT_WHEREEVER)
		player:save()
		db.asyncQuery("UPDATE `battle_royale_scores` SET `wins` = `wins` + 1 WHERE `player_id` = " .. db.escapeString(playerId))
		self:reset()
	end
end

-- reset br state
function BattleRoyale:reset()
	-- cleanBattleRoyaleMap()
	self.isBattle = false
	brPlayersStats = {}
	brGame = nil
	totalPlayerCount = 0
	brGame = BattleRoyale:new(nil, {}, false, false, 1000000)
end

-- adds player
function BattleRoyale:addPlayer(player)
	if self.canRegister then
		if self:alreadyRegistered(player) then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You are already signend for battle royale")
			return
		end
		table.insert(self.players, player)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You just signed up for battle royale. \n Remember that you can unregister from battle royale with !royale unregister until battle has not started.")
	else
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Signing up for battle royale is not open yet.")
	end
end

-- remove player
function BattleRoyale:removePlayer(player)
	local removedPlayerName = player:getName()
	for i = 1, #self.players do
		if self.players[i]:getName() == removedPlayerName then
			table.remove(self.players, i)
			return true
		end		
	end
	return false
end

-- checks if player is already registered
function BattleRoyale:alreadyRegistered(player)
	local playerName = player:getName()
	for _, p in ipairs(self.players) do
		if p:getName() == playerName then
			return true
		end
	end
	return false
end

-- allows register
function BattleRoyale:startRegister()
	self.canRegister = true
	broadcastMessage("Signing up for Battle Royale just started! \nSign up with !royale command", MESSAGE_STATUS_CONSOLE_BLUE)
end

-- closes register
function BattleRoyale:closeRegister()
	self.canRegister = false
end