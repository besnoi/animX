animx=require 'animx'

function love.load()
	down=animx.newAnimation{
		img='character.png',
		noOfFrames=3,
		tileHeight=128/4
	}:loop()
	left=animx.newAnimation{
		style='rough',  -- since all sprites will share same image, we only need to set style once!
		img='character.png',
		startFrom=4,   --start from 4 and go on till 4+3=7!!
		noOfFrames=3,
		tileHeight=128/4
	}:loop()
	right=animx.newAnimation{
		img='character.png',
		startFrom=7,   --start from 7 and go on till 7+3=10!!
		noOfFrames=3,
		tileHeight=128/4
	}:loop()
	up=animx.newAnimation{
		img='character.png',
		startFrom=10,   --start from 10 and go on till 10+3=13!!
		noOfFrames=3,
		tileHeight=128/4
	}:loop()
	character=animx.newActor{
		['down']=down,
		['left']=left,
		['right']=right,   --> we could create right as mirror of left! but for now let it be!
		['up']=up,
	}:switch('down')
	SPEED=200
	characterX,characterY=400-16,300-16
end

function love.update(dt)
	animx.update(dt)
	if love.keyboard.isDown('down') or love.keyboard.isDown('up') then
		character:switch(love.keyboard.isDown('down') and 'down' or 'up')
		characterY=characterY+SPEED*dt*(love.keyboard.isDown('down') and 1 or -1)
	elseif love.keyboard.isDown('left') or love.keyboard.isDown('right') then
		character:switch(love.keyboard.isDown('right') and 'right' or 'left')
		characterX=characterX+SPEED*dt*(love.keyboard.isDown('right') and 1 or -1)
	else
		character:getAnimation():setFrame(2) --turns out 2 is the idle frame for all anim!!!
		character:stopAnimation()
	end
end

function love.draw()
	character:draw(characterX,characterY,0,5,5,16,16)
end

--[[
	In some cases the animation won't render (try pressing an arrow key twice)!
	This is the problem of real-time events not animX
	I am sure the user will come up with a solution!!
	(Please make a PR in that case :>)
]]