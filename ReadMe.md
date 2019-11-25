# animX

*Animation in Love2d has never been so easy!!* Now I hate to look like a soap salesman... but animX has [all the features](#features-of-animx) you'd expect from an animation library plus some extra features of its own! I suggest you head over to [A quick walkthrough](#a-quick-walkthrough) if you are short on time!

## What animX is about?

animX is all about handling animations in a manner that makes your code much more declarative, much more readable, and much more shorter.

## Features of animX:
-------------------------

- Has special Animation instances with animation modes like `loop`, `bounce`, `rewind`, etc!
- Supports different delays for individual frames just like Bart's library but without consuming too much memory
- Allows loading animations and animation instances from a metafile
- Has special Animated Sprites aka *Actors* to handle animations (execution, transitions, etc) by their name
- Allows loading group of animations and all animations for an *actor* from a metafile
- Supports callback functions like `onSwitch`, `onFrameChange`,`onAnimOver`,`onCycleOver`,etc just like [Walt](https://github.com/davisdude/Walt)
- Allows creating animation from single as well as multiple images (for *Actors* I mean)
- Has a very comfortable animation extraction system supporting numerous algorithms **\***
- After extracting animations you can export them to XML (again as a single entity or as group of animations)
- Also supports animation's source styles like `rough`, `smooth` (just like Katsudo)
- Has a number of aliases to make you feel it's *your* library and *you* wrote it!

> **\*** In case you don't have metafiles to work with!

------------------------------------------
**Note:** For metafile, only XML data-format is supported (as of now). But I'll be happy to write for JSON (and other formats) if some-one really wants me to!


## A Quick Walkthrough

Working with symmetric spritesheets is a *hell* lot easier with animX. Let's say we have this spritesheet:-
<p align='center'>
<img src='Examples/Exporting%20Animation/glitch_crab.png' title="The SpriteSheet for crab animation (Credit- Glitch)"><br/>
</p>

There are 6 sprites per row and a total of 24 images!! So you do just this:-

```lua
anim=animx.newAnimation{
	img='glitch_crab.png',   --url/reference to the image
	spritesPerRow=6,
	noOfFrames=24
}:loop()
```
And that's it! You loaded 24 quads in just four lines! (The last line only loops the animation which ofcourse is not necessary!)

> But what about huge non-symmetric spritesheets?

Let's say we have this spritesheet by Kenney and we want to animate this in Love2D (Note this spritesheet is unsymmetric with alternating width and height for each frame)

<p align='center'>
<img src='Examples/Importing%20Animation%20from%20XML%20to%20Actor/kenney_asset.png' title="The SpriteSheet for walking animation (Credit- Kenney)"><br/>
</p>

No probs. As long as you have an generic [XML metafile](Examples/Importing%20Animation%20from%20XML%20to%20Actor/walk_sheet.xml) describing the animation - this is a walk in the park - atleast with animX by your side:-

```lua
animx=require 'animx'

alien=animx.newAnimation('res/spritesheet.png')
--Note res/spritesheet.xml must be present!!

function love.draw()
	alien:draw()
end
```

But that was only for walking. What about jumping, swimming and all of these? Should one rely on multiple XML files for that? **No** To solve this problem animX has special *actors* which are nothing but animation holders and make switching between animations a lot easier

So to increase the bar let's say we have this image here with this difficult to parse [XML file](Examples/Side%20Scroller/res/spritesheet.xml) by the same name:

<p align='center'>
<img width=664 height=481 src='Examples/Side%20Scroller/res/spritesheet.png' title="The SpriteSheet for our actor. Sorry about bad packing at some places! (Credit- Segel)"><br/>
</p>

Since this image is symmetric we don't even need the metafile as demonstrated in [this example](Examples/Side%20Scroller/main2.lua) but since it's a good idea to keep data away from code here's how we do it with animX:-

```lua
animx=require 'animx'

samurai=animx.newActor('res/spritesheet.png'):switch('running')

function love.draw()
	--This will display our Samurai running at the center of the screen
	samurai:draw(400,300,0,1,1,samurai:getWidth()/2,samurai:getHeight()/2)
end
```

Note that we are not doing ```animx.update(dt)``` in ``love.update`` only because there's nothing else in ``love.update`` and animX overrides it by default making work a little easier for us in such cases (where all that `love.update` contains is `animx.update`)

There are also other stuff such texture styles, animation modes, animation handlers, etc which we didn't talk here. But I've dedicated a short tutorial for that over [here](Examples)


### Installing animX

Just drop the package (by the name `animx`) in a seperate folder and require it:-

```lua
animx=require 'animx
```

### Running Demos

animX comes with a lot of demos to get you started. These are available in the [demos](TODO) branch. You can run them with the latest (as of now) version of Love2D (11.3)

### Documentation

You can read the documentation over [here](https://github.com/YoungNeer/animX/wiki)
