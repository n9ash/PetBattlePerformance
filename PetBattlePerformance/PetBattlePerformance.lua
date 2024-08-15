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
		frame.userStart = nil;
		frame.userTotal = 0;

		frame:RegisterEvent("PET_BATTLE_PET_ROUND_RESULTS");
		frame:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
		frame:RegisterEvent("PET_BATTLE_FINAL_ROUND");
		frame:RegisterEvent("PET_BATTLE_CLOSE");
	elseif (event == "PET_BATTLE_PET_ROUND_RESULTS") then
		if (frame.userStart) then
--			local d = YELLOW_FONT_COLOR_CODE .. format("%.3fs", (GetTime() - frame.userStart)) .. "|r";
--			DEFAULT_CHAT_FRAME:AddMessage("[" .. AddonTitle .. "] " .. select(1, ...) .. "   " .. d, 0.7, 0.7, 1.0);

			frame.userTotal = frame.userTotal + GetTime() - frame.userStart;
			frame.userStart = nil;
		end
	elseif (event == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE") then
		frame.userStart = GetTime();
		frame.round = select(1, ...);
	elseif (event == "PET_BATTLE_FINAL_ROUND") then
		frame.winner = select(1, ...);
	elseif (event == "PET_BATTLE_CLOSE") then
		frame.endTime = GetTime();

		frame:UnregisterEvent("PET_BATTLE_PET_ROUND_RESULTS");
		frame:UnregisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
		frame:UnregisterEvent("PET_BATTLE_FINAL_ROUND");
		frame:UnregisterEvent("PET_BATTLE_CLOSE");

		local duration = ceil(frame.endTime - frame.startTime - frame.userTotal);
		local minutes, seconds = floor(duration / 60), duration % 60;

		local d = YELLOW_FONT_COLOR_CODE .. (minutes > 0 and format("%dm %ds", minutes, seconds) or format("%ds", seconds)) .. "|r";
		local r = YELLOW_FONT_COLOR_CODE .. frame.round .. "|r";
		local o = YELLOW_FONT_COLOR_CODE .. (frame.winner == 1 and "Win" or "Loss") .. "|r";

		DEFAULT_CHAT_FRAME:AddMessage("[" .. AddonTitle .. "] This battle lasted " .. d ..
			" (+" .. ceil(frame.userTotal) .. "s input) over " .. r ..
			" rounds, and resulted in a " .. o .. ".", 0.7, 0.7, 1.0);
	else
		print("[OnEvent] " .. event .. " NYI");
	end
end

frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", frame.OnEvent);