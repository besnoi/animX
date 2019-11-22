--[[
	The Animation Class for animX
	Author: Neer
]]

--Unlike iffy we use metatables
local Animation={
	texture,           --the spritesheet for the animation
	frames,            --the frames in the animation
	duration,          --duration for each sprite- a smart table (idea stolen from Walt)
	cache,             --an internal variable to account for same duration across multiple frames
	mode,              --the mode of the animation - {'loop'/'rewind'/'once'/'bounce',times}
	direction,         --the sense of the animation
	curFrame,          --the current frame that's being rendered
	active,            --whether the animation is being played or not
	curTimes,          --keeps count of number of times animation executed
	timer,             --an internal timer variable
	p_flipX,           --whether to flip along x-axis [internal]
	p_flipY,           --whether to flip along y-axis [internal]
	p_onCycleOver,     --handler called when an animation cycle is complete [internal]
	p_onAnimOver,      --handler called when the entire animation is over [internal]
	p_onAnimStart,     --handler called when the animation is started [internal]
	p_onAnimRestart,   --handler called whenever the animation is restarted [internal]
	p_onChange,        --handler called whenever current frame is changed [internal]
	p_onUpdate,        --called at every frame regardless of it's active property [internal]
}

--an internal function which just sets the default values
function Animation:init(startingFrame,delay)
	self:setDelay(delay)
	self.startingFrame=startingFrame
	self:start()	
	self.mode={'loop',1}
end

--[[the addFrame concept was stolen from BartBes' animation library. Anyways -
  what this func does is create a new quad and associate it with the given
  animation. The frame would be appended to the last of the framelist!
]]
function Animation:addFrame(x,y,w,h,delay)
	if y then
		--User passed in position of the quad
		table.insert(self.frames,
			love.graphics.newQuad(x,y,w,h,self:getAtlas():getDimensions())
		)
	else
		--User passed in a quad
		table.insert(self.frames,x)
	end

	--Note we are not calling setDelay cause it's a new frame!
	if delay and delay~=self.duration[#self.duration] then
		self.duration[#self.duration+1]=delay
		self.cache[#self.cache+1]=1
	else
		self.cache[#self.cache]=self.cache[#self.cache]+1
	end
end

--Not to be confused with p_onAnimOver!
function Animation:onAnimOver(fn)
	self.p_onAnimOver=fn or function() end
	return self
end

--Not to be confused with p_onCycleOver!
function Animation:onCycleOver(fn)
	self.p_onCycleOver=fn or function() end
	return self
end

--Not to be confused with p_onAnimStart!
function Animation:onAnimStart(fn)
	self.p_onAnimStart=fn or function() end
	return self
end

--Not to be confused with p_onAnimRestart!
function Animation:onAnimRestart(fn)
	self.p_onAnimRestart=fn or function() end
	return self
end

--Not to be confused with p_onChange!
function Animation:onChange(fn)
	self.p_onChange=fn or function() end
	return self
end

--Not to be confused with p_onUpdate!
function Animation:onUpdate(fn)
	self.p_onUpdate=fn or function() end
	return self
end

--Rewind the animation any number of times, (nil or negative)=>infinite
function Animation:rewind(times)
	self.mode={'rewind',times or -1}
	return self
end

--Similar to rewind except the definition of 'cycle' is different!
--also `bounce` by default reverses only once while `rewind` rewinds forever
function Animation:bounce(times)
	self.mode={'bounce',times or 1}
	return self
end

--loops the animation in obverse or reverse direction (obverse by default)
function Animation:loop(times,dir)
	self.mode={'loop',times or -1}
	self.direction=dir or 1
	return self
end

--same as loop just direction is always reversed
function Animation:reverse(times)
	return self:loop(times,-1)
end

--Executes an animation once in the obverse direction!
function Animation:once()
	return self:loop(1,1)
end

--restarts the animation from where it was
function Animation:restart()
	self.active=true
	self.curFrame=self.startingFrame
	self.curTimes=0
	self.p_onAnimRestart(self)
end

--Returns the total number of frames in animation
function Animation:getSize() return #self.frames end

--Returns the total number of times the animation has been played
function Animation:getTimes() return self.curTimes end

--Returns the current Frame of the animation (a number)
function Animation:getCurrentFrame() return math.max(1,math.min(self.curFrame,self:getSize())) end

--Returns the current quad that's being rendered (a Quad)
function Animation:getCurrentQuad() return self.frames[self:getCurrentFrame()] end

--Returns whether or not is the animation active!
function Animation:isActive() return self.active end

--Returns the dimensions of the current frame
function Animation:getDimensions() local x,y,w,h=self:getCurrentQuad():getViewport(); return w,h end
function Animation:getWidth() return select(1,self:getDimensions()) end
function Animation:getHeight() return select(2,self:getDimensions()) end

function Animation:setStyle(style)
	assert(style=='rough' or style=='smooth',"animX Error!! Expected 'smooth' or 'rough' in setStyle fn")
	if style=='rough' then
		self:getImage():setFilter('nearest','nearest')
	else
		self:getImage():setFilter('linear','linear')
	end
	return self
end

--Returns the texture for the animation (an Image)
function Animation:getAtlas() return self.texture end

--Sometimes you may want to change the atlas (maybe for something like character clothes)
--The next fn changes the texture for the animation
function Animation:setAtlas(img)
	if type(img)=='string' then img=love.graphics.newImage(img) end
	self.texture = img
	return self
end

--Sets the current frame as n
function Animation:jumpToFrame(n)
	assert(n>=1 and n<=self:getSize(), "animX Error: Frame is out of bounds!")
	self.curFrame=n
	return self
end

--To be called only when an animation just starts (private fn)
function Animation:start()
	self.p_onAnimStart(self)
	self.curFrame=self.startingFrame
	self.direction=1
	self.active=true
	self.timer=0
	self.curTimes=0
end

--To be called only when an animation has completed a 'cycle' (private fn)
function Animation:cycle()
	self.curTimes=self.curTimes+1
	self.p_onCycleOver(self)
end

--To be called only when the current frame has to be changed (private fn)
function Animation:change()
	self.curFrame=self.curFrame+self.direction
	self.p_onChange(self)
end

--Stops the animation! Use anim.active=false if you don't want to trigger any callback!
function Animation:stop()
	--It is important that active is first set to false and then handler is called
	self.active=false
	self.p_onAnimOver(self)	
end

--gets the duration of the given frame or current frame if provided nil
function Animation:getDelay(frame)
	frame=frame or self:getCurrentFrame()
	--u for cache and v for duration
	local u,v=1,1
	assert(frame>=1 and frame<=self:getSize(),"animX Error: Frame is out of bounds!")
	for i=1,self:getSize() do
		if u>self.cache[v] then u=1 v=v+1 end
		if i==frame then
			return self.duration[v]
		end
		u=u+1
	end
end

--sets the duration of the given frame or all frames if only one arg
function Animation:setDelay(frame,delay)
	if not delay then
		--Set delay for all frames
		delay,frame=frame
		self.duration={delay}
		self.cache={self:getSize()}
		return self
	end
	--Set delay for only one frame
	assert(frame>=1 and frame<=self:getSize(),"animX Error: Frame is out of bounds!")
	
	local u,v=1,1

	for i=1,self:getSize() do
		if u>self.cache[v] then u=1 v=v+1 end
		if i==frame then
			--If same delay as before then breakout!
			if delay==self.duration[v] then break end
			if self.cache[v]==1 then
				--This is the most simple case (when no buffer)
				self.duration[v]=delay
				--so in other cases self.cache[v] is asserted to be >1
			elseif u==1 then
				--for beginning of the buffer
				table.insert(self.duration,v+1,self.duration[v])
				table.insert(self.cache,v+1,self.cache[v]-1)
				self.duration[v],self.cache[v]=delay,1
			elseif self.cache[v]==u then
				--for ending of the buffer
				table.insert(self.duration,v+1,delay)
				table.insert(self.cache,v+1,1)
				self.cache[v]=self.cache[v]-1
			else
				--at the middle of the buffer (darn it!)
				table.insert(self.duration,v+1,self.duration[v])
				table.insert(self.duration,v+1,delay)
				table.insert(self.cache,v+1,self.cache[v]-u)
				table.insert(self.cache,v+1,1)
				self.cache[v]=self.cache[v]-1
			end
		end
		u=u+1
	end
	return self
end

--gets the current animation mode
function Animation:getMode()
	return self.mode and self.mode[1]
end

--check if current mode is equal to one of the given modes
function Animation:isMode(...)
	for i=1,select('#',...) do
		if self.mode[1]==select(i,...) then
			return true
		end
	end
end

function Animation:update(dt)
	self:p_onUpdate(dt)
	if not self.active then return end

	self.timer=self.timer+dt

	--Get the delay for the current frame!
	local delay=self:getDelay(self.curFrame)

	if self.timer>delay then
		self.timer=self.timer%delay
		self:change()
		if self.curFrame>self:getSize() then			
			self:cycle()
			if self:getMode()=='bounce' then
				--If we are bouncing and we are done then stop
				if self.mode[2]>0 and self.curTimes>=self.mode[2] then return self:stop() end
			end
			if self:isMode('bounce','rewind') then
				--If we are bouncing and we are NOT done or if we are rewinding then continue
				self.curFrame=self:getSize()
				self.direction=-1
			elseif self:getMode()=='loop' then
				--If we are looping in the obverse direction and we are done then stop
				--Regardless of whether we are done reset the current frame back to 1
				if self.direction==1 then
					self.curFrame=1
					if self.mode[2]>0 and self.curTimes>=self.mode[2] then return self:stop() end
				end
			else
				--I think I was drunk when I wrote this section but I'm letting it be
				--just in case I wasn't drunk!
				if self.mode[2]>0 and self.curTimes>=self.mode[2] then
					return self:stop()
				else
					self.curFrame=self:getSize()
					self:cycle()
				end
			end

		elseif self.curFrame<1 then
			self.curFrame=1
			
			if self:getMode()=='bounce' then
				self:cycle()
			end
			if self:isMode('bounce','rewind') then
				if self.mode[2]>0 and self.curTimes>=self.mode[2] then self:stop()
				else
					self.direction=1
				end
			elseif self:getMode()=='loop' then
				if self.mode[2]>0 and self.curTimes>=self.mode[2] then self:stop()
				else
					self:cycle()
					if self.mode[2]>0 and self.curTimes==self.mode[2] then return self:stop() end
					self.curFrame=self:getSize()
				end
			else
				self:stop()
			end
		end
		self.curFrame=math.max(1,self.curFrame)
	end
end

--Whether to flip horizontally and/or vertically
function Animation:flip(flipX,flipY)
	self.p_flipX,self.p_flipY=flipX,flipY
	return self
end

--Specifically flip only along one axis!
function Animation:flipX(b) return self:flip(b) end
function Animation:flipY(b) return self:flip(nil,b) end

function Animation:render(x,y,r,sx,sy,ox,oy,...)
	sx,sy=sx or 1, sy or 1
	sx=self.p_flipX and -sx or sx
	sy=self.p_flipY and -sy or sy
	love.graphics.draw(
		self:getTexture(),self:getCurrentQuad(),
		x,y,r,sx,sy,ox,oy,...
	)
end

--This function is not defined here but on the main library file!
Animation.exportToXML=nil

--Just setting some aliases- kinda my speciality

Animation.getTexture=Animation.getAtlas
Animation.getImage=Animation.getAtlas
Animation.getSource=Animation.getAtlas
Animation.setTexture=Animation.setAtlas
Animation.setSource=Animation.setAtlas
Animation.setImage=Animation.setAtlas
Animation.getTotalFrames=Animation.getTimes
Animation.draw=Animation.render
Animation.goToFrame=Animation.jumpToFrame
Animation.setFrame=Animation.jumpToFrame
Animation.getActive=Animation.isActive
Animation.onAnimationStart=Animation.onAnimStart
Animation.onAnimationOver=Animation.onAnimOver
Animation.onAnimationRestart=Animation.onAnimRestart
Animation.onFrameChange=Animation.onChange
Animation.onTick=Animation.onUpdate

return Animation
