animx=require 'animx'

atlases={love.graphics.newImage("tc.png"),love.graphics.newImage("tc.png")}

-- This is how you can create an animation from scratch
smokeAnim=animx.newAnimation{
	img=atlases[1],
	noOfFrames=17,
	tileWidth=30,tileHeight=55,
	style='rough',
	onCycleOver=function(this) print('Cycle #'..this:getTimes()) end,
	onAnimOver=function() print('Animation is over') end,
	onAnimStart=function() print('Starting Animation') end,
	onAnimRestart=function() print('Restarting Animation') end
}:bounce(5)

--Try tweaking it with something like :rewind(2), :loop(2), :reverse(), :rewind(-1), :loop(-1)

-- Want to add a frame after you have created the animation?
smokeAnim:addFrame(30*7,55,30,55)
-- The above is exactly the same as doing
--smokeAnim:addFrame(love.graphics.newQuad(30*7,55,30,55,smokeAnim:getTexture():getDimensions()))

love.update=function(dt) smokeAnim:update(dt) end
--you could even say animx.update(dt)

function love.draw()
	love.graphics.print('Press Left/Right to change style!\nSpace to restart')
	smokeAnim:render(400,300,0,10,10,smokeAnim:getWidth()/2,smokeAnim:getHeight()/2)
end

local i=1
function love.keypressed(key)
	if key=='escape' then love.event.quit()
	elseif key=='space' then smokeAnim:restart()
	elseif key=='left' or key=='right' then
		i=i+(key=='left' and -1 or 1)
		i=i<1 and #atlases or (i>#atlases and 1 or i)
		smokeAnim:setAtlas(atlases[i])
	end
end