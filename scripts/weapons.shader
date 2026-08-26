

progs/weapons/grenadelauncher/w_grenade_d
{
    {
       	map progs/weapons/grenadelauncher/w_grenade_d.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/weapons/grenadelauncher/w_grenade_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/nailgun/scope
{
    {
       	map progs/weapons/nailgun/scope.tga
        blendFunc GL_ONE GL_ONE
        rgbGen entity
    }
}

progs/weapons/nailgun/nail
{
    {
        progs/weapons/nailgun/nail_g.tga
        blendFunc add
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}

progs/weapons/hyperblaster/mhb
{
    {
       	map progs/weapons/hyperblaster/mhb.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/weapons/hyperblaster/mhb_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/blaster/bp_lo
{
    {
       	map progs/weapons/blaster/bp_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/weapons/blaster/bp_lo_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}


progs/weapons/lightning_gun/lg_lo
{
    {
       	map progs/weapons/lightning_gun/lg_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/weapons/lightning_gun/lg_lo_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}


progs/weapons/darkmatter/dmg
{
    {
       	map progs/weapons/darkmatter/dmg.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/weapons/darkmatter/dmg_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/railgun/rg
{
    {
       	map progs/weapons/railgun/rg.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/weapons/railgun/rg_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

gfx/recticals/nailgun_scope_target
{
	sort 16
	nodepth
	cull disable
	{
		map gfx/recticals/nailgun_scope_target.tga
		blendfunc GL_ONE GL_ONE
		tcMod rotate 200
		tcMod scale 1 1
	}
}


gfx/recticals/nailgun_scope_target_NAN
{
	sort 16
	nodepth
	cull disable
	{
		map gfx/recticals/nailgun_scope_target_NAN.tga
		blendfunc GL_ONE GL_ONE
		tcMod rotate 200
		tcMod scale 1 1
	}
}

progs/weapons/railgun/gui_ready
{
    sort 16
    {
       	map progs/weapons/railgun/bg.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
    {
        map progs/weapons/railgun/bg_charge.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/railgun/gui_notready
{
    sort 16
    {
       	map progs/weapons/railgun/bg.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
    {	 
	animMap 6 progs/weapons/railgun/bg_charge2_0.tga progs/weapons/railgun/bg_charge2_1.tga

      //  map progs/weapons/railgun/bg_charge2.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/rocketlauncher/gui1
{
    sort 16
    {	 
	//animMap 6 progs/weapons/railgun/bg_charge2_1.tga progs/weapons/railgun/bg_charge2_3.tga

      	map progs/weapons/rocketlauncher/gui1.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/rocketlauncher/gui2
{
    sort 16
    {	 
	//animMap 6 progs/weapons/railgun/bg_charge2_1.tga progs/weapons/railgun/bg_charge2_3.tga

      	map progs/weapons/rocketlauncher/gui2.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/rocketlauncher/gui3
{
    sort 16
    {	 
	//animMap 6 progs/weapons/railgun/bg_charge2_1.tga progs/weapons/railgun/bg_charge2_3.tga

      	map progs/weapons/rocketlauncher/gui3.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/rocketlauncher/gui4
{
    sort 16
    {	 
	//animMap 6 progs/weapons/railgun/bg_charge2_1.tga progs/weapons/railgun/bg_charge2_3.tga

      	map progs/weapons/rocketlauncher/gui4.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

progs/weapons/shotgun/gui_ready
{
    sort 16
    {
       	map progs/weapons/shotgun/bg.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
}

progs/weapons/shotgun/gui_notready
{
    sort 16
    {
       	animMap 6 progs/weapons/shotgun/bg1_0.tga progs/weapons/shotgun/bg1_1.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
}

progs/weapons/hyperblaster/gui_ready
{
    sort 16
    {
       	map progs/weapons/hyperblaster/bg.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
}

progs/weapons/hyperblaster/gui_notready
{
    sort 16
    {
       	animMap 6 progs/weapons/hyperblaster/bg1_0.tga progs/weapons/hyperblaster/bg1_1.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
}

progs/weapons/machinegun/gui_ready
{
    sort 16
    {
       	map progs/weapons/machinegun/bg.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
}

progs/weapons/machinegun/gui_notready
{
    sort 16
    {
       	map progs/weapons/machinegun/bg1.tga 
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen entity
    }
}

progs/weapons/machinegun/crosshair_machinegun
{
    sort 16
    {
       	map progs/weapons/machinegun/crosshair_machinegun.tga 
         blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity

    }
}

effects/weapons/tracerlarge
{
    sort 16
    {
       	map effects/weapons/tracerlarge.tga 
         blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity

    }
}

models/weapons/blaster/flare
{
    sort 16
    nodepth
    cull disable
    {
       	map progs/weapons/flare.tga 
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

