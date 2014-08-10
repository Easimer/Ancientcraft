-- Generated from template

if Ancientcraft == nil then
	Ancientcraft = class({})
end

minesarenotset = true
ancientsarenotset = true


function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheUnitByNameAsync( "npc_dota_creature_peasant", context )
    PrecacheModel( "npc_dota_creature_peasant", context )
	PrecacheUnitByNameAsync( "npc_dota_creature_acolyte", context )
    PrecacheModel( "npc_dota_creature_acolyte", context )
	PrecacheItemByNameSync( "item_peasants", context )
	PrecacheUnitByNameAsync( "npc_dota_btower", context )
	PrecacheUnitByNameAsync( "npc_dota_bfort", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = Ancientcraft()
	GameRules.AddonTemplate:InitGameMode()
end

function Ancientcraft:InitGameMode()
	print( "Ancientcraft is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:SetPreGameTime( 10.0 )
	GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetSafeToLeave(true)
	Convars:RegisterCommand( "ac_recheckmines", function(...) return self:CheckMines( ... ) end, "[debug] check for mines again", FCVAR_CHEAT )
	Convars:RegisterCommand( "ac_printchat", function(...) return self:PrintToChat( ... ) end, "[debug] print to chat", FCVAR_CHEAT )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( Ancientcraft, "OnNPCSpawned" ), self )
	ListenToGameEvent( "player_chat", Dynamic_Wrap( Ancientcraft, "OnChat" ), self)
end

function Ancientcraft:OnChat(event)
	print("Chat: " .. event.text) 
	if not event.teamonly and event.text == "gg" then
		print("GG CALL DETECTED")
		GameRules:MakeTeamLose(PlayerResource:GetTeam(event.userid))
	end
end

function Ancientcraft:InitAncients()
	local good_ancient = Entities:FindByName(nil, "dota_goodguys_fort") --assuming there's only one ancient on the map with this name
	good_ancient:RemoveAbility("backdoor_protection_in_base")
	good_ancient:RemoveAbility("train_peasant_base")
	good_ancient:AddAbility("train_peasant_base")
	good_ancient:GetAbilityByIndex(0):SetLevel(1)
	local bad_ancient = Entities:FindByName(nil, "dota_badguys_fort") --assuming there's only one ancient on the map with this name
	bad_ancient:RemoveAbility("backdoor_protection_in_base")
	bad_ancient:RemoveAbility("train_acolyte_base")
	bad_ancient:AddAbility("train_acolyte_base")
	bad_ancient:GetAbilityByIndex(0):SetLevel(1)
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if ( PlayerResource:IsValidPlayer( nPlayerID ) ) then
			if PlayerResource:GetPlayer(nPlayerID):GetTeam() == DOTA_TEAM_GOODGUYS then
				good_ancient:SetControllableByPlayer(nPlayerID, true)
				good_ancient:SetOwner(PlayerResource:GetPlayer(nPlayerID):GetAssignedHero())
				print("give good control to " .. nPlayerID)
			elseif PlayerResource:GetPlayer(nPlayerID):GetTeam() == DOTA_TEAM_BADGUYS then
				bad_ancient:SetControllableByPlayer(nPlayerID, true)
				bad_ancient:SetOwner(PlayerResource:GetPlayer(nPlayerID):GetAssignedHero())
				print("give bad control to " .. nPlayerID)
			end
		end
	end
end

function Ancientcraft:GiveGold(givenGold, isScourge)
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if ( PlayerResource:IsValidPlayer( nPlayerID ) ) then
			if isScourge == PlayerResource:GetPlayer(nPlayerID):GetTeam() then
				PlayerResource:ModifyGold(nPlayerID, 200, true, 0)
			elseif not isScourge == PlayerResource:GetPlayer(nPlayerID):GetTeam() then
				PlayerResource:ModifyGold(nPlayerID, 200, true, 0)
			end
		end
	end
end

function Ancientcraft:CheckMines()
	goldmines = Entities:FindAllByName("gold_mine")
	noM = 0
	for i,mine in ipairs(goldmines) do noM = noM + 1 end
	--print("Found " .. noM .. " mines.")
	Convars:RegisterCommand( "ac_printchat", function(...) return self:PrintToChat( ... ) end, "[debug] print to chat", FCVAR_CHEAT )
	for i,v in ipairs(goldmines) do
		v:SetMaxHealth(5000)
		v:SetHealth(5000)
		v:SetInvulnCount(0)
		v:SetTeam(4)
	end
	--neutral = Entities:FindAllByClassname("npc_dota_neutral")
	--for i,c in ipairs(neutral) do print(neutral:GetTeam()) end
end

function Ancientcraft:PrintToChat(msg)
	GameRules:SendCustomMessage(msg, 3, 1)
end

-- Evaluate the state of the game
function Ancientcraft:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
		if minesarenotset then
			self:CheckMines()
			minesarenotset = false
		end
		if ancientsarenotset then
			Ancientcraft:PrintToChat("Welcome to Ancientcraft MP!")
			Ancientcraft:PrintToChat("To train your first unit, click on the ancient and cast \"Train Peasant/Acolyte\".")
			Ancientcraft:PrintToChat("Your objective is to destroy the enemy's base.")
			Ancientcraft:InitAncients()
			ancientsarenotset = false
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function Ancientcraft:spawnunits()
	
end

function GiveGold(parameter)
	mine = parameter.target
	if mine:GetName() == "gold_mine" then
		mine:SetHealth(mine:GetHealth()-100)
		print("Caster team is " .. parameter.caster:GetTeam())
		Ancientcraft:GiveGold(100, parameter.caster:GetTeam())
		print(mine:GetTeam())
	else
		print(mine:GetTeam())
	end
end

function spook()
	Ancientcraft:PrintToChat(nil, "you have been visited by spoki skelton of doto competetiev scene", nil)
	Ancientcraft:PrintToChat(nil, "322 and kappa will come to you", nil)
	Ancientcraft:PrintToChat(nil, "but only if you all chat 'thank mr skeltal'", nil)
end

function Ancientcraft:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
		return
	end
	if spawnedUnit:IsCreature() then
	end
	if spawnedUnit:IsRealHero() then
		spawnedUnit:GetAbilityByIndex(0):SetLevel(1)
		spawnedUnit:GetAbilityByIndex(1):SetLevel(1)
		spawnedUnit:GetAbilityByIndex(2):SetLevel(1)
		spawnedUnit:GetAbilityByIndex(3):SetLevel(1)
		spawnedUnit:GetAbilityByIndex(4):SetLevel(1)
		spawnedUnit:GetAbilityByIndex(5):SetLevel(1)
	end
end

function Ancientcraft:DebugUnit(parameter)
	print("DEBUG UNIT\n--------")
	print(parameter.target:GetName())
	print(parameter.target:GetTeam())
	local pos = parameter.target:GetAbsOrigin()
	print("Position:")
	print("X: " .. pos.x .. " Y: " .. pos.y .. " Z: " .. pos.z)
	print("Abilities:")
	print("Count: " .. parameter.target:GetAbilityCount())
	for i=0,3,1 do
		local ability = parameter.target:GetAbilityByIndex(i)
		print(ability:GetAbilityName())
	end
	print("--------")
end

function DebugUnit(parameter) Ancientcraft:DebugUnit(parameter) end

function SpawnPeasant(parameter)
	local caster = parameter.caster
	if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
		local peasant = nil
		if parameter.caster:GetName() == "dota_goodguys_fort" then
			peasant = CreateUnitByName("npc_dota_creature_peasant", Entities:FindByName(nil, "peasant_spawn"):GetOrigin() + RandomVector(200), true, caster, caster, caster:GetTeamNumber())
		elseif string.match(caster:GetName(), "npc_dota_hero_kunkka") or string.match(caster:GetName(), "npc_dota_hero_warlock") then
			rPrint(parameter)
			peasant = CreateUnitByName("npc_dota_creature_peasant", parameter.target_points[1], true, caster, caster, caster:GetTeamNumber())
		end
		peasant:AddAbility("build_tower")
		peasant:AddAbility("build_rax")
		peasant:AddAbility("build_guard_tower")
		peasant:AddAbility("mine")
		for i=0,3,1 do
			peasant:GetAbilityByIndex(i):SetLevel(1)
		end
		for j=0, 9, 1 do
			if PlayerResource:GetTeam(j) == DOTA_TEAM_GOODGUYS then
				peasant:SetControllableByPlayer(j, true)
				peasant:SetOwner(PlayerResource:GetPlayer(j):GetAssignedHero())
			end
		end
	elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then
		local acolyte = nil
		if parameter.caster:GetName() == "dota_badguys_fort" then
			acolyte = CreateUnitByName("npc_dota_creature_acolyte", Entities:FindByName(nil, "acolyte_spawn"):GetOrigin() + RandomVector(200), true, caster, caster, caster:GetTeamNumber())
		elseif string.match(caster:GetName(), "npc_dota_hero_warlock") or string.match(caster:GetName(), "npc_dota_hero_kunkka") then
			acolyte = CreateUnitByName("npc_dota_creature_acolyte", parameter.target_points[1], true, caster, caster, caster:GetTeamNumber())
		end
		acolyte:AddAbility("build_tower")
		acolyte:AddAbility("build_rax")
		acolyte:AddAbility("build_guard_tower")
		acolyte:AddAbility("mine")
		for i=0,3,1 do
			acolyte:GetAbilityByIndex(i):SetLevel(1)
		end
		for j=0, 9, 1 do
			if PlayerResource:GetTeam(j) == DOTA_TEAM_BADGUYS then
				acolyte:SetControllableByPlayer(j, true)
				acolyte:SetOwner(PlayerResource:GetPlayer(j):GetAssignedHero())
			end
		end
	end
end

function SpawnBarracks(parameter)
	local caster = parameter.caster
	local barrack = nil
	if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
		barrack = CreateUnitByName("npc_dota_bfort", parameter.target_points[1], true, caster, caster, caster:GetTeamNumber())
		barrack:AddAbility("train_footman")
		barrack:GetAbilityByIndex(0):SetLevel(1)
		for j=0, 9, 1 do
			if PlayerResource:GetTeam(j) == DOTA_TEAM_GOODGUYS then
				barrack:SetControllableByPlayer(j, true)
				barrack:SetOwner(PlayerResource:GetPlayer(j):GetAssignedHero())
			end
		end
	elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then
		barrack = CreateUnitByName("npc_dota_bfort", parameter.target_points[1], true, caster, caster, caster:GetTeamNumber())
		barrack:AddAbility("train_ghoul")
		barrack:GetAbilityByIndex(0):SetLevel(1)
		for j=0, 9, 1 do
			if PlayerResource:GetTeam(j) == DOTA_TEAM_BADGUYS then
				barrack:SetControllableByPlayer(j, true)
				barrack:SetOwner(PlayerResource:GetPlayer(j):GetAssignedHero())
			end
		end
	end
end

function rPrint(s, l, i) -- recursive Print (structure, limit, indent)
	l = (l) or 100; i = i or "";	-- default item limit, indent string
	if (l<1) then print "ERROR: Item limit reached."; return l-1 end;
	local ts = type(s);
	if (ts ~= "table") then print (i,ts,s); return l-1 end
	print (i,ts);           -- print "table"
	for k,v in pairs(s) do  -- print "[KEY] VALUE"
		l = rPrint(v, l, i.."\t["..tostring(k).."]");
		if (l < 0) then break end
	end
	return l
end