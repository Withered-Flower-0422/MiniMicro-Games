// 2048

import "bmfFonts"
f = bmfFonts.Font.load("/sys/fonts/minimicro-pro-20.bmf")

clear

gfx.clear color.clear
gfx.drawRect 0, 0, 100, 100, color.black, 2
gfx.fillRect 2, 2, 96, 96, color.white
Block = new Sprite
Block.image = gfx.getImage(0, 0, 100, 100)
gfx.clear

// SFX
actSound = file.loadSound("/sys/sounds/pickup.wav")
deathSound = file.loadSound("/sys/sounds/airburst.wav")

// 2048 config
_2048 = {
0: {"bkgClr": color.silver, "txtClr": color.white, "txtScale": 0, "offsetX": 0, "offsetY": 0},
2: {"bkgClr": "#FFFFFF80", "txtClr": color.black, "txtScale": 3, "offsetX": 22, "offsetY": 27},
4: {"bkgClr": "#FFFFC080", "txtClr": color.black, "txtScale": 3, "offsetX": 22, "offsetY": 27},
8: {"bkgClr": "#FFC00080", "txtClr": color.white, "txtScale": 3, "offsetX": 22, "offsetY": 27},
16: {"bkgClr": "#FF8000FF", "txtClr": color.white, "txtScale": 3, "offsetX": 44, "offsetY": 27},
32: {"bkgClr": "#FF4000FF", "txtClr": color.white, "txtScale": 3, "offsetX": 44, "offsetY": 27},
64: {"bkgClr": "#FF0000FF", "txtClr": color.white, "txtScale": 3, "offsetX": 44, "offsetY": 27},
128: {"bkgClr": "#FFFF80FF", "txtClr": color.black, "txtScale": 2, "offsetX": 44, "offsetY": 18},
256: {"bkgClr": "#FFFF00FF", "txtClr": color.black, "txtScale": 2, "offsetX": 44, "offsetY": 18},
512: {"bkgClr": "#FFCD00FF", "txtClr": color.black, "txtScale": 2, "offsetX": 44, "offsetY": 18},
1024: {"bkgClr": "#FFA640FF", "txtClr": color.black, "txtScale": 1, "offsetX": 28, "offsetY": 9},
2048: {"bkgClr": "#FF735AFF", "txtClr": color.black, "txtScale": 1, "offsetX": 28, "offsetY": 9},
"else":{"bkgClr": "#000000FF", "txtClr": color.white, "txtScale": 1, "offsetY": 9},
}
_2048["else"].offsetX = function(n); return str(n).len * 7; end function

// 2048 logic
init = function
	clear
	display(6).mode = displayMode.sprite
	globals.disp = display(6)
	globals.orders = 0
	disp.sprites = []
	while not (4<=orders<=6)
		globals.orders = val(input("Orders?(4~6): "))
	end while
	text.clear
	for i in range(0, orders-1)
		for j in range(0, orders-1)
			noob = new Block
			noob.id = orders * i + j
			noob.x = 100 * j + 530 - 50 * orders
			noob.y = 640 - (100 * i + 370 - 50 * orders)
			noob.tint = color.silver
			disp.sprites.push noob
		end for
	end for
	globals.list2048 = [0] * (orders^2)
	globals.canDo = {"left": 0, "right": 0, "up": 0, "down": 0}
	globals.action = ["left", "right", "up", "down"]
	generate2
	update
end function
generate2 = function
	while 1
		index = rnd * orders^2
		if list2048[index] == 0 then
			list2048[index] = 2
			return
		end if
	end while
end function
list.remove0 = function(self)
	while self.indexOf(0) != null
		self.remove(self.indexOf(0))
	end while
end function
list.append0 = function(self, tolen)
	dif = self.len - tolen + 1
	if dif > 0 then return
	for i in range(dif); self.push 0; end for
end function
getSameNumberIndex = function(lst)
	res = []
	length = lst.len
	pointer = 0
	while pointer < length - 1
		if lst[pointer] == lst[pointer+1] then
			res.push pointer
			pointer += 2
		else
			pointer += 1
		end if
	end while
	return res
end function
pushNumber = function(lst)
	res = lst[:]
	res.remove0
	sameNumberIndex = getSameNumberIndex(res)
	for i in sameNumberIndex
		res[i] *= 2
		res[i+1] = 0
	end for
	res.remove0
	res.append0 orders
	return res
end function
next2048 = function(direction)
	res = list2048[:]
	for i in range(0, orders-1)
		tmp = []
		if direction == "left" then
			for j in range(0, orders-1)
				tmp.push res[orders*i+j]
			end for
			tmp = pushNumber(tmp)
			for j in range(0, orders-1)
				res[orders*i+j] = tmp[j]
			end for
		else if direction == "right" then
			for j in range(orders-1, 0)
				tmp.push res[orders*i+j]
			end for
			tmp = pushNumber(tmp)
			for j in range(orders-1, 0)
				res[orders*i+j] = tmp[orders-1-j]
			end for
		else if direction == "up" then
			for j in range(0, orders-1)
				tmp.push res[i+orders*j]
			end for
			tmp = pushNumber(tmp)
			for j in range(0, orders-1)
				res[i+orders*j] = tmp[j]
			end for
		else if direction == "down" then
			for j in range(orders-1, 0)
				tmp.push res[i+orders*j]
			end for
			tmp = pushNumber(tmp)
			for j in range(orders-1, 0)
				res[i+orders*j] = tmp[orders-1-j]
			end for
		end if
	end for
	return res
end function
isDie = function
	canDo.left = 1; canDo.right = 1; canDo.up = 1; canDo.down = 1 
	for s in canDo
		if next2048(s.key) == list2048 then canDo[s.key] = 0
	end for
	if canDo.values.sum == 0 then return 1 else return 0
end function
act = function
	keyPress = key.get.code
	if 17 <= keyPress <= 20 then
		if canDo[action[keyPress-17]] then
			actSound.play
			globals.list2048 = next2048(action[keyPress-17])
			generate2
		end if
	else if keyPress == 82 or keyPress == 114 then
		init
	else if keyPress == 27 then
		exit
	end if
	update
end function
update = function
	gfx.clear
	for s in disp.sprites
		tmp = list2048[s.id]
		if tmp <= 2048 then
			f.print tmp, s.x-_2048[tmp].offsetX, s.y-_2048[tmp].offsetY, _2048[tmp].txtScale, _2048[tmp].txtClr
			s.tint = _2048[tmp].bkgClr
		else
			f.print tmp, s.x-_2048["else"].offsetX(tmp), s.y-_2048["else"].offsetY, _2048["else"].txtScale, _2048["else"].txtClr
			s.tint = _2048["else"].bkgClr
		end if
	end for
	gfx.print "Score: " + calculateScore, 0, 0, color.lime
end function
calculateScore = function
	score = 0
	for i in list2048.indexes
		if list2048[i] > 2 then score += (list2048[i] / 4) ^ 2
	end for
	return score
end function

// Main loop
init
while 1
	if isDie then
		deathSound.play
		text.clear
		text.color = color.red
		print "Game Over!"
		print "Your final score is " + calculateScore + "."
		text.color = color.white
		print "Thanks for playing!"
		text.color = color.orange
		exit
	else
		act
	end if
end while