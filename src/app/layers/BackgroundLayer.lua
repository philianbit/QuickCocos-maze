BackgroundLayer=class("BackgroundLayer",function()
		return display.newLayer()
	end)

--创建Tile基类，Block和Trap是继承自Tile的子类
--构造函数传入图块坐标
local Tile=class("Tile")
function Tile:ctor(x,y,type)
	self.x=x
	self.y=y
	self.type=type
end
local Block=class("Block",Tile)
local Trap=class("Trap",Tile)

--常数
PASS=0
BLOCK=1
TRAP=2



function BackgroundLayer:ctor(level)
	
	self.tileArr={}
	self.blockArr={}
	self.trapArr={}
	self.level=level
	self.blocksize=0
	self:createBk()
	-- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.scrollBackgrounds))
	-- self:scheduleUpdate()
end

function BackgroundLayer:createBk()
	if self.level/2.0<=1.0 then
		--单个图块的大小
		self.blocksize=64
		--载入地图
		if self.level==1 then
			self.map=cc.TMXTiledMap:create("maps/map1.tmx")
				:align(display.BOTTOM_LEFT,display.left,display.bottom)
				:addTo(self)
		elseif self.level==2 then
			self.map=cc.TMXTiledMap:create("maps/map2.tmx")
				:align(display.BOTTOM_LEFT,display.left,display.bottom)
				:addTo(self)
			end
	elseif self.level/2.0>1.0 and self.level/2.0<=2.0 then
		self.blocksize=32
		if self.level==3 then
			self.map=cc.TMXTiledMap:create("maps/map3.tmx")
				:align(display.BOTTOM_LEFT,display.left,display.bottom)
				:addTo(self)
		elseif self.level==4 then
			self.map=cc.TMXTiledMap:create("maps/map4.tmx")
				:align(display.BOTTOM_LEFT,display.left,display.bottom)
				:addTo(self)
			end
	elseif self.level/2.0>2.0 and self.level/2.0<=3.0 then
		self.blocksize=32
		if self.level==5 then
		self.map=cc.TMXTiledMap:create("maps/map5.tmx")
			:align(display.BOTTOM_LEFT,display.left,display.bottom)
			:addTo(self)
		elseif self.level==6 then
			self.map=cc.TMXTiledMap:create("maps/map6.tmx")
				:align(display.BOTTOM_LEFT,display.left,display.bottom)
				:addTo(self)
			end
	end
						
	self:getBlockPos()
end

function BackgroundLayer:getBlockPos()
	-- local objectsLayer=self.map:getObjectGroup("block")
	-- print("objectsLayer" ..objectsLayer)
	local tiles=self.map:getObjectGroup("block"):getObjects()
	-- print("tiles" ..tiles)
	

	mapRowSize=self.map:getMapSize().width
	mapColSize=self.map:getMapSize().height
	--mapRowSize=15,mapColSize=10
	print("mapRowSize" ..mapRowSize .."mapColSize" ..mapColSize)
	-- for row=1,mapRowSize,1 do
	-- 	tileArr[row]={}
	-- 	for col=1,mapColSize,1 do
	-- 		tileArr[row][col]=PASS
	-- 	end
	-- end

	self.tileNumber=table.getn(tiles)
	--tileNumber是总共的图块数量，86个
	print("tileNumber" ..self.tileNumber)
	local dict={}

	for i=1,self.tileNumber,1 do
		dict=tiles[i]
		if dict==nil then
			break
		end
		--障碍
		if dict["gid"]=="2" then
			-- print("block") 
			--tmx的y轴方向和cocos相反
			--tmx每个图块的锚点在左下角所以需要+self.blocksize/2
			local y=dict["y"]+self.blocksize/2
			local x=dict["x"]+self.blocksize/2
			local block=Block.new(x,y,BLOCK) 
			table.insert(self.tileArr,block)
			table.insert(self.blockArr,block)
			--为什么显示不出来画的方格？
			local rect=cc.DrawNode:create()
			rect:drawSolidRect(cc.p(x-self.blocksize/2,y-self.blocksize/2), cc.p(x+self.blocksize/2,y+self.blocksize/2), cc.c4f(255, 0, 0, 255))
			self:addChild(rect,10)

			-- cc.DrawPrimitives.drawSolidRect(cc.p(x-self.blocksize/2,y-self.blocksize/2), cc.p(x+self.blocksize/2,y+self.blocksize/2), cc.c4f(255, 0, 0, 255))
		elseif dict["gid"]=="1" then
			-- print("trap") 
			local y=dict["y"]+self.blocksize/2
			local x=dict["x"]+self.blocksize/2
			local trap=Trap.new(x,y,TRAP)
			table.insert(self.tileArr,trap)
			table.insert(self.trapArr,trap)
		end
	end


end




return BackgroundLayer