// Snake

import "listUtil"

clear
disp = display(4)
gfx.color = color.white

// SFX
eatSound = file.loadSound("/sys/sounds/munch.wav")
deathSound = file.loadSound("/sys/sounds/airburst.wav")

// draw background
gfx.fillRect 0, 0, 20, 20

Rect = new Sprite
Rect.image = gfx.getImage(0, 0, 20, 20)
gfx.clear

for i in range(0, 29)
	for j in range(0, 29)
		noob = new Rect
		noob.id = [j, i]
		noob.x = 20 * j + 190
		noob.y = 20 * i + 30
		noob.tint = color.gray
		disp.sprites.push noob
	end for
end for

// snake logic
init = function
	globals.snake = [[14, 14], [13, 14]]
	globals.direction = [1, 0]
	globals.inputs = [1, 0]
	globals.t = time
	generateFood
end function
generateFood = function
	while 1
		globals.food = [floor(30*rnd), floor(30*rnd)]
		if snake.indexOf(food) == null then return
	end while
end function
snakeMove = function
	globals.snake = [snake[0].plus(direction)] + snake
	if snake[0] == food then
		eatSound.play
		snake.push
		generateFood
	end if
	snake.pop
end function
isDie = function
	body = snake.deepCopy
	head = body.pull
	if not (0<=head[0]<=29) or not (0<=head[1]<=29) then return 1
	if body.indexOf(head) != null then return 1
	return 0
end function
update = function
	for s in disp.sprites
		if s.id == food then
			s.tint = color.red
		else if snake.indexOf(s.id) != null then
			s.tint = color.white
		else
			s.tint = color.gray
		end if
	end for
	gfx.clear
	gfx.print "Score: " + (snake.len - 2) * 10, 0, 610, color.lime
end function

// input
inputsStorage = function
	if key.pressed("left") then
		globals.inputs = [-1, 0]
	else if key.pressed("right") then
		globals.inputs = [1, 0]
	else if key.pressed("up")then
		globals.inputs = [0, 1]
	else if key.pressed("down") then
		globals.inputs = [0, -1]
	end if
end function
directionChange = function
	if inputs.plus(direction) != [0, 0] then globals.direction = inputs[:]
end function

// Main loop
init
while 1
	inputsStorage
	if time - t > 0.075 then
		directionChange
		t = time
		snakeMove
		if isDie then
			deathSound.play
			wait 1.5
			clear
			gfx.print "Game Over!", 405, 360, color.red
			gfx.print "Your final score is: " + (snake.len - 2) * 10, 320, 320, color.red
			gfx.print "Press Esc to quit.", 360, 280, color.white
			while not key.pressed("escape"); end while
			clear
			break
		end if
		update
	end if
	yield
end while