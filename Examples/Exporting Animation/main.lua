animx=require 'animx'

anim=animx.newAnimation{
	img='glitch_crab.png',
	spritesPerRow=6,
	interval=.03,
	tileHeight=516/4  -- try removing this and adding noOfFrames=24
}:loop()
--[[
	Note that unlike 'Working with TileSource' example we don't give
	the number of quads cause there's blank space at the end of the animation.
	So we leave it nil so that animX would calculate it on it's own
]]

animx.hideWarnings=true --try removing this with animation.xml present
anim:exportToXML('exported/animation.xml')
--[[
	Note that animX will ignore any path thatchu give it!
	You can see it as a feature or as a bug - up to you!
]]--

love.graphics.setNewFont(25)
function love.draw()
	love.graphics.printf("He..he..he!!\nI can export this animation to XML!!",0,130,800,'center')
	anim:draw(400,300,0,1,1,108/2,160/2)
end
