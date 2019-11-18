animx=require 'animx'

alien=animx.newActor():
	addAnimation('idle',{
		img='front.png'
	}):
	addAnimation('walking','walk_sheet.png'):
	switch('idle'):setStyle('rough')

function love.draw()
	love.graphics.print('Press Space to Run')
	alien:draw(400,300,0,5,5,alien:getWidth()/2,alien:getHeight()/2)
end

function love.keypressed(key)
	if key=='space' then
		alien:switch('walking'):getAnimation('walking'):loop():setStyle('rough')
	end
end

