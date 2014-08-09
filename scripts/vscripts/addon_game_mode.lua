-- Generated from template

if Ancientcraft == nil then
	Ancientcraft = class({})
end
givenGold = 0

minesarenotset = true

humanWood = 250
scourgeWood = 250


function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheUnitByNameAsync( "npc_dota_creature_tower_peasant", context )
    PrecacheModel( "npc_dota_creature_tower_peasant", context )
	PrecacheUnitByNameAsync( "npc_dota_creature_rax_peasant", context )
    PrecacheModel( "npc_dota_creature_rax_peasant", context )
	PrecacheItemByNameSync( "item_peasants", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = Ancientcraft()
	GameRules.AddonTemplate:InitGameMode()
end

function Ancientcraft:InitGameMode()
	print( "Ancientcraft is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:SetPreGameTime( 15.0 )
	GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetSafeToLeave(true)
	Convars:RegisterCommand( "ac_recheckmines", function(...) return self:CheckMines( ... ) end, "[debug] check for mines again", FCVAR_CHEAT )
	Convars:RegisterCommand( "ac_printchat", function(...) return self:PrintToChat( ... ) end, "[debug] print to chat", FCVAR_CHEAT )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( Ancientcraft, "OnNPCSpawned" ), self )
	GameRules:SendCustomMessage("Welcome to Ancientcraft MP!", 3, 1)
	GameRules:SendCustomMessage("Welcome to Ancientcraft MP!", 1, 1)
end

function Ancientcraft:GiveGold(givenGold, isScourge)
	
	gghero = nil
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if ( PlayerResource:IsValidPlayer( nPlayerID ) ) then
			local player = PlayerResource:GetPlayer(nPlayerID)
			print("Found player in team" .. player:GetTeam())
			if isScourge == PlayerResource:GetPlayer(nPlayerID):GetTeam() then
				gghero = nPlayerID
				print("gghero is team 3")
			elseif not isScourge == PlayerResource:GetPlayer(nPlayerID):GetTeam() then
				gghero = nPlayerID
				print("gghero is team 2")
			end
		end
	end
	print("goldgive")
	PlayerResource:ModifyGold(gghero, 200, true, 0)
end

function Ancientcraft:CheckMines()
	goldmines = Entities:FindAllByName("gold_mine")
	noM = 0
	for i,mine in ipairs(goldmines) do noM = noM + 1 end
	print("Found " .. noM .. " mines.")
	Convars:RegisterCommand( "ac_printchat", function(...) return self:PrintToChat( ... ) end, "[debug] print to chat", FCVAR_CHEAT )
	ShowMessage("Found " .. noM .. " mines.")
	for i,v in ipairs(goldmines) do
		v:SetMaxHealth(5000)
		v:SetHealth(5000)
		v:SetInvulnCount(0)
		v:SetTeam(4)
	end
	neutral = Entities:FindAllByClassname("npc_dota_neutral")
	for i,c in ipairs(neutral) do print(neutral:GetTeam()) end
end

function Ancientcraft:PrintToChat(cmdname, msg, team)
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

function CutTree(parameter) -- #cut4gaben
	local tree = parameter.target
	local caster = parameter.caster
	local casterTeam = caster:GetTeam()
	tree:Kill()
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if ( PlayerResource:IsValidPlayer( nPlayerID ) ) then
			local player = PlayerResource:GetPlayer(nPlayerID)
			print("Found player in team" .. player:GetTeam())
			if casterTeam == PlayerResource:GetPlayer(nPlayerID):GetTeam() then
				scourgeWood = scourgeWood + 200
				print("gwhero is team 3")
			elseif not casterTeam == PlayerResource:GetPlayer(nPlayerID):GetTeam() then
				humanWood = humanWood + 200
				print("gwhero is team 2")
			end
		end
	end
end

initialLVLUP = false

function Ancientcraft:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
		return
	end
	if spawnedUnit:IsCreature() then
		print("Creature spawned: " .. spawnedUnit:GetName() .. " Team: " .. spawnedUnit:GetTeam())
	end
	if spawnedUnit:IsRealHero() then
		if not initialLVLUP then
			spawnedUnit:GetAbilityByIndex(0):SetLevel(4)
			spawnedUnit:GetAbilityByIndex(1):SetLevel(4)
			spawnedUnit:GetAbilityByIndex(2):SetLevel(4)
		end
		initialLVLUP = true
	end
end

function Ancientcraft:DebugUnit(parameter)
	print("DEBUG UNIT\n--------")
	print(parameter.target:GetName())
	print(parameter.target:GetTeam())
	local pos = parameter.target:GetAbsOrigin()
	print("Position:")
	print("X: " .. pos.x .. " Y: " .. pos.y .. " Z: " .. pos.z)
	print("--------")
end

function DebugUnit(parameter) Ancientcraft:DebugUnit(parameter) end