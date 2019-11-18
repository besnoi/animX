animx=require 'animx'

--[[
	WARNING: Constrain yourself only with the library functions. Don't
	be inspired by how I implemented the movement part. We don't do jumping
	animation simply because it'd only make the code more difficult to read
	You can check up the modern platformer example for that!
]]

characterImage=love.graphics.newImage('character.png')

idleAnim=animx.newAnimation{
	img=characterImage,
	style='rough',
	noOfFrames=1,
	tileWidth=16
}

jumpAnim=animx.newAnimation{
	img=characterImage,
	frames={2,3},    --the animations consists of frame 2 and 3
	tileWidth=16
}

walkAnim=animx.newAnimation{
	img=characterImage,
	startFrom=10,
	noOfQuads=2,
	delay=.2,
	tileWidth=16
}:loop()  --Try removing this loop

-- There are atleast three ways to add animations to an actor

--Method 1
alien=animx.newActor{
	['idle']=idleAnim,
	['walking']=walkAnim
}
	:onSwitch(function(this,prevState)
		print ((
			"I was %s before but I'm %s now!"
		):format(prevState,this.current))
	end)
	:switch('idle')

--Method 2:
alien:addAnimation('jumping',jumpAnim)
--Method 3:
alien:addAnimation('climbing',{
	img=characterImage,
	frames={6,7}, --another way of adding frames
	tileWidth=16
})
alien:getAnimation('climbing'):loop()

ld=love.keyboard

function love.update(dt)

	animx.update(dt)
	
	if ld.isDown('right') or ld.isDown('left') then
		alien:switch('walking')
		alien:flipX(ld.isDown('left'))
		alien.x=alien.x+200*dt*(ld.isDown('left') and -1 or 1)
	elseif ld.isDown('up') or ld.isDown('down') then
		alien:switch('climbing')
		alien.y=alien.y+200*dt*(ld.isDown('up') and -1 or 1)
	else
		for i=1,1000000 do
			--I call this function a million times and still no frame-drop!
			alien:switch('idle')
			--This is because this has no effect if alien is already idle!
		end
	end
end

--We exploit the fact that an actor in animX has no x and y members!
alien.x,alien.y=400,300

function love.draw()
	alien:render(alien.x,alien.y,0,10,10,8,8)
	love.graphics.print(love.timer.getFPS())
end