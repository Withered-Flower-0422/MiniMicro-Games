// Kloski

swap = function(a, b)
	tmp = kloski[a[0]][a[1]]
	kloski[a[0]][a[1]] = kloski[b[0]][b[1]]
	kloski[b[0]][b[1]] = tmp
end function
update = function
	clear
	for i in range(0,12 - order)
		print
	end for
	for i in range(0, order - 1)
		print " " * (30 - order * 1.5), ""
		for j in range(0, order - 1)
			if kloski[i][j] == " " then 
				print "    ", "" 
			else if kloski[i][j] < 10 then
				print " " + kloski[i][j] + "  ", ""
			else
				print kloski[i][j] + "  ",""
			end if
		end for
		print; print
	end for
	print
end function
up = function
	if vacancy[0] < order - 1 then
		tmp = vacancy[:]
		vacancy[0] += 1
		swap(vacancy, tmp)
	end if
end function
right = function
	if vacancy[1] then
		tmp = vacancy[:]
		vacancy[1] -= 1
		swap(vacancy, tmp)
	end if
end function
down = function
	if vacancy[0] then
		tmp = vacancy[:]
		vacancy[0] -= 1
		swap(vacancy, tmp)
	end if
end function
left = function
	if vacancy[1] < order - 1 then
		tmp = vacancy[:]
		vacancy[1] += 1
		swap(vacancy, tmp)
	end if
end function
isSolved = function
	tmp = []
	for i in range(0, order-1)
		for j in range(0, order-1)
			tmp.push(kloski[i][j])
		end for
	end for
	tmp.pop
	return tmp == range(1, order^2-1)
end function
init = function
	clear
	order = 0
	while order < 3 or order > 10
		order = input("Orders(3~10): ").val
	end while
	globals.order = order
	shuffleTimes = 3 ^ order
	globals.kloski = []
	for i in range(0,order-1)
		tmp = []
		for j in range(0,order-1)
			tmp.push(j + i * order + 1)
		end for
		globals.kloski.push(tmp)
	end for
	globals.kloski[order-1][order-1] = " "
	globals.vacancy = [order-1,order-1]
	while shuffleTimes; shuffleTimes -= 1
		func = [@up, @right, @down, @left]
		if not vacancy[0] then func.remove(func.indexOf(@down))
		if not vacancy[1] then func.remove(func.indexOf(@right))
		if vacancy[0] == order - 1 then func.remove(func.indexOf(@up))
		if vacancy[1] == order - 1 then func.remove(func.indexOf(@left))
		func.shuffle; f = func[0]; f
	end while
	update
end function

//Main loop
init
while 1
	keyCode = key.get.code
	if keyCode == 17 then left
	if keyCode == 18 then right
	if keyCode == 19 then up
	if keyCode == 20 then down
	if keyCode == 27 then init
	update
	if isSolved then
		print " " * 20 + "Solved! Press 'R' to restart."
		while 1
			if key.get.lower == "r" then
				init
				break
			end if
		end while
	end if
end while