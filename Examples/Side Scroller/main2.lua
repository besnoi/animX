animx=require 'animx'

img=love.graphics.newImage('spritesheet.png')

samurai=animx.newActor():
	addAnimation('attack',{
		img=img,
		tileHeight=275,
		nq=8
	}):addAnimation('blinking',{
		img=img,
		tileHeight=275,
		y=275,
		nq=8
	}):
	addAnimation('die',{
		img=img,
		tileHeight=275,
		y=2*275,
		nq=8
	}):
	addAnimation('hurt',{
		img=img,
		tileHeight=275,
		y=3*275,
		nq=8
	}):
	addAnimation('standing',{
		img=img,
		tileHeight=275,
		y=4*275,
		nq=8
	}):
	addAnimation('jumping',{
		img=img,
		tileWidth=332,  --in this case we must give tileWidth
		tileHeight=275,
		y=5*275,
		nq=2
	}):
	addAnimation('walking',{
		img=img,
		tileHeight=275,
		y=6*275,
		nq=8
	}):
	loopAll()

samurai:exportToXML('spritesheet.xml')

love.graphics.setNewFont(30)
function love.draw()
	samurai:draw(400,300,0,1,1,samurai:getWidth()/2,samurai:getHeight()/2)
	love.graphics.printf('-> '..samurai:getState():upper(),0,440,800,'center')
end

--Get all the states of samurai ('idle','blinking',etc) as a table
local states=samurai:getStates()
local marker=1
samurai:switch(states[1])

function love.keypressed(key)
	if key=='space' then
		marker=(marker+1)>#states and 1 or (marker+1)
		samurai:switch(states[marker])
	end
end