local royaleStartSign = GlobalEvent("royaleRegisterStart")

function royaleStartSign.onTime(interval)
	brGame:startRegister()
end

royaleStartSign:time("20:00")
royaleStartSign:register()

local royaleStopSign = GlobalEvent("royaleRegisterStop")

function royaleStopSign.onTime(interval)
	brGame:closeRegister()
	broadcastMessage("Signing up for Battle Royale just stopped. \nBattle will start in minute", MESSAGE_STATUS_CONSOLE_BLUE)
end

royaleStopSign:time("20:14")
royaleStopSign:register()

local royaleBegin = GlobalEvent("royaleBegin")

function royaleBegin.onTime(interval)
	brGame:begin()
end

royaleBegin:time("20:15")
royaleBegin:register()

local royaleClean = GlobalEvent("royaleClean")

function royaleClean.onTime(interval)
	cleanBattleRoyaleMap()
end

royaleClean:time("03:00")
royaleClean:register()