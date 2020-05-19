-- credits: https://github.com/gurgaczj
-- contact: https://otland.net/members/zuber966.239759/

-- BR CONFIG
local royaleMapXSize = {121, 267} -- min, max X map size
local royaleMapYSize = {108, 289} -- min, max Y map size
local royaleMapOrigin = {197, 202} -- map origin point
local royaleMapRadius = 100 -- map radius
local royaleZoneChestsCount = 30 -- number of chests in one zone -> explained later
local itemsInChest = 4 -- number of items in chest, make sure it is not greater than number of weapons of all rarity types
local BR_MAX_HP = 500 -- hp value at the start
local BR_MAX_MP = 300 -- mp value at the start

local TOP_LEVEL_STRUCTURE = 6 -- top Z level walkable val
local LOWEST_LEVEL_STRUCTURE = 8 -- lowest Z level walkable val

local COMMON_ITEMS = {8704, 7618, 2417, 2428, 20092, 2666, 2674, 2643, 2511} -- common items ids
local LESS_COMMON_ITEMS = {38615, 38614, 7457, 7618, 2789, 2435, 7387, 2463, 2647, 2541, 7620, 7588, 38616} -- less common ids
local RARE_ITEMS = {38613, 2451, 38617, 2521, 2476, 2477} -- rare ids

-- these three copies weapon ids from upper item
-- main purpose is to make sure that chest contains weapon
local COMMON_WEAPONS = {2417, 20092, 2428}
local LESS_COMMON_WEAPONS = {7387, 2435}
local RARE_WEAPONS = {2451}

-- Explanation. Fire spawn in circles. First small fire field and some time after small is replaced by big one
local TIME_TO_SPAWN_BIG_FIRE = 4500 -- amount of time (ms) to spawn big fire after small
local TIME_TO_SPAWN_SMALL_FIRE = 1900 -- amount of time to spawn small fire after big one

local REMOVED_EXP = 7915800 -- exp amount which you want player to have on the beggining of br

-- map divieded into square zones for better chest spawn distribution
-- min X, max X, min Y, max Y
local ROYALE_MAP_ZONES = {
	{121, 192, 202, 289},
	{193, 267, 198, 285},
	{190, 264, 108, 197},
	{122, 189, 115, 201}
}

-- chests that spawn always
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

FIRE_SPAWN_TIME = 120000 -- amount of time it takes to start spawn fire after event starts

thanks = "Thank you for participating in Battle Royale!"

-- for tests
-- local ROYALE_MAP_ZONES = {
	-- {171, 203, 186, 217}
-- }

-- local royaleMapXSize = {171, 203}
-- local royaleMapYSize = {186, 217}

---
--- functions
---

-- teleports player to random pos inside battle royale map
-- only z=7
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

-- moves all player items to depot
function moveItemsToDepot(player)
	local depot = player:getDepotChest(1, true)--:getItem(0)
	for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local item = player:getSlotItem(i)
		if item ~= nil then
			item:moveTo(depot)
		end
	end
end

-- moves all player items to his position
-- main purpose is to remove winner items
function moveItemsToPosition(player)
	local pos = player:getPosition()
	for i = CONST_SLOT_HEAD, CONST_SLOT_AMMO do
		local item = player:getSlotItem(i)
		if item ~= nil then
			item:moveTo(pos)
		end
	end
end

-- stores player stats
function getPlayerStatsInfo(player)
	local skullTimeVal = player:getSkullTime()
	local levelVal = player:getLevel()
	local maxHealthVal = player:getMaxHealth()	
	local maxManaVal = player:getMaxMana()	
	local removedExpVal = player:getExperience() - REMOVED_EXP
	if removedExpVal < 0 then
		removedExpVal = removedExpVal
		player:addExperience(removedExpVal * (-1) + 100)
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
		skull = player:getSkull(),
		magicLevel = player:getBaseMagicLevel(),
		manaSpent = player:getManaSpent()
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

-- sets player stats back
function setPlayerStatsBack(player, statsTable)
	player:setVocation(statsTable.vocation)
	if statsTable.removedExp > 0 then
		player:addExperience(statsTable.removedExp)
	else
		player:removeExperience(statsTable.removedExp * (-1))
	end
	player:setMaxMana(statsTable.maxMana)
	player:setMaxHealth(statsTable.maxHealth)
	player:setMana(statsTable.maxMana)
	player:setHealth(statsTable.maxHealth)
	player:setSkullTime(statsTable.skullTime)
	player:setSkull(statsTable.skull)
	player:setBaseMagicLevel(statsTable.magicLevel)
	player:setManaSpent(statsTable.manaSpent)
	for i = SKILL_FIST, SKILL_FISHING do
		player:setSkillValues(i, statsTable.Skills[i].level, statsTable.Skills[i].percent, statsTable.Skills[i].tries)
	end
end

-- removes player conditions
function removeAllConditions(player)
	for condition = CONDITION_POISON, CONDITION_SPELLGROUPCOOLDOWN do
		if player:hasCondition(condition) then
			player:removeCondition(condition)
		end
	end
end

-- remove all blessings
function removeBlessing(player)
	for i = 1, 8 do
		player:removeBlessing(i)
	end
end

-- gives all blessings to player
function giveBlessing(player)
	for i = 1, 8 do
		player:addBlessing(i)
	end
end

-- sets hp and mana for player for br game
function setHPAndMana(player)
	player:setMaxHealth(BR_MAX_HP)
	player:setHealth(BR_MAX_HP)
	player:setMaxMana(BR_MAX_MP)
	player:setMana(BR_MAX_MP)
end

-- gives reward for player
-- todo: make it reward winner
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

-- adds coins for player
function addPremiumPointsForPlayer(playerGUID, points)
	db.asyncQuery("UPDATE accounts a LEFT JOIN players p on a.id = p.account_id SET coins = coins + " .. db.escapeString(points) .." where p.id= " .. db.escapeString(playerGUID))
end

-- computes gold prize for player at taken place
function calculateGoldPrize(totalPlayerCount, actualPlayersCount, goldPool)
	local percent = (actualPlayersCount * 100)/totalPlayerCount
	percent = (100 - percent)/100
	local prize = math.floor((percent*goldPool))
	return prize
end

-- register event for player
function registerEvent(player, eventName)
	if player:registerEvent(eventName) then
		print("Event " .. eventName .. " registered successfully for player " .. player:getName())
	end
end

-- removes player event
function unregisterEvent(player, eventName)
	if player:unregisterEvent(eventName) then
		print("Event " .. eventName .. " unregistered successfully for player " .. player:getName())
	end
end

-- spawns fire on battle royale map, circle by circle
function spawnFire(minusRadius, fireID)
	if not brGame.isBattle then
		return false
	end
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
			Game.createItem(fireID, 1, Position(x, y, z))
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

-- picks place for chest spawning
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
		until count == royaleZoneChestsCount
	end
	count = 0
end

-- spawn constant chests
function spawnConstantChests()
	for i = 1, #CONSTANT_CHEST_SPAWN do
		createChest(CONSTANT_CHEST_SPAWN[i][1], CONSTANT_CHEST_SPAWN[i][2], CONSTANT_CHEST_SPAWN[i][3])
	end
end

-- creates chest at x, y, z pos
function createChest(x, y, z)
	local chest = Game.createItem(27531, 1, Position(x, y, z))
	for i = 1, itemsInChest do
		if i == 1 then
			chest = addRandomWeaponToChest(chest)
		else
			chest = addRandomItemToChest(chest)
		end		
	end
end

-- add item to chest, item cannot repeat
function addRandomItemToChest(chest)
	local item = getRandomItem()
	if chest:getItemCountById(item) ~= 0 then
		chest = addRandomItemToChest(chest)
	else
		if item == 38616 then
			chest:addItem(item, 20, INDEX_WHEREEVER, 0)
		elseif item == 38615 or item == 38614 then
			chest:addItem(item, 3, INDEX_WHEREEVER, 0)
		else
			chest:addItem(item, 1, INDEX_WHEREEVER, 0)
		end
		
	end
	return chest
end

-- add random weapon to chest
-- main purpose of this function is to make sure that chest contains weapon
function addRandomWeaponToChest(chest)
	chest:addItem(getRandomWeapon(), 1, INDEX_WHEREEVER, 0)
	return chest
end

-- draw item
function getRandomItem()
	local itemClass = math.random(10)
	if 0 <= itemClass and itemClass <= 5 then -- common items
		return COMMON_ITEMS[math.random(#COMMON_ITEMS)]
	elseif 6 <= itemClass and itemClass <= 9 then -- less common items
		return LESS_COMMON_ITEMS[math.random(#LESS_COMMON_ITEMS)]
	else -- rare items
		return RARE_ITEMS[math.random(#RARE_ITEMS)]
	end
end

-- draw weapon
function getRandomWeapon()
	local itemClass = math.random(10)
	if 0 <= itemClass and itemClass <= 5 then -- common items
		return COMMON_WEAPONS[math.random(#COMMON_WEAPONS)]
	elseif 6 <= itemClass and itemClass <= 9 then -- less common items
		return LESS_COMMON_WEAPONS[math.random(#LESS_COMMON_WEAPONS)]
	else -- rare items
		return RARE_WEAPONS[math.random(#RARE_WEAPONS)]
	end
end

-- clean br map, removes: chests, small and big fire, monsters
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

-- gives player bonus exp time
function giveBonusExp(player, hours)
	local plusTime = hours * 60 * 60
	db.asyncQuery("UPDATE players SET bonusexp = " .. db.escapeString(os.time() + plusTime) .. " WHERE id = " .. db.escapeString(player:getGuid()))
end

-- teleports player to temple
function teleportToTemple(player)
	local templePosition = player:getTown():getTemplePosition()
	player:teleportTo(templePosition, false)
end

-- reset skull for player
function resetSkull(player)
	player:setSkull(SKULL_NONE)
	player:setSkullTime(0)
end

-- add message which is diplayed to player after his death in br mode
function insertMessage(playerID, message, messageType)
	db.asyncQuery("INSERT INTO `battle_royale_reward_msg` (`player_id`, `message`, `message_type`) VALUES (" .. db.escapeString(playerID) .. ", " .. db.escapeString(message) .. ", " .. db.escapeString(messageType) ..")")
end