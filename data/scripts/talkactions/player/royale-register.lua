local maxHealth = TalkAction("!health")
function maxHealth.onSay(player, words, param)
	print(Prey.Credits)
	print("player " .. player:getName() .. " max health: " .. player:getMaxHealth() .. " max mana: " .. player:getMaxMana())
end

maxHealth:separator(" ")
maxHealth:register()


local outfit = TalkAction("!outfit")

function outfit.onSay(player, words, param)
	local params = param:split(" ")
	print(tostring(player:hasOutfit(params[1], params[2])))
	player:addOutfitAddon(params[1], params[2])
	print(tostring(player:removeOutfitAddon(params[1], params[2])))
end

outfit:separator(" ")
outfit:register()

local xex = TalkAction("!sex")

function xex.onSay(player, words, param)
	print(player:getSex())
end

xex:separator(" ")
xex:register()

local time1 = TalkAction("!time")

function time1.onSay(player, words, param)
	print(os.time())
end

time1:separator(" ")
time1:register()

local check = TalkAction("!check")

function check.onSay(player, words, param)
local count = 0
		for r = 1, 98 do
			for a = 1, 1440 do
				local angle = (a / 4) * (math.pi / 180)
				local x = math.floor(192 + r * math.cos(angle))
				local y = math.floor(202 + r * math.sin(angle))
				local tile = Tile(Position(x, y, 7))
				-- TODO: iterate over tile:getItems()
				if tile ~= nil then
					local item = tile:getItemById(26385, -1)
					if item ~= nil then
					
						count = count + 1
						item:remove(-1)
					end
				end
			end
		end
		print("Chests = " .. tostring(count))
end

check:separator(" ")
check:register()

local chest = TalkAction("!chest")

function chest.onSay(player, words, param)
	Game.createItem(26385, 1, Position(190, 204, 7))
end

chest:separator(" ")
chest:register()

local teleport = TalkAction("!teleport")

function teleport.onSay(player, words, param)
	teleportPlayerToRoyale(player)
end

teleport:separator(" ")
teleport:register()

local giveBonusExp = TalkAction("!bonus")
--local br = BattleRoyale

function giveBonusExp.onSay(player, words, param)
	local bonusTime = tonumber(param) * 60 * 60
	player:setBonusExp(bonusTime)
end

giveBonusExp:separator(" ")
giveBonusExp:register()

local firerem = TalkAction("!firerem")
--local br = BattleRoyale

function firerem.onSay(player, words, param)
	local originX = 146
	local originY = 140
	for r = 1, tonumber(param) do
		for a = 1, 360 do
			local angle = a * (math.pi / 180)
			local x = math.floor(originX + r * math.cos(angle))
			local y = math.floor(originY + r * math.sin(angle))
			local tile = Tile(Position(x, y , 7))
			local item = tile:getItemById(1493, -1)
			if item ~= nil then
				item:remove(-1)
			end
		end
	end
end

firerem:separator(" ")
firerem:register()


local talk = TalkAction("!royale")
--local br = BattleRoyale

function talk.onSay(player, words, param)
	--br:addPlayerToBattleRoyale(player)
	if brGame == nil then
		print("brGame is nil")
	end
	brGame:addPlayer(player)
end

talk:separator(" ")
talk:register()

local startBR = TalkAction("!reg")
function startBR.onSay(player, words, param)
	brGame:startRegister()
end

startBR:separator(" ")
startBR:register()

local beginBR = TalkAction("!start")
function beginBR.onSay(player, words, param)
	brGame:begin()
end

beginBR:separator(" ")
beginBR:register()

local resetBR = TalkAction("!reset")
function resetBR.onSay(player, words, param)
	brGame:reset()
end

resetBR:separator(" ")
resetBR:register()

local setlvl = TalkAction("!level")
function setlvl.onSay(player, words, param)
	-- player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your lvl = " .. player:getLevel())
	-- local minusExp = tonumber(player:getExperience()) - 4200
	player:setSkillValues(SKILL_SWORD, 120, 0, 0)
	player:setSkillValues(SKILL_AXE, 120, 0, 0)
	player:setSkillValues(SKILL_CLUB, 120, 0, 0)
	-- player:removeExperience(minusExp, true)
	-- player:addSkillTries(SKILL_CLUB, 10)
	-- player:addSkillTries(SKILL_SWORD, 10)
	-- player:addSkillTries(SKILL_AXE, 10)
	-- player:addSkillTries(SKILL_DISTANCE, 10)
	-- player:addSkillTries(SKILL_SHIELD, 10)
	-- player:addSkillTries(SKILL_FISHING, 10)
	-- print(tostring(SKILL_FIST) .. " " .. tostring(SKILL_FISHING))
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your lvl = " .. player:getLevel())
end

setlvl:separator(" ")
setlvl:register()

local bless = TalkAction("!bless")
function bless.onSay(player, words, param)
	for i = 1, 6 do
		player:addBlessing(i)
	end
end

bless:separator(" ")
bless:register()

local exper = TalkAction("!exp")
function exper.onSay(player, words, param)
	player:addExperience(10000000)
end

exper:separator(" ")
exper:register()

local skull = TalkAction("!skull")
function skull.onSay(player, words, param)
	print(tostring(player:getSkull()) .. tostring(player:getSkullTime()))
	player:setSkull(SKULL_NONE)
	player:setSkullTime(0)
end

skull:separator(" ")
skull:register()

local poison = TalkAction("!field")
function poison.onSay(player, words, param)
	local position = Position(144, 138, 7)
	Game.createItem(1487, 1, position)
	-- local item = Item(1489)
	-- item:moveTo(position)
	local tile = Tile(Position(143, 138, 7))
	tile:addItem(Item(105))
end

poison:separator(" ")
poison:register()
