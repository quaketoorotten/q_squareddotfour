
progs/cherub_wing
{
    cull none
    surfaceparm trans
    program defaultskin
    {
       	progs/cherub_wing.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}

progs/maggotcomplete
{
    cull none
    surfaceparm trans
    program defaultskin
    {
       	progs/maggotcomplete.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}


progs/pinky_d
{
    cull none
    surfaceparm trans
    program defaultskin
    {
       	progs/pinky_d.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}

progs/commando
{
    cull none
    surfaceparm trans
    program defaultskin
    {
       	progs/commando.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}

progs/lostsoul
{
    cull none
    surfaceparm trans
    program defaultskin
    {
       	progs/lostsoul.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}

progs/caco
{
    cull none
    surfaceparm trans
    program defaultskin
    {
       	progs/caco.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}

progs/dis1
{
    sort 16
    {
       	map progs/monsters/corpseburneffect_sm.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
	rgbGen entity	// identity
	tcMod scroll 2.1 2.1  
    }
}

progs/dis2
{
    sort 16
    {
       	map progs/monsters/corpseburneffect_sm.tga
        blendFunc blend
	rgbGen entity	// identity
	tcMod scroll 2.1 2.1 
    }
}

progs/dis3
{
    sort 16
    {
       	map progs/monsters/corpseburneffect_sm.tga
        blendFunc blend
	rgbGen entity	// identity
	tcMod scroll 2.1 2.1 
    }
}

progs/zsec3
{
    sort 16
    {
       	map progs/zsec3.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
	rgbGen entity	// identity
	tcMod scroll 2.1 2.1 
    }
}

progs/zsec1
{
    cull none
    surfaceparm trans
    program defaultskin
    {
       	progs/zsec1.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite 
    }
}

models/monsters/berserker/berserker_lp
{
    {
       	map progs/monsters/berserker/berserker_lp.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/berserker/berserker_lp_g.tga
        blendfunc GL_ONE GL_ONE
 	rgbgen wave sin 0.6 0.4 0 1
    }
}

models/monsters/gladiator/glad_body_lo
{
    {
       	map progs/monsters/gladiator/glad_body_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/gladiator/glad_body_glowpass.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 0.6 0.4 0 1
    }
}

models/monsters/gladiator/glad_arms_gun_lo
{
    {
       	map progs/monsters/gladiator/glad_arms_gun_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/gladiator/glad_arms_gun_glow2.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}


models/monsters/gladiator/glad_railgun
{
    {
       	map progs/monsters/gladiator/glad_arms_gun_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/gladiator/glad_arms_gun_glowpass.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/gladiator/shield
{	
    surfaceparm nodraw
    surfaceparm nolightmap
    surfaceparm nomarks
    {
       	map $blank
    }

}

models/monsters/gladiator/shield2
{	
    cull none
    sort 16	
    {
       	animMap 8 progs/monsters/gladiator/glad_shieldadd_0.tga progs/monsters/gladiator/glad_shieldadd_1.tga progs/monsters/gladiator/glad_shieldadd_2.tga progs/monsters/gladiator/glad_shieldadd_3.tga
	blendfunc GL_ONE GL_ONE
	rgbGen const ( 0.5 0.5 0.5 )	// identity
    }

    {
       	map progs/monsters/gladiator/glad_shieldwave.tga 
	blendfunc GL_ONE GL_ONE
	rgbGen const ( 0.2 0.2 0.2 )	// identity
	tcMod scroll 1.1 1.1 
    }
}

models/monsters/gladiator/glad_head_lo
{
    {
       	map progs/monsters/gladiator/glad_head_lo.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/iron_maiden/base
{
    {
       	map progs/monsters/iron_maiden/base.tga
        rgbGen lightingDiffuse
    }
    {
       	map progs/monsters/iron_maiden/base_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/iron_maiden/dress
{
    cull none
    {
       	map progs/monsters/iron_maiden/dress2.tga
	blendfunc GL_ONE GL_ONE
	rgbgen wave sin 0.6 0.2 0 1
    }
    {
       	map progs/monsters/iron_maiden/dress1.tga
	blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
	rgbGen lightingDiffuse
    }
}

models/monsters/iron_maiden/wrist_spike
{
    cull none
    surfaceparm trans
    {
       	map progs/monsters/iron_maiden/wrist_spike.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        depthWrite
        rgbGen lightingDiffuse
    }
}

models/monsters/gladiator/shield
{	
    surfaceparm nodraw
    surfaceparm nolightmap
    surfaceparm nomarks
    {
       	map $blank
    }

}

models/monsters/sentry/sentry
{
    {
       	map progs/monsters/sentry/sentry.tga
        rgbGen lightingDiffuse
    }
    {
       	map progs/monsters/sentry/sentry_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/sentry/sentry_glass
{
    {
       	map progs/monsters/sentry/sentry_glass.tga
	blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
        rgbGen const ( 0.2 0.2 0.2 )
    }
}

textures/glass/clean_core2
{
    {
        map progs/monsters/sentry/sentry_glass.tga
        blendfunc GL_ONE GL_ONE
	rgbGen const ( 0.4 0.4 0.4 )
	//tcMod scroll 1.1 1.1 
    }
}

models/monsters/sentry/sentry_liquid
{
    {
       	map progs/monsters/sentry/sentry_liquid.tga
	blendfunc GL_ONE GL_ONE
        rgbGen const ( 0.1 0.1 0.1 )
    }
}


models/monsters/sentry/sentry_collision
{	
    surfaceparm nodraw
    surfaceparm nolightmap
    surfaceparm nomarks
    {
       	map $blank
    }

}

models/monsters/grunt/grunt_arms
{
    {
       	map progs/monsters/grunt/grunt_arms.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/grunt/grunt_arms_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 0.6 0.6 0.5 1
    }
}

models/monsters/grunt/grunt_arms2
{
    {
       	map progs/monsters/grunt/grunt_arms.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/grunt/grunt_arms_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 1 0.6 0.5 1
    }
    {
        map progs/monsters/grunt/grunt_arms_glowmask.tga
        blendfunc GL_ONE GL_ONE
//	rgbGen con
	rgbgen wave sin 1 0.4 0.5 1 
    }
}

models/monsters/grunt/grunt_body
{
    {
       	map progs/monsters/grunt/grunt_body.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/grunt/grunt_body_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 0.6 0.4 0.5 1
    }
}

models/monsters/grunt/grunt_body2
{
    {
       	map progs/monsters/grunt/grunt_body.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/grunt/grunt_body_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 10.6 0.5 2
    }
    {
        map progs/monsters/grunt/grunt_body_g2.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 1 0.4 0.5 2
    }
}

models/monsters/grunt/grunt_head
{
    {
       	map progs/monsters/grunt/grunt_head.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/grunt/grunt_head_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity
    }
}

models/monsters/grunt/grunt_head2
{
    {
       	map progs/monsters/grunt/grunt_head.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/grunt/grunt_head_g2.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity
    }
    {
        map progs/monsters/grunt/grunt_head_glowmask.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 1 0.4 0.5 1
    }
}

models/monsters/teleport_dropper/td_pod
{
    {
       	map progs/monsters/teleport_dropper/td_pod_d.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/teleport_dropper/td_pod_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/teleport_dropper/telDrop
{
    {
       	map progs/monsters/teleport_dropper/teldrop.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/teleport_dropper/teldrop_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/teleport_dropper/telDrop_teeth
{
    {
       	map progs/monsters/teleport_dropper/teldrop_teeth.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
	depthWrite
	rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_arms_lo
{
    {
       	map progs/monsters/strogg_marine/smv_arms_lo.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_arms_lo2
{
    {
       	map progs/monsters/strogg_marine/smv_arms_lo2.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_arms_lo3
{
    {
       	map progs/monsters/strogg_marine/smv_arms_lo3.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_head_b
{
    {
       	map progs/monsters/strogg_marine/smv_head_b.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_head_b2
{
    {
       	map progs/monsters/strogg_marine/smv_head_b2.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_head_b3
{
    {
       	map progs/monsters/strogg_marine/smv_head_b3.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_teeth
{
    {
       	map progs/monsters/strogg_marine/smv_teeth.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_blaster_lo
{
    {
       	map progs/monsters/strogg_marine/smv_arms_lo.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_bodylegs_lo
{
    {
       	map progs/monsters/strogg_marine/smv_bodylegs_lo.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_bodylegs_lo2
{
    {
       	map progs/monsters/strogg_marine/smv_bodylegs_lo2.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/smv_bodylegs_lo3
{
    {
       	map progs/monsters/strogg_marine/smv_bodylegs_lo3.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/strogg_marine/machinegunarm_lo
{
    {
       	map progs/monsters/strogg_marine/machinegunarm_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/strogg_marine/smv_glowpass.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/strogg_marine/shotgunarm_lo
{
    {
       	map progs/monsters/strogg_marine/machinegunarm_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/strogg_marine/smv_glowpass.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/gunner_body_base
{
    {
       	map progs/monsters/gunner/gunner_body_base.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/gunner/gunner_body_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/gunner_arml_base
{
    {
       	map progs/monsters/gunner/gunner_arml_base.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/gunner_armr_base
{
    {
       	map progs/monsters/gunner/gunner_armr_base.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/gunner_gundoors_base
{
    {
       	map progs/monsters/gunner/gunner_gundoors_base.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/gunner_head_base
{
    {
       	map progs/monsters/gunner/gunner_head_base.tga
        rgbGen lightingDiffuse
    }
}

models/monsters/scientist/sci_2
{
    {
       	map progs/monsters/scientist/sci_2.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/scientist/sci_2_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/scientist/sci_1b
{
    {
       	map progs/monsters/scientist/sci_1b.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/scientist/sci_1b_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/scientist/sci_blade
{
    {
        map progs/monsters/scientist/sci_blade.tga
        blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
        alphaFunc GT0
	depthWrite
	rgbGen lightingDiffuse
    }
}

models/monsters/heavyhovertank/hh_lo_b
{
    {
       	map progs/monsters/heavyhovertank/hh_lo_b.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/heavyhovertank/hh_lo_b_g.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}

models/monsters/heavyhovertank/hh_lo
{
    {
       	map progs/monsters/heavyhovertank/hh_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/heavyhovertank/hh_lo_g.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 0.6 0.4 0 3
    }
}


models/monsters/heavyhovertank/hh_lo_ring
{
    {
        map progs/monsters/heavyhovertank/hh_lo_ring.tga
        blendfunc GL_ONE GL_ONE
	rgbGen entity	// identity
    }
}


models/monsters/stream_protector/sp_lo
{
    {
       	map progs/monsters/stream_protector/sp_lo.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/stream_protector/sp_g.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 0.6 0.4 0 3
    }
}


models/monsters/tactical/tt_body
{
    {
       	map progs/monsters/tactical/tt_body.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/tactical/tt_body_g.tga
        blendfunc GL_ONE GL_ONE
	rgbgen entity
    }
}

models/monsters/light_tank/lt
{
    {
       	map progs/monsters/lt_tank/lt_tank.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/lt_tank/lt_glow.tga
        blendfunc GL_ONE GL_ONE
	rgbgen entity
    }
}

"models/monsters/failed_transfer/slimy_low"
{
    {
       	map progs/monsters/failed_transfer/ft_low.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/failed_transfer/ft_low_leg_g.tga
        blendfunc GL_ONE GL_ONE
	rgbgen entity
    }
    {
        map progs/monsters/failed_transfer/ft_low_torso_g.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 1 0.4 0.5 1
    }
}

"models/monsters/tank/tank"
{
    {
       	map progs/monsters/tank/tank.tga
        rgbGen lightingDiffuse
    }
    {
        map progs/monsters/tank/tank_glowpass1.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 1 0.4 0.5 1 
    }
    {
        map progs/monsters/tank/tank_glowpass.tga
        blendfunc GL_ONE GL_ONE
	rgbgen wave sin 0.6 0.2 0 1
    }
}

"models/monsters/tank/tank_skull"
{
    {
       	map progs/monsters/tank/tank_skull.tga
        rgbGen lightingDiffuse
    }
}
