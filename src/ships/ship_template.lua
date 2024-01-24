
--[[

 ________  __      __  _______   ________        _______  
|        \|  \    /  \|       \ |        \      |       \ 
 \$$$$$$$$ \$$\  /  $$| $$$$$$$\| $$$$$$$$      | $$$$$$$\
   | $$     \$$\/  $$ | $$__/ $$| $$__          | $$  | $$
   | $$      \$$  $$  | $$    $$| $$  \         | $$  | $$
   | $$       \$$$$   | $$$$$$$ | $$$$$         | $$  | $$
   | $$       | $$    | $$      | $$_____       | $$__/ $$
   | $$       | $$    | $$      | $$     \      | $$    $$
    \$$        \$$     \$$       \$$$$$$$$       \$$$$$$$ 
                                                                                             
                                 

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

	save("speed,psp,pr8,plm,player_x,player_y","2.1,6,3,30,64,64")

	b_sprite_colour = parse_data"10,11,12,3|0,1,2,3|0,8,9,15|14,4,5,6"	-- changed depending on player
	
	-- player shoot offset , player_shoot direction , player_shoot direction 2
	formation_a=parse_data"-14,7|14,7"
	psoff,psdir=unpack(parse_data"-4,-2,4,-2|.49,.51")

	psdir_b=split".5,.5"

	player={x=63,y=140,hb=gen_hitbox(1)}

	player_form = 0
end

function update_player()
	lr,ud=tonum(btn"1")-tonum(btn"0"),tonum(btn"3")-tonum(btn"2")
	
	if game_freeze then 
		lr,ud = 0,0
	end
	player_movement(lr,ud)

	bnk = mid(-2,mid(bnk-bnkspd,0.5,bnk+bnkspd)+lr*bnkspd*2.5,2.95)
end

function draw_player()
	foreach(puls,drw_pul)						-- player projectiles
	
	player_visible=player_flash<=0 or global_flash	-- in regards to respawn flash
	if player_visible then

		-- muzzle flash
		if pmuz>0 then
			pmuz-=0.5 -- "decrement" muzzle flash animation
			for i=-5,5,10 do
				local x_position=player_x-i
				if(bnk_offset>0 and i<0)x_position-=3		-- change muzzle positions if the player is shooting
				if(bnk_offset<0 and i>0)x_position+=3		-- seperate check for each muzzle , bad but this is staying
				sspr_obj(split"13,14,15,16"[4-pmuz\1],x_position,player_y+2)
			end
		end							
		-- muzzle flash (unsurprisingly)

		sspr_obj(flr(bnk+3),player_x,player_y)		-- player sprite
	end
	player_flash=max(0,player_flash-1)
end

function player_hurt(_source)	
	new_explosion(player_x,player_y,1)

	-- move player to location
	player_lerpx_1,player_lerpx_2,delx,dely=player_x,player_x,player_lerpx_1,player_lerpy_1
	player.x,player.y=player_lerpx_1,player_lerpy_1
	
	save("player_lerp_perc,player_lerp_delay,player_immune,player_flash,combo_num,combo_counter,live_preview_offset,live_flash,max_rank,draw_particles_above","0,30,180,180,0,0,1,30,600,30")
	lives-=1

	new_bulcancel(30, 75)
	
	if(lives<0)save("slow_motion,disable_timer,fade_lerpperc,fade_exit,fade_pause","true,99999,0,true,90")  return

	sfx(55,2)
end


----------=================  GENERIC BUT REQUIRED  =================----------

function player_shoot()	
	if(not btn(5))return

	if(plast>0 or #puls>plm)plast-=1 return -- don't shoot if the timer isn't zero or if above shot limit

	pmuz=4
	bnk_offset=tonum(bnk<-1)*-1+tonum(bnk>1)


	for i=1,#psoff,2 do
		local index=ceil(i*.5)
		local dir = lerp(psdir[index],psdir_b[index], op_perc)

		local bul=new_bul(false,player_x+psoff[i]+bnk_offset,player_y+psoff[i+1],3,dir)
	end

	plast=pr8 -- set last shot to shot rate
	sfx(62,2)
end

----------=================  TYPE B FUNCTIONS  =================----------

function player_movement(lr,ud)
	-- if(not player_active)return
	input_disabled=disable_timer!=0

	inbtn=btn()&15
	if(player_lerp_perc>=0)lerp_player()		-- lerp player only when ya want <3

	player_x,player_y=player.x,player.y
	delx,dely=delx or player_x, dely or player_y


	-- player shot queuing --
	if btn"5" then
		ps_held_prev+=1
	else 
		ps_held_prev=0
	end
	
	-- movement input
	local mspeed=speed

	-- anti-cobblestone
	if(inbtn!=last_btn)player_x,player_y=player_x\1,player_y\1
	last_btn=inbtn

	if input_disabled or player_lerp_perc>=0 then
		if(disable_timer>0)disable_timer-=1
		bnk=0
	else
		--normalized movement
		local nrm=lr!=0 and ud!=0 and 0.717 or 1
		player_x,player_y=mid(-16,player_x+lr*nrm*mspeed,142),mid(2,player_y+ud*nrm*mspeed,124)
		-- add data back to table for niceties
		player.x,player.y=player_x,player_y
	end

	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.2),lerp(dely,player_y,0.2) -- tokens

	for enem in all(enems) do
		if(not enem.disabled and enem.t>60 and player_col(enem))player_hurt()
	end
end