AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    
    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
    end
    
    self.NextArc = 0
end

function ENT:Use( activator, caller )
    self:SetArcEnabled( not self:GetArcEnabled() )
    
    if IsValid( activator ) and activator:IsPlayer() then
        activator:ChatPrint( "Lightning Arc: " .. ( self:GetArcEnabled() and "ENABLED" or "DISABLED" ) )
    end
end

function ENT:Think()
    if not self:GetArcEnabled() then return end
    if CurTime() < self.NextArc then return end
    
    self.NextArc = CurTime() + math.max( self:GetArcRate(), 0.01 )
    
    local startPos = self:GetPos()
    local mode = self:GetArcMode()
    local range = self:GetArcRange()
    
    if mode == ARC_MODE_CONNECT then
        self:FireConnectArcs( startPos, range )
    elseif mode == ARC_MODE_TRACE then
        local tr = util.TraceLine( {
            start = startPos,
            endpos = startPos + self:GetUp() * -range,
            filter = self
        } )
        self:FireArc( startPos, tr.HitPos, false )
    else
        local dir = VectorRand():GetNormalized()
        local tr = util.TraceLine( {
            start = startPos,
            endpos = startPos + dir * range,
            filter = self
        } )
        self:FireArc( startPos, tr.HitPos, false )
    end
end

function ENT:FireConnectArcs( startPos, range )
    local targets = {}
    
    for _, ent in ipairs( ents.FindInSphere( startPos, range ) ) do
        if ent ~= self and ( ent:IsPlayer() or ent:IsNPC() or ent:GetClass() == "prop_physics" or ent:GetClass() == "ent_term_arccube" ) then
            local targetPos = ent:GetPos()
            local obbCenter = ent:OBBCenter()
            if obbCenter then
                targetPos = targetPos + obbCenter
            end
            targets[#targets + 1] = targetPos
        end
    end
    
    local traceCount = self:GetArcMultiTarget() and 6 or 3
    for i = 1, traceCount do
        local dir = VectorRand():GetNormalized()
        local tr = util.TraceLine( {
            start = startPos,
            endpos = startPos + dir * range,
            filter = self
        } )
        if tr.Hit then
            targets[#targets + 1] = tr.HitPos
        end
    end
    
    if #targets == 0 then return end
    
    local arcCount = self:GetArcMultiTarget() and math.min( #targets, 4 ) or 1
    
    for i = 1, arcCount do
        if #targets == 0 then break end
        local idx = math.random( 1, #targets )
        self:FireArc( startPos, targets[idx], true )
        table.remove( targets, idx )
    end
end

function ENT:FireArc( startPos, endPos, isConnect )
    local fx = EffectData()
    fx:SetStart( startPos )
    fx:SetOrigin( endPos )
    fx:SetScale( self:GetArcScale() )
    fx:SetMagnitude( self:GetArcSegments() )
    fx:SetRadius( self:GetArcJitter() )
    fx:SetSurfaceProp( self:GetArcWidth() )
    fx:SetHitBox( self:GetArcDuration() )
    fx:SetMaterialIndex( self:GetArcFlicker() )
    fx:SetColor( self:GetArcLightBrightness() )
    fx:SetEntity( self )
    
    local branchCount = self:GetArcBranchCount()
    if branchCount > 0 then
        fx:SetDamageType( branchCount )
    end
    
    fx:SetNormal( Vector(
        self:GetArcColorR() / 255,
        self:GetArcColorG() / 255,
        self:GetArcColorB() / 255
    ) )
    
    local flags = 0
    if self:GetArcNoLight() then flags = flags + 1 end
    if self:GetArcBranches() then flags = flags + 2 end
    if self:GetArcNoFade() then flags = flags + 4 end
    if isConnect then flags = flags + 8 end
    if self:GetArcThickCore() then flags = flags + 16 end
    if self:GetArcNoFlicker() then flags = flags + 32 end
    if self:GetArcNoSound() then flags = flags + 64 end
    fx:SetFlags( flags )
    
    util.Effect( "eff_term_goodarc", fx )
end

function ENT:PreEntityCopy()
    self.ArcData = {
        Scale = self:GetArcScale(),
        Segments = self:GetArcSegments(),
        Jitter = self:GetArcJitter(),
        Range = self:GetArcRange(),
        Rate = self:GetArcRate(),
        Width = self:GetArcWidth(),
        Duration = self:GetArcDuration(),
        Flicker = self:GetArcFlicker(),
        LightBrightness = self:GetArcLightBrightness(),
        BranchCount = self:GetArcBranchCount(),
        ColorR = self:GetArcColorR(),
        ColorG = self:GetArcColorG(),
        ColorB = self:GetArcColorB(),
        Mode = self:GetArcMode(),
        Enabled = self:GetArcEnabled(),
        NoLight = self:GetArcNoLight(),
        Branches = self:GetArcBranches(),
        NoFade = self:GetArcNoFade(),
        ThickCore = self:GetArcThickCore(),
        NoFlicker = self:GetArcNoFlicker(),
        MultiTarget = self:GetArcMultiTarget(),
        NoSound = self:GetArcNoSound(),
    }
    duplicator.StoreEntityModifier( self, "ArcData", self.ArcData )
end

function ENT:PostEntityPaste( ply, ent, createdEntities )
    local d = self.ArcData
    if not d then return end
    
    self:SetArcScale( d.Scale or 1 )
    self:SetArcSegments( d.Segments or 8 )
    self:SetArcJitter( d.Jitter or 20 )
    self:SetArcRange( d.Range or 256 )
    self:SetArcRate( d.Rate or 0.2 )
    self:SetArcWidth( d.Width or 1 )
    self:SetArcDuration( d.Duration or 1 )
    self:SetArcFlicker( d.Flicker or 1 )
    self:SetArcLightBrightness( d.LightBrightness or 1 )
    self:SetArcBranchCount( d.BranchCount or 0 )
    self:SetArcColorR( d.ColorR or 100 )
    self:SetArcColorG( d.ColorG or 150 )
    self:SetArcColorB( d.ColorB or 255 )
    self:SetArcMode( d.Mode or 0 )
    self:SetArcEnabled( d.Enabled ~= false )
    self:SetArcNoLight( d.NoLight or false )
    self:SetArcBranches( d.Branches or false )
    self:SetArcNoFade( d.NoFade or false )
    self:SetArcThickCore( d.ThickCore or false )
    self:SetArcNoFlicker( d.NoFlicker or false )
    self:SetArcMultiTarget( d.MultiTarget or false )
    self:SetArcNoSound( d.NoSound or false )
end

duplicator.RegisterEntityModifier( "ArcData", function( ply, ent, data )
    ent.ArcData = data
end )