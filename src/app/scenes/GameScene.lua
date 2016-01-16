--local Player=require("app.actor.Player")
local GameScene=class("GameScene",function()
		return display.newScene("GameScene")
	end)

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local MainScene=require("app.scenes.MainScene")

UP=28
DOWN=29
LEFT=26
RIGHT=27
ESC=6
PLAYER_HALFSIZE=20
PRINT_TAG=200




function GameScene:ctor(level)

	
	self:initParams()

	if not self:initMaze(level[1]) then
		do return end
	end
	self.player=Player.new()
	self:initPlayer()
	self:addChild(self.player)	

	self:initTarget()
	
	self:initScheduler()
	self:keyboardCallback()

	

	
	-- self.eventLayer=display.newLayer()
	-- self.eventLayer:addNodeEventListener(cc.KEYPAD_EVENT, handler(self, self.testKeyboard))
	-- self:addChild(self.eventLayer)
	-- self.eventLayer:setKeypadEnabled(true)
	
end


--初始化
function GameScene:initParams()
	self.time=0
	--被冻住的按键
	self.keyFrozen={}
	--正在被按的键
	self.keyPressing=-1
	--播放trap特效
	self.trapAni=false
	--是否是暂停状态
	self.pause=false
	self.backgroundLayer=nil
	self.pauseLayer=nil
	self.targetplace=nil
	self.gameover=false
	--死亡的地方
	-- self.diedPlace={}

end
--初始化player属性
function GameScene:initPlayer()
	self.player:setPosition(cc.p(self.backgroundLayer.blocksize/2-100,display.height-self.backgroundLayer.blocksize/2*3))
	self.player:setOpacity(0)
	self.player:setRotation(90)
	local fade=cc.FadeIn:create(1)
	self.player:runAction(fade)
end

function GameScene:initMaze(level)
	-- print("level:" ..level)
	if self.backgroundLayer then
		self:removeChild(self.backgroundLayer,true)
	end
	self.backgroundLayer=BackgroundLayer.new(level)
		:addTo(self)
	-- print(self.backgroundLayer.level)
	if not self.backgroundLayer then
		do return false end
	end

	return true
end

function GameScene:initTarget()
	local targetX=display.width-self.backgroundLayer.blocksize/2
	local targetY=self.backgroundLayer.blocksize/2*3
	local action1=cc.ScaleTo:create(4.0, 1.2, 1.2)
	local action2=cc.ScaleTo:create(3.0, 0.5, 0.5)	
	local seq=cc.RepeatForever:create(cc.Sequence:create({action1,action2}))
	self.targetplace=display.newSprite("images/target.png")
					 :pos(targetX,targetY)
					 :setScale(0.5)
					 :addTo(self)
	self.targetplace:runAction(seq)				 

end

function GameScene:addCountNumber()
	local time=math.ceil(self.time)
	self.min=9-math.floor(time/60)
	self.sec=60-math.mod(math.ceil(self.time),60)-1
	-- print("min" ..self.min .."sec" ..self.sec)
	if self.min<=0 and self.sec<=0 then
		-- print("failgame")
		self:failGame()
		do return end
	end
	local minStr=self.min ..""
	local secStr=self.sec ..""
	if self.min<10 then
		minStr="0" ..self.min
	end
	if self.sec<10 then
		secStr="0" ..self.sec
	end
	self.timeStr=minStr ..":" ..secStr
	if self.timelabel then
		self:removeChild(self.timelabel, true)
	end
	self.timelabel=display.newBMFontLabel({text=self.timeStr,font="images/Number.fnt",x=display.cx,y=display.cy})
	self:addChild(self.timelabel)

end

function GameScene:initScheduler()
	--player和block以及trap的包围盒碰撞检测
	local function checkCollision(dt)
		--如果游戏结束
		if self.gameover then
			self.overtime=self.overtime+dt
			if(self.overtime>4) then
				local level=self.backgroundLayer.level
				self:cleanup()
				app:enterScene("GameScene",{{level}},"FADE",1.0)
			end
			do return end
		end
		if self.pause then
			do return end
		end
		self.time=dt+self.time
		self:addCountNumber()
		-- print(math.ceil(self.time))
		self.keyFrozen={}
		local x,y=self.player:getPosition()
		if self.targetplace then
			local tx,ty=self.targetplace:getPosition()
			if math.abs(x-tx)<20 and math.abs(y-ty)<20 then
				-- print("reachTarget")			
				self:reachTarget()
			end
		end

		--检测是否出边界
		if x>=display.width-PLAYER_HALFSIZE or x<=PLAYER_HALFSIZE or y>=display.height-PLAYER_HALFSIZE or y<=PLAYER_HALFSIZE then
			-- print("出边界了")
			if x>=display.width-PLAYER_HALFSIZE then
				table.insert(self.keyFrozen,RIGHT)
				self.player:setPositionX(display.width-PLAYER_HALFSIZE)
			elseif x<=PLAYER_HALFSIZE then
				table.insert(self.keyFrozen,LEFT)
				self.player:setPositionX(PLAYER_HALFSIZE)
			end
			if y>=display.height-PLAYER_HALFSIZE then
				table.insert(self.keyFrozen,UP)
				self.player:setPositionY(display.height-PLAYER_HALFSIZE)
			elseif y<=PLAYER_HALFSIZE then
				table.insert(self.keyFrozen,DOWN)
				self.player:setPositionY(PLAYER_HALFSIZE)
			end
			--如果正在按键盘，则立刻停止行走
			--因为键盘按下过程中是没有相应事件的
			for i,v in ipairs(self.keyFrozen) do
				-- print("v=" ..v)
				if self.keyPressing==v then
					-- print("stop walk")
					self.player:stopWalk()
					self.keyPressing=-1
					break
				end
			end
			--
			-- do return end
		end

		--检测是否碰上block或trap
		-- print("player.x" ..x .."player.y" ..y)
		for i=1,self.backgroundLayer.tileNumber,1 do
			if math.abs(self.backgroundLayer.tileArr[i].x-x)<=self.backgroundLayer.blocksize/2+PLAYER_HALFSIZE and math.abs(self.backgroundLayer.tileArr[i].y-y)<=self.backgroundLayer.blocksize/2+PLAYER_HALFSIZE then 
				-- if  then
					if(self.backgroundLayer.tileArr[i].type==BLOCK) then
						-- print("block")
						self:collideBlock(x,y,self.backgroundLayer.tileArr[i].x,self.backgroundLayer.tileArr[i].y)
					end
					if(self.backgroundLayer.tileArr[i].type==TRAP) then
						-- self.trapAni=false
						-- print("trap")
						self:collideTrap()
					end
					-- print("collide")
				-- end
			else
				-- self.keyFrozen=-1
			end

		end
	end
	self.m_handler =  scheduler.scheduleUpdateGlobal(checkCollision)
end

function GameScene:reachTarget()
	--完成一关
	--存储已通过的关卡
	--如果当前关卡比已通过关卡大，则更新关卡
	local passLevel=cc.UserDefault:getInstance():getIntegerForKey("passLevel", 1)
	if passLevel<self.backgroundLayer.level then
		cc.UserDefault:getInstance():setIntegerForKey("passLevel", self.backgroundLayer.level)
	end
	--找到关卡对应的时间
	local timeKey="bestTime" ..self.backgroundLayer.level
	--获得上次的最佳时间
	local bestTime=cc.UserDefault:getInstance():getIntegerForKey(timeKey, 600)
	-- print("bestTime:" ..bestTime)
	--将本局所用时间取整
	local time=math.ceil(self.time)
	--如果比上次最佳时间用时少，则替换最佳时间 
	if bestTime>time then
		cc.UserDefault:getInstance():setIntegerForKey(timeKey, time)
		-- print("new bestTime:" ..time)
	end	
	
	if self.backgroundLayer.level<6 then
		-- print(cc.UserDefault:getInstance():getIntegerForKey("passLevel"))
		--清除数据载入新关卡
		scheduler.unscheduleGlobal(self.m_handler)
		self.backgroundLayer.level=self.backgroundLayer.level+1
		self:reloadLevel(self.backgroundLayer.level)
	--完成第六关
	else
		self:cleanup()
		app:enterScene("MainScene",nil,"FADE",1.0)	

	end

end

function GameScene:reloadLevel(newlevel)
	-- print("type" ..tolua.type(self.targetplace))	
	--移除所有的脚印
	while self:getChildByTag(PRINT_TAG) do
		self:removeChildByTag(PRINT_TAG, true)
	end
	
	self:removeChild(self.targetplace)
	self:removeChild(self.backgroundLayer)

	
	self:initParams()
	self:initMaze(newlevel)
	self:initPlayer()
	self:initTarget()
	
	self:initScheduler()
end


function GameScene:keyboardCallback()
	local function keyboardPressed(key,event)
		if key==ESC then
			if not self.pause then
				-- print("暂停")
				self:pauseGame()
			elseif self.pause then
				-- print("恢复")
				self:resumeGame()
			end
		elseif self.pause then
			do return end
		end

		--如果这个方向已经不能走了，则不响应按键
		for i,v in ipairs(self.keyFrozen) do
			-- print("v=" ..v)
			if key==v then
				do return end
			end
		end
		self.keyPressing=key
		-- print("self.keyPressing" ..self.keyPressing)
		self.player:startWalk(key)
	end
	local function keyboardReleased(key,event)
		-- print("release")
		self.keyPressing=-1
		self.player:stopWalk()
	end

	self.m_listener=cc.EventListenerKeyboard:create()
	--EVENT_KEYBOARD_PRESSED只在键盘被按下的一瞬间响应，因此需要额外的keyPressing记录键盘是否正在被按
	self.m_listener:registerScriptHandler(keyboardPressed,
		cc.Handler.EVENT_KEYBOARD_PRESSED)
	self.m_listener:registerScriptHandler(keyboardReleased,
		cc.Handler.EVENT_KEYBOARD_RELEASED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self)
end

function GameScene:collideBlock(playerX,playerY,blockX,blockY)
	self.keyFrozen={}
	--x差别大，说明是水平方向上的障碍物
	if math.abs(playerX-blockX)>math.abs(playerY-blockY) then
		--障碍在右方
		if playerX<blockX then
			-- print("障碍在右方")
			table.insert(self.keyFrozen,RIGHT)
		--障碍在左方
		else
			-- print("障碍在左方")
			table.insert(self.keyFrozen,LEFT)
		end
	--y差别大，说明是竖直方向上的障碍物
	else 
		--障碍在上方
		if playerY<blockY then
			-- print("障碍在上方")
			table.insert(self.keyFrozen,UP)
			
		--障碍在下方
		else
			-- print("障碍在下方")
			table.insert(self.keyFrozen,DOWN)
		end
	end

	--如果正在按键盘，则立刻停止行走
	for i,v in ipairs(self.keyFrozen) do
		-- print("v=" ..v)
		if self.keyPressing==v then
			-- print("stop walk")
			self.player:stopWalk()
			self.keyPressing=-1
			break
		end
	end
end

function GameScene:collideTrap()
	
	local function callbackFunc()
		-- cc.Node:create(self.backgroundLayer.blocksize/2,display.height-self.backgroundLayer.blocksize/2*3)
		self:initPlayer()
		--被冻住的按键
		self.keyFrozen={}
		--正在被按的键
		self.keyPressing=-1
		--播放trap特效
		self.trapAni=false
		--是否是暂停状态
		self.pause=false
	end

	if not self.trapAni then
		audio.playSound("sound/heavyprint.wav", false)
		self.player:stopWalk()
		self.keyPressing=-1
		self.trapAni=true
		--effects
		local scale1=cc.ScaleTo:create(0.2, 1.2)
		local scale2=cc.ScaleTo:create(0.2, 1.0)
		local fade=cc.Blink:create(1,3)	
		--print copy
		local sprite=display.newSprite("images/print_die.png")
		local tint=cc.TintTo:create(1.5, 255, 0, 0)
		sprite:setPosition(self.player:getPosition())
		sprite:setRotation(self.player:getRotation())
		sprite:setOpacity(255*0.8)		
		self:addChild(sprite,0,PRINT_TAG)
		sprite:runAction(tint)

		self.player:runAction(transition.sequence({scale1,scale2,fade,cc.CallFunc:create(callbackFunc)}))

	end
end




function GameScene:pauseGame()
	self.pause=true			
	self.pauseLayer=display.newSprite("images/pause_bk.png")
					:pos(display.cx,display.cy)
					:addTo(self)
	self.pauseBtn=cc.ui.UIPushButton.new({normal="images/pause.png"})	
					  :pos(display.cx+100,display.cy)	
					  :onButtonRelease(
					  	function()
					  		self:resumeGame()
					    end)
					  :addTo(self)	
	self.backBtn=cc.ui.UIPushButton.new({normal="images/back.png"})	
					  :pos(display.cx-100,display.cy-100)
					  :setScale(0.7)
					  :setRotation(-30)
					  :onButtonRelease(
					  	function()
					  		self:backToMainScene()
					    end)
					  :addTo(self)	
	-- self.soundBtnState="on"
	soundOn=cc.UserDefault:getInstance():getBoolForKey("soundOn", true)
	if soundOn then		
		self.soundBtn=cc.ui.UIPushButton.new({normal="images/soundbOn.png"})
					:pos(display.cx,100)
					:addTo(self)

	else
		self.soundBtn=cc.ui.UIPushButton.new({normal="images/soundb.png"})
					:pos(display.cx,100)					
					:addTo(self)
	end

	self.soundBtn:onButtonRelease(function()
		soundOn=cc.UserDefault:getInstance():getBoolForKey("soundOn", true)
		if soundOn then
			-- print("关闭音乐")
			-- body
			self.soundBtn:setButtonImage("normal", "images/soundb.png")
			audio.stopMusic(true)
			-- audio.pauseMusic()
			cc.UserDefault:getInstance():setBoolForKey("soundOn", false)
		else
			-- print("开启音乐")
			-- body
			self.soundBtn:setButtonImage("normal", "images/soundbOn.png")
			audio.playMusic("sound/bk.mp3", true)
			-- audio.pauseMusic()
			cc.UserDefault:getInstance():setBoolForKey("soundOn", true)
		end
	end)

end

function GameScene:backToMainScene()
	self:cleanup()
	app:enterScene("MainScene",nil,"FADE",1.0)	
end

function GameScene:resumeGame()
	self.pause=false
	-- audio.playMusic("sound/bk.mp3", true)
	self:removeChild(self.pauseBtn,true)
	self:removeChild(self.backBtn, true)
	self:removeChild(self.soundBtn,true)
	self:removeChild(self.pauseLayer,true)
end

function GameScene:failGame()
	local function callbackFunc()
		self:removeChild(self.player, true)
	end
	local level=self.backgroundLayer.level
	self.gameover=true

	self.player:stopWalk()
	self.keyPressing=-1
	self.trapAni=true
	--effects
	local scale1=cc.ScaleTo:create(0.2, 1.2)
	local scale2=cc.ScaleTo:create(0.2, 1.0)
	local fade=cc.Blink:create(1,3)	
	--print copy
	local sprite=display.newSprite("images/print_die.png")
	local tint=cc.TintTo:create(1, 255, 0, 0)
	sprite:setPosition(self.player:getPosition())
	sprite:setRotation(self.player:getRotation())
	sprite:setOpacity(255*0.8)	
	--方便删除的时候好找
	-- sprite:setTag(PRINT_TAG)

	self:addChild(sprite)
	

	local bg=display.newSprite("images/pause_bk.png")
			:pos(display.cx,display.cy)
			:addTo(self)
	bg:setOpacity(0.5*255)
	bg:runAction(cc.TintTo:create(1, 255, 150, 150))

	sprite:runAction(tint)
	self.player:runAction(transition.sequence({scale1,scale2,fade,cc.CallFunc:create(callbackFunc)}))


	self.overtime=0
end

function GameScene:cleanup()										
    print("GameScene cleanup")
    cc.Director:getInstance():getEventDispatcher():removeEventListener(self.m_listener)
    scheduler.unscheduleGlobal(self.m_handler)
end

function GameScene:onEnter()	

end

function GameScene:onEnterTransitionFinish()		
end

--暂停
function GameScene:onExit()	
	self:removeAllChildren()	
    -- print("GameScene onExit")
end


function GameScene:onExitTransitionStart()	
end





return GameScene