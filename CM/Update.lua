function GottaGoFaster.UpdateCM()
  if (GottaGoFaster.CurrentCM and next(GottaGoFaster.CurrentCM)) then
    GottaGoFaster.UpdateCMTimer();
  end
end

function GottaGoFaster.UpdateCMInformation()
  if (GottaGoFaster.CurrentCM and next(GottaGoFaster.CurrentCM)) then
    if (GottaGoFaster.CurrentCM["Completed"] == false) then
      for i = 1, GottaGoFaster.CurrentCM["Steps"] do
        local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(i);
        if (criteriaInfo.totalQuantity == 0 or not criteriaInfo.totalQuantity) then
          -- Final Value = 0 Means CM Complete
          GottaGoFaster.CompleteCM();
          return false;
        end
        -- workaround for blizzard removing flat count values from API C_ScenarioInfo.GetCriteriaInfo(i)
        if (i == GottaGoFaster.CurrentCM["Steps"]) then
          local currentCount = tonumber(string.format("%.1f", (criteriaInfo.quantity * criteriaInfo.totalQuantity) / 100));
          if (GottaGoFaster.CurrentCM["CurrentValues"][i] ~= currentCount) then
            -- Update Value
            GottaGoFaster.CurrentCM["CurrentValues"][i] = currentCount;
            if (currentCount == criteriaInfo.totalQuantity) then
              -- Add Objective Time
              GottaGoFaster.CurrentCM["ObjectiveTimes"][i] = GottaGoFaster.ObjectiveCompleteString(GottaGoFaster.CurrentCM["Time"]);
            end
          end
        else
          if (GottaGoFaster.CurrentCM["CurrentValues"][i] ~= criteriaInfo.quantity) then
            -- Update Value
            GottaGoFaster.CurrentCM["CurrentValues"][i] = criteriaInfo.quantity;
            if (criteriaInfo.quantity == criteriaInfo.totalQuantity) then -- or ((i == GottaGoFaster.CurrentCM["Steps"]) and (curValue == 100))) then
              -- Add Objective Time
              if (not GottaGoFaster.CurrentCM["ObjectiveTimes"][i]) then
                GottaGoFaster.CurrentCM["ObjectiveTimes"][i] = GottaGoFaster.ObjectiveCompleteString(
                  GottaGoFaster.Utility.ShortenStr(GottaGoFaster.CurrentCM["Time"], 1));
              end
            end
          end
        end
        
        if (GottaGoFaster.CurrentCM["CurrentValues"][i] == GottaGoFaster.CurrentCM["FinalValues"][i] and not GottaGoFaster.CurrentCM["ObjectiveTimes"][i]) then
          -- Objective Already Complete But No Time Filled Out (Re-Log / Re-Zone)
          GottaGoFaster.CurrentCM["ObjectiveTimes"][i] = "?";
        end
      end
    end
  end
end

function GottaGoFaster.CMFinalParse()
  if (GottaGoFaster.CurrentCM and next(GottaGoFaster.CurrentCM)) then
    for i = 1, GottaGoFaster.CurrentCM["Steps"] do
      GottaGoFaster.CurrentCM["CurrentValues"][i] = GottaGoFaster.CurrentCM["FinalValues"][i];
      if (not GottaGoFaster.CurrentCM["ObjectiveTimes"][i]) then
        GottaGoFaster.CurrentCM["ObjectiveTimes"][i] = GottaGoFaster.ObjectiveCompleteString(GottaGoFaster.Utility.ShortenStr(GottaGoFaster.CurrentCM["Time"], 1));
      end
    end
  end
end

function GottaGoFaster.AddBestRun(run)
  if (GottaGoFaster.CurrentCM and next(GottaGoFaster.CurrentCM) and run ~= "NF") then
    GottaGoFaster.CurrentCM["BestRun"] = run;
    GottaGoFaster.PrintBestRun(GottaGoFaster.CurrentCM["BestRun"]);
  end
end

function GottaGoFaster.StartCM(offset)
  if (GottaGoFaster.CurrentCM and next(GottaGoFaster.CurrentCM)) then
    GottaGoFaster.CurrentCM["StartTime"] = GetTime() + offset;
    GottaGoFaster.BuildCMTooltip();
  end
end

function GottaGoFaster.CompleteCM()
  if (GottaGoFaster.CurrentCM and next(GottaGoFaster.CurrentCM)) then
    GottaGoFaster.CurrentCM["Completed"] = true;
    GottaGoFaster.CMFinalParse();
  end
end

function GottaGoFaster.WipeCM()
  if (GottaGoFaster.CurrentCM and next(GottaGoFaster.CurrentCM)) then
    GottaGoFaster.CurrentCM = table.wipe(GottaGoFaster.CurrentCM);
  end
end
