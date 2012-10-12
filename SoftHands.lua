--[[ 
SoftHands.lua

A silly demonstration of the BhDemoShield in action.
 
MIT License
Copyright (C) 2012. Andy Bower, Bowerhaus LLP

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

require "box2d"

SoftHands=Core.class(Sprite)

function SoftHands:addBottle(name, x)
	local bottle=Bitmap.new(name)
	bottle:setScale(0.45)
	self.world:createRectangle(bottle, {type="dynamic", draggable=true, resitution=0.5})
	bottle:setPosition(x, application:getContentHeight()-bottle:getHeight()/2)
	self:addChild(bottle)
end

function SoftHands:init()
	local w, h=application:getContentWidth(), application:getContentHeight()

	local bg=Bitmap.new("Images/Bg.png")
	bg:setAnchorPoint(0.5, 0.5)
	bg:setScale(0.5)
	bg:setPosition(w/2, h/2)
	self:addChild(bg)

	self.world=b2.World.new(0, 10, true)
	self.edge=self.world:createTerrain(nil, { 0, 0, w, 0, w, h, 0, h, 0, 0 })

	self:addBottle("Images/Fairy1.png", 70)
	self:addBottle("Images/Fairy2.png", w/2)
	self:addBottle("Images/Fairy3.png", w-70)

	stage:addEventListener(Event.ENTER_FRAME, function() self.world:update() end)
	stage:addChild(self)
end

SoftHands.new()