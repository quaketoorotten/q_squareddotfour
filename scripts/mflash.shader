effects/weapons/mgun_muzzleflash
{
	sort 16
	nodepth
	cull disable
	{
		map effects/weapons/shotgun_mflash.tga
		blendfunc GL_ONE GL_ONE
		tcMod rotate 800
		tcMod scale 1 1
	}
	{
		map effects/weapons/mgun_muzzleflash.tga
		blendfunc GL_ONE GL_ONE
		tcMod rotate -360
	}
}

effects/weapons/shotgun_mflash
{
	sort 16
	nodepth
	cull disable
	{
		map effects/weapons/shotgun_mflash.tga
		blendfunc GL_ONE GL_ONE
		tcMod rotate -800
		tcMod scale 1 1
	}
	{
		map effects/weapons/flash_half3_mf.tga
		blendfunc GL_ONE GL_ONE
	}
}

effects/weapons/blaster_mflash
{
	sort 16
	nodepth
	cull disable
	{
		map effects/weapons/flash_blue2.tga
		blendfunc GL_ONE GL_ONE
		tcMod rotate -800
	}
	{
		map effects/weapons/flash_half4_mf.tga
		blendfunc GL_ONE GL_ONE
		//tcMod rotate -800
		//tcMod scale 2 2.5 
	}
}

effects/weapons/flash_half3
{
	sort 16
	nodepth
	cull disable
	{
		map effects/weapons/flash_half3.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave sin 3 3 0 7
	}
	{
		map effects/weapons/flash_half3.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave sin 3 3 0 7
		//tcMod scale 2 2.5 
	}
}

effects/weapons/lightning_bolt
{	
	sort additive
	nodepth
	{
		map effects/weapons/lgun.tga
		tcMod scroll 0 3.1 
                rgbgen wave sin 1 2 0 7
		blendfunc GL_ONE GL_ONE
	}
}

effects/weapons/darkmatterbolt
{	
	sort additive
	nodepth
//	deformVertexes autosprite
	{
		map effects/weapons/darkmatterbolt.tga
		tcMod scroll 0 3.1 
                rgbgen wave sin 1 2 0 7
		blendfunc GL_ONE GL_ONE
	}
}

effects/weapons/lightning_bolt2
{	
	sort additive
	nodepth
	{
		map effects/weapons/lgun_smallbolt.tga
		tcMod scroll 0 3.1 
                rgbgen wave sin 1 2 0 7
		blendfunc GL_ONE GL_ONE
	}
}

effects/weapons/lightning_bolt3
{	
	sort additive
	nodepth
	{
		map effects/weapons/lgun_smallbolt.tga
                rgbgen wave sin 1 2 0 7
		blendfunc GL_ONE GL_ONE
	}
}

effects/electricity/electricity
{	
	sort additive
	nodepth
	{
		map effects/electricity/electricity.tga
                rgbgen wave sin 1 2 0 7
		blendfunc GL_ONE GL_ONE
	}
}


effects/weapons/rail_trail
{	
	sort additive
	nodepth
	{
		map effects/weapons/rail_trail3.tga
		blendfunc GL_ONE GL_ONE
	}
}

effects/weapons/rail_trail_2
{	
	sort additive
	nodepth
	{
		map effects/weapons/rail_trail2.tga
		blendfunc GL_ONE GL_ONE
	}
}

effects/weapons/rail_mflash
{
	sort 16
	nodepth
	cull disable
	{
		map effects/weapons/rail_flash.tga
		blendfunc GL_ONE GL_ONE
	}
	{
		map effects/weapons/flash_green.tga
		blendfunc GL_ONE GL_ONE
	}
}

effects/weapons/darkmatter_core
{
	sort 16
	nodepth
	cull disable
	autosprite
	{
		clampMap effects/weapons/darkmatteradd.tga
		blendfunc GL_ONE GL_ONE
		tcMod rotate -360
	}
	{
		clampMap effects/weapons/darkmatter_haze.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate -800
	}
	{
		clampMap effects/weapons/darkmatter_dot.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        	alphaFunc GT0
		tcMod rotate -360
	}
	{
		clampMap effects/weapons/darkmatterfilter.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate 800
	}
	{
		clampMap effects/weapons/darkmatter_ring.tga
		blendfunc GL_ONE GL_ONE
		rgbgen wave sin 3 3 0 7
		tcMod rotate 360
		alphaGen const 0.5
	}
}

effects/weapons/darkmatter
{
	sort 16
	nodepth
	cull disable
	deformVertexes autosprite
	
	{
		clampMap effects/weapons/darkmatter_ring.tga
		blendfunc GL_ONE GL_ONE
		//rgbgen wave sin 0.2 1 0 2
		tcMod rotate -360
		alphaGen const 0.2
	}
	{
		clampMap effects/weapons/darkmatter_haze.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate -360
	}

	{
		clampMap effects/weapons/darkmatteradd.tga
		blendFunc GL_ONE GL_ONE
		//rgbgen wave sin 1 1 2 2
		tcMod rotate 360
	}
	{
		clampMap effects/weapons/darkmatter_ring.tga
		blendfunc GL_ONE GL_ONE
		//rgbgen wave sin 0.2 1 0 2
		tcMod rotate 360
		alphaGen const 0.2
	}
	{
		clampMap effects/weapons/darkmatter_haze.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate 360
	}

	{
		clampMap effects/weapons/darkmatter_dot.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        	alphaFunc GT0
		tcMod rotate -360
	}
	{
		clampMap effects/weapons/darkmatterfilter.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate 800
		rgbgen wave sin 1 1 0 2
		alphaGen const 0.2
	}
}

effects/weapons/darkmatter_explode
{
	sort 16
	nodepth
	cull disable
	
	{
		map effects/weapons/darkmatter_haze.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate -360
		tcMod scroll 1.1 2.1 
	}

	{
		map effects/weapons/darkmatter_haze.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate 360
		tcMod scroll 1.1 2.1 
	}

	{
		map effects/weapons/darkmatter_dot.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        	alphaFunc GT0
		tcMod rotate -360
		tcMod scroll 1.1 3.1 
	}
	{
		map effects/weapons/darkmatterfilter.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
     		alphaFunc GT0
		tcMod rotate 800
		rgbgen wave sin 1 1 0 2
		
		tcMod scroll 3.1 3.1 
	}
}
