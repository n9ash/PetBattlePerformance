local AddonName, PetBattlePerformance = ...
local AddonTitle = C_AddOns.GetAddOnMetadata(AddonName, "Title") or AddonName;
local AddonVersion = C_AddOns.GetAddOnMetadata(AddonName, "Version") or "?";

--------------------------------------------------------------------------------
-- Frame Scripts
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame");

function frame:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local arg1 = select(1, ...);
		if (arg1 == AddonName) then
--			DEFAULT_CHAT_FRAME:AddMessage("[" .. AddonTitle .. "] |cFF00FF00" .. AddonVersion .. "|r loaded.", 0.7, 0.7, 1.0);
			frame:RegisterEvent("PET_BATTLE_OPENING_START");
		end
	elseif (event == "PET_BATTLE_OPENING_START") then
		frame.startTime = GetTime();
		frame.inputStart = nil;
		frame.inputTotal = 0;

		frame:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
		frame:RegisterEvent("PET_BATTLE_ACTION_SELECTED");
		frame:RegisterEvent("PET_BATTLE_FINAL_ROUND");
		frame:RegisterEvent("PET_BATTLE_CLOSE");
	elseif (event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE") then
		frame.inputStart = GetTime();
		frame.round = select(1, ...);
	elseif (event == "PET_BATTLE_ACTION_SELECTED") then
		if (frame.inputStart) then
			frame.inputTotal = frame.inputTotal + GetTime() - frame.inputStart;
			frame.inputStart = nil;
		end
	elseif (event == "PET_BATTLE_FINAL_ROUND") then
		frame.winner = select(1, ...);
	elseif (event == "PET_BATTLE_CLOSE") then
		frame.endTime = GetTime();

		frame:UnregisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
		frame:UnregisterEvent("PET_BATTLE_ACTION_SELECTED");
		frame:UnregisterEvent("PET_BATTLE_FINAL_ROUND");
		frame:UnregisterEvent("PET_BATTLE_CLOSE");

		local duration = frame.endTime - frame.startTime - frame.inputTotal;
		local minutes, seconds = floor(duration / 60), duration % 60;

		local d = YELLOW_FONT_COLOR:WrapTextInColorCode(format("%d:%04.1f", minutes, seconds));
		local r = YELLOW_FONT_COLOR:WrapTextInColorCode(frame.round);
		local o = YELLOW_FONT_COLOR:WrapTextInColorCode(frame.winner == 1 and "Win" or "Loss");

		local info = ChatTypeInfo["PARTY"];
		DEFAULT_CHAT_FRAME:AddMessage(format(
			"[%s] This battle lasted %s (+%.1fs input) over %s rounds, and resulted in a %s.",
			AddonTitle, d, frame.inputTotal, r, o), info.r, info.g, info.b, info.id);
	else
		print("[OnEvent] " .. event .. " NYI");
	end
end

frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", frame.OnEvent);