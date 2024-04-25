AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "helmet"
ENT.Category		= ""

ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.Models =  "models/dean/gtaiv/helmet.mdl"

if SERVER then
util.AddNetworkString("Val_helmet")

function ENT:Initialize()

	self.Entity:SetModel( self.Models )
	self.Entity:SetMaterial("models/mat_jack_motorcyclehelmet")
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
			
	local phys = self:GetPhysicsObject() 
		
	if phys:IsValid() then
		
		phys:Wake()
			
	end

	self.Ent_Health = 300	
	self:DrawShadow()
	self.SpawnTime = 0
	self.EntCount = 0
end
--[[ 
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "zombie_tree1" )
	ent:SetPos( tr.HitPos + tr.HitNormal * 32 ) 
	ent:Spawn()
	ent:Activate()

	return ent
end ]]
 
function ENT:Think()

end

function ENT:OnTakeDamage( dmg )
		local ply = dmg:GetAttacker()
		local inflictor = dmg:GetInflictor()
		if type(inflictor) == "Entity" then return end
		self.Ent_Health = self.Ent_Health - dmg:GetDamage()
		
end

function ENT:Use( btn, ply )
end

function ENT:StartTouch( entity )
	return false
end

function ENT:EndTouch( entity )
	return false
end

function ENT:Touch( entity )
	return false
end

end

if CLIENT then

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

surface.CreateFont( "BuilderText",
{
	font	= "Arial",
	size	= 21,
	weight	= 400
})


function ENT:Initialize()
	
end

function ENT:Draw()

	self:DrawModel() 
	
					
	
end
	
end
