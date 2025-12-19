ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Lightning Arc Cube"
ENT.Author = "regunkyle"
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_BOTH

ARC_MODE_RANDOM = 0
ARC_MODE_TRACE = 1
ARC_MODE_CONNECT = 2

function ENT:SetupDataTables()
    self:NetworkVar( "Float", 0, "ArcScale" )
    self:NetworkVar( "Float", 1, "ArcSegments" )
    self:NetworkVar( "Float", 2, "ArcJitter" )
    self:NetworkVar( "Float", 3, "ArcRange" )
    self:NetworkVar( "Float", 4, "ArcRate" )
    self:NetworkVar( "Float", 5, "ArcWidth" )
    self:NetworkVar( "Float", 6, "ArcDuration" )
    self:NetworkVar( "Float", 7, "ArcFlicker" )
    self:NetworkVar( "Float", 8, "ArcLightBrightness" )
    self:NetworkVar( "Float", 9, "ArcBranchCount" )
    
    self:NetworkVar( "Int", 0, "ArcColorR" )
    self:NetworkVar( "Int", 1, "ArcColorG" )
    self:NetworkVar( "Int", 2, "ArcColorB" )
    self:NetworkVar( "Int", 3, "ArcMode" )
    
    self:NetworkVar( "Bool", 0, "ArcEnabled" )
    self:NetworkVar( "Bool", 1, "ArcNoLight" )
    self:NetworkVar( "Bool", 2, "ArcBranches" )
    self:NetworkVar( "Bool", 3, "ArcNoFade" )
    self:NetworkVar( "Bool", 4, "ArcThickCore" )
    self:NetworkVar( "Bool", 5, "ArcNoFlicker" )
    self:NetworkVar( "Bool", 6, "ArcMultiTarget" )
    self:NetworkVar( "Bool", 7, "ArcNoSound" )
    
    if SERVER then
        self:SetArcScale( 1 )
        self:SetArcSegments( 8 )
        self:SetArcJitter( 20 )
        self:SetArcRange( 256 )
        self:SetArcRate( 0.2 )
        self:SetArcWidth( 1 )
        self:SetArcDuration( 1 )
        self:SetArcFlicker( 1 )
        self:SetArcLightBrightness( 1 )
        self:SetArcBranchCount( 0 )
        self:SetArcColorR( 100 )
        self:SetArcColorG( 150 )
        self:SetArcColorB( 255 )
        self:SetArcMode( ARC_MODE_RANDOM )
        self:SetArcEnabled( true )
        self:SetArcNoLight( false )
        self:SetArcBranches( false )
        self:SetArcNoFade( false )
        self:SetArcThickCore( false )
        self:SetArcNoFlicker( false )
        self:SetArcMultiTarget( false )
        self:SetArcNoSound( false )
    end
end