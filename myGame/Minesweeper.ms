// Minesweeper

// import libraries
import "listUtil"
import "bmfFonts"
import "stringUtil"
import "mathUtil"

f = bmfFonts.Font.load("/sys/fonts/minimicro-pro-20.bmf")

// SFX
WIN_SOUND = file.loadSound("/sys/sounds/fanfare.wav")
BOOM_SOUND = file.loadSound("/sys/sounds/airburst.wav")
EXPOLRE_SOUND = file.loadSound("/sys/sounds/pop.wav")

// config
	// image config
BLOCK_TILES = file.loadImage("/sys/pics/blockTiles.png")

DISCOVERED_IMAGE = BLOCK_TILES.getImage(96, 0, 32, 32)
UNDISCOVERED_IMAGE = BLOCK_TILES.getImage(0, 96, 32, 32)

BAR_IMAGE = file.loadImage("/sys/pics/Block4.png")
BUTTON_IMAGE = file.loadImage("/sys/pics/Block2.png")

	// char config
NULL = ""
MINE = "*"
FLAG = char(161)
UNCERTAIN = "?"
OFFSET_X = 8; OFFSET_Y = 8

	// color config
DISCOVERED_COLOR = "#C0C0C0FF"
UNDISCOVERED_COLOR = "#80D2FFFF"
NUM_COLOR = [
	color.clear, color.blue, color.green,
	color.red, color.navy, color.maroon, 
	color.aqua, color.black, color.silver]
MARK_COLOR = {
	NULL: color.clear,
	MINE: [color.black, color.red],
	FLAG: color.red,
	UNCERTAIN: color.black}

BAR_COLOR = color.silver
SELECT_COLOR = color.gray
BUTTON_COLOR = color.silver
TEXT_COLOR = {
	"easy": color.lime,
	"medium": color.aqua,
	"hard": color.red,
	"custom": color.black,
	"row_title": color.orange,
	"column_title": color.orange,
	"mine_title": color.orange,
	"row": color.lime,
	"column": color.aqua,
	"mine": color.red,
	"restart": color.lime,
	"exit": color.red,
	"die": color.red,
	"win": color.lime,
	"thanks": color.pink}

// creat obj
Zone = new Sprite
Zone.markList = [NULL, FLAG, UNCERTAIN]
Zone.init = function
	self.isMine = 0
	self.discovered = 0
	self.markIndex = 0
end function
Zone.update = function
	if self.discovered then
		self.image = DISCOVERED_IMAGE
		self.tint = DISCOVERED_COLOR
		if self.isMine then
			clr = MARK_COLOR[MINE][isDie]
			f.print MINE, self.x-OFFSET_X, self.y-OFFSET_Y, 1, clr
			return
		end if
		f.print self.num, self.x-OFFSET_X, self.y-OFFSET_Y, 1, NUM_COLOR[self.num]
	else
		self.image = UNDISCOVERED_IMAGE
		self.tint = UNDISCOVERED_COLOR
		mark = Zone.markList[self.markIndex]
		f.print mark, self.x-OFFSET_X, self.y-OFFSET_Y, 1, MARK_COLOR[mark]
	end if
end function

// helper functions
inRange = function(id)
	return 0 <= id[0] < row and 0 <= id[1] < clm
end function
toIndex = function(id)
	return clm * id[0] + id[1]
end function

// functions
getSelfNum = function(id)
	res = 0; around = getAround(id)
	for id in around
		if sp[toIndex(id)].isMine then res += 1
	end for
	return res
end function
mark = function(id)
	index = toIndex(id)
	if not sp[index].discovered then
		gfx.fillRect sp[index].x-16, sp[index].y-16, sp[index].x+16, sp[index].y+16, color.clear
		sp[index].markIndex += 1 
		sp[index].markIndex %= 3
	end if
end function
pressButton = function
	if mouse.button then
		chosen = underMouse
		while mouse.button; end while
		if chosen == underMouse then return chosen
	end if
end function
click = function
	if mouse.button(0) then
		chosen = underMouse
		while mouse.button(0)
			if start then timeUpdate
			if mouse.button(1) and chosen == underMouse then
				while mouse.button(1); if start then timeUpdate; end while
				if chosen == underMouse then return [chosen, "bothClick"]
			end if
		end while 
		if chosen == underMouse then return [chosen, "leftClick"]
	else if mouse.button(1) then
		chosen = underMouse
		while mouse.button(1)
			if start then timeUpdate
			if mouse.button(0) and chosen == underMouse then
				while mouse.button(0); if start then timeUpdate; end while
				if chosen == underMouse then return [chosen, "bothClick"]
			end if
		end while  
		if chosen == underMouse then return [chosen, "rightClick"]
	end if
	return [null, null]
end function
getPressKey = function
	if key.pressed("backspace") then
		while key.pressed("backspace"); end while
		return "backspace"
	end if
	if key.pressed("delete") then
		while key.pressed("delete"); end while
		return "delete"
	end if
	for i in range(9)
		if key.pressed(i) then
			while key.pressed(i); end while
			return i
		end if
		if key.pressed("["+i+"]") then
			while key.pressed("["+i+"]"); end while
			return i
		end if
	end for
end function
underMouse = function
	if not sp then return null
	for i in sp.indexes
		if sp[i].contains(mouse) then return sp[i].id
	end for
end function
createMineZone = function(r, c)
	for i in range(0, r-1)
		for j in range(0, c-1)
			zone = new Zone
			zone.id = [i, j]
			zone.x = 496 - 16 * clm + 32 * j
			zone.y = 304 + 16 * row - 32 * i
			zone.init; zone.update
			zone.localBounds = new Bounds
			zone.localBounds.width = zone.image.width
			zone.localBounds.height = zone.image.height
			sp.push zone
		end for
	end for
end function
getAround = function(id)
	r = id[0]; c = id[1]
	return [
		[r-1, c-1], [r-1, c], [r-1, c+1], 
		[r, c-1], [r, c+1], 
		[r+1, c-1], [r+1, c], [r+1, c+1], 
		].filtered(@inRange)
end function
generateMines = function(id)
	globals.firstClick = 0
	globals.start = 1
	globals.startTime = time
	globals.dt = startTime
	around = getAround(id)
	tmp = sp.indexes
	tmp.removeVal toIndex(id)
	for k in around
		tmp.removeVal toIndex(k)
	end for
	tmp.shuffle
	mineIndexList = tmp[:mineNum]
	for k in mineIndexList
		sp[k].isMine = 1
	end for
	for s in sp
		s.num = getSelfNum(s.id)
	end for
end function
explore = function(id)
	index = toIndex(id)
 	if sp[index].discovered or sp[index].markIndex != 0 then return
	q = {id: 1}
	while q
		id = q.pop; index = toIndex(id)
		sp[index].discovered = 1; EXPOLRE_SOUND.play
		if sp[index].isMine then
			globals.isDie = 1
			return
		end if
		if sp[index].num == 0 then
			tmp = getAround(id)
			for k in tmp
				if not sp[toIndex(k)].discovered then q.push k
			end for
		end if
	end while
end function
exploreAround = function(id)
	markNum = 0; noFlag = []; around = getAround(id)
	undiscoveredAround = []
	for aid in around
		if not sp[toIndex(aid)].discovered then undiscoveredAround.push aid
	end for
	for aid in undiscoveredAround
		index = toIndex(aid)
		if sp[index].markIndex == 1 then markNum += 1
		if sp[index].markIndex == 0 then noFlag.push aid
	end for
	if markNum == sp[toIndex(id)].num then
		for aid in noFlag
			explore aid
		end for
	end if
end function
update = function
	flagNum = 0
	for s in sp
		s.update
		if s.markIndex == 1 then flagNum += 1
	end for
	gfx.line 0, 630, 480, 630, color.clear, 40
	f.print "Mine: " + (mineNum - flagNum), 0, 620, 1, color.white
end function
timeUpdate = function
	if time - dt >= 0.01 then
		globals.dt = time
		gfx.line 480, 630, 960, 630, color.clear, 40
		data = "Time: " + mathUtil.numToStr(time - startTime, 2)
		f.print data, 800-16*(data.len-10), 620, 1, color.white
	end if
end function
update_pre = function
	gfx.line 300, 260, 500, 260, color.clear, 300
	for s in bar
		s.value.tint = BAR_COLOR
		f.print barNum[s.value.id], s.value.x-8*barNum[s.value.id].len+4, s.value.y-8, 1, TEXT_COLOR[s.value.id]
	end for
	select.tint = SELECT_COLOR
end function
isWin = function
	undiscoveredNum = 0
	for s in sp
		if not s.discovered then undiscoveredNum += 1
	end for
	return undiscoveredNum == globals.mineNum
end function
win = function
	WIN_SOUND.play
	globals.endTime = time
	gfx.fillRect 0, 0, 960, 608, color.clear
	for s in sp
		s.discovered = 1
		if s.isMine then s.image = UNDISCOVERED_IMAGE
	end for
	update
	for s in sp
		if s.isMine then
			s.image = UNDISCOVERED_IMAGE
			s.tint = UNDISCOVERED_COLOR
		end if
	end for
	gameOver "win"
end function
die = function
	BOOM_SOUND.play
	globals.endTime = time
	gfx.fillRect 0, 0, 960, 608, color.clear
	for s in sp
		s.discovered = 1
	end for
	update
	gameOver "die"
end function
gameOver = function(state)
	gfx.line 0, 630, 960, 630, color.clear, 40
	f.print "Mine: 0", 0, 620, 1, color.white
	data = "Time: " + mathUtil.numToStr(endTime - startTime, 2)
	f.print data, 800-16*(data.len-10), 620, 1, color.white

	// restart
	Button = new Sprite 
	Button.image = BAR_IMAGE
	Button.x = 400; Button.y = 15
	Button.scale = 0.5
	Button.id = "restart"
	Button.tint = BUTTON_COLOR
	Button.localBounds = new Bounds
	Button.localBounds.width = Button.image.width
	Button.localBounds.height = Button.image.height
	f.print Button.id, Button.x-Button.id.len*5-2, Button.y-5, 0.8, TEXT_COLOR[Button.id]
	sp.push Button

	// exit
	Button = new Sprite 
	Button.image = BUTTON_IMAGE
	Button.x = 600; Button.y = 15
	Button.scale = 0.5
	Button.id = "exit"
	Button.tint = BUTTON_COLOR
	Button.localBounds = new Bounds
	Button.localBounds.width = Button.image.width
	Button.localBounds.height = Button.image.height
	f.print Button.id, Button.x-Button.id.len*5, Button.y-5, 0.8, TEXT_COLOR[Button.id]
	sp.push Button

	while 1
		chosen = pressButton
		if chosen =="restart" then 
			init
			break
		else if chosen == "exit" then
			key.clear
			print; print
			text.color = TEXT_COLOR[state]
			if state == "win" then
				text.print "Finish in " + round(endTime - startTime, 2) + " seconds."
			else if state == "die" then
				text.print "Fail."
			end if
			text.color = TEXT_COLOR.thanks
			text.print "Thanks for playing!"
			text.color = color.orange
			exit
		end if
		yield
	end while
end function
createButtons = function
	difficulty = ["easy", "medium", "hard"]
	for i in difficulty.indexes
		Button = new Sprite 
		Button.image = BUTTON_IMAGE
		Button.x = 300 * i + 180; Button.y = 500
		Button.scale = 1
		Button.id = difficulty[i]
		Button.tint = BUTTON_COLOR
		Button.localBounds = new Bounds
		Button.localBounds.width = Button.image.width
		Button.localBounds.height = Button.image.height
		f.print Button.id, Button.x-Button.id.len*10+3, Button.y-10, 1.2, TEXT_COLOR[Button.id]
		sp.push Button
	end for

	f.print "Row: ", 100, 350, 1.2, TEXT_COLOR.row_title
	f.print "Column: ", 100, 250, 1.2, TEXT_COLOR.row_title
	f.print "Mine: ", 100, 150, 1.2, TEXT_COLOR.row_title
	selection = ["row", "column", "mine"]
	for i in selection.indexes
		Bar = new Sprite
		Bar.image = BAR_IMAGE
		Bar.x = 400; Bar.y = 360 - i * 100
		Bar.scale = 0.75
		Bar.id = selection[i]
		Bar.tint = BAR_COLOR
		Bar.localBounds = new Bounds
		Bar.localBounds.width = Bar.image.width
		Bar.localBounds.height = Bar.image.height
		globals.bar[selection[i]] = Bar
		sp.push Bar
	end for
	globals.select = globals.bar.row
	select.tint = SELECT_COLOR

	Button = new Sprite 
	Button.image = BUTTON_IMAGE
	Button.x = 700; Button.y = 260
	Button.scale = 1
	Button.id = "custom"
	Button.tint = BUTTON_COLOR
	Button.localBounds = new Bounds
	Button.localBounds.width = Button.image.width
	Button.localBounds.height = Button.image.height
	f.print Button.id, Button.x-Button.id.len*10+4, Button.y-10, 1.2, TEXT_COLOR[Button.id]
	sp.push Button
end function 
init = function
	// difficulty selection
	clear
	display(6).mode = displayMode.sprite; display(5).clear
	display(6).sprites = []; globals.sp = display(6).sprites
	globals.bar = {}
	globals.barNum = {"row": "", "column": "", "mine": ""}
	createButtons
	while 1
		chosen = pressButton
		if chosen then
			if chosen == "easy" then
				globals.barNum.row = "9"
				globals.barNum.column = "9"
				globals.barNum.mine = "10"
				break
			else if chosen == "medium" then
				globals.barNum.row = "16"
				globals.barNum.column = "16"
				globals.barNum.mine = "40"
				break
			else if chosen == "hard" then
				globals.barNum.row = "16"
				globals.barNum.column = "30"
				globals.barNum.mine = "99"
				break
			else if chosen == "custom" then
				r = barNum.row.val; c = barNum.column.val; m = barNum.mine.val
				if 5 <= r <= 18 and 5 <= c <= 30 and r * c * 0.04 <= m <= r * c * 0.5 then
					break
				else 
					f.print "Please keep rows in 5 to 18,", 300, 50
					f.print "columns in 5 to 30, and the proportion of mines in 0.04 to 0.5.", 55, 25
				end if
			else
				globals.select = bar[chosen]
			end if
			update_pre
		end if
		pressKey = getPressKey
		if pressKey != null then
			if pressKey == "backspace" then
				if barNum[select.id] then barNum[select.id] = barNum[select.id][:-1]
			else if pressKey == "delete" then 
				barNum[select.id] = ""
			else
				if barNum[select.id].len < 3 then barNum[select.id] += pressKey
			end if
			update_pre
		end if
		yield
	end while

	// init 
	clear

	// disp config
	display(6).mode = displayMode.sprite
	globals.tileDisp = display(6); tileDisp.sprites = []; globals.sp = tileDisp.sprites
	globals.numDisp = display(5); numDisp.clear
	
	// var
	globals.isDie = 0
	globals.row = barNum.row.val
	globals.clm = barNum.column.val
	globals.mineNum = barNum.mine.val
	globals.firstClick = 1
	globals.start = 0
	createMineZone row, clm
	
	update
	f.print "Time: 0.00", 800, 620, 1, color.white
end function

// Main loop
init
while 1
	if key.pressed("r") then init
	if start then timeUpdate
	chosen = click; id = chosen[0]; act = chosen[1]
	if id then
		if act == "bothClick" then
			exploreAround id
		else if act == "leftClick" then
			if firstClick then generateMines id
			explore id
		else if act == "rightClick" then
			mark id
		end if
		update; if isDie then die; if isWin then win
	end if
	yield
end while
