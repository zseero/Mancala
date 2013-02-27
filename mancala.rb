system("cls")

class Score
	attr_accessor :cCaptured
	attr_accessor :cActive
	attr_accessor :uCaptured
	attr_accessor :uActive

	def initialize cCaptured, cActive, uCaptured, uActive
		@cCaptured = cCaptured
		@cActive = cActive
		@uCaptured = uCaptured
		@uActive = uActive
	end

	def total who
		if who == :u
			return @uCaptured + @uActive
		elsif who == :c
			return @cCaptured + @cActive
		end
	end

	def difference
		return total(:u) - total(:c)
	end
end

class IndexDepth
	attr_accessor :index
	attr_accessor :depth

	def initialize index, depth
		@index = index
		@depth = depth
	end
end

class Board
	attr_accessor :cData
	attr_accessor :uData

	def initialize cData = [0, 4, 4, 4, 4, 4, 4], uData = [0, 4, 4, 4, 4, 4, 4]
		@cData = cData #these should be arrays, containing numbers. Each number is the amount
		@uData = uData #of marbles inside that slot. The 0th index is the large hole.
	end

	def constructPossibles depth
		possibles = []
		for i in 0..(depth - 1)
			nums = (1..6).to_a
			amt = 6 ** (depth - i - 1)
			for repeat in 1..(6 ** i)
				for ii in 0..5
					n = nums[ii]
					srange = amt * ii
					srange += (amt * 6) * (repeat - 1)
					erange = amt * (ii + 1)
					erange += (amt * 6) * (repeat - 1)
					erange -= 1
					range = srange..erange
					for r in range
						if possibles[r].nil?
							z = []
							depth.times do
								z << 0
							end
							possibles[r] = z
						end
						possibles[r][i] = n
					end
				end
			end
		end
		possibles
	end

	def test who = :c
		arry = @cData
		arry = @uData if who == :u
		for i in 1..6
			if arry[i] == i
				return i
			end
		end
		false
	end

	def utest who = :c
		arry = @uData
		arry = @cData if who == :u
		amt = 0
		for i in 1..6
			if arry[i] == i
				amt += 1
			end
		end
		amt
	end

	def getMove depth = 6, who = :c
		uData = @uData
		cData = @cData
		uData = @cData if who == :u
		cData = @uData if who == :u
		i = test
		return i if i
		results = []
		possibles = constructPossibles depth
		for i in 0..(possibles.length - 1)
			b = copy
			p = possibles[i]
			ii = 0
			points = 0
			usum = uData.inject{|sum, x| sum + x }
			amt = b.utest who
			success = true
			negpoints = 1
			while ii < p.length
				r = b.move(who, p[ii])
				success = false if p[ii] == 0
				points = 0 if b.utest(who) > amt
				yay = b.test who
				if yay
					#results << IndexDepth.new(p[0], ii)
					points += 1
					#break
				else
					#risk = 
					#negpoints *= risk
					#points -= 0.5
				end
				ii += 1
			end
			unow = uData.inject{|sum, x| sum + x }
			difference = usum - unow
			results << IndexDepth.new(p[0], points + difference) if success
		end
		return 4 if results.length == 0
		max = 0
		for i in 1..(results.length - 1)
			max = i if results[i].depth > results[max].depth
		end
		results[max].index
	end

	def uMove index
		b = move :u, index
		print
		b
	end

	def cMove
		m = getMove
		puts "CPU: " + m.to_s
		b = move :c, m
		print
		b
	end

	def move who, index
		main = @cData
		main = @uData if who == :u
		i = index
		amt = main[index]
		main[index] = 0
		current = main
		currentwho = who
		amt.times do
			i -= 1
			if i == -1
				if currentwho == :u
					current = @cData
					currentwho = :c
				elsif currentwho == :c
					current = @uData
					currentwho = :u
				end
				i = 6
			end
			current[i] += 1
		end
		return true if i == 0 && currentwho == who
		false
	end

	def getScore
		u = 0
		c = 0
		for i in 1..6
			u += @uData[i]
			c += @cData[i]
		end
		Score.new(c, @cData[0], u, @uData[0])
	end

	def end?
		udone = true
		cdone = true
		for i in 1..6
			udone = false if @uData[i] != 0
			cdone = false if @cData[i] != 0
		end
		if udone || cdone
			puts "Gameover"
			score = getScore
			puts "You: " + score.total(:u).to_s
			puts "CPU: " + score.total(:c).to_s
			if score.difference > 0
				puts "You won! :D"
			elsif score.difference < 0
				puts "You lost! D:"
			else
				puts "It\'s a tie!"
			end
			exit
		end
	end

	def print
		#system("cls")
		c = @cData.dup
		u = @uData.reverse
		puts c.join(" | ") + " |  "
		puts "  | " + u.join(" | ")
	end

	def copy
		Board.new @cData.dup, @uData.dup
	end
end

b = Board.new
b.print
while true
	run = true
	while run
		printf "You: "
		i = gets.to_i
		run = b.uMove i
		b.end?
	end
	run = true
	while run
		run = b.cMove
		b.end?
	end
end

while !true
	run = true
	while run
		printf "You: "
		i = gets.to_i
		run = b.uMove i
		b.end?
	end
	bb = b.copy
	run = true
	while run
		printf "Opponent: "
		i = gets.to_i
		run = b.move(:c, i)
		b.print
		b.end?
	end
	run = true
	while run
		move = bb.getMove
		puts "CPU would have moved: " + move.to_s
		run = bb.move(:c, move)
		b.end?
	end
end