util.AddNetworkString( "arccube_property" )
util.AddNetworkString( "arccube_preset" )

net.Receive( "arccube_property", function( len, ply )
    local ent = net.ReadEntity()
    local prop = net.ReadString()
    local value = net.ReadType()
    
    if not IsValid( ent ) or ent:GetClass() ~= "ent_term_arccube" then return end
    if not gamemode.Call( "CanProperty", ply, "arccube_settings", ent ) then return end
    
    local props = {
        enabled = function( v ) ent:SetArcEnabled( v ) end,
        scale = function( v ) ent:SetArcScale( math.Clamp( v, 0.1, 50 ) ) end,
        segments = function( v ) ent:SetArcSegments( math.Clamp( v, 3, 128 ) ) end,
        jitter = function( v ) ent:SetArcJitter( math.Clamp( v, 1, 1000 ) ) end,
        range = function( v ) ent:SetArcRange( math.Clamp( v, 16, 16384 ) ) end,
        rate = function( v ) ent:SetArcRate( math.Clamp( v, 0.01, 30 ) ) end,
        width = function( v ) ent:SetArcWidth( math.Clamp( v, 0.1, 20 ) ) end,
        duration = function( v ) ent:SetArcDuration( math.Clamp( v, 0.1, 20 ) ) end,
        flicker = function( v ) ent:SetArcFlicker( math.Clamp( v, 0.1, 20 ) ) end,
        lightbrightness = function( v ) ent:SetArcLightBrightness( math.Clamp( v, 0, 20 ) ) end,
        branchcount = function( v ) ent:SetArcBranchCount( math.Clamp( v, 0, 50 ) ) end,
        mode = function( v ) ent:SetArcMode( math.Clamp( v, 0, 2 ) ) end,
        nolight = function( v ) ent:SetArcNoLight( v ) end,
        branches = function( v ) ent:SetArcBranches( v ) end,
        nofade = function( v ) ent:SetArcNoFade( v ) end,
        thickcore = function( v ) ent:SetArcThickCore( v ) end,
        noflicker = function( v ) ent:SetArcNoFlicker( v ) end,
        multitarget = function( v ) ent:SetArcMultiTarget( v ) end,
        nosound = function( v ) ent:SetArcNoSound( v ) end,
        color = function( v )
            if istable( v ) then
                ent:SetArcColorR( math.Clamp( v[1] or 100, 0, 255 ) )
                ent:SetArcColorG( math.Clamp( v[2] or 150, 0, 255 ) )
                ent:SetArcColorB( math.Clamp( v[3] or 255, 0, 255 ) )
            end
        end,
    }
    
    if props[prop] then props[prop]( value ) end
end )

net.Receive( "arccube_preset", function( len, ply )
    local ent = net.ReadEntity()
    local preset = net.ReadTable()
    
    if not IsValid( ent ) or ent:GetClass() ~= "ent_term_arccube" then return end
    if not gamemode.Call( "CanProperty", ply, "arccube_settings", ent ) then return end
    
    if preset.scale then ent:SetArcScale( preset.scale ) end
    if preset.segments then ent:SetArcSegments( preset.segments ) end
    if preset.jitter then ent:SetArcJitter( preset.jitter ) end
    if preset.range then ent:SetArcRange( preset.range ) end
    if preset.rate then ent:SetArcRate( preset.rate ) end
    if preset.width then ent:SetArcWidth( preset.width ) end
    if preset.duration then ent:SetArcDuration( preset.duration ) end
    if preset.flicker then ent:SetArcFlicker( preset.flicker ) end
    if preset.lightbrightness then ent:SetArcLightBrightness( preset.lightbrightness ) end
    if preset.branchcount then ent:SetArcBranchCount( preset.branchcount ) end
    if preset.mode then ent:SetArcMode( preset.mode ) end
    if preset.branches ~= nil then ent:SetArcBranches( preset.branches ) end
    if preset.thickcore ~= nil then ent:SetArcThickCore( preset.thickcore ) end
    if preset.nofade ~= nil then ent:SetArcNoFade( preset.nofade ) end
    if preset.noflicker ~= nil then ent:SetArcNoFlicker( preset.noflicker ) end
    if preset.nolight ~= nil then ent:SetArcNoLight( preset.nolight ) end
    if preset.multitarget ~= nil then ent:SetArcMultiTarget( preset.multitarget ) end
    if preset.nosound ~= nil then ent:SetArcNoSound( preset.nosound ) end
    
    if preset.color and istable( preset.color ) then
        ent:SetArcColorR( preset.color[1] or 100 )
        ent:SetArcColorG( preset.color[2] or 150 )
        ent:SetArcColorB( preset.color[3] or 255 )
    end
end )