animx=require 'animx'

alien=animx.newActor('alienPink.png')
:switch('swim'):getAnimation():loop():setDelay(.4)

function love.draw()
	alien:draw(400,300,0,1,1,alien:getWidth()/2,alien:getHeight()/2)
end