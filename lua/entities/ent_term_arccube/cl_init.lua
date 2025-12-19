include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()
    
    if not self:GetArcEnabled() then return end
    if self:GetArcNoLight() then return end
    
    local dlight = DynamicLight( self:EntIndex() )
    if dlight then
        dlight.Pos = self:GetPos()
        dlight.R = self:GetArcColorR()
        dlight.G = self:GetArcColorG()
        dlight.B = self:GetArcColorB()
        dlight.Brightness = math.min( 2 * self:GetArcLightBrightness(), 5 )
        dlight.Size = math.min( 128 * self:GetArcScale(), 512 )
        dlight.Decay = 1000
        dlight.DieTime = CurTime() + 0.1
    end
end

local function AddSliderSubmenu( submenu, label, current, values, callback )
    local sub = submenu:AddSubMenu( label .. ": " .. current )
    for _, v in ipairs( values ) do
        sub:AddOption( tostring( v ), function() callback( v ) end )
    end
end

local function AddToggle( submenu, label, state, callback )
    submenu:AddOption( ( state and "☑ " or "☐ " ) .. label, function() callback( not state ) end )
end

properties.Add( "arccube_settings", {
    MenuLabel = "Arc Settings",
    Order = 1000,
    MenuIcon = "icon16/lightning.png",
    
    Filter = function( self, ent, ply )
        if not IsValid( ent ) then return false end
        if ent:GetClass() ~= "ent_term_arccube" then return false end
        if not gamemode.Call( "CanProperty", ply, "arccube_settings", ent ) then return false end
        return true
    end,
    
    MenuOpen = function( self, option, ent, tr )
        local submenu = option:AddSubMenu()
        
        local enableOpt = submenu:AddOption( ent:GetArcEnabled() and "⚡ Disable Arc" or "⚡ Enable Arc", function()
            self:SetProperty( ent, "enabled", not ent:GetArcEnabled() )
        end )
        enableOpt:SetIcon( ent:GetArcEnabled() and "icon16/stop.png" or "icon16/accept.png" )
        
        submenu:AddSpacer()
        
        local modeNames = { [0] = "Random Direction", [1] = "Trace Down", [2] = "Connect" }
        local modeMenu = submenu:AddSubMenu( "Mode: " .. modeNames[ent:GetArcMode()] )
        for i, name in pairs( modeNames ) do
            modeMenu:AddOption( name, function() self:SetProperty( ent, "mode", i ) end )
        end
        
        submenu:AddSpacer()
        
        AddSliderSubmenu( submenu, "Scale", ent:GetArcScale(),
            { 0.1, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5, 8, 10, 15, 20 },
            function( v ) self:SetProperty( ent, "scale", v ) end )
        
        AddSliderSubmenu( submenu, "Segments", ent:GetArcSegments(),
            { 3, 4, 6, 8, 10, 12, 16, 20, 24, 32, 48, 64 },
            function( v ) self:SetProperty( ent, "segments", v ) end )
        
        AddSliderSubmenu( submenu, "Jitter", ent:GetArcJitter(),
            { 1, 5, 10, 15, 20, 30, 40, 60, 80, 100, 150, 200, 300, 500 },
            function( v ) self:SetProperty( ent, "jitter", v ) end )
        
        AddSliderSubmenu( submenu, "Range", ent:GetArcRange(),
            { 32, 64, 128, 256, 384, 512, 768, 1024, 1536, 2048, 3072, 4096, 8192 },
            function( v ) self:SetProperty( ent, "range", v ) end )
        
        AddSliderSubmenu( submenu, "Fire Rate", ent:GetArcRate() .. "s",
            { 0.01, 0.02, 0.05, 0.1, 0.15, 0.2, 0.3, 0.5, 0.75, 1, 1.5, 2, 3, 5 },
            function( v ) self:SetProperty( ent, "rate", v ) end )
        
        submenu:AddSpacer()
        
        local advMenu = submenu:AddSubMenu( "Advanced Settings" )
        
        AddSliderSubmenu( advMenu, "Beam Width", ent:GetArcWidth() .. "x",
            { 0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 2.5, 3, 4, 5, 8, 10 },
            function( v ) self:SetProperty( ent, "width", v ) end )
        
        AddSliderSubmenu( advMenu, "Duration", ent:GetArcDuration() .. "x",
            { 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 8, 10 },
            function( v ) self:SetProperty( ent, "duration", v ) end )
        
        AddSliderSubmenu( advMenu, "Flicker Speed", ent:GetArcFlicker() .. "x",
            { 0.1, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 5, 10 },
            function( v ) self:SetProperty( ent, "flicker", v ) end )
        
        AddSliderSubmenu( advMenu, "Light Brightness", ent:GetArcLightBrightness() .. "x",
            { 0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 8, 10 },
            function( v ) self:SetProperty( ent, "lightbrightness", v ) end )
        
        AddSliderSubmenu( advMenu, "Branch Count", ent:GetArcBranchCount() == 0 and "Auto" or ent:GetArcBranchCount(),
            { 0, 1, 2, 3, 4, 5, 6, 8, 10, 15, 20 },
            function( v ) self:SetProperty( ent, "branchcount", v ) end )
        
        submenu:AddSpacer()
        
        local colorMenu = submenu:AddSubMenu( "Color" )
        
        local colors = {
            { "Blue (Default)", 100, 150, 255 },
            { "Electric Blue", 50, 100, 255 },
            { "Sky Blue", 100, 200, 255 },
            { "Red", 255, 30, 30 },
            { "Pink", 220, 20, 60 },
            { "Green", 30, 255, 30 },
            { "Lime", 150, 255, 50 },
            { "Yellow", 255, 255, 30 },
            { "Gold", 255, 200, 50 },
            { "Purple", 160, 30, 255 },
            { "Teal", 50, 200, 200 },
            { "Orange", 255, 130, 30 },
        }
        
        for _, c in ipairs( colors ) do
            colorMenu:AddOption( c[1], function()
                self:SetProperty( ent, "color", { c[2], c[3], c[4] } )
            end )
        end
        
        colorMenu:AddSpacer()
        
        local customColorOpt = colorMenu:AddOption( "Custom Color...", function()
            self:OpenColorPicker( ent )
        end )
        customColorOpt:SetIcon( "icon16/color_wheel.png" )
        
        submenu:AddSpacer()
        
        local toggleMenu = submenu:AddSubMenu( "Toggle Options" )
        
        AddToggle( toggleMenu, "Branches", ent:GetArcBranches(),
            function( v ) self:SetProperty( ent, "branches", v ) end )
        
        AddToggle( toggleMenu, "Thick Core", ent:GetArcThickCore(),
            function( v ) self:SetProperty( ent, "thickcore", v ) end )
        
        AddToggle( toggleMenu, "No Fade", ent:GetArcNoFade(),
            function( v ) self:SetProperty( ent, "nofade", v ) end )
        
        AddToggle( toggleMenu, "No Flicker", ent:GetArcNoFlicker(),
            function( v ) self:SetProperty( ent, "noflicker", v ) end )
        
        AddToggle( toggleMenu, "No Dynamic Light", ent:GetArcNoLight(),
            function( v ) self:SetProperty( ent, "nolight", v ) end )
        
        AddToggle( toggleMenu, "No Sound", ent:GetArcNoSound(),
            function( v ) self:SetProperty( ent, "nosound", v ) end )
        
        AddToggle( toggleMenu, "Multi-Target (Connect Mode)", ent:GetArcMultiTarget(),
            function( v ) self:SetProperty( ent, "multitarget", v ) end )
        
        submenu:AddSpacer()
        
        local presetMenu = submenu:AddSubMenu( "Presets" )
        
        presetMenu:AddOption( "Default", function()
            self:ApplyPreset( ent, {
                scale = 1, segments = 8, jitter = 20, range = 256, rate = 0.2,
                width = 1, duration = 1, flicker = 1, lightbrightness = 1,
                color = { 100, 150, 255 }, branches = false, thickcore = false,
                branchcount = 0, mode = ARC_MODE_RANDOM, multitarget = false,
                nofade = false, noflicker = false, nolight = false, nosound = false
            } )
        end )
        
        presetMenu:AddSpacer()
        
        presetMenu:AddOption( "Tesla Coil", function()
            self:ApplyPreset( ent, {
                scale = 1, segments = 12, jitter = 25, range = 300, rate = 0.08,
                width = 1, duration = 0.8, flicker = 1.5, lightbrightness = 1.5,
                color = { 150, 180, 255 }, branches = true, thickcore = true,
                branchcount = 3, mode = ARC_MODE_CONNECT, multitarget = true
            } )
        end )
        
        presetMenu:AddOption( "Gentle Spark", function()
            self:ApplyPreset( ent, {
                scale = 0.5, segments = 6, jitter = 10, range = 128, rate = 0.3,
                width = 0.75, duration = 0.5, flicker = 0.5, lightbrightness = 0.5,
                color = { 100, 150, 255 }, branches = false, thickcore = false,
                branchcount = 0, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Plasma Storm", function()
            self:ApplyPreset( ent, {
                scale = 3, segments = 24, jitter = 80, range = 1024, rate = 0.03,
                width = 2, duration = 1.5, flicker = 3, lightbrightness = 3,
                color = { 200, 50, 255 }, branches = true, thickcore = true,
                branchcount = 6, mode = ARC_MODE_RANDOM, multitarget = false
            } )
        end )
        
        presetMenu:AddOption( "Fire Arc", function()
            self:ApplyPreset( ent, {
                scale = 1.5, segments = 16, jitter = 40, range = 384, rate = 0.1,
                width = 1.5, duration = 1, flicker = 2, lightbrightness = 2,
                color = { 255, 100, 30 }, branches = true, thickcore = true,
                branchcount = 4, mode = ARC_MODE_TRACE
            } )
        end )
        
        presetMenu:AddOption( "Matrix Code", function()
            self:ApplyPreset( ent, {
                scale = 0.75, segments = 8, jitter = 5, range = 512, rate = 0.05,
                width = 0.5, duration = 2, flicker = 0.25, lightbrightness = 0.75,
                color = { 30, 255, 30 }, branches = false, thickcore = false,
                branchcount = 0, mode = ARC_MODE_TRACE, noflicker = true
            } )
        end )
        
        presetMenu:AddOption( "Chain Lightning", function()
            self:ApplyPreset( ent, {
                scale = 1, segments = 10, jitter = 30, range = 512, rate = 0.15,
                width = 1, duration = 1, flicker = 1, lightbrightness = 1.5,
                color = { 100, 200, 255 }, branches = true, thickcore = true,
                branchcount = 2, mode = ARC_MODE_CONNECT, multitarget = true
            } )
        end )
        
        presetMenu:AddOption( "Welding Arc", function()
            self:ApplyPreset( ent, {
                scale = 0.3, segments = 4, jitter = 3, range = 64, rate = 0.02,
                width = 2, duration = 0.3, flicker = 5, lightbrightness = 4,
                color = { 255, 255, 255 }, branches = false, thickcore = true,
                branchcount = 0, mode = ARC_MODE_TRACE, noflicker = false
            } )
        end )
        
        presetMenu:AddOption( "Sith Lightning", function()
            self:ApplyPreset( ent, {
                scale = 1.2, segments = 14, jitter = 35, range = 400, rate = 0.04,
                width = 0.8, duration = 0.6, flicker = 2, lightbrightness = 1.5,
                color = { 180, 50, 255 }, branches = true, thickcore = false,
                branchcount = 5, mode = ARC_MODE_RANDOM, multitarget = false
            } )
        end )
        
        presetMenu:AddSpacer()
        
        presetMenu:AddOption( "Electric Fence", function()
            self:ApplyPreset( ent, {
                scale = 0.4, segments = 5, jitter = 8, range = 96, rate = 0.5,
                width = 0.6, duration = 0.2, flicker = 3, lightbrightness = 0.8,
                color = { 255, 255, 100 }, branches = false, thickcore = false,
                branchcount = 0, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Taser", function()
            self:ApplyPreset( ent, {
                scale = 0.2, segments = 3, jitter = 2, range = 32, rate = 0.015,
                width = 0.4, duration = 0.15, flicker = 8, lightbrightness = 1,
                color = { 100, 150, 255 }, branches = false, thickcore = true,
                branchcount = 0, mode = ARC_MODE_TRACE
            } )
        end )
        
        presetMenu:AddOption( "Power Surge", function()
            self:ApplyPreset( ent, {
                scale = 2, segments = 20, jitter = 60, range = 768, rate = 0.05,
                width = 1.8, duration = 1.2, flicker = 2.5, lightbrightness = 2.5,
                color = { 255, 200, 50 }, branches = true, thickcore = true,
                branchcount = 4, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Static Discharge", function()
            self:ApplyPreset( ent, {
                scale = 0.6, segments = 7, jitter = 15, range = 200, rate = 0.8,
                width = 0.5, duration = 0.1, flicker = 1, lightbrightness = 0.6,
                color = { 200, 220, 255 }, branches = true, thickcore = false,
                branchcount = 2, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Lightning Strike", function()
            self:ApplyPreset( ent, {
                scale = 5, segments = 32, jitter = 150, range = 4096, rate = 2,
                width = 3, duration = 0.8, flicker = 1, lightbrightness = 5,
                color = { 220, 220, 255 }, branches = true, thickcore = true,
                branchcount = 8, mode = ARC_MODE_TRACE, nofade = false
            } )
        end )
        
        presetMenu:AddOption( "Unstable Energy", function()
            self:ApplyPreset( ent, {
                scale = 1.5, segments = 18, jitter = 50, range = 400, rate = 0.02,
                width = 1.2, duration = 0.4, flicker = 6, lightbrightness = 2,
                color = { 255, 50, 50 }, branches = true, thickcore = true,
                branchcount = 5, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Healing Beam", function()
            self:ApplyPreset( ent, {
                scale = 0.8, segments = 10, jitter = 12, range = 300, rate = 0.1,
                width = 1, duration = 1.5, flicker = 0.3, lightbrightness = 1,
                color = { 50, 255, 150 }, branches = false, thickcore = true,
                branchcount = 0, mode = ARC_MODE_CONNECT, noflicker = true
            } )
        end )
        
        presetMenu:AddOption( "Death Ray", function()
            self:ApplyPreset( ent, {
                scale = 1.8, segments = 6, jitter = 5, range = 1024, rate = 0.05,
                width = 2.5, duration = 2, flicker = 0.2, lightbrightness = 3,
                color = { 255, 50, 20 }, branches = false, thickcore = true,
                branchcount = 0, mode = ARC_MODE_TRACE, noflicker = true, nofade = true
            } )
        end )
        
        presetMenu:AddOption( "Force Lightning", function()
            self:ApplyPreset( ent, {
                scale = 1, segments = 12, jitter = 28, range = 350, rate = 0.03,
                width = 0.7, duration = 0.5, flicker = 2.5, lightbrightness = 1.8,
                color = { 150, 180, 255 }, branches = true, thickcore = false,
                branchcount = 4, mode = ARC_MODE_CONNECT, multitarget = true
            } )
        end )
        
        presetMenu:AddOption( "Arcane Magic", function()
            self:ApplyPreset( ent, {
                scale = 1.2, segments = 15, jitter = 35, range = 350, rate = 0.12,
                width = 1, duration = 1.2, flicker = 1.5, lightbrightness = 1.5,
                color = { 180, 80, 255 }, branches = true, thickcore = true,
                branchcount = 3, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Neon Sign", function()
            self:ApplyPreset( ent, {
                scale = 0.5, segments = 4, jitter = 2, range = 128, rate = 0.1,
                width = 1.5, duration = 3, flicker = 0.1, lightbrightness = 1.5,
                color = { 255, 50, 150 }, branches = false, thickcore = true,
                branchcount = 0, mode = ARC_MODE_TRACE, noflicker = true, nofade = true
            } )
        end )
        
        presetMenu:AddOption( "Bug Zapper", function()
            self:ApplyPreset( ent, {
                scale = 0.3, segments = 4, jitter = 5, range = 48, rate = 0.4,
                width = 0.8, duration = 0.1, flicker = 4, lightbrightness = 1,
                color = { 150, 100, 255 }, branches = false, thickcore = true,
                branchcount = 0, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Jacob's Ladder", function()
            self:ApplyPreset( ent, {
                scale = 0.6, segments = 8, jitter = 10, range = 128, rate = 0.08,
                width = 1, duration = 0.6, flicker = 2, lightbrightness = 1.2,
                color = { 100, 150, 255 }, branches = false, thickcore = true,
                branchcount = 0, mode = ARC_MODE_TRACE
            } )
        end )
        
        presetMenu:AddOption( "Van de Graaff", function()
            self:ApplyPreset( ent, {
                scale = 0.8, segments = 10, jitter = 20, range = 256, rate = 0.25,
                width = 0.6, duration = 0.3, flicker = 1.5, lightbrightness = 0.8,
                color = { 200, 180, 255 }, branches = true, thickcore = false,
                branchcount = 3, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Overcharge", function()
            self:ApplyPreset( ent, {
                scale = 4, segments = 28, jitter = 100, range = 1500, rate = 0.01,
                width = 2.5, duration = 0.5, flicker = 5, lightbrightness = 4,
                color = { 255, 255, 200 }, branches = true, thickcore = true,
                branchcount = 8, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Ghostly", function()
            self:ApplyPreset( ent, {
                scale = 1, segments = 12, jitter = 30, range = 300, rate = 0.15,
                width = 0.8, duration = 2, flicker = 0.5, lightbrightness = 0.5,
                color = { 100, 255, 200 }, branches = true, thickcore = false,
                branchcount = 2, mode = ARC_MODE_RANDOM, nofade = false
            } )
        end )
        
        presetMenu:AddOption( "Solar Flare", function()
            self:ApplyPreset( ent, {
                scale = 2.5, segments = 20, jitter = 70, range = 600, rate = 0.06,
                width = 2, duration = 1, flicker = 2, lightbrightness = 3,
                color = { 255, 180, 50 }, branches = true, thickcore = true,
                branchcount = 5, mode = ARC_MODE_RANDOM
            } )
        end )
        
        presetMenu:AddOption( "Quiet Spark", function()
            self:ApplyPreset( ent, {
                scale = 0.5, segments = 6, jitter = 10, range = 128, rate = 0.2,
                width = 0.75, duration = 0.5, flicker = 1, lightbrightness = 0.5,
                color = { 100, 150, 255 }, branches = false, thickcore = false,
                branchcount = 0, mode = ARC_MODE_RANDOM, nosound = true
            } )
        end )
    end,
    
    Action = function( self, ent )
        self:SetProperty( ent, "enabled", not ent:GetArcEnabled() )
    end,
    
    SetProperty = function( self, ent, prop, value )
        net.Start( "arccube_property" )
        net.WriteEntity( ent )
        net.WriteString( prop )
        net.WriteType( value )
        net.SendToServer()
    end,
    
    ApplyPreset = function( self, ent, preset )
        net.Start( "arccube_preset" )
        net.WriteEntity( ent )
        net.WriteTable( preset )
        net.SendToServer()
    end,
    
    OpenColorPicker = function( self, ent )
        local frame = vgui.Create( "DFrame" )
        frame:SetSize( 300, 380 )
        frame:SetTitle( "Arc Color" )
        frame:Center()
        frame:MakePopup()
        
        local mixer = vgui.Create( "DColorMixer", frame )
        mixer:Dock( FILL )
        mixer:SetPalette( true )
        mixer:SetAlphaBar( false )
        mixer:SetWangs( true )
        mixer:SetColor( Color( ent:GetArcColorR(), ent:GetArcColorG(), ent:GetArcColorB() ) )
        
        local btn = vgui.Create( "DButton", frame )
        btn:Dock( BOTTOM )
        btn:SetTall( 30 )
        btn:SetText( "Apply Color" )
        btn.DoClick = function()
            local c = mixer:GetColor()
            self:SetProperty( ent, "color", { c.r, c.g, c.b } )
            frame:Close()
        end
    end
} )