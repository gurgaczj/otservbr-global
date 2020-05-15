local royaleStartSign = GlobalEvent("royaleRegisterStart")

function royaleStartSign.onTime(interval)
	brGame:startRegister()
	broadcastMessage("Signing up for Battle Royale just started! \nSign up with !royale command", MESSAGE_STATUS_CONSOLE_BLUE)
end

royaleStartSign:time("19:57")
royaleStartSign:register()

local royaleStopSign = GlobalEvent("royaleRegisterStop")

function royaleStopSign.onTime(interval)
	brGame:closeRegister()
	broadcastMessage("Signing up for Battle Royale just stopped \nBattle will start in minute", MESSAGE_STATUS_CONSOLE_BLUE)
end

royaleStopSign:time("20:00")
royaleStopSign:register()

local royaleBegin = GlobalEvent("royaleBegin")

function royaleBegin.onTime(interval)
	brGame:begin()
end

royaleBegin:time("20:01")
royaleBegin:register()

local royaleClean = GlobalEvent("royaleClean")

function royaleClean.onTime(interval)
	brGame:reset()
end

royaleClean:time("03:00")
royaleClean:register()