
--[[

 ______  __ __  ____   ___         __ 
|      ||  |  ||    \ /  _]       /  ]
|      ||  |  ||  o  )  [_       /  / 
|_|  |_||  ~  ||   _/    _]     /  /  
  |  |  |___, ||  | |   [_     /   \_ 
  |  |  |     ||  | |     |    \     |
  |__|  |____/ |__| |_____|     \____|
                                                     

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
	type = "c"

	save("speeda,speedb,psp,pr8,plm,olm,ps_maxvol,ps_minimum_volley_trigger,ps_volley_count","2.2,1.2,5,2,30,3,6,3,0")

	-- player shoot offset , player_shoot direction , player_shoot direction 2
	psoff,psdir=unpack(parse_data"0,-3,-4,-1,5,-1|.5,.49,.51")

	player={x=63,y=140,hb=hb_reg}

	fade_colours_mid = split"0,13, 1,5, 2,5, 3,6"
	fade_colours = split"0,13, 1,0, 2,5, 3,6"

	shot_num = 0
	stored_count = 0
	player_shot_pause = 0
	burst_count = 0
	
	time_in_shade = 0 
	time_in_reg = 0

	max_shade_time = 180		-- max time spent in shade
	max_shade_block = 240		-- amount of time shade is blocked for after using it
	shade_block = 0
end

function update_player()
	if target_stance==1 then 
		player.hb = gen_hitbox(1,parse_data"-5,-5,12,11")
		
		time_in_shade+=1
		time_in_reg = 0
	else
		player.hb = gen_hitbox(1)

		time_in_shade=0
		time_in_reg+=1
	end

	-- debug = time_in_shade .. "|" .. time_in_reg .. "\n" .. shade_block

	player_movement()
end

function draw_player()
	foreach(puls,drw_pul)						-- player projectiles
	
	player_visible=player_flash<=0 or global_flash	-- in regards to respawn flash
	if player_visible and not slow_motion then


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

		-- define fade colours
		local colours = ps_held_prev<20 and fade_colours_mid or fade_colours

		if target_stance==1 then 
			for i=1,#colours,2 do 
				pal(colours[i],colours[i+1])
			end
		end

		sspr_obj(flr(bnk+3),player_x,player_y)		-- player sprite

		if target_stance==1 then 
			for i=1,#colours,2 do 
				pal(colours[i],colours[i])
			end
		end

	end
	player_flash=max(0,player_flash-1)
end

function player_hurt(_source)
	-- dont hurt the player if they're shaded
	if target_stance == 1 or time_in_reg<10 then -- 10 frame invuln after leaving shade , feels better like this
		-- find if the _source was a bullet
		if _source and _source.filters then 			
			spawn_oneshot(9,3, _source.x, _source.y + eqrnd"2")
			stored_count+=1
			del(buls,_source)
		end
		return
	end

	stored_count = 0
	shade_block = 0

	new_explosion(player_x,player_y,1)

	-- move player to location
	player_lerpx_1,player_lerpx_2,delx,dely=player_x,player_x,player_lerpx_1,player_lerpy_1
	player.x,player.y=player_lerpx_1,player_lerpy_1
	
	save("player_lerp_perc,player_lerp_delay,player_immune,player_flash,combo_num,combo_counter,live_preview_offset,live_flash,bombs,max_rank,draw_particles_above","0,30,180,180,0,0,1,30,1,600,30")
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
function damage_enem(hit, _damage_amount, ignore_invuln)
	local damage_amount = _damage_amount * 1.5				-- small boost in damage to keep up
	if(time_in_reg<30)damage_amount = _damage_amount * 3	-- damage boost to make the burst more damaging

	if hit.t>30 then

		-- intropause means you can chain the combo off the boss before it's taking damage
		if(hit.intropause<=0)hit.health-=damage_amount
	elseif ignore_invuln then
		hit.health-=damage_amount
	end

	-- flash enemy
	hit.flash = hit.flash<-1 and 4 or hit.flash

	if not hit.dead then 
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
	bnk_offset=tonum(bnk<-1)*-1+tonum(bnk>1)
	
	-- burst thing
	if target_stance==0 and stored_count>0 then 
		if t%5==0 then
			for i=0,mid(1,stored_count*.5,2) do 
				local mult = min(.01 + (burst_count\2)*.01,.05)

				new_bul(false,player_x+bnk_offset,player_y,4,.5 + i*mult)
				if(i>0)new_bul(false,player_x+bnk_offset,player_y,4,.5 - i*mult)
			end
			burst_count +=1
			stored_count=min(stored_count-1,10) 
		end
	else
		burst_count = 0
	end
	
	if(ps_volley_count<=0 or player_shot_pause>0)player_shot_pause-=1 return -- if there's no queued volley or no shot pause
	if(plast>0 or #puls>plm)plast-=1 return -- don't shoot if the timer isn't zero or if above shot limit

	ps_volley_count-=1


	pmuz=4


	for i=shot_num==0 and 1 or 3,shot_num==0 and 2 or #psoff,2 do
		local index=ceil(i*.5)

		local dir = psdir[index]
		dir += (dir-.5) * (shot_num-1)

		local bul=new_bul(false,player_x+psoff[i]+bnk_offset,player_y+psoff[i+1],3,dir)
	end

	shot_num = (shot_num+1)%3

	plast=pr8 -- set last shot to shot rate
	sfx(62,2)
end

----------=================  TYPE C FUNCTIONS  =================----------

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

	local prev_stance = target_stance

	-- define stance a or stance b
	target_stance=ps_held_prev>10 and 1 or 0
	if(shade_block>0)shade_block-=1 target_stance=0		-- force regular stance if shadeblocked
	if(disable_timer!=0)target_stance=0

	if(shade_block==1)player_flash = 16
	if(prev_stance ~= target_stance and target_stance == 0)shade_block = min(30 + time_in_shade*1.5,max_shade_block)

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

	-- SHOT FIRED --
	if target_stance==1 then
		-- player_immune = player_immune > 1 and player_immune or 2
		player_shot_pause = 15
		-- player_flash = 2
		ps_volley_count=0

		if(time_in_shade>max_shade_time-45)player_flash = 2
		if(time_in_shade>max_shade_time)shade_block = max_shade_block
		return
	end


	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.2),lerp(dely,player_y,0.2) -- tokens

	for enem in all(enems) do
		if(not enem.disabled and enem.t>60 and player_col(enem))player_hurt()
	end
end