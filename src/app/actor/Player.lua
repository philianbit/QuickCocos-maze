Player=class("Player", function ()
	-- body
	return display.newSprite("images/print_still.png")
end)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local BackgroundLayer=require("app.layers.BackgroundLayer")

WALK_PACE=25
-- WALK_PACE=50
MOVE=100
ANI=101

function Player:ctor()
	-- self.setPosition(display.cx,display.bottom-100)
	self.firstWalk=true
	self.getBlock=false
	self.Moveaction=nil
	self.Aniaction=nil
	self.m_handler=nil
	self.feetSprites={left=display.newSprite("images/print_walk1.png"),right=display.newSprite("images/print_walk2.png")}
	self:addAniamtionCache()
	
end

function Player:startWalk(keyPressed)
	--播放走路音效
	self.printSound=audio.playSound("sound/print.wav", true)
	-- print("walk")
	local function move(dt)
		
		-- transition.playAnimationOnce(self, display.getAnimationCache("pd"))
		if self.dir=="up" then
			self.Moveaction = transition.moveBy(self, {time = 0.2, x = 0, y = WALK_PACE})
			-- transition.execute(self,cc.MoveBy:create(0.2,cc.p(0,WALK_PACE)))
			-- print(self.dir)
			elseif self.dir=="down" then
				self.Moveaction = transition.moveBy(self, {time = 0.2, x = 0, y = -WALK_PACE})
				-- self.Moveaction=transition.execute(self,cc.MoveBy:create(0.2,cc.p(0,-WALK_PACE)))
				-- print(self.dir)
				elseif self.dir=="left" then
					self.Moveaction = transition.moveBy(self, {time = 0.2, x = -WALK_PACE, y = 0})
					-- self.Moveaction=transition.execute(self,cc.MoveBy:create(0.2,cc.p(-WALK_PACE,0)))
					-- print(self.dir)
					elseif self.dir== "right" then
						self.Moveaction = transition.moveBy(self, {time = 0.2, x = WALK_PACE, y = 0})
						-- self.Moveaction=transition.execute(self,cc.MoveBy:create(0.2,cc.p(WALK_PACE,0)))
						-- print(self.dir)
		end
		self.Moveaction:setTag(MOVE)
	end
	--上
	if keyPressed==UP then
		-- if not self.firstWalk then
		-- 	transition.resumeTarget(self)
		-- else
			self.Aniaction=transition.playAnimationForever(self, display.getAnimationCache("pd"))
			self.Aniaction:setTag(ANI)
			-- self.firstWalk=false
		-- end
		transition.rotateTo(self,{rotate=0,time=0.1}) 
		transition.execute(self,cc.MoveBy:create(0.2,cc.p(0,WALK_PACE)))
		self.dir="up"
		if self.m_handler then
			-- print("self.m_handler重置")
			scheduler.unscheduleGlobal(self.m_handler)
			self.m_handler=nil
		end
			self.m_handler=scheduler.scheduleGlobal(move, 0.3)		
		
	
	--下
	elseif keyPressed==DOWN then
		-- if not self.firstWalk then
		-- 	transition.resumeTarget(self)
		-- else
			self.Aniaction=transition.playAnimationForever(self, display.getAnimationCache("pd"))
			self.Aniaction:setTag(ANI)
			-- self:runAction(self.Aniaction)
			-- self.firstWalk=false
		-- end
		transition.rotateTo(self,{rotate=180,time=0.1})		
		transition.execute(self,cc.MoveBy:create(0.2,cc.p(0,-WALK_PACE)))
		self.dir="down"
		if self.m_handler then
			-- print("self.m_handler重置")
			scheduler.unscheduleGlobal(self.m_handler)
			self.m_handler=nil
		end
		self.m_handler=scheduler.scheduleGlobal(move, 0.3)		
	
	--左
	elseif keyPressed==LEFT then 
		-- if not self.firstWalk then
		-- 	transition.resumeTarget(self)
		-- else
			self.Aniaction=transition.playAnimationForever(self, display.getAnimationCache("pd"))
			self.Aniaction:setTag(ANI)
			-- self:runAction(self.Aniaction)
			-- self.firstWalk=false
		-- end
		transition.rotateTo(self,{rotate=-90,time=0.1})		
		transition.execute(self,cc.MoveBy:create(0.2,cc.p(-WALK_PACE,0)))
		self.dir="left"
		if self.m_handler then
			-- print("self.m_handler重置")
			scheduler.unscheduleGlobal(self.m_handler)
			self.m_handler=nil
		end
		self.m_handler=scheduler.scheduleGlobal(move, 0.3)		
	
	--右
	elseif keyPressed==RIGHT then
		-- if not self.firstWalk then
		-- 	transition.resumeTarget(self)
		-- else
			self.Aniaction=transition.playAnimationForever(self, display.getAnimationCache("pd"))
			self.Aniaction:setTag(ANI)
			-- self.firstWalk=false
		-- end
		transition.rotateTo(self,{rotate=90,time=0.1})		
		transition.execute(self,cc.MoveBy:create(0.2,cc.p(WALK_PACE,0)))
		self.dir="right"
		if self.m_handler then
			-- print("self.m_handler重置")
			scheduler.unscheduleGlobal(self.m_handler)
			self.m_handler=nil
		end
		self.m_handler=scheduler.scheduleGlobal(move, 0.3)		
	end

end

function Player:stopWalk()
	--停止播放脚步声音效
	audio.stopSound(self.printSound)
	if self.m_handler then
		-- print("unscheduleGlobal")
		scheduler.unscheduleGlobal(self.m_handler)
		self.m_handler=nil
	end
	-- transition.stopTarget(self)
	self:stopActionByTag(MOVE)
	self:stopActionByTag(ANI)
	transition.removeAction(self.Moveaction)
	self:setSpriteFrame("print_still.png")
end


function Player:addAniamtionCache()
	display.addSpriteFrames("images/walk.plist","images/walk.png")
	-- local sprite=display.newSprite("images/1.jpg")
	local frames=display.newFrames("print_walk%d.png",1,2)
	local animation=display.newAnimation(frames,0.5)
	-- animation:setDelayPerUnit(0.2)
	-- animation:setRestoreOriginalFrame(true) 
	display.setAnimationCache("pd",animation)
end

function Player:playAnime()
	-- transition.stopTarget(self)
	-- transition.playAnimationForever(self, display.getAnimationCache("pd"))
end

return Player