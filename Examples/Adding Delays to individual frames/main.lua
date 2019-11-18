animx=require 'animx'

charAnim=animx.newAnimation{
	img='character.png',
	style='rough',
	noOfFrames=2,
}:loop()

charAnim:setDelay(1,2)   --the eye must be open for 2 seconds
charAnim:setDelay(2,.1)  --the eye must be closed for .1 second

function love.draw()
	charAnim:render(400,600,0,3,3,charAnim:getWidth()/2,charAnim:getHeight())
end

--[[LEGAL NOTE: Pokemon is the copyright of Nintendo and all that! I have no right over this sprite nor do you. I used it because it was the only suitable image i found at the moment. (The internet shows you copyrighted stuff first) Please someone make a PR and replace this with a CC0 image!!
]]
