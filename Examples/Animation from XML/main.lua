animx=require 'animx'

anim=animx.newAnimation('atlas.png'):setStyle('rough'):loop()

function love.draw()
	anim:draw(400,300,0,15,15,24/2,24/2)
end