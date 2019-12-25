local animx={
	animObjs={}       --the animation objects that were created
}

local LIB_PATH=...

local function lastIndexOf(str,char)
	for i=str:len(),1,-1 do if str:sub(i,i)==char then return i end end
end

local function fileExists(url)
	return love.filesystem.getInfo(url) and
	       love.filesystem.getInfo(url).type=="file"
end

local imgCache = {}

local function newImage(path)
	if not imgCache[path] then
        imgCache[path] = love.graphics.newImage(path)
    end
    return imgCache[path]
end

--Borrowed from [euler](https://github.com/YoungNeer/euler)
function round(value,precision)
	local temp = 10^(precision or 0)	
	if value >= 0 then 
		return math.floor(value * temp + 0.5) / temp
	else 
		return math.ceil(value * temp - 0.5) / temp 
	end
end

--removes the path and only gets the filename
local function removePath(filename)
	local pos=1
	local i = string.find(filename,'[\\/]', pos)
	pos=i
	while i do
		i = string.find(filename,'[\\/]', pos)
		if i then
			pos = i + 1
		else i=pos break
		end
	end
	if i then filename=filename:sub(i) end
	return filename
end

--remove extension from a file as well as remove the path
local function removeExtension(filename,dontremovepath)
	if not dontremovepath then filename=removePath(filename) end
	return filename:sub(1,lastIndexOf(filename,".")-1)
end

local Animation=require (LIB_PATH..'.animation')
local Actor=require (LIB_PATH..'.actor')

--[[
	Creates a new animation either from scratch or from an XML file!
	(Note that quads are added in LtR-TtB fashion)
	@Params:
		@OverLoad-1:
		img    -  The URL of the image. An XML file must exist by the same name!

		@OverLoad-2:
		params -  A table of parameters (something I stole from sodapop)
			img           -  The image (could be a reference or url)
			x,y           -  The offset from where to start extracting the quads (0,0)
			qw,qh         -  The dimensions of the quad
			sw,sh         -  The dimensions of the image (auto-calc'd if nil)
			spr           -  The number of sprites per row
			nq            -  The number of quads to extract (auto-calc'd if nil)
			quads         -  An already existing table of quads for animation
			frames        -  The frames (by number) that u wanna add in the animation
			style         -  The style of the image (just something I stole from katsudo)
			startingFrame -  The frame from where to start the animation (must exist!)
			startFrom     -  The frame from where to start ripping the sprites
			delay         -  The interval between any two frames
			onAnimOver    -  What happens when the animation is over
			onAnimStart -  What happens when the animation is started
			onAnimRestart -  What happens when the animation is restarted
			onCycleOver   -  What happens when one cycle is over
			onChange      -  What happens at every animation frame change
			onUpdate      -  What happens at every frame
	@Returns
		An Animation Instance
--]]
function animx.newAnimation(params)

	local img,quads,sw,sh,startingFrame,delay
	local onAnimStart,onAnimRestart,onAnimOver,onCycleOver,onChange,onUpdate

	if type(params)=='string' then
		--Overload 1
		img=(params)
		sw,sh=img:getDimensions()
		quads=animx.newAnimationXML(img,removeExtension(params,true)..'.xml')
		startingFrame,delay=1,.1
	else
		--Overload 2
		img=params.img or params.source or params.image or params.texture or params.atlas or params.spritesheet
		assert(img,"animX Error: Expected Image or URI in `newAnimation`!")
		img = type(img)=='string' and newImage(img) or img

		sw=params.sw or params.imgWidth or params.textureWidth or img:getWidth()
		sh=params.sh or params.imgHeight or params.textureHeight or img:getHeight()
		local x,y=params.x or params.offsetX or 0, params.y or params.y or params.offsetY or 0

		local nq=params.nq or params.images or params.noOfTiles or params.numberOfQuads or params.noOfQuads or params.noOfFrames

		--The tile-height will by default be the height of the image!
		local qw=params.qw or params.quadWidth or params.frameWidth or params.tileWidth
		local qh=params.qh or params.quadHeight or params.frameHeight or params.tileHeight
		local frames=params.frames or {}
		local spr=params.spr or params.spritesPerRow or params.tilesPerRow or params.quadsPerRow
		quads=params.quads or {}

		if spr and nq then
			assert(nq>=spr,"animX Error: No of sprites per row can't be less than total number of quads!!!")
		end

		--[[
			User has to give atleast one of quad-width and
			number of sprites per row to calculate no of quads
		]]--

		--if user has not given sprites per row then let qh simply be image height
		if not spr then 
			qh=qh or img:getHeight()
		else
			if not qh then
				assert(nq,"animX Error: You have to give number of quads in this case!!!")
			end
			qh=qh or img:getHeight()/(nq/spr)
		end

		if qw then
			if #frames>0 then
				--If user has given us a bunch of frames then we set this to zero if nil
				nq=nq or 0
			else
				--Otherwise we make the number of quads equal to the max no of quads
				nq = math.min(nq or math.huge, math.floor(sw/qw) * math.floor(sh/qh))
			end
		elseif spr then
			--If user has given us number of sprites per row
			nq=math.min(nq or math.huge,spr*math.floor(sh/qh))
		elseif #quads>0 then
			--If user has given us some quads to work with - we set this to zero if nil
			nq=nq or 0
		end
		
		spr = spr or nq

		--If user has not given anything dissecting then make the image a quad!
		if not qw and not spr then
			spr,nq=1,1
			qw,qh=img:getWidth(),img:getHeight()
		end

		if #quads==0 or not nq then
			if #frames==0 then
				assert(spr and spr>0,"animX Error: Sprites per row can't be zero!!")
			else
				assert(qw,"animX Error: You must give tileWidth in this case")
			end
		end

		--If user has not given the tileWidth then calculate it based on number of sprites per row
		if nq>0 and spr then
			qw=qw or img:getWidth()/spr
		end

		assert(
			qw~=1/0,
			'animX Error: Oops! Something bad happened! Please do report the error!'
		)

		local style=params.style
		if style=='rough' then img:setFilter('nearest','nearest') end

		local startPoint=params.startFrom or params.startPoint
		delay=params.delay or params.interval or .1
		startingFrame=params.startingFrame or 1
		onAnimOver=params.onAnimOver or params.onAnimEnd or params.onAnimationOver or params.onAnimationEnd
		onAnimStart=params.onAnimStart or params.onAnimationStart
		onAnimRestart=params.onAnimRestart or params.onAnimationRestart
		onChange=params.onChange or params.onFrameChange
		onUpdate=params.onUpdate or params.onTick
		onCycleOver=params.onCycleOver or params.onCycleEnd

		--We need the quad dimensions if user has not given us a bunch of quads
		if #quads==0 then
			assert(qw and qh,"animX Error: Quad dimensions coudn't be calculated in `newAnimation`!")
			--IMPORTANT: We want integers not highly precise floats or doubles
			qw,qh=round(qw),round(qh)
		end		

		--Calculate offset from the startpoint
		if startPoint then
			x=((startPoint-1)*qw)%sw
			y=qh*math.floor(((startPoint-1)*qw)/sw)
		end

		--Add given frames to the quads table
		for i=1,#frames do
			quads[#quads+1]=love.graphics.newQuad(
				((frames[i]-1)*qw)%sw,
				qh*math.floor(((frames[i]-1)*qw)/sw),
				qw,qh,sw,sh
			)
		end

		local offsetx=x

		assert(nq,"animX Error!! Number of quads couldn't be calculated!")

		for i = 1, nq do
			if x >= sw then
				y = y + qh
				x = offsetx
			end
			quads[#quads+1]= love.graphics.newQuad(x, y, qw, qh, sw, sh)
			x = x + qw
		end
	end

	local animation_obj={
		['texture']=img,
		['frames']=quads
	}
	table.insert(animx.animObjs,setmetatable(animation_obj,{__index=Animation}))	
	animation_obj:onAnimStart(onAnimStart):init(startingFrame,delay)
	animation_obj
		:onAnimOver(onAnimOver)
		:onAnimRestart(onAnimRestart)
		:onChange(onChange)
		:onCycleOver(onCycleOver)
		:onUpdate(onUpdate)
	
	return animx.animObjs[#animx.animObjs]
end

--[[:-
	Creates a new Actor either from scratch or from an XML file
	@params:
		@Overload-1
			Takes no parameters. Returns an empty actor
		@Overload-2
			metafile:
				A string referring to the URL of the XML file containing
				the information about all the animations for the actor
				(you could ofcourse add animations later on if you want)
				If this is nil then an empty actor (without animations) is created
		@Overload-3
			{...}: A list of all the animations
	@returns:
		An Actor instance
-:]]
function animx.newActor(arg)
	local actor={}
	setmetatable(actor,{__index=Actor}):init()
	if type(arg)=='string' then
		--User gave us a link to the XML file
		local img=newImage(arg)
		local anims=animx.newActorXML(img,removeExtension(arg,true)..'.xml')
		for i in pairs(anims) do
			actor:addAnimation(i,{
				['img']=img,
				['quads']=anims[i]
			})
		end
		return actor
	else
		if arg then
			--User gave us a table of animations for the actor
			for name,anim in pairs(arg) do
				actor:addAnimation(name,anim)
			end
		end
		--[[
			Otherwise User gave us nothing
		    - meaning empty actor has to be created
		]]
	end
	return actor
end

--[[
	Adds an animation to the actor
	@Params
		name - The name of the animation
		@Overload-1
			anim - An animation instance
		@Overload-2
			anim - A to-be-created animation instance
	@Returns
		The actor itself
]]--
function Actor:addAnimation(name,anim)
	if anim.cache and anim.direction then 
		--User provided an already created animation
		self.animations[name]=anim
	else
		--User provided a to-be-created animation
		self.animations[name]=animx.newAnimation(anim)
	end
	return self
end

--[[
	Creates a new animation from XML file!
	You'll most of the time use newAnimation to indirectly call this fn!
	@Params:-
		image - The Image for the animation
	@Returns:-
		An array of quads denoting the animation
]]--
function animx.newAnimationXML(image,filename)
	local i,t,sw,sh=1,{},image:getDimensions()
	for line in love.filesystem.lines(filename) do
		if i>1 and line:match('%a') and not line:match('<!') and line~="</TextureAtlas>" then
			local _, frameNo = string.match(line, "name=([\"'])(.-)%1")
			frameNo=tonumber(frameNo)
			--Frames must start from 1!
			if not frameNo or frameNo<=0 then goto continue end

			assert(not t[frameNo],
				"animX Error!! Duplicate Frames found for ("..frameNo..") for "..filename
			)
			local _, x = string.match(line, "x=([\"'])(.-)%1")
			local _, y = string.match(line, "y=([\"'])(.-)%1")
			local _, width = string.match(line, "width=([\"'])(.-)%1")
			local _, height = string.match(line, "height=([\"'])(.-)%1")
			
			t[frameNo]=love.graphics.newQuad(x,y,width,height,sw,sh)
			::continue::
		end
		i=i+1
	end
	return t
end

--[[
	Creates a new actor from XML file!
	You'll most of the time use newActor to indirectly call this fn!
	@Params:-
		image - The Image for the animation
	@Returns:-
		A table/linkhash of quads indexed by the animation name and then the frame number
]]--
function animx.newActorXML(image,filename)
	local i,t,sw,sh=1,{},image:getDimensions()
	for line in love.filesystem.lines(filename) do
		if i>1 and line:match('%a') and not line:match('<!') and line~="</TextureAtlas>" then
			local _, frameNo = string.match(line, "name=([\"'])(.-)%1")
			local animName=frameNo:match('[%a ]+')
			frameNo=tonumber(frameNo:match('%d+'))
			--Frames must exist and must start from 1! Also animation name must be present
			if not animName or not frameNo or frameNo<=0 then goto continue end

			if not t[animName] then t[animName]={} end
			assert(not t[animName][frameNo],
				"animX Error!! Duplicate Frames found for ("..frameNo..") for "..filename
			)
			local _, x = string.match(line, "x=([\"'])(.-)%1")
			local _, y = string.match(line, "y=([\"'])(.-)%1")
			local _, width = string.match(line, "width=([\"'])(.-)%1")
			local _, height = string.match(line, "height=([\"'])(.-)%1")
			
			t[animName][frameNo]=love.graphics.newQuad(x,y,width,height,sw,sh)
			::continue::
		end
		i=i+1
	end
	return t
end

--[[
	Exports an animation (instance) to XML!
	@Params:
		filename: By what name should the animation be exported
	@Returns:-
		Whether or not animX was successful in exporting
]]
function Animation:exportToXML(filename)
	filename=removePath(filename)
	if fileExists(filename) then
		if not animx.hideWarnings then 
			error(string.format("animX Warning! File '%s' Already Exists!",filename))
		end
	end
	local outfile=io.open(filename,'w')
	if not outfile then
		if animx.hideWarnings then
			return false
		else
			error("animx Error! Something's wrong with the io")
		end
	end
	local sname,x,y,width,height

	outfile:write(string.format('<TextureAtlas imageName="%s">\n',removeExtension(filename)))
	for i=1,#self.frames do
		x,y,width,height=self.frames[i]:getViewport()
		outfile:write(
			string.format('\t<SubTexture name="%i" x="%i" y="%i" width="%i" height="%i"/>\n',
				i,x,y,width,height
			)
		)
	end
	outfile:write("</TextureAtlas>")
	return outfile:close()
end

--[[
	Exports an actor (all the animations associated with it) to XML!
	@Params:
		filename: By what name should the actor be exported
	@Returns:-
		Whether or not animx was successful in exporting
]]
function Actor:exportToXML(filename)
	filename=removePath(filename)
	if fileExists(filename) then
		if not animx.hideWarnings then 
			error(string.format("animX Warning! File '%s' Already Exists!",filename))
		end
	end
	local outfile=io.open(filename,'w')
	if not outfile then
		if animx.hideWarnings then
			return false
		else
			error("animx Error! Something's wrong with the io")
		end
	end
	local sname,x,y,width,height

	outfile:write(string.format('<TextureAtlas imageName="%s">\n',removeExtension(filename)))
	for anim in pairs(self.animations) do
		for i=1,#self.animations[anim].frames do
			x,y,width,height=self.animations[anim].frames[i]:getViewport()
			outfile:write(
				string.format('\t<SubTexture name="%s" x="%i" y="%i" width="%i" height="%i"/>\n',
					anim..i,x,y,width,height
				)
			)
		end
	end
	outfile:write("</TextureAtlas>")
	return outfile:close()
end

--Updates all the animation objects at once so you won't see them in your code
function animx.update(dt)
	for i=1,#animx.animObjs do
		animx.animObjs[i]:update(dt)
	end
end

love.update=function(dt) animx.update(dt) end
animx.newAnimatedSprite=animx.newActor

return animx

