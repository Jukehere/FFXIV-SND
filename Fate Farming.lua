  --[[

  ****************************************
  *       Zadnor Z3 Fate Farming         * 
  ****************************************

  Stolen by: Juke ♥
  Created by: Prawellp

  ***********
  * Version *
  *  0.0.3  *
  ***********

*********************
*  Required Plugins *
*********************

Plugins that are needed for it to work:

    -> VNavmesh :   (for Pathing/Moving)  https://puni.sh/api/repository/veyn       
    -> Pandora :    (for Fate targeting) https://love.puni.sh/ment.json             
    -> RotationSolver Reborn :  (for Attacking enemys)  https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json       
        -> Target -> activate "Select only Fate targets in Fate" and "Target Fate priority"
        -> Target -> "Engage settings" set to "Previously engaged targets (enagegd on countdown timer)"
    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat
    
    BTW THIS IS JUNK SO PUT A FLAG TO WHERE YOU WANT TO COME BACK AFTER THE FATE IS OVER XOXO

*********************
*  Optional Plugins *
*********************

This Plugins are Optional and not needed unless you have it enabled in the settings:
   
    -> Bossmod Reborn : (for AI dodging) https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> AI Settings -> enable "Follow during combat" and "Follow out of combat"
]]
--[[

**************
*  Settings  *
**************
]]

ManualRepair = true --true (yes)| false (no) --will repair your gear after every fate if the threshold is reached.
RepairAmount = 99   -- the amount of Condition you gear will need before getting Repaired
ExtractMateria = false --true (yes)| false (no) --will Extract Materia if you can

BMR = true --true (yes)| false (no)    --will activate bossmod AI for dodging

FateWarning = false --true (yes)| false (no) --echos a warning in chat with sound from Known Dangerous Fates
Announce = 2
--Change this value for how much echos u want in chat 
--2 is the fate your Moving to and Bicolor gems amount (lol)
--1 is only Bicolor gems (lolololol)
--0 is nothing
--echos will appear after it found a new fate 
  
--[[
  
************
*  Script  *
*   Start  *
************
  
]]
------------------------------Functions----------------------------------------------
--Gets the Location fo the Fate
function FateLocation()
    fates = GetActiveFates()
    minDistance = 50000
    fateId = 0
    for i = 0, fates.Count-1 do
    tempfate = fates[i]
    if tempfate == 1742 or tempfate == 1741 or tempfate == 1740 or tempfate == 1739 or tempfate == 1738 or tempfate == 1737 or tempfate == 1736 or tempfate == 1603 or tempfate == 1734 or tempfate == 1733 then --(Whitelist (still need to find away to make it better))
        distance = GetDistanceToPoint(GetFateLocationX(fates[i]), GetFateLocationY(fates[i]), GetFateLocationZ(fates[i]))
    if distance < minDistance then
        minDistance = distance
        fateId = fates[i]
        Fate2 = fateId
    end
    end
end
  
fateX = GetFateLocationX(fateId)
fateY = GetFateLocationY(fateId)+5
fateZ = GetFateLocationZ(fateId)
LogInfo(fateX.." , "..fateY.." , "..fateZ)
end

--Paths to the Fate
function FatePath()
while IsInFate() == false and GetCharacterCondition(4) == false do
    yield("/wait 3")
    yield('/gaction "mount roulette"')
    yield("/wait 3")
end
if fateX == 0 and fateY == 5 and fateZ == 0 then
    noFate = true
    yield("/wait 2")
end
--Announcement for FateId
if fateX ~= 0 and fateY ~= 5 and fateZ ~= 0 then
    noFate = false
    if HasFlightUnlocked(zoneid) then
    PathfindAndMoveTo(fateX, fateY, fateZ, true)
    else
    PathfindAndMoveTo(fateX, fateY, fateZ)
    end
    if Announce == 2 then
        yield("/echo Moving to Fate: "..fateId)  
end

--Announcement for gems
if gcount == 0  and fateId ~= 0 and Announce == 1 or Announce == 2 then
    yield("/e Gems: "..gems)
    yield("/wait 0.5")
    gcount = gcount +1
end
end
end

--Paths to the enemy (for Meele)
function enemyPathing()
    while GetDistanceToTarget() > 3.5 do
        local enemy_x = GetTargetRawXPos()
        local enemy_y = GetTargetRawYPos()
        local enemy_z = GetTargetRawZPos()
    if PathIsRunning() == false then 
        PathfindAndMoveTo(enemy_x, enemy_y, enemy_z)
    end
        yield("/wait 0.1")
    end
end
InstanceCount = 0
--When there is no Fate 
function noFateSafe()
    if noFate == true then
    if fcount == 0 then
        yield("/echo No Fate existing")
        fcount = fcount +1
        yield("/vnav moveflag")
    end
  end
  end
---------------------------Beginning of the Code------------------------------------
gcount = 0
cCount = 0
fcount = 0
zoneid = GetZoneID()
if NavIsReady() == false then
yield("/echo Building Mesh Please wait...")
end

--Will mount if not mounted on start
if GetCharacterCondition(4) == false then
    yield('/gaction "mount roulette"')
    yield("/wait 3")
    end
    yield("/rotation auto")
  
--Start of the Code
while NavIsReady() == false do
yield("/wait 1")
end
if NavIsReady() then
yield("/echo Mesh is Ready!")
end
while true do
gems = GetItemCount(26807)
---------------------------Fate Pathing part--------------------------------------
FateLocation()
FatePath()
noFateSafe()
Fate1 = fateId
-------------------------------Fate Pathing Process------------------------------
--Jumps when landing while pathing to a fate
while PathIsRunning() or PathfindInProgress() and IsInFate() == false do
    InstanceCount = 0
--Stops Moving to dead Fates
FateLocation()
yield("/wait 1")

if Fate1 ~= Fate2 then
if PathIsRunning() == false then
    FateLocation()
    FatePath()
end
    yield("/wait 0.5")
end
--Stops Pathing when in Fate
if PathIsRunning() and IsInFate() == true then
    yield("/wait 0.5")
end
end
--Dismounting upon arriving in fate
while IsInFate() and GetCharacterCondition(4) do
    yield("/gaction dismount")
    yield("/wait 0.3")
    PathStop()
    yield("/vnavmesh stop")
end
-------------------------------Fate----------------------------------------------
--Dismounts when in fate
bmaiactive = false
while IsInFate() do
    yield("/vnavmesh stop")
    if GetCharacterCondition(4) == true then
        yield("/vnavmesh stop")
        yield("/gaction dismount")
        yield("/wait 2")
        PathStop()
        yield("/vnavmesh stop")
    end
--Activates Bossmod upon landing in a fate
if GetCharacterCondition(4) == false and bmaiactive == false then 
    if BMR == true then
        yield("/bmrai on")
        yield("/bmrai followtarget on")
        bmaiactive = true
    end
end
--Paths to enemys when Bossmod is disabled
    if BMR == false then 
    enemyPathing()
    end
    PathStop()
    yield("/vnavmesh stop")
    yield("/wait 1")
    fcount = 0
    gcount = 0
    cCount = 0

end
--Disables bossmod when the fate is over
if IsInFate() == false and bmaiactive == true then 
    if BMR == true then
        yield("/bmrai off")
        yield("/bmrai followtarget off")
        bmaiactive = false
    end
end

-----------------------------After Fate------------------------------------------
while GetCharacterCondition(26) do
yield("/wait 1")
end
--Repair function
if ManualRepair == true then
    if NeedsRepair(RepairAmount) then
    while not IsAddonVisible("Repair") do
    yield("/generalaction repair")
    yield("/wait 0.5")
    end
    yield("/pcall Repair true 0")
    yield("/wait 0.1")
if IsAddonVisible("SelectYesno") then
    yield("/pcall SelectYesno true 0")
    yield("/wait 0.1")
end
while GetCharacterCondition(39) do 
    yield("/wait 1") 
end
    yield("/wait 1")
    yield("/pcall Repair true -1")
end
end
end