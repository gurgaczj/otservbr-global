-- BR CONFIG

--for tests
local royaleMapXSize = {171, 203}
local royaleMapYSize = {186, 217}

-- local royaleMapXSize = {121, 267}
-- local royaleMapYSize = {108, 289}
local royaleMapOrigin = {197, 202}
local royaleMapRadius = 98
royaleMinusRadiusOnFire = 0
local royaleQuadrandChestsCount = 30
local maxItemsInChest = 3
local BRMaxHP = 300
local BRMaxMana = 30

local TOP_LEVEL_STRUCTURE = 6
local LOWEST_LEVEL_STRUCTURE = 8

local COMMON_ITEMS = {8704, 2643, 2649, 2461, 9814, 2401, 2380, 2384}
local LESS_COMMON_ITEMS = {26387, 26386, 2398, 7457, 2412, 10301, 7618}
local RARE_ITEMS = {26383, 2417, 3963, 2378}

local TIME_TO_SPAWN_BIG_FIRE = 5742
local TIME_TO_SPAWN_SMALL_FIRE = 2461

-- for tests
local ROYALE_MAP_ZONES = {
	{171, 203, 186, 217}
}

thanks = "Thank you for participating in Battle Royale"


-- local ROYALE_MAP_ZONES = {
	-- {121, 192, 202, 289},
	-- {193, 267, 198, 285},
	-- {190, 264, 108, 197},
	-- {122, 189, 115, 201}
-- }

local CONSTANT_CHEST_SPAWN = {
	{210, 124, 8},
	{156, 169, 8},
	{151, 152, 8},
	{226, 134, 6},
	{246, 182, 6},
	{226, 262, 8},
	{163, 263, 6},
	{131, 251, 7}
}

-- DON'T CHANGE, UNLESS YOU KNOW WHAT YOU ARE DOING
local SKILL_PERCENTAGE = 1
local SKILL_LEVEL = 2
local SKILL_TRIES = 3
local LEVEL = 4
local MAX_HP = 5
local MAX_MP = 6
local REMOVED_EXP = 7
local SKULL_TIME = 8
local SKULL = 9
local VOCATION = 10
-- local SKILL_PERCENTAGE = "skill_percent"
-- local SKILL_LEVEL = "skill_level"
-- local SKILL_TRIES = "skill_tries"
-- local LEVEL = "level"
-- local MAX_HP = "max_hp"
-- local MAX_MP = "max_mp"
-- local REMOVED_EXP = "removed_exp"
-- local SKULL_TIME = "skull_time"
-- local SKULL = "skull"
-- local VOCATION = "vocation"

function teleportPlayerToRoyale(player)
	local x = math.random(royaleMapXSize[1], royaleMapXSize[2])
	local y = math.random(royaleMapYSize[1], royaleMapYSize[2])
	local pos = Position(x, y, 7)
	local tile = Tile(pos)
	if tile == nil then
		teleportPlayerToRoyale(player)
		return
	end
	if tile:isWalkable() then
		player:teleportTo(pos)
		return true
	else
		teleportPlayerToRoyale(player)
	end
end

function moveItemsToDepot(player)
	local depot = player:getDepotChest(1, true)--:getItem(0)
	for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local item = player:getSlotItem(i)
		if item ~= nil then
			item:moveTo(depot)
		end
	end
end

function moveItemsToPosition(player)
	local pos = player:getPosition()
	for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local item = player:getSlotItem(i)
		if item ~= nil then
			item:moveTo(pos)
		end
	end
end

function getPlayerStatsInfo(player)
	local skullTimeVal = player:getSkullTime()
	local levelVal = player:getLevel()
	local maxHealthVal = player:getMaxHealth()	
	local maxManaVal = player:getMaxMana()	
	local removedExpVal = player:getExperience() - 4300
	if removedExpVal < 0 then
		removedExpVal = removedExpVal * (-1)
		player:addExperience(removedExpVal + 100)
	else
		player:removeExperience(removedExpVal)
	end
	
	local statsTable = {
		removedExp = removedExpVal,
		skullTime = player:getSkullTime(),
		level = player:getLevel(),
		maxHealth = maxHealthVal,
		maxMana = maxManaVal,
		vocation = player:getVocation(),
		skull = player:getSkull()
	}
	statsTable.Skills = {}
	for i = SKILL_FIST, SKILL_FISHING do
		statsTable.Skills[i] = {
			level = player:getSkillLevel(i),
			percent = player:getSkillPercent(i),
			tries = player:getSkillTries(i)
		}
	end
	return statsTable
end

function setPlayerStatsBack(player, statsTable)
	player:setVocation(statsTable.vocation)
	if statsTable.removedExp > 0 then
		player:addExperience(statsTable.removedExp)
	end
	player:setMaxMana(statsTable.maxMana)
	player:setMaxHealth(statsTable.maxHealth)
	player:setMana(statsTable.maxMana)
	player:setHealth(statsTable.maxHealth)
	player:setSkullTime(statsTable.skullTime)
	player:setSkull(statsTable.skull)
	for i = SKILL_FIST, SKILL_FISHING do
		player:setSkillValues(i, statsTable.Skills[i].level, statsTable.Skills[i].percent, statsTable.Skills[i].tries)
	end
end

function removeAllConditions(player)
	for condition = CONDITION_POISON, CONDITION_SPELLGROUPCOOLDOWN do
		if player:hasCondition(condition) then
			player:removeCondition(condition)
		end
	end
end

function removeBlessing(player)
	for i = 1, 6 do
		player:removeBlessing(i)
	end
end

function giveBlessing(player)
	for i = 1, 6 do
		player:addBlessing(i)
	end
end

function setHPAndMana(player)
	player:setMaxHealth(BRMaxHP)
	player:setHealth(BRMaxHP)
	player:setMaxMana(BRMaxMana)
	player:setMana(BRMaxMana)
end

function rewardPlayer(player, totalPlayerCount, place, goldPool)
	local message = "You have taken " .. tostring(place) .. " place.\n"
	local prize = calculateGoldPrize(totalPlayerCount, place - 1, goldPool)
	local bankBalance = player:getBankBalance()
	bankBalance = bankBalance + prize
	player:setBankBalance(bankBalance)
	local playerId = player:getGuid()
	message = message .. "You have earned " .. tostring(prize) .. " gold. Check your bank balance.\n"
	if place == 3 then
		local points = 50
		addPremiumPointsForPlayer(playerId, points)
		message = message .. "Nice, you have earned yourself " .. points .. " tibia coins.\n"
	elseif place == 2 then
		local points = 100
		addPremiumPointsForPlayer(playerId, points)
		message = message .. "Nice, you have earned yourself " .. points .. " tibia coins.\n"
		brGame:rewardWinner()
	end
	message = message .. thanks
	insertMessage(playerId, message, MESSAGE_INFO_DESCR)
end

function addPremiumPointsForPlayer(playerGUID, points)
	db.asyncQuery("UPDATE accounts a LEFT JOIN players p on a.id = p.account_id SET coins = coins + " .. db.escapeString(points) .." where p.id= " .. db.escapeString(playerGUID))
end

function calculateGoldPrize(totalPlayerCount, actualPlayersCount, goldPool)
	local percent = (actualPlayersCount * 100)/totalPlayerCount
	percent = (100 - percent)/100
	local prize = math.floor((percent*goldPool))
	return prize
end

function registerEvent(player, eventName)
	if player:registerEvent(eventName) then
		print("Event " .. eventName .. " registered successfully for player " .. player:getName())
	end
end

function unregisterEvent(player, eventName)
	if player:unregisterEvent(eventName) then
		print("Event " .. eventName .. " unregistered successfully for player " .. player:getName())
	end
end


function spawnFire(minusRadius, fireID)
	if not brGame.isBattle then
		return false
	end
	--royaleMinusRadiusOnFire = (fireID == 1493)
	local radius = royaleMapRadius - minusRadius
	for z = TOP_LEVEL_STRUCTURE, LOWEST_LEVEL_STRUCTURE do
		for a = 1, 1440 do
			local angle = (a / 4) * (math.pi / 180)
			local x = math.floor(royaleMapOrigin[1] + radius * math.cos(angle))
			local y = math.floor(royaleMapOrigin[2] + radius * math.sin(angle))
			if fireID == 1493 then
				local tile = Tile(x, y, z)
				if tile ~= nil then
					local item = tile:getItemById(1494)
					if item ~= nil then 
						item:remove(-1)
					end
				end
			end
			--if royaleMapXSize[1] <= x and x <= royaleMapXSize[2] and royaleMapYSize[1] <= y and y <= royaleMapYSize[2] then
			Game.createItem(fireID, 1, Position(x, y, z))
			--end
		end
	end
	if minusRadius ~= royaleMapRadius then
		if fireID == 1494 then
			addEvent(spawnFire, TIME_TO_SPAWN_BIG_FIRE, minusRadius, 1493)
		else
			addEvent(spawnFire, TIME_TO_SPAWN_SMALL_FIRE, minusRadius + 1, 1494)
		end
	end
	return true
end

function spawnChests()
	spawnConstantChests()
	for i = 1, #ROYALE_MAP_ZONES do
		local count = 0
		repeat
			local x = math.random(ROYALE_MAP_ZONES[i][1], ROYALE_MAP_ZONES[i][2])
			local y = math.random(ROYALE_MAP_ZONES[i][3], ROYALE_MAP_ZONES[i][4])
			local tile = Tile(x, y, 7)
				if tile ~= nil then
					if tile:isWalkable() then
						local isNotChestAlreadyOnTile = tile:getItemById(27531) == nil
						if isNotChestAlreadyOnTile then
							createChest(x, y, 7)
							count = count + 1
						end
					end
				end
		until count == royaleQuadrandChestsCount
	end
	count = 0
end

function spawnConstantChests()
	for i = 1, #CONSTANT_CHEST_SPAWN do
		createChest(CONSTANT_CHEST_SPAWN[i][1], CONSTANT_CHEST_SPAWN[i][2], CONSTANT_CHEST_SPAWN[i][3])
	end
end

function createChest(x, y, z)

	local chest = Game.createItem(27531, 1, Position(x, y, z))
	local itemsInChest = math.random(maxItemsInChest)
	for i = 1, 5 do -- todo: local constant
		chest = addRandomItemToChest(chest)
	end
end

function addRandomItemToChest(chest)
	local item = getItem()
	if chest:getItemCountById(item) ~= 0 then
		chest = addRandomItemToChest(chest)
	else
		chest:addItem(item, 1, INDEX_WHEREEVER, 0)
	end
	return chest
end

function getItem()
	local itemClass = math.random(10)
	if 0 <= itemClass and itemClass <= 5 then -- common items
		return COMMON_ITEMS[math.random(#COMMON_ITEMS)]
	elseif 6 <= itemClass and itemClass <= 9 then -- less common items
		return LESS_COMMON_ITEMS[math.random(#LESS_COMMON_ITEMS)]
	else -- rare items
		return RARE_ITEMS[math.random(#RARE_ITEMS)]
	end
end

function cleanBattleRoyaleMap()
	for z = TOP_LEVEL_STRUCTURE, LOWEST_LEVEL_STRUCTURE do
		for r = 1, royaleMapRadius do
			for a = 1, 1440 do
				local angle = (a / 4) * (math.pi / 180)
				local x = math.floor(royaleMapOrigin[1] + r * math.cos(angle))
				local y = math.floor(royaleMapOrigin[2] + r * math.sin(angle))
				local tile = Tile(Position(x, y, z))
				-- TODO: iterate over tile:getItems()
				if tile ~= nil then
					local item = tile:getItemById(1493, -1)
					local items = tile:getItems()
					if item ~= nil then
						item:remove(-1)
					end
					item = tile:getItemById(27531, -1)
					if item ~= nil then
						item:remove(-1)
					end
					item = tile:getItemById(1496, -1)
					if item ~= nil then
						item:remove(-1)
					end
					item = tile:getItemById(1494, -1)
					if item ~= nil then
						item:remove(-1)
					end
					local creatures = tile:getCreatures()
					if creatures then
						for c = 1, #creatures do
							if creatures[c]:isMonster() then
								creatures[c]:remove()
							end
						end
					end
				end
			end
		end
	end
end

function giveBonusExp(player, hours)
	local plusTime = hours * 60 * 60
	db.asyncQuery("UPDATE players SET bonusexp = " .. db.escapeString(os.time() + plusTime) .. " WHERE id = " .. db.escapeString(player:getGuid()))
end

function teleportToTemple(player)
	local templePosition = player:getTown():getTemplePosition()
	player:teleportTo(templePosition, false)
end

function resetSkull(player)
	player:setSkull(SKULL_NONE)
	player:setSkullTime(0)
end

function insertMessage(playerID, message, messageType)
	db.asyncQuery("INSERT INTO `battle_royale_reward_msg` (`player_id`, `message`, `message_type`) VALUES (" .. db.escapeString(playerID) .. ", " .. db.escapeString(message) .. ", " .. db.escapeString(messageType) ..")")
end