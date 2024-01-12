// Spider Solitaire

import "listUtil"
import "stringUtil"
import "bmfFonts"
f = bmfFonts.Font.load("/sys/fonts/minimicro-pro-20.bmf")

// Init
clear
text.color = color.white
disp4 = display(4)
display(6).mode = displayMode.sprite
disp6 = display(6)
disp6.sprites = []
offset = [0, 0]
showTip = 0
done = 0

// SFX
doneSound = file.loadSound("/sys/sounds/bling.wav")
completeSound = file.loadSound("/sys/sounds/fanfare.wav")
pickSound = file.loadSound("/sys/sounds/pickup.wav")
dealSound = file.loadSound("/sys/sounds/ting.wav")
errorSound = file.loadSound("/sys/sounds/blipA4.wav")
undoSound = file.loadSound("/sys/sounds/swoosh.wav")

// Cards config
cardRank = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

drawCard = function(n)
	gfx.drawRect 0, 0, 80, 35, color.white
	gfx.fillRect 1, 1, 78, 33, color.orange
	if n < 13 then
		f.print char(9824), 0, 0, 2
		tmp = [50, 32][n==9]
		f.print cardRank[n], tmp, 4, 1.5
	end if
end function
Card = []
for i in range(0, 13)
	Card.push new Sprite
	drawCard i
	Card[i].image = gfx.getImage(0, 0, 80, 35)
	gfx.clear
end for

cards = []; heap = []; remain = []; hold = []; cache = []
invis = [4] * 4 + [3] * 6
for i in range(0, 12)
	for j in range(0, 7)
		cards.push i
	end for
end for
cards.shuffle
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

// Functions
saveScene = function
	cache.push {"heap": heap.deepCopy, "remain": remain.deepCopy, "invis": invis.deepCopy, "done": globals.done}
	if cache.len > 10 then cache.pull
end function
undo = function
	data = cache.pop
	if data then
		undoSound.play
		globals.heap = data.heap
		globals.invis = data.invis
		globals.remain = data.remain
		globals.done = data.done
	end if
end function
insinde = function(n, a, b)
	if n < a then return a
	if n > b then return b
	return n
end function
cardUnderMouse = function
	cards = disp6.sprites
	if not cards then return null
	for i in cards.indexes
		if cards[i].contains(mouse) then return cards[i].id
	end for
end function
isAvailale = function(l)
	i = l[0]; j = l[1]
	if j <= invis[i] then return 0
	tmp1 = heap[i][j:]
	tmp2 = range(tmp1[0])[:tmp1.len]
	if tmp1 == tmp2 then return 1 else return 0
end function
noVacancy = function
	for i in heap
		if not i then return 0
	end for
	return 1
end function
checkDone = function
	for i in heap.indexes
		for j in heap[i].indexes
			if heap[i][j] == 12 and j > invis[i] and heap[i][j:] == range(12) then
				doneSound.play
				heap[i] = heap[i][:j]
				if heap[i].len == invis[i]+1 then invis[i] -= 1
				globals.done += 1
				break
			end if
		end for
	end for
end function
update = function
	disp6.sprites = []
	disp4.sprites = []
	gfx.clear
	if showTip then
		globals.showTip = 0
		gfx.print "Unable to deal cards when there are vacancies.", 160, 270, color.white
	end if
	for i in heap.indexes
		for j in heap[i].indexes
			tmp = [13, heap[i][j]][j>invis[i]]
			card = new Card[tmp]
			card.x = 95 * i + 52
			card.y = 600 - 30 * j
			card.id = [i, j]
			card.localBounds = new Bounds
			card.localBounds.width = card.image.width
			card.localBounds.height = card.image.height
			disp6.sprites.push card
		end for
	end for
	card = new Card[13]
	card.x = 900
	card.y = 40
	card.id = -99
	card.localBounds = new Bounds
	card.localBounds.width = card.image.width
	card.localBounds.height = card.image.height
	disp6.sprites.push card
	f.print remain.len, 889, 27, 1.5
	card = new Card[13]
	card.x = 900
	card.y = 80
	card.id = -100
	card.localBounds = new Bounds
	card.localBounds.width = card.image.width
	card.localBounds.height = card.image.height
	disp6.sprites.push card
	f.print "<-", 877, 67, 1.5
	card = new Card[13]
	card.x = 60
	card.y = 40
	card.tint = color.aqua
	disp6.sprites.push card
	f.print done, 49, 27, 1.5
	for i in hold.indexes
		card = new Card[hold[i]]
		card.x = mouse.x
		card.y = mouse.y - 30 * i
		disp4.sprites.push card
	end for
end function

// Main loop
update
while 1
	if mouse.button then
		chosenCard = cardUnderMouse
		if chosenCard == -99 then
			while mouse.button; end while
			if chosenCard == cardUnderMouse then
				saveScene
				if noVacancy then
					tmp = remain.pop
					if tmp then
						dealSound.play
						for i in heap.indexes
							heap[i].push tmp[i]
						end for
					else
						cache.pop
					end if
				else
					cache.pop
					if remain then
						errorSound.play
						showTip = 1
					end if
				end if
			end if
		else if chosenCard == -100 then
			while mouse.button; end while
			if chosenCard == cardUnderMouse then undo
		else if chosenCard then
			if isAvailale(chosenCard) then
				saveScene
				pickSound.play
				hold = heap[chosenCard[0]][chosenCard[1]:]
				heap[chosenCard[0]] = heap[chosenCard[0]][:chosenCard[1]]
				while mouse.button
					update
					yield
				end while
				placeAt = floor(insinde(mouse.x/96, 0, 9))
				if heap[placeAt] and heap[placeAt][-1] != hold[0]+1 then
					placeAt = chosenCard[0]
					cache.pop
				else if chosenCard[0] == placeAt then
					cache.pop
				end if
				heap[placeAt] += hold
				if heap[chosenCard[0]].len == invis[chosenCard[0]]+1 and placeAt != chosenCard[0] then invis[chosenCard[0]] -= 1
				hold = []
			end if
		end if
		checkDone
		update
		if done == 8 then
			completeSound.play
			gfx.print "Well Done!", 410, 290, color.white
			gfx.print "Thanks for playing!", 345, 260, color.red
			text.color = color.orange
			exit
		end if
	end if
	yield
end while