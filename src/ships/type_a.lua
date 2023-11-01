
--[[

 _______   _______ _____       ___  
|_   _\ \ / / ___ \  ___|     / _ \ 
  | |  \ V /| |_/ / |__      / /_\ \
  | |   \ / |  __/|  __|     |  _  |
  | |   | | | |   | |___     | | | |
  \_/   \_/ \_|   \____/     \_| |_/
                                    
                                 
]]


-- this should cover all of the code required for type_b
--[[
	THIS SHOULD CONTAIN ..

	init_player
	update_player
	draw_player

	... 

	any functions that are required for the player to function

]]

function init_player()
	type = "a"

	save("speeda,speedb,psp,pr8,plm,olm,stance_change_treshold,opt_x,opt_y,time_in_stance_b,ps_maxvol,ps_minimum_volley_trigger,ps_volley_count,jump_frames,time_in_stance_a,player_shot_pause","1.6,1.6,5,5,30,5,10,64,164,0,6,3,0,5,0,0")

	-- player shoot data
	psoff,psdir=unpack(parse_data"-4,-2,4,-2|.5,.5")

	player,opt_burst,dash_hurt_enemies={x=63,y=140,hb=gen_hitbox(1)},{hb=gen_hitbox(1,parse_data"-10,-5,22,20")},{}

	debug=""
	
	-- init options
	for i=1,3 do add(options,{x=10,y=10,shot_count=0,muz=0,dir=.5}) end
	-- init options

	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,14},1)
	poke(0x5f2e,1)
end

function update_player()
	player_movement()
	upd_options()
end

function draw_player()
	foreach(opuls,drw_pul)						-- options projectiles
	foreach(puls,drw_pul)						-- player projectiles
	
	player_visible=player_flash<=0 or global_flash	-- in regards to respawn flash
	if player_visible and not slow_motion then
		opt_draw_above=false
		foreach(options,drw_option)

		-- muzzle flash
		if pmuz>0 then
			pmuz-=0.5 -- "decount" muzzle flash animation
			for i=-5,5,10 do
				local x_position=player_x-i
				if(bnk_offset>0 and i<0)x_position-=3		-- change muzzle positions if the player is shooting
				if(bnk_offset<0 and i>0)x_position+=3		-- seperate check for each muzzle , bad but this is staying
				sspr_obj(split"13,14,15,16"[4-pmuz\1],x_position,player_y+2)
			end
		end							
		-- muzzle flash (unsurprisingly)

		sspr_obj(flr(bnk+3),player_x,player_y)		-- player sprite

		draw_rotor()


		-- draw options above
		opt_draw_above=true
		foreach(options,drw_option)
	end
	player_flash=max(0,player_flash-1)
end

function player_hurt(_source)	
	new_explosion(player_x,player_y,1)

	-- move player to location
	player_lerpx_1,player_lerpx_2,delx,dely=player_x,player_x,player_lerpx_1,player_lerpy_1
	player.x,player.y,opt_x,opt_y=player_lerpx_1,player_lerpy_1,player_lerpx_1,player_lerpy_1
	
	save("player_lerp_perc,player_lerp_delay,player_immune,player_flash,combo_num,combo_counter,ps_laser_length,live_preview_offset,live_flash,bombs,max_rank,draw_particles_above","0,30,180,180,0,0,0,1,30,1,600,30")
	lives-=1
	

	new_bulcancel(30, 75)
	
	-- make the pickups no longer seek 
	for pickup in all(pickups) do pickup.seek=false end

	
	if(lives<0)save("slow_motion,disable_timer,spiral_lerpperc,spiral_exit,spiral_pause","true,99999,0,true,90")  return

	sfx(55,2)
end

----------=================  GENERIC BUT REQUIRED  =================----------


-- ambiguous but chain is in reference to the combo chain
-- and combo is the actual combo number itself
function damage_enem(hit, damage_amount, ignore_invuln)
	if hit.t>30 or ignore_invuln then

		-- intropause means you can chain the combo off the boss before it's taking damage
		combo_num+=target_stance==1 and .06 or .08  --~~ roughly the same

		if(hit.intropause<=0)hit.health-=damage_amount
	end

	-- flash enemy
	hit.flash = hit.flash<-1 and 4 or hit.flash

	if hit.health<=0 and not hit.dead then 
		hit.dead=true

		local sui=hit.sui_shot
		if(sui>0)create_spawner(sui\1,{x=hit.x,y=hit.y},sui%1==0 and -1 or sui%1)
			
		--[[
			putting decimals in the suicide shot thing can allow for prefined angles
			4 		= pattern 4 and targeted
			4.75 	= pattern 4 and shooting down
			2.999 	= pattern 2 and shooting as close to the right as is possible
		]]--
	end
end



function player_shoot()
	if(btnp"4")player_bomb()

	player_shot_pause-=1
	
	if(ps_volley_count<=0 or player_shot_pause>0)return -- if there's no queued volley
	if(plast>0 or #puls>plm)plast-=1 return -- don't shoot if the timer isn't zero or if above shot limit
	
	foreach(options,opt_shoot)

	-- SHOT FIRED --
	ps_volley_count-=1


	pmuz=4
	bnk_offset=tonum(bnk<-1)*-1+tonum(bnk>1)

	for i=1,#psoff,2 do
		local index=ceil(i*.5)
		new_bul(false,player_x+psoff[i]+bnk_offset,player_y+psoff[i+1],3,psdir[index])
	end

	plast=target_stance==1 and not boss_active and 3 or pr8 -- set last shot to shot rate
	sfx(62,2)
end


function drw_option(opt)
	if(target_stance==1 and time_in_stance_b<8)allpal(7)

	if opt.above==opt_draw_above then
		if(opt.muz>0)sspr_obj(split"19,20"[2-opt.muz\1],opt.x,opt.y-5)opt.muz-=0.5
		sspr_anim(2,opt.x,opt.y)
	end

	allpal()
end

function upd_options()

	-- options perc
	op_perc=lerp(op_perc,target_stance,target_stance==1 and .3 or .07)
	
	opt_burst.x,opt_burst.y=opt_x,lerp(player_y,opt_y,op_perc)-20

	if target_stance==1 then 
		if time_in_stance_b==0 then 
			dash_hurt_enemies={}
			
			local part=new_basepart(player_x,player_y,0,8,p_grape,1)
			part.rad=20
		end

		if(time_in_stance_b<6 and time_in_stance_b%2==0)pnew_circ(opt_burst.x,opt_burst.y+4, 0, 10, 0)
		time_in_stance_b+=1  

		opt_y-=lerp(25,.05,easeoutquad(min(time_in_stance_b,jump_frames)/jump_frames))


		if time_in_stance_b<30 then
			for enem in all(enem_col(opt_burst)) do 
				
				for prev_enem in all(dash_hurt_enemies) do 
					if(prev_enem==enem)goto continue
				end

				sfx"54"

				damage_enem(enem,35,true)
				if(enem.dead and enem.active)combo_num+=10

				add(dash_hurt_enemies,enem)

				::continue::
			end
		end
	else 
		time_in_stance_b=0
	end

	-- particles on stance change
	if time_in_stance_b%2!=0 and time_in_stance_b<8 then 
		local part=new_basepart(opt_burst.x+1,opt_burst.y,0,-.8-time_in_stance_b*.05,p_wave,10)
		part.rad,part.torad,part.toradspd=1,20-time_in_stance_b,0.25
	end

	for i,opt in inext,options do
		local ox1,oy1=rot_opt(opt,(1/#options)*i,10,6,0,0.01)
		local ox2,oy2=rot_opt(opt,(1/#options)*i,6,6,-8,0.03)
		ox2+=opt_x - player_x
		oy2+=opt_y - player_y

		opt.x,opt.y=lerp(ox1,ox2-delx+player_x,op_perc)+delx,lerp(oy1,oy2-dely+player_y,op_perc)+dely
	end
end

function opt_shoot(_option)
	if(_option.shot_count>olm)return
	local bul=new_bul(_option,_option.x,_option.y-5,4,_option.dir)

	_option.shot_count+=1
	_option.muz=2
end

function rot_opt(_opt,_rad,_width,_height,_oy,_speed)
	local pos=(_rad+t*_speed)%1
	_opt.above=target_stance==0 and pos<.5 or false --  or 
	return cos(pos)*_width,sin(pos)*_height+_oy
end

----------=================  TYPE B FUNCTIONS  =================----------

function draw_rotor()
	local t=t\4
	if t%3<2 then 
		oval(player_x-7,player_y-6,player_x+8,player_y+7,7)

		local start=93+tonum(t%3<1)
		sspr_obj(start,player_x-5,player_y-5)
		sspr_obj(start+2,player_x+1,player_y+1)
	end
end

function player_movement()
	input_disabled=disable_timer!=0

	inbtn=btn()&15
	if(player_lerp_perc>=0)lerp_player()		-- lerp player only when ya want <3

	player_x,player_y=player.x,player.y
	delx,dely=delx or player_x, dely or player_y


	-- player shot queuing --
	if btn"5" then
		ps_held_prev+=1
		if(ps_volley_count<=ps_minimum_volley_trigger)ps_volley_count+=ps_maxvol
	else 
		ps_held_prev=0
	end

	local prev_stance=target_stance
	-- define stance a or stance b
	if op_perc<.05 or ps_held_prev<=stance_change_treshold then
		target_stance=prev_stance==1 and time_in_stance_b<90 and 1 or ps_held_prev>stance_change_treshold and 1 or 0
	end
	if(disable_timer!=0)target_stance=0
	
	-- movement input
	local mspeed,lr,ud=target_stance==1 and speedb or speeda,tonum(btn"1")-tonum(btn"0"),tonum(btn"3")-tonum(btn"2")
	
	-- anti-cobblestone
	if(inbtn!=last_btn)player_x,player_y=player_x\1,player_y\1
	last_btn=inbtn

	if input_disabled or player_lerp_perc>=0 then
		if(disable_timer>0)disable_timer-=1
		bnk,target_stance=0,0
	else
		--normalized movement
		local nrm=lr!=0 and ud!=0 and 0.717 or 1
		player_x,player_y,bnk=mid(-16,player_x+lr*nrm*mspeed,142),mid(2,player_y+ud*nrm*mspeed,124),mid(-2,mid(bnk-bnkspd,0.5,bnk+bnkspd)+lr*bnkspd*2.5,2.95)

		-- add data back to table for niceties
		player.x,player.y=player_x,player_y

		if(prev_stance!=target_stance and target_stance==1)opt_x,opt_y,player_shot_pause,draw_particles_above=delx,dely,30,15
	end

	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.3),lerp(dely,player_y,0.3) -- tokens

	for enem in all(enems) do
		if(not enem.disabled and enem.t>60 and player_col(enem))player_hurt()
	end
end