// Frenzy

clear
disp = display(4)
mouse.visible = 0
mouse.locked = 1
yield
mouse.locked = 0

// SFX
eatSound = file.loadSound("/sys/sounds/munch.wav")
victorySound = file.loadSound("/sys/sounds/fanfare.wav")
eatenSound = file.loadSound("/sys/sounds/airburst.wav")
growupSound = file.loadSound("/sys/sounds/bonus.wav")

// draw circle
gfx.clear color.clear
gfx.fillEllipse 5, 5, 118, 118, color.gray
gfx.drawEllipse 5, 5, 118, 118, color.white, 10

Circle = new Sprite
Circle.image = gfx.getImage(0, 0, 128, 128)
gfx.clear

rnds = function(a, b)
	return (b - a) * rnd + a
end function
rndSign = function
	return sign(rnd - 0.5)
end function

Circle.vx = 0
Circle.vy = 0
Circle.boundryX = [-40, 1000]
Circle.boundryY = [-40, 680]
Circle.beyondX = function(x)
	return x > self.boundryX[1] or x < self.boundryX[0]
end function
Circle.beyondY = function(y)
	return y > self.boundryY[1] or y < self.boundryY[0]
end function
Circle.init = function
	self.vx = 0; self.vy = 0
	self.y = rnds(self.boundryY[0], self.boundryY[1])
	self.x = self.boundryX[2*rnd]
end function
Circle.giveSpeed = function(speedRate = 1, minSpeed = 0.5, maxSpeed = 1)
	if sqrt(self.vx ^ 2 + self.vy ^ 2) < 0.00001 then
		self.vx = rndSign * rnds(minSpeed, maxSpeed) * speedRate
		self.vy = rndSign * rnds(minSpeed, maxSpeed) * speedRate
	end if
end function
Circle.roam = function
	nextx = self.x + self.vx; nexty = self.y + self.vy
	if self.beyondX(nextx) or self.beyondY(nexty) then
		self.vx = 0; self.vy = 0
	else
		self.x = nextx; self.y = nexty
	end if
end function
Circle.touchingPlayer = function
	d = sqrt((self.x - player.x) ^ 2 + (self.y - player.y) ^ 2)
	return d <= 64 * (self.scale + player.scale)
end function
Circle.update = function(speedRate = 2)
	self.giveSpeed(speedRate)
	self.roam
	if self.touchingPlayer and not invicibleCD then
		if self.scale > player.scale then
			eatenSound.play
			player.tint = color.red
			wait 1
			globals.invicibleCD = 100
			player.init
			growthReduce
		else
			eatSound.play
			globals.growth += self.growth
			if globals.growth >= 900 then globals.growth = 900
			self.init
			growup
		end if
		growthUpdate
	end if
end function

// creat player
player = new Circle
player.x = 480
player.y = 660
player.scale = 25/128
player.tint = color.white
disp.sprites.push player

player.init = function
	mouse.locked = 1
	yield
	mouse.locked = 0
	globals.mousePos = [mouse.x, mouse.y]
	self.vx = 0; self.vy = 0
	self.y = 660
	self.x = 480
	globals.target = [480, 320]
end function
target = [480, 320]
player.update = function
	if invicibleCD then self.tint = color.purple else self.tint = color.white
	mouseMove = getMouseMove
	player.boundryX = [self.scale*64, 960-self.scale*64]
	player.boundryY = [self.scale*64, 640-self.scale*64]
	target[0] += mouseMove[0]
	target[1] += mouseMove[1]
	if target[0] > self.boundryX[1] then target[0] = self.boundryX[1]
	if target[1] > self.boundryY[1] then target[1] = self.boundryY[1]
	if target[0] < self.boundryX[0] then target[0] = self.boundryX[0]
	if target[1] < self.boundryY[0] then target[1] = self.boundryY[0]
	dx = target[0] - self.x
	dy = target[1] - self.y
	self.vx = dx / 15
	self.vy = dy / 15
	self.x += self.vx
	self.y += self.vy
end function

mousePos = [mouse.x, mouse.y]
getMouseMove = function
	res = [mouse.x-mousePos[0], mouse.y-mousePos[1]]
	globals.mousePos = [mouse.x, mouse.y]
	return res
end function
growthReduce = function(point1=200, point2=600)
	if round(player.scale*128) == 25 then globals.growth = 0
	if round(player.scale*128) == 35 then globals.growth = point1
	if round(player.scale*128) == 45 then globals.growth = point2
end function
growup = function(point1=200, point2=600)
	if growth >= point1 and player.scale*128 < 35 then
		player.scale = 35/128
		growupSound.play
	else if growth >= point2 and player.scale*128 < 45 then
		player.scale = 45/128
		growupSound.play
	end if
end function
growthUpdate = function(point1=200, point2=600, point3=900)
	if growth < point1 then
		gfx.color = color.green
		point = point1
	else if growth < point2 then
		gfx.color = color.orange
		point = point2
	else 
		gfx.color = color.blue
		point = point3
	end if
	gfx.clear
	gfx.print growth + " / " + point
end function

// creat a bunch of circles
for i in range(64)
	noob = new Circle
	noob.init
	if i >= 60 then
		noob.tint = color.red
		noob.growth = 8
		noob.scale = 50/128
	else if i >= 50 then
		noob.tint = color.blue
		noob.growth = 5
		noob.scale = 40/128
	else if i >= 30 then
		noob.tint = color.orange
		noob.growth = 3
		noob.scale = 30/128
	else
		noob.tint = color.green
		noob.growth = 2
		noob.scale = 20/128
	end if
	disp.sprites.push noob
end for

// Main loop
invicibleCD = 0
growth = 0
growthUpdate
while 1
	if invicibleCD then invicibleCD -= 1
	for s in disp.sprites
		s.update
	end for
	if growth >= 900 then
		victorySound.play
		player.tint = color.aqua
		wait 5
		clear
		print "Complete!"
		print "Thanks for playing!"
		mouse.visible = 1
		break
	end if
	yield
end while