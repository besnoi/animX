
animx=require 'animx'

--[[
	Since the spritesheet is symmetrical one-rowed tilesource we don't
	need to specify anything other then the number of images in the atlas!
	(Ofcourse specifying the image is must in any case)
]]

skins={love.graphics.newImage('walk.png'),love.graphics.newImage('walk2.png')}

mushroomAnim=animx.newAnimation{
	img=skins[1],
	noOfFrames=4
}:loop()

function love.draw()
	love.graphics.print("Press any key to change the skin!")
	mushroomAnim:draw(368,268)
end

function love.keypressed(key)
	mushroomAnim:setAtlas(mushroomAnim:getAtlas()==skins[1] and skins[2] or skins[1])
end