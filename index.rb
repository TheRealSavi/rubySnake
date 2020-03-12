require 'ruby2d'
require 'matrix'
set width: 600, height: 600

$enableGame = true

class Grid
  attr_reader :gridSize, :pixelSize, :borderSize
  def initialize(gridSize, borderSize)
    @gridSize = gridSize
    @pixelSize = 600 / gridSize
    @borderSize = borderSize
    @pixels = build()
  end

  def build()
    grid = []
    @gridSize.times do |j|
      @gridSize.times do |i|
        grid.push(Square.new(x: i * @pixelSize, y: j * @pixelSize, size:@pixelSize - @borderSize, color: "blue"))
      end
    end
    return grid
  end

  def getPixel(x, y)
    pos = y * @gridSize + x
    return @pixels[pos]
  end
end

class Snake
  attr_accessor :vel
  def initialize(gameGrid, food)
    @food = food
    @gameGrid = gameGrid
    @pos = Vector[0, 0]
    @vel = Vector[0, 1]
    @snakeSize = 1
    @tail = []
  end

  def move()
    @pos += @vel
    $ui2.text = @pos.to_s

    @tail.push(Vector[@pos[0],@pos[1]])

    unless edgeCheck()
      @gameGrid.getPixel(@pos[0], @pos[1]).color = "green"
    end

    if @tail.length > @snakeSize
      oldTail = @tail.shift()
      @gameGrid.getPixel(oldTail[0], oldTail[1]).color = "blue"
    end
  end

  def eat()
    if @pos == @food.pos
      @food.eat(@tail)
      @snakeSize += 5
    end
  end

  def tailCheck()
    (@tail.length - 1).times do |i|
      if @tail[i] == @pos
        return true
      end
    end
    return false
  end

  def edgeCheck()
    if @pos[0] >= @gameGrid.gridSize || @pos[0] <= -1 || @pos[1] >= @gameGrid.gridSize || @pos[1] <= -1
      return true
    else
      return false
    end
  end

  def update()
    hitTail = tailCheck()
    hitEdge = edgeCheck()
    if hitTail == true || hitEdge == true
      $ui.text = "Game Over"
      $enableGame = false
      @vel = Vector[0, 0]
    else
      eat()
      move()
      eat()
    end
  end

end

class Food
  attr_reader :pos
 def initialize(gameGrid)
   @gameGrid = gameGrid
   @pos = Vector[rand(0..@gameGrid.gridSize - 1).to_i, rand(0..@gameGrid.gridSize - 1).to_i]
   @gameGrid.getPixel(@pos[0], @pos[1]).color = "red"
 end

 def eat(tail)
   @gameGrid.getPixel(@pos[0], @pos[1]).color = "green"
   @pos = Vector[rand(0..@gameGrid.gridSize - 1).to_i, rand(0..@gameGrid.gridSize - 1).to_i]
   until tailCheck(tail) == false
     @pos = Vector[rand(0..@gameGrid.gridSize - 1).to_i, rand(0..@gameGrid.gridSize - 1).to_i]
     $ui.text = @pos.to_s
   end
   @gameGrid.getPixel(@pos[0], @pos[1]).color = "red"
   $ui.text = @pos.to_s
 end

 def tailCheck(tail)
   tail.each do |bit|
     if bit == @pos
       return true
     end
   end
   return false
 end

end

gameGrid = Grid.new(20,1)
food = Food.new(gameGrid)
snake = Snake.new(gameGrid, food)
$ui = Text.new("Food")
$ui2 = Text.new("Head", x: 200)

$frames = 0
update do
  if $enableGame == true
    $frames += 1
    $frames = $frames % 5
    if $frames == 0
      snake.update
    end
  end
end

on :key_down do |event|
  case event.key
  when "w"
    snake.vel = Vector[0,-1]
  when "a"
    snake.vel = Vector[-1,0]
  when "s"
    snake.vel = Vector[0,1]
  when "d"
    snake.vel = Vector[1,0]
  end
end

show
