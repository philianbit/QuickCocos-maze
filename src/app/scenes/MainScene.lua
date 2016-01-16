local MainScene=class("MainScene",function()
	return display.newScene("MainScene")
end)



function MainScene:ctor()
	startBtnClicked=false
	mainBkimage=display.newSprite("images/main_bk.png")
		:pos(display.cx,display.cy)
		:addTo(self)

	--标题
	local title=display.newSprite("images/title.png")
				:pos(display.cx,display.cy+150)
				:addTo(self)
	-- self.soundBtnState="on"
	--音乐按钮
	soundOn=cc.UserDefault:getInstance():getBoolForKey("soundOn", true)
	if soundOn then
		audio.playMusic("sound/bk.mp3", true)
		soundBtn=cc.ui.UIPushButton.new({normal="images/soundOn.png"})
					:pos(display.cx,100)
					:addTo(self)

	else
		soundBtn=cc.ui.UIPushButton.new({normal="images/sound.png"})
					:pos(display.cx,100)					
					:addTo(self)
	end

	soundBtn:onButtonRelease(function()
		soundOn=cc.UserDefault:getInstance():getBoolForKey("soundOn", true)
		if soundOn then
			-- print("关闭音乐")
			-- body
			soundBtn:setButtonImage("normal", "images/sound.png")
			audio.stopMusic(true)
			-- audio.pauseMusic()
			cc.UserDefault:getInstance():setBoolForKey("soundOn", false)
		else
			-- print("开启音乐")
			-- body
			soundBtn:setButtonImage("normal", "images/soundOn.png")
			audio.playMusic("sound/bk.mp3", true)
			-- audio.pauseMusic()
			cc.UserDefault:getInstance():setBoolForKey("soundOn", true)
		end
	end)
	
	
    --获取已通过关卡
	local passLevel=cc.UserDefault:getInstance():getIntegerForKey("passLevel", 0)
	-- print("passLevel" ..passLevel)
	--记录每一关的最佳时间
	local bestTime={}
	if passLevel~=0 then
		for i=1,passLevel,1 do
			local timeKey="bestTime" ..i
			local levelTime=cc.UserDefault:getInstance():getIntegerForKey(timeKey, 600)
			table.insert(bestTime,levelTime)
			-- print("levelTime" ..levelTime)
		end
	end
	local btn1PosX,btn1PosY=display.cx/4,display.cy
	local scale1=cc.ScaleTo:create(0.5, 1.2, 1.2)
	local scale2=cc.ScaleTo:create(0.5, 1.0, 1.0)
	local sequenceAction=cc.Sequence:create(scale1,scale2)

	--根据对应关卡和按钮位置，创建选关按钮
	--此处创建2-6关的按钮
	local function newLevelButton(level,x,y)
		if level>6 or level<1 then
			do return end
		end

		local btn=cc.ui.UIPushButton.new({normal="images/start.png",pressed="images/start2.png"})
				  :pos(btn1PosX,btn1PosY)	
				  :rotation(math.random(0,359))			  
				  :addTo(self)

		

		transition.execute(btn, cc.MoveTo:create(1.5, cc.p(x, y)), {
   						delay = 0.1,
   				 		easing = "backout",
 						onComplete = 
 				 		function()       							
							--如果按钮对应的关卡已通过，则更换按钮图片，缩小按钮
							if level<=passLevel then
								btn:onButtonRelease(function()
									  		app:enterScene("GameScene",{{level}},"FADE",1.0)
									  	end)
								btn:setButtonImage("normal", "images/start2.png")
								btn:setScale(0.8)
								
								--时间显示
								local time=bestTime[level]
								local min=math.floor(time/60)
								local sec=math.mod(time,60)
								local minStr=min ..""
								local secStr=sec ..""
								if min<10 then
									minStr="0" ..min
								end
								if sec<10 then
									secStr="0" ..sec
								end
								local timeStr=minStr ..":" ..secStr
								local btnx=x
								local btny=y
								local timelabel=display.newBMFontLabel({text=timeStr,font="images/smallNumber.fnt",x=btnx,y=btny-70})
								self:addChild(timelabel)
							--如果按钮对应的是已通过关卡的下一个关卡，则突出显示
							elseif level==passLevel+1 then
								btn:onButtonRelease(function()
									  		app:enterScene("GameScene",{{level}},"FADE",1.0)

									  	end)
								-- startBtn:stopAction(transition.execute(startBtn,cc.RepeatForever:create(sequenceAction)))	
								local scale1=cc.ScaleTo:create(0.5, 1.2, 1.2)
								local scale2=cc.ScaleTo:create(0.5, 1.0, 1.0)
								-- move1=cc.MoveBy:create(0.5,cc.p(0,10))
								-- move2=cc.MoveBy:create(0.5,cc.p(0,-10))
								local sequenceAction=cc.Sequence:create(scale1,scale2)
								transition.execute(btn,cc.RepeatForever:create(sequenceAction))
							elseif level>passLevel+1 then
								btn:setOpacity(0.6*255)				
							end
       							
   				 		end
					})
		return btn
	end

	startBtn=cc.ui.UIPushButton.new({normal="images/start.png",pressed="images/start2.png"})
		:onButtonRelease(
			function()
				if not startBtnClicked then 
				--出现选关界面和按钮
				startBtnClicked=true
				transition.execute(mainBkimage, cc.MoveTo:create(1.0, cc.p(display.cx, 3*display.cy)), {
   				 delay = 0.1,
   				 easing = "backout"
				})
				transition.execute(title, cc.MoveTo:create(1.0, cc.p(display.cx, 3*display.cy)), {
   				 delay = 0.1,
   				 easing = "backout"
				})
				transition.execute(startBtn, cc.MoveTo:create(1.0, cc.p(btn1PosX,btn1PosY)), {
   				 delay = 0.1,
   				 easing = "backout",
 				 onComplete = 
 				 function()
 				 	transition.execute(soundBtn, cc.MoveTo:create(1.0, cc.p(display.width-70,70)), {
   					 delay = 0.1,
   					 easing = "backout"})
 				 	self:removeChild(startBtn, true)
 				 	btn1=newLevelButton(1,btn1PosX,btn1PosY)
					btn2=newLevelButton(2,btn1PosX+300,btn1PosY+200)
					btn3=newLevelButton(3,btn1PosX+350,btn1PosY)
					btn4=newLevelButton(4,btn1PosX+330,btn1PosY-200)
					btn5=newLevelButton(5,btn1PosX+600,btn1PosY+140)
					btn6=newLevelButton(6,btn1PosX+620,btn1PosY-160)
					-- --中等难度按钮
     --   				medBtn=cc.ui.UIPushButton.new({normal="images/start.png",pressed="images/start2.png"})
					--    :pos(startBtn:getPosition())
					--    :addTo(self)
					-- --高等难度按钮
					-- highBtn=cc.ui.UIPushButton.new({normal="images/start.png",pressed="images/start2.png"})
					--    :pos(startBtn:getPosition())
					--    :addTo(self)
					-- transition.execute(medBtn, cc.MoveTo:create(1.5, cc.p(display.cx, display.cy)), {
   		-- 				delay = 1.0,
   		-- 		 		easing = "backout",
 				-- 		onComplete = 
 				--  		function()
     --   						medBtn:onButtonRelease(
     --   							function()
     --   								--进入游戏
					-- 				app:enterScene("GameScene",{{3}},"FADE",1.0)
     --   							end)
   		-- 		 		end
					-- })
					-- transition.execute(highBtn, cc.MoveTo:create(1.5, cc.p(display.cx*1.5, display.cy*0.5)), {
   		-- 				delay = 1.0,
   		-- 		 		easing = "backout",
 				-- 		onComplete = 
 				--  		function()
     --   						highBtn:onButtonRelease(
     --   							function()
     --   								--进入游戏
					-- 				app:enterScene("GameScene",{{5}},"FADE",1.0)	
     --   							end)
   		-- 		 		end
					-- })

   				 end
			})
			else
				--进入游戏
				app:enterScene("GameScene",{{1}},"FADE",1.0)	
			end
		end)
		:pos(display.cx,display.cy)
		:addTo(self)
	transition.execute(startBtn,cc.RepeatForever:create(sequenceAction))

	-- function()
	-- 		app:enterScene("GameScene",nil,"FADE",1.0)
	-- 	end

end



function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene