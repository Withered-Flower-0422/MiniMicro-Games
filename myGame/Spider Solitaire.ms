// Spider Solitaire

// import preparation
import "listUtil"
import "stringUtil"
import "bmfFonts"
f = bmfFonts.Font.load("/sys/fonts/minimicro-pro-20.bmf")

// SFX
doneSound = file.loadSound("/sys/sounds/bling.wav")
completeSound = file.loadSound("/sys/sounds/fanfare.wav")
pickSound = file.loadSound("/sys/sounds/pickup.wav")
dealSound = file.loadSound("/sys/sounds/ting.wav")
errorSound = file.loadSound("/sys/sounds/blipA4.wav")
undoSound = file.loadSound("/sys/sounds/swoosh.wav")

// creat Card obj
cardRank = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
Card = []
for i in range(0, 13)
	Card.push new Sprite
	gfx.drawRect 0, 0, 80, 35, color.black
	gfx.fillRect 1, 1, 78, 33, color.white
	if i < 13 then
		f.print char(9824), 0, 0, 2, color.black
		ofs = [50, 32][i==9]
		f.print cardRank[i], ofs, 4, 1.5, color.black
	end if
	Card[i].image = gfx.getImage(0, 0, 80, 35)
	gfx.clear
end for

// config
maxSaveScenes = 999

cardColor = color.white

dealButtonTextColor = color.black
undoButtonTextColor = color.black
doneScreenTextColor = color.black
dealButtonColor = color.aqua
undoButtonColor = color.gray
doneScreenColor = color.silver

// helper functions
inside = function(n, a, b)
	if n < a then return a
	if n > b then return b
	return n
end function

// functions
creatButtons = function
	// creat doneScreen
	doneScreen = new Card[13]
	doneScreen.tint = doneScreenColor
	doneScreen.x = 60; doneScreen.y = 40
	buttonDisp.sprites.push doneScreen

	// creat dealButton
	dealButton = new Card[13]
	dealButton.tint = dealButtonColor
	dealButton.x = 900; dealButton.y = 40
	dealButton.id = "deal"
	dealButton.localBounds = new Bounds
	dealButton.localBounds.width = dealButton.image.width
	dealButton.localBounds.height = dealButton.image.height
	buttonDisp.sprites.push dealButton

	// creat undoButton
	undoButton = new Card[13]
	undoButton.tint = undoButtonColor
	undoButton.x = 900; undoButton.y = 80
	undoButton.id = "undo"
	undoButton.localBounds = new Bounds
	undoButton.localBounds.width = undoButton.image.width
	undoButton.localBounds.height = undoButton.image.height
	buttonDisp.sprites.push undoButton
end function
creatCardsGraph = function
	// creat heaps graph
	for i in heap.indexes
		for j in heap[i].indexes
			tmp = [13, heap[i][j]][j>invis[i]]
			card = new Card[tmp]
			card.tint = cardColor
			card.x = 95 * i + 52
			card.y = 600 - 30 * j
			card.id = [i, j]
			card.localBounds = new Bounds
			card.localBounds.width = card.image.width
			card.localBounds.height = card.image.height
			heapDisp.sprites.push card
		end for
	end for

	// creat holding-cards graph
	for i in hold.indexes
		card = new Card[hold[i]]
		card.x = mouse.x
		card.y = mouse.y - 30 * i
		holdDisp.sprites.push card
	end for
end function
saveScene = function
	cache.push [heap.deepCopy, invis.deepCopy, remain.deepCopy, globals.doneNum]
	if cache.len > maxSaveScenes then cache.pull
end function
undo = function
	if cache.len < 2 then return
	cache.pop
	data = cache[-1]
	if data then
		undoSound.play
		globals.heap = data[0].deepCopy
		globals.invis = data[1].deepCopy
		globals.remain = data[2].deepCopy
		globals.doneNum = data[3]
	end if
end function
deal = function
	if not remain then return
	if noVacancy then
		dealSound.play
		dealCards = remain.pop
		for i in heap.indexes
			heap[i].push dealCards[i]
		end for
	else
		errorSound.play
		globals.showTip = 1
	end if
end function
dragCards = function(l)
	if canPick(l) then
		pickSound.play
		i = l[0]; j = l[1]
		globals.hold = heap[i][j:]; heap[i] = heap[i][:j]
		while mouse.button; update; yield; end while
		placeAt = floor(inside(mouse.x / 96, 0, 9))
		if not canPut(placeAt) then placeAt = i
		heap[placeAt] += hold; globals.hold = []
	end if
end function
underMouse = function
	element = buttonDisp.sprites + heapDisp.sprites
	if not element then return null
	for i in element.indexes
		if element[i].contains(mouse) then return element[i].id
	end for
end function
noVacancy = function
	for i in heap
		if not i then return 0
	end for
	return 1
end function
updateInvis = function
	for i in heap.indexes
		if heap[i].len == invis[i] + 1 then invis[i] -= 1
	end for
end function
checkDone = function
	for i in heap.indexes
		for j in heap[i].indexes
			if heap[i][j] == 12 and j > invis[i] and heap[i][j:] == range(12) then
				doneSound.play
				heap[i] = heap[i][:j]
				globals.doneNum += 1
				break
			end if
		end for
	end for
end function
canPick = function(l)
	i = l[0]; j = l[1]
	if j <= invis[i] then return 0
	return heap[i][j:] == range(heap[i][j])[:heap[i][j:].len]
end function
canPut = function(i)
	if not heap[i] then return 1
	return hold[0] == heap[i][-1] - 1
end function
pressButton = function
	if mouse.button then
		chosen = underMouse
		if chosen isa list then return chosen
		while mouse.button; end while
		if chosen == underMouse then return chosen
	end if
end function
complete = function
	completeSound.play
	gfx.print "Well Done!", 410, 325, color.white
	gfx.print "Thanks for playing!", 345, 295, color.red
	text.color = color.orange
	exit
end function
update = function
	// clear all
	holdDisp.sprites = []; heapDisp.sprites = []; gfx.clear

	// print button description
	f.print remain.len, 889, 27, 1.5, dealButtonTextColor
	f.print doneNum, 49, 27, 1.5, doneScreenTextColor
	f.print "<-", 877, 67, 1.5, undoButtonTextColor
	
	// show  error tip
	if showTip then
		globals.showTip = 0
		gfx.print "Unable to deal cards when there are vacancies.", 160, 270, color.white
	end if

	// creat cards graph
	creatCardsGraph
end function
init = function
	// graph preparation
	clear; text.color = color.white
	display(6).mode = displayMode.sprite
	display(7).mode = displayMode.sprite
	globals.buttonDisp = display(6); buttonDisp.sprites = []
	globals.holdDisp = display(4); holdDisp.sprites = []
	globals.heapDisp = display(7); heapDisp.sprites = []
	globals.doneNum = 0; globals.showTip = 0

	// creat buttons
	creatButtons

	// cards preparation
	cards = []
	for i in range(12)
		cards += [i] * 8
	end for
	cards.shuffle

	// global var preparation
	globals.heap = []; globals.remain = []
	globals.hold = []; globals.cache = []
	globals.invis = [4] * 4 + [3] * 6

	// deal initial cards
	for i in range(0, 9)
		cnt = [5, 6][i<4]; tmp = []
		while cnt; cnt -= 1
			tmp.push cards.pop
		end while
		heap.push tmp[:]
	end for
	for i in range(0, 4)
		tmp = []
		for j in range(0, 9)
			tmp.push cards.pop
		end for
		remain.push tmp[:]
	end for

	// initial update
	update

	// save initial scene
	saveScene
end function

// Main loop
init
while 1
	press = pressButton
	if press then
		if press == "deal" then
			deal
		else if press == "undo" then
			undo
		else
			dragCards press
		end if
		checkDone; updateInvis; update
		saveScene; if cache[-1] == cache[-2] then cache.pop
	end if
	if key.pressed("r") then init
	if doneNum == 8 then complete
	yield
end while