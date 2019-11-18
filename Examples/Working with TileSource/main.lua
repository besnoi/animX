animx=require 'animx'

anim=animx.newAnimation{
	img='glitch_asset.png',
	spritesPerRow=7,
	tileHeight=154,	--I knew it'd be somewhere near 640/4!
	numberOfQuads=20  --try removing this!
}:reverse() --reverse loop
--[[
	Note that If we don't give the tileHeight then it'd be
	defaulted to image-height which we of-course don't want!!
]]

function love.draw()
	anim:draw(400,300,0,3,3,108/2,160/2)
end