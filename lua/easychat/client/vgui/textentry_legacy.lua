local PANEL = {}

surface.CreateFont("EasyChatCompletionFont", {
	font = "Roboto",
	size = 16,
})

function PANEL:Init()
	self.PlaceholderColor = color_white

	self:SetFont("EasyChatCompletionFont")
	self:SetUpdateOnType(true)
	self:SetMultiline(true)
end

function PANEL:OnTab() end

function PANEL:SetCompletionText(text)
	if not text or text:Trim() == "" then
		self.CompletionText = nil
	else
		self.CompletionText = text
	end
end

function PANEL:SetPlaceholderColor(col)
	self.PlaceholderColor = col
end

function PANEL:OnKeyCodeTyped(key_code)
	EasyChat.SetupHistory(self, key_code)
	EasyChat.UseRegisteredShortcuts(self, key_code)

	if key_code == KEY_TAB then
		self:OnTab()
		return true
	elseif key_code == KEY_ENTER or key_code == KEY_PAD_ENTER then
		self:OnEnter()
	end
end

local surface_DisableClipping = _G.surface.DisableClipping
local surface_SetDrawColor = _G.surface.SetDrawColor
local surface_SetTextColor = _G.surface.SetTextColor
local surface_DrawOutlinedRect = _G.surface.DrawOutlinedRect
local surface_DrawRect = _G.surface.DrawRect
local surface_SetFont = _G.surface.SetFont
local surface_GetTextSize = _G.surface.GetTextSize
local surface_SetTextPos = _G.surface.SetTextPos
local surface_DrawText = _G.surface.DrawText
local string_format, string_find, string_sub = _G.string.format, _G.string.find, _G.string.sub

local should_blink = false -- so we dont trigger by default
local blink_text = nil
local red_color = Color(255, 0, 0)
local function blink(w, h)
	if not should_blink then return end

	local col_val = math.abs(math.sin(RealTime() * 10)) * 255
	surface_SetDrawColor(col_val, 0, 0, col_val)
	surface_DrawOutlinedRect(0, 0, w, h)

	if blink_text then
		surface_SetFont("EasyChatCompletionFont")
		local text_w, text_h = surface_GetTextSize(blink_text)
		local text_x, text_y = w / 2 - text_w / 2, - (text_h + 2)

		surface_DisableClipping(true)
			surface_DrawRect(text_x - 2, text_y - 2, text_w + 4, text_h + 4)

			surface_SetTextPos(text_x, text_y)
			surface_SetTextColor(color_white)
			surface_DrawText(blink_text)
		surface_DisableClipping(false)
	end
end

function PANEL:TriggerBlink(text)
	should_blink = true
	blink_text = text
	timer.Create("ECTextEntryBlink", 2, 1, function()
		should_blink = false
		blink_text = nil
	end)
end

function PANEL:PaintOver(w, h)
	if EasyChat.UseDermaskin then return end

	if self.CompletionText then
		local cur_value = self:GetText()
		surface_SetTextColor(self.PlaceholderColor)
		surface_SetFont("EasyChatCompletionFont")
		local cur_text_w = surface_GetTextSize(cur_value)
		local start_pos, end_pos = string_find(self.CompletionText, cur_value, 1, true)
		if start_pos == 1 then
			local sub_completion = string_sub(self.CompletionText, end_pos + 1)
			surface_SetTextPos(cur_text_w + 3, 5)
			surface_DrawText(sub_completion)
		else
			local sub_completion = string_format("<< %s >>", self.CompletionText)
			surface_SetTextPos(cur_text_w + 15, 5)
			surface_DrawText(sub_completion)
		end
	end

	blink(w, h)
end

vgui.Register("TextEntryLegacy", PANEL, "DTextEntry")