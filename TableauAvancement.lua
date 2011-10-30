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

theError = ""

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
	self.coeff = data["coeff"]
	self.xmax = data["xmax"]
	self.reactLim = data["reactLim"]
	--------
	self:resizeGC()
end

function Tableau:resizeGC()
    self.nbrCol = self.nbrReact + self.nbrProd
	self.xStart = .05*screenX
	self.yStart = .15*screenY
	self.width = .9*screenX
	self.height = .8*screenY
	self.xEnd = self.xStart + self.width
	self.yEnd = self.yStart + self.height
	self.stepX = (1/self.nbrCol)*self.width
	self.stepY = .25*self.height
end

function Tableau:paint(gc)
	gc:drawRect(self.xStart,self.yStart,self.width,self.height)
	for i=self.yStart+self.stepY,self.yEnd-self.stepY,self.stepY do
	    gc:drawLine(self.xStart,i,self.xEnd,i)
	end
	for i=self.yStart+self.stepY,self.yEnd-self.stepY,self.stepY do
	    gc:drawLine(self.xStart,i,self.xEnd,i)
	end
end

-- End Classes --

--   Events:   --

function on.create()
	on.resize()
	recupData() -- makes theData
	tableau = Tableau(theData)
	print("Done Init. Error : ", theError ~= "")
end

function on.resize()
	--if device.api == "1.1" then platform.window:setPreferredSize(0,0) end
    device.isCalc = (platform.window:width() < 320)
    device.theType = platform.isDeviceModeRendering() and "handheld" or "software"
    screenX = pww()
    screenY = pwh()
    if tableau then tableau:resizeGC() end
end

function on.paint(gc)
	gc:setColorRGB(0,0,0)
	--if theError then gc:setAlpha(128) end -- fond a moitié transparent
	tableau:paint(gc)
	
	if theError then
	--	gc:setAlpha(255) -- affichage de l'erreur en non-transparent
	
		--Error handling code here....		
	end
end

--  End Events --

--  Functions  --
function recupData()
	theData = { nbrReact = var.recall("nbrreact"), nbrProd = var.recall("nbrprod"), lNoms = var.recall("lnoms"), lCoeffs = var.recall("lcoeff"), lMoles = var.recall("lmoles"), lReste = var.recall("lreste"), reactLim = var.recall("reactlim"), xmax = var.recall("xmax") }
	for _,v in pairs(theData) do
		if not v then theError = "Veuillez exécuter le programme avancement() avant de consulter le tableau !" end
	end
end

--  End Func.  --

















