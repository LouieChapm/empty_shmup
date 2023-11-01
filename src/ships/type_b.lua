
--[[

 _______   _______ _____     ______ 
|_   _\ \ / / ___ \  ___|    | ___ \
  | |  \ V /| |_/ / |__      | |_/ /
  | |   \ / |  __/|  __|     | ___ \
  | |   | | | |   | |___     | |_/ /
  \_/   \_/ \_|   \____/     \____/ 
                                 

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
	ship_type = 1

	save("speeda,speedb,psp,pr8,plm,ps_laser_dur,ps_laser_length,ps_laser_dlength,ps_laser_maxlength,olm,ps_maxvol,ps_minimum_volley_trigger,ps_volley_count","1.8,0.8,5,3,30,0,0,1.05,10,3,6,3,0")

	-- player shoot offset , player_shoot direction , player_shoot direction 2
	formation_a=parse_data"-14,7|14,7"
	psoff,psdir=unpack(parse_data"-4,-2,4,-2|.49,.51")

	player,player_laser_data={x=63,y=140,hb=gen_hitbox(1)},{hb=gen_hitbox(1)}
	
	-- init options
	for i=1,2 do add(options,{x=10,y=10,shot_count=0,muz=0,dir=i==1 and .475 or .525}) end
	-- init options
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

		drw_player_laser()							-- draw player laser thing

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
	player.x,player.y=player_lerpx_1,player_lerpy_1
	
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
	if hit.t>30 then

		-- intropause means you can chain the combo off the boss before it's taking damage
		combo_num+=target_stance==1 and (boss_active and .1 or .2) or .1  --~~ roughly the same

		if(hit.intropause<=0)hit.health-=damage_amount
	elseif ignore_invuln then
		hit.health-=damage_amount
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
	
	if(ps_volley_count<=0)return -- if there's no queued volley
	if(plast>0 or #puls>plm)plast-=1 return -- don't shoot if the timer isn't zero or if above shot limit

	-- SHOT FIRED --

	if target_stance==1 then
		player_laser()
		return
	end
	
	-- reset laser if you're not shooting it maeght
	if(ps_laser_length!=0)ps_volley_count,ps_laser_length=0,0 return


	ps_volley_count-=1
	foreach(options,opt_shoot)


	pmuz=4
	bnk_offset=tonum(bnk<-1)*-1+tonum(bnk>1)


	for i=1,#psoff,2 do
		local index=ceil(i*.5)
		local bul=new_bul(false,player_x+psoff[i]+bnk_offset,player_y+psoff[i+1],3,psdir[index])
	end

	plast=pr8 -- set last shot to shot rate
	sfx(62,2)
end


function drw_option(opt)
	if opt.above==opt_draw_above then
		if(opt.muz>0)sspr_obj(split"19,20"[2-opt.muz\1],opt.x,opt.y-5)opt.muz-=0.5
		sspr_anim(2,opt.x,opt.y)
	end
end

function upd_options()
	-- options perc
	op_perc=lerp(op_perc,target_stance,0.1)

	for i,opt in inext,options do
		local ox1,oy1=unpack(formation_a[i])
		local ox2,oy2=rot_opt(opt,(1/#options)*i,8,4,-8,0.01)
		opt.x,opt.y=lerp(ox1,ox2-delx+player_x,op_perc)+delx,lerp(oy1,oy2-dely+player_y,op_perc)+dely
	end
end

function opt_shoot(_option)
	if(_option.shot_count>olm)return
	new_bul(_option,_option.x,_option.y-5,4,_option.dir)

	_option.shot_count+=1
	_option.muz=2
end

function rot_opt(_opt,_rad,_width,_height,_oy,_speed)
	local pos=(_rad+t*_speed)%1
	_opt.above=pos<=0.5
	return cos(pos)*_width,sin(pos)*_height+_oy
end


function drw_player_laser()
	-- width
	if(ps_laser_length<=0)return

	local sy=player_laser_data.y
	for data in all(parse_data"5,4|4,5|3,6|1,7") do --5,1|4,2|3,3|1,7") do
		local width,col=unpack(data)
		if(width<=2 and t%6<3)width+=1
		rectfill(player_x-width,sy-1,player_x+width+1,ps_laser_hit_height, col)
	end

	sspr_obj(22,player_x,player_y-11)
	
	circfill(player_x+t%2,player_y-9,3+(t\6)%3,7)
end


----------=================  TYPE B FUNCTIONS  =================----------

function player_movement()
	-- if(not player_active)return
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


	-- define stance a or stance b
	target_stance=ps_held_prev>15 and 1 or 0
	if(ps_held_prev==15)sfx(59,3)
	if(disable_timer!=0)target_stance=0
	
	-- movement input
	local mspeed,lr,ud=target_stance==1 and speedb or speeda,tonum(btn"1")-tonum(btn"0"),tonum(btn"3")-tonum(btn"2")
	
	-- anti-cobblestone
	if(inbtn!=last_btn)player_x,player_y=player_x\1,player_y\1
	last_btn=inbtn

	if input_disabled or player_lerp_perc>=0 then
		if(disable_timer>0)disable_timer-=1
		bnk=0
	else
		--normalized movement
		local nrm=lr!=0 and ud!=0 and 0.717 or 1
		player_x,player_y,bnk=mid(-16,player_x+lr*nrm*mspeed,142),mid(2,player_y+ud*nrm*mspeed,124),mid(-2,mid(bnk-bnkspd,0.5,bnk+bnkspd)+lr*bnkspd*2.5,2.95)

		-- add data back to table for niceties
		player.x,player.y=player_x,player_y

	end

	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.2),lerp(dely,player_y,0.2) -- tokens

	for enem in all(enems) do
		if(not enem.disabled and enem.t>60 and player_col(enem))player_hurt()
	end
end



function player_laser()
	-- find max height
	ps_laser_length=min(5+ps_laser_length*ps_laser_dlength,128)

	player_laser_data.hb,player_laser_data.x,player_laser_data.y={ox=-10,oy=-ps_laser_length,w=22,h=ps_laser_length},player_x,player_y-10

	-- find all enemies that *could* be hit by the laser
	-- find which one of those enemies is the lowest
	local lowest,lowest_enem=-50,nil
	for enem in all(enem_col(player_laser_data)) do 
		if(enem.y>lowest)lowest,lowest_enem=enem.y,enem
	end

	-- update the laser hitbox to match the lowest enemy
	if lowest_enem then
		ps_laser_length = player_y - lowest_enem.y
		player_laser_data.hb.oy,player_laser_data.hb.h=-ps_laser_length,ps_laser_length
		
		
	end
	ps_laser_hit_height=lowest_enem and lowest_enem.y + lowest_enem.hb.oy + lowest_enem.hb.h or player_y - ps_laser_length

	-- PERFORMANCE
	-- THIS IS TERRIBLE
	-- I"M LOOPING OVER EVERY ENEMY INSTEAD OF THE SMALLER LIST I ALREADY HAVE
	-- PICO FORCED MY HAND , IM DOING THIS FOR TOKENS AND TOKENS ALONE
	for enem in all(enem_col(player_laser_data)) do
		damage_enem(enem, enem.elite and 1 or 1.6)
		add_ccounter(2,25)
	end

	if(t%4==0)new_debris(player_x,player_y-10,.5,5,-7)sfx(60,2)
	

	if(ps_laser_hit_height>-5)spawn_oneshot(8,3,player_x+eqrnd"5",ps_laser_hit_height+eqrnd"2")
end