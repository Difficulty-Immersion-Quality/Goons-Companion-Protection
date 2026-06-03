-- Credits to Focus

-- Config
GCP_DebugEnabled = false

local PRESETS = {
	{ 255, 0,   0   }, -- C1  #ff0000 Red
	{ 255, 165, 0   }, -- C2  #ffa500 Orange
	{ 255, 255, 0   }, -- C3  #ffff00 Yellow
	{ 0,   255, 0   }, -- C4  #00ff00 Green
	{ 0,   191, 255 }, -- C5  #00bfff Blue
	{ 238, 130, 238 }, -- C6  #ee82ee Violet
	{ 255, 255, 255 }, -- C7  #ffffff White
	{ 192, 192, 192 }, -- C8  #c0c0c0 Silver
	{ 0,   0,   0   }, -- C9  #000000 Black
	{ 199, 44,  134 }, -- C10 #c72c86 Magenta
	{ 255, 214, 238 }, -- C11 #ffd6ee Blush
}

-- Internals
local Machine = Ext.IsServer() and "S" or "C"
local RESET   = "\x1b[0m"

local function Format(...)
	return #{ ... } <= 1 and tostring((...)) or string.format(...)
end

local function Lerp(a, b, t)
	return math.floor(a + (b - a) * t + 0.5)
end

local function RgbToANSI(r, g, b)
	return string.format("\x1b[1;38;2;%d;%d;%dm", r, g, b)
end

local function RawPrint(...)
	print(Format(...))
end

-- CoreBuilder
local CoreBuilder = {}
CoreBuilder.__index = CoreBuilder

function GCPPrint()
	return setmetatable({ _segs = {} }, CoreBuilder)
end

function CoreBuilder:Colour(text, r, g, b)
	self._segs[#self._segs + 1] = { Text = tostring(text), Color = { r, g, b } }
	return self
end

function CoreBuilder:Grad(text, r1, g1, b1, r2, g2, b2)
	text = tostring(text)
	local len = #text
	if len == 0 then return self end
	for i = 1, len do
		local t = len > 1 and (i - 1) / (len - 1) or 0
		self._segs[#self._segs + 1] = {
			Text  = text:sub(i, i),
			Color = { Lerp(r1, r2, t), Lerp(g1, g2, t), Lerp(b1, b2, t) },
		}
	end
	return self
end

function CoreBuilder:Raw(text)
	self._segs[#self._segs + 1] = { Text = tostring(text) }
	return self
end

function CoreBuilder:Build()
	local parts = {}
	for _, seg in ipairs(self._segs) do
		if seg.Color then
			parts[#parts + 1] = RgbToANSI(seg.Color[1], seg.Color[2], seg.Color[3]) .. seg.Text .. RESET
		else
			parts[#parts + 1] = seg.Text
		end
	end
	return table.concat(parts)
end

function CoreBuilder:Print()
	RawPrint(self:Build())
end

for i, color in ipairs(PRESETS) do
	CoreBuilder["C" .. i] = function(self, text)
		return self:Colour(text, color[1], color[2], color[3])
	end
end

-- Public
function GCPDebug(...)
	if not GCP_DebugEnabled then return end
	GCPPrint():C10(string.format("[%s GCP] ", Machine)):Raw(Format(...)):Print()
end
