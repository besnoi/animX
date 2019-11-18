animx=require 'animx'

samurai=animx.newActor('res/spritesheet.png'):loopAll()

samurai:getAnimation('dying'):bounce(-1)
samurai:getAnimation('jumping'):setDelay(.5)

love.graphics.setNewFont(30)
function love.draw()
	samurai:draw(400,300,0,1,1,samurai:getWidth()/2,samurai:getHeight()/2)
	love.graphics.printf('-> '..samurai:getState():upper(),0,440,800,'center')
end

--Get all the states of samurai ('idle','blinking',etc) as a table
local states,marker=samurai:getStates(),1
samurai:switch(states[1])

function love.keypressed(key)
	marker=(marker+1)>#states and 1 or (marker+1)
	samurai:switch(states[marker])
end