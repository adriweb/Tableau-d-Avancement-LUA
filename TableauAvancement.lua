------------------------------
-- Tableau d'Avancement LUA --
--       Adriweb  2011      --
------------------------------
-- Parts are from BetterLuaAPI
-- Source : github.com/adriweb

--   Globals   --

device = { api, hasColor, isCalc, theType, lang }
device.api = platform.apilevel
device.hasColor = platform.isColorDisplay()
device.lang = locale.name()

-- End Globals --

--   Events:   --

function on.create()
	on.resize()
end

function on.resize()
	if device.api == "1.1" then platform.window:setPreferredSize(0,0) end
    
    device.isCalc = (platform.window:width() < 320)
    device.theType = platform.isDeviceModeRendering() and "handheld" or "software"
end


--  End Events --