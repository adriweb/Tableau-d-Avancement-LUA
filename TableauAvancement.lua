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
	self.equation1 = {}
	self.equation2 = {}
	for k,v in pairs(self.noms) do
	    table.insert(self.equation1, "   " .. tostring(self.noms[k]))
	    table.insert(self.equation2,(tostring(self.coeff[k])~="1" and tostring(self.coeff[k]) or ""))
	    --print(self.equation[k])
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
	self.txtSize = 9+(screenX-pww())/50
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
	    if i ~= (self.xStart*1.65+2*self.stepX)+(0.95*self.stepX) then
	        gc:drawString("+",self.xStart+i-.35*self.stepX,self.yStart+.22*self.stepY,"top")
	    end
	end
	self:paintTexts(gc)
end

function Tableau:paintTexts(gc)
    gc:setFont("sansserif", "r", self.txtSize)
    -- Equation
    for k,v in pairs(self.equation1) do
        gc:drawString(self.equation1[k],self.xStart+(k+.3)*self.stepX,self.yStart+.25*self.stepY,"top")
        gc:setColorRGB(255,0,0)
        gc:drawString(self.equation2[k],self.xStart+(k+.31)*self.stepX,self.yStart+.25*self.stepY,"top")
        gc:setColorRGB(0,0,0)
    end
    gc:drawString("->",self.xStart+(1+self.nbrReact)*self.stepX,self.yStart+.25*self.stepY,"top")
    -- 1ere colonne
    gc:drawString("Etat initial",self.xStart*1.3,self.yStart+1.1*self.stepY,"top")
    gc:drawString("x = x(init)",self.xStart*1.4,self.yStart+1.5*self.stepY,"top")
    gc:drawString("En cours",self.xStart*1.15,self.yStart+2.1*self.stepY,"top")
    gc:drawString("x = x",self.xStart*1.4,self.yStart+2.5*self.stepY,"top")
    gc:drawString("Etat final",self.xStart*1.3,self.yStart+3.1*self.stepY,"top")
    gc:drawString("x = x(f)",self.xStart*1.4,self.yStart+3.5*self.stepY,"top")
    --gc:drawString(string.uchar(8308),10,10,"top")
    -- autres colonnes
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
    if screenY < pwh()+100 and (key == "*" or key == "+") then screenX = screenX + 25 screenY = screenY + 25 end
    if screenX > pww() and (key == "/" or key == "-") then screenX = screenX - 25 screenY = screenY - 25 end
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





