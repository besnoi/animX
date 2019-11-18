--[[
	The Actor Class for animX
	Author: Neer
]]

local Actor={
	animations,        --list of all the animations in the actor
	current,           --the current animation (by it's name)
	p_onAnimSwitch,    --handler called when an animation is switched [internal]
}

--an internal function which just sets the default values
function Actor:init()
	self.animations={}
	self.p_onAnimSwitch=function() end
end

function Actor:switch(newState)
	local prevState=self.current
	if prevState==newState then return self end
	--This prevents a recursive situation!!
	if self:isActive() then self:stopAnimation() end
	self.current=newState
	self:p_onAnimSwitch(prevState)
	self:startAnimation()
	return self
end

--Checks if the current animation of the actor is stopped
function Actor:isActive()
	if not self:getCurrentAnimation() then return false end
	return self:getCurrentAnimation():isActive()
end

--Stops the actor's animation
function Actor:stopAnimation()
	if self:getCurrentAnimation() then
		self:getCurrentAnimation():stop()
	end
	return self
end

--Starts the animation for the actor
function Actor:startAnimation()
	if self:getCurrentAnimation() then
		self:getCurrentAnimation():start()
	end
	return self
end

--These functions is defined in the main file
Actor.addAnimation=nil
Actor.exportToXML=nil

--Not to be confused with p_onAnimSwitch!
function Actor:onSwitch(fn)
	self.p_onAnimSwitch=fn
	return self
end

--Returns the given or current animation if given arg is nil
function Actor:getAnimation(name)
	return self.animations[name or self.current]
end

--Returns the current animation that's being rendered
function Actor:getCurrentAnimation()
	return self:getAnimation(self.current)
end

--Gets a table of all the states
function Actor:getStates()
	local t={}
	for i in pairs(self.animations) do
		t[#t+1]=i
	end
	return t
end

--Loops all the animations in the actor
function Actor:loopAll(...)
	for i in pairs(self.animations) do
		self.animations[i]:loop(...)
	end
	return self
end

--Returns the name of the current animation
function Actor:getName() return self.current end

--Returns the size of the current animation
function Actor:getDimensions() return self:getCurrentAnimation():getDimensions() end
function Actor:getWidth() return self:getCurrentAnimation():getWidth() end
function Actor:getHeight() return self:getCurrentAnimation():getHeight() end

--Sets the style of the image
function Actor:setStyle(val) self:getCurrentAnimation():setStyle(val) return self end 

--Flips the current animation
function Actor:flip(...) self:getCurrentAnimation():flip(...) return self end
function Actor:flipX(...) self:getCurrentAnimation():flipX(...) return self end
function Actor:flipY(...) self:getCurrentAnimation():flipY(...) return self end

function Actor:render(...)
	self:getCurrentAnimation():render(...)
end

--==Aliases==--

Actor.getCurrentAnim=Actor.getCurrentAnimation
Actor.getState=Actor.getName
Actor.changeAnim=Actor.switch
Actor.set=Actor.switch
Actor.draw=Actor.render

return Actor