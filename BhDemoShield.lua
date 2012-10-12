--[[ 
BhDemoShield.lua

A demo overlay that shows a hand image to indicate where a user touches the screen. 
Useful for recording demos.

Simply add this file to your project.
 
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

BhDemoShield=BhDemoShield or Core.class(Sprite)

local FINGER_ENTRY_TIME=0.3
local FINGER_EXIT_TIME=0.8
local FINGER_SCALE=0.6

function BhDemoShield:init(scale)
	-- Ensure we are a singleton. Dispose of any previous instance.
	if BhDemoShield.sharedInstance then
		BhDemoShield.sharedInstance:removeFromParent()
	end
	BhDemoShield.sharedInstance=self
	stage:addChild(self)
	
	self.scale=scale or FINGER_SCALE	
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
	self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
	self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
	self:addEventListener(Event.TOUCHES_CANCEL, self.onTouchesCancel, self)
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	
	self.rhandup=Texture.new(pathto("Images/HandFingerUp.png"))
	self.rhanddn=Texture.new(pathto("Images/HandFingerDn.png"))
	self.fingers={}
end

function BhDemoShield:getRestingPosition(index)
	local x, y=application:getContentWidth()*1.1, application:getContentHeight()*1.1
	if index>1 then
		x=0
	end
	return x, y
end

function BhDemoShield:getArmRotation(x)
	-- Choose a rotation that is dependent on the x value to make it look as if
	-- the arm is pivoting.
	return (x-application:getContentWidth())/application:getContentWidth()*20+10
end

function BhDemoShield:addHandFinger(index, x, y)
	local finger=self.fingers[index]
	if not(finger) then
		-- If the finger doesn't yet exist
		finger=Sprite.new()
		finger.up=Bitmap.new(self.rhandup)
		finger.dn=Bitmap.new(self.rhanddn)
		
		-- Tune the following so that the finger points to the correct location
		-- when up and down.
		finger.up:setAnchorPoint(0.08, 0.07)
		finger.dn:setAnchorPoint(0.08, 0.07)
		
		finger:addChild(finger.up)
		finger:addChild(finger.dn)
		finger.dn:setAlpha(0)		
		self.fingers[index]=finger
		
		finger:setScale(self.scale)
		if index>1 then
			-- Create a pseudo left hand
			finger:setScaleX(-self.scale)	
		end
		finger:setPosition(self:getRestingPosition(index))
	end
	
	if finger.tween then 
		-- If finger is already on the way in or out then cancel and redirect
		finger.tween:setPaused(true)
	end

	local rotation=self:getArmRotation(x)		
	finger.up:setAlpha(1)
	finger.dn:setAlpha(0)
	local dnTween1=GTween.new(finger.up, 0.01, {alpha=0}, {autoPlay=false})
	local dnTween2=GTween.new(finger.dn, 0.01, {alpha=1}, {autoPlay=false, nextTween=dnTween1})
	finger.tween=GTween.new(finger, FINGER_ENTRY_TIME, {x=x, y=y, rotation=rotation}, {ease=easing.inOutCubic, nextTween=dnTween2})

	self:addChild(finger)
	return finger
end

function BhDemoShield:removeHandFinger(index)
	local finger=self.fingers[index]

	local exitX, exitY=self:getRestingPosition(index)
	if finger.tween then 
		-- If finger is on the way in or out then immediately do it
		finger.tween:toEnd()
	end

	finger.up:setAlpha(1)
	finger.dn:setAlpha(0)
	local upTween1=GTween.new(finger.up, 0.01, {alpha=1}, {autoPlay=false})
	local upTween2=GTween.new(finger.dn, 0.01, {alpha=0}, {autoPlay=false, nextTween=upTween1})
	finger.tween=GTween.new(finger, FINGER_EXIT_TIME, {x=exitX, y=exitY, rotation=0}, {ease=easing.inOutCubic, nextTween=upTween2})
	
--	self.fingers[index]=nil 
end

function BhDemoShield:onEnterFrame(event)
	-- Ensure that we are always at the top of the zOrder
	stage:addChild(BhDemoShield.sharedInstance)
end

function BhDemoShield:onMouseDown(event)
	-- Fake a touch event with id 0, this allows buttons to work in the simulator
	-- that doesn't normally understand touch events.	
	event.touch={ x=event.x, y=event.y, id=0}
	self:onTouchesBegin(event)	
end

function BhDemoShield:onMouseMove(event)
	-- Fake a touch event with id 0, this allows buttons to work in the simulator
	-- that doesn't normally understand touch events.	
	event.touch={ x=event.x, y=event.y, id=0}
	self:onTouchesMove(event)	
end

function BhDemoShield:onMouseUp(event)
	-- Fake a touch event with id 0, this allows buttons to work in the simulator
	-- that doesn't normally understand touch events.	
	event.touch={ x=event.x, y=event.y, id=0}
	self:onTouchesEnd(event)	
end

function BhDemoShield:onTouchesBegin(event)
	-- Ignore touch event 1 since this will already have been handled by mouse down (id=0)
	if event.touch.id~=1 then
		local id=event.touch.id
		if id==0 then id=1 end
		self:addHandFinger(id, event.touch.x, event.touch.y)
	end
end

function BhDemoShield:onTouchesMove(event)
	if event.touch.id~=1 then
			local id=event.touch.id
		if id==0 then id=1 end
		local finger=self.fingers[id]
		if finger.tween then
			finger.tween:toEnd()
		end
		finger:setPosition(event.touch.x, event.touch.y)
		finger:setRotation(self:getArmRotation(event.touch.x))	
	end
end

function BhDemoShield:onTouchesEnd(event)
	if event.touch.id~=1 then
		local id=event.touch.id
		if id==0 then id=1 end	
		self:removeHandFinger(id)
	end
end

function BhDemoShield:onTouchesCancel(event)
end

BhDemoShield.new()
