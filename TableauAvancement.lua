------------------------------
-- Tableau d'Avancement LUA --
--       Adriweb  2011      --
------------------------------
-- Parts are from BetterLuaAPI
-- Source : github.com/adriweb

--   Globals   --

platform.apilevel = '1.0'
device = { api, hasColor, isCalc, theType, lang }
device.api = platform.apilevel
device.hasColor = platform.isColorDisplay()
device.lang = locale.name()

-- End Globals --

--BetterLuaAPI:--

local function test(arg)
	return arg and 1 or 0
end

local function screenRefresh()
	return platform.window:invalidate()
end

local function pww()
	return platform.window:width()
end

local function pwh()
	return platform.window:height()
end

local function drawPoint(x, y)
	myGC:fillRect(x, y, 1, 1)
end

local function drawCircle(x, y, diameter)
	myGC:drawArc(x - diameter/2, y - diameter/2, diameter,diameter,0,360)
end

local function drawCenteredString(str)
	myGC:drawString(str, (pww() - myGC:getStringWidth(str)) / 2, pwh() / 2, "middle")
end

local function drawXCenteredString(str,y)
	myGC:drawString(str, (pww() - myGC:getStringWidth(str)) / 2, y, "top")
end

--  End BLAPI  --

--  Class(es)  --

Tableau = class()

function Tableau:init(data)
	self.nbrReact = data["nbrReact"]
	self.nbrProd = data["nbrProd"]
	self.restes = data["restes"]
	self.moles = data["moles"]
	self.noms = data["noms"]
	self.coeff = data["coeffs"]
	self.xmax = data["xmax"]
	self.reactLim = data["reactLim"]
	self.nbrCol = self.nbrReact + self.nbrProd
	self.equation = ""
	for k,v in pairs(self.noms) do
	    self.equation = self.equation .. tostring(self.coeff[k]) .. " " .. tostring(self.noms[k])
	    if k ~= self.nbrReact then
	        if k < self.nbrCol then self.equation = self.equation .. " + " end
	    else
	        self.equation = self.equation .. " -> "
	    end
	end
	--------
	self:resizeGC()
end

function Tableau:resizeGC()
	self.xStart = .05*screenX
	self.yStart = .15*screenY
	self.width = .9*screenX
	self.height = .8*screenY
	self.xEnd = self.xStart + self.width - 1
	self.yEnd = self.yStart + self.height
	self.stepX = (1/(1+self.nbrCol))*self.width
	self.stepY = .25*self.height
	self.txtSize = 9
end

function Tableau:paint(gc)
	gc:drawRect(self.xStart,self.yStart,self.width,self.height+1)
	for i=self.yStart+self.stepY,self.yEnd,self.stepY do
	    gc:drawLine(self.xStart,i,self.xEnd,i)
	end
	gc:drawLine(self.xStart*1.65+self.stepX,self.yStart,self.xStart*1.65+self.stepX,self.yEnd-1)
	gc:drawLine(self.xStart*1.52+(1+self.nbrReact)*self.stepX*1.005,self.yStart+self.stepY,self.xStart*1.52+(1+self.nbrReact)*self.stepX*1.005,self.yEnd-1)
	for i=self.xStart*1.65+2*self.stepX,self.xEnd,0.95*self.stepX do
	    gc:drawLine(i,self.yStart+self.stepY,i,self.yEnd-1)
	end
	self:paintTexts(gc)
end

function Tableau:paintTexts(gc)
    gc:setFont("sansserif", "r", self.txtSize)
    gc:drawString(self.equation,self.xStart+1.5*self.stepX,self.yStart,"top")
end

-- End Classes --

--   Events:   --

function on.create()
    theError = ""
	on.resize()
	recupData() -- makes theData
	tableau = Tableau(theData)
	for k,v in pairs(tableau) do
	    --print(k,v)
	end
	var.monitor("luasignal")
	print("Done Init. Got Error ?", theError ~= "")
end

function on.resize()
	--if device.api == "1.1" then platform.window:setPreferredSize(0,0) end
    device.isCalc = (platform.window:width() < 320)
    device.theType = platform.isDeviceModeRendering() and "handheld" or "software"
    screenX = pww()
    screenY = pwh()
    if tableau then tableau:resizeGC() end
end

function on.charIn(key)
    if key == "*" or key == "+" then print("plus") screenX = screenX + 25 screenY = screenY + 25 end
    if key == "/" or key == "-" then screenX = screenX - 25 screenY = screenY - 25 end
    if tableau then tableau:resizeGC() end
    screenRefresh()
end

function on.paint(gc)
	gc:setColorRGB(0,0,0)

    tableau:paint(gc)
	
	if theError ~= "" then
	    print(theError)
	    gc:drawString(theError,5,5,"top")
	end
end

function on.varChange()
    on.create()  -- reinitialisation du script.
end

--  End Events --

--  Functions  --
function recupData()
	theData = { nbrReact = var.recall("nbrreact"), nbrProd = var.recall("nbrprod"), noms = var.recall("lnoms"), coeffs = var.recall("lcoeff"), moles = var.recall("lmoles"), restes = var.recall("lreste"), reactLim = var.recall("reactlim"), xmax = var.recall("xmax")}
	if tonumber(theData["xmax"]) > 9000 or var.recall("luasignal") < 42 then theError = "Veuillez exécuter le programme avancement() avant de consulter le tableau !" else theError = "" end
end

--  End Func.  --





