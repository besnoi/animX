animx=require 'animx'
evilImg=love.graphics.newImage('alienYellow.png')

--same as saying animx.newAnimatedSprite()
evilChar=animx.newActor() --returns an empty actor with no animations

walkingDir='right'

evilChar:addAnimation('standing',{
	img=evilImg,     --same as source/image/atlas/spritesheet/texure
	interval=1,      --same as delay
	onAnimOver=function()
		evilChar:switch('walking')
		evilChar:flipX(walkingDir=='right')
	end,
	x=69,y=255,      --same as offsetX and offsetY
	nq=1,            --same as noOfQuads
	qw=66,qh=82      --same as quadWidth and quadHeight
}):addAnimation('walking',{
	img=evilImg,
	delay=.5,
	quads={
		love.graphics.newQuad(0,339,68,83,evilImg:getDimensions()),
		love.graphics.newQuad(0,0,70,86,evilImg:getDimensions())
	}
}):switch('standing')

evilChar:getAnimation('walking'):onAnimOver(function()
	evilChar:switch('standing')
	walkingDir=walkingDir=='left' and 'right' or 'left'
end)


--it'd hardly have any effect but just to demonstrate this feature
evilChar:setStyle('smooth')

evilChar:exportToXML('alienYellow.xml')
--See `Exporting Animation` for notes on exporting

love.graphics.setNewFont(25)
function love.draw()
	love.graphics.printf("He..he..he (evil laugh)!!\nI can export this Animated Sprite to XML!!",0,20,800,'center')
	for i=1,5 do
		evilChar:draw(100+150*(i-1),600,0,2,2,evilChar:getWidth()/2,evilChar:getHeight())
	end
end