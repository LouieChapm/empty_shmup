pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
fmenu_cart_address="shmup_menu.p8"

#include data/inf_crumbs.txt
#include data/inf_spawns.txt
#include data/inf_patterns.txt
#include data/inf_sprites.txt
#include data/inf_enems.txt

#include src/mapfuncs.lua
#include src/sprfuncs.lua
#include src/bulfuncs.lua
#include src/expfuncs.lua

#include base_shmup.lua
#include type_a.lua

-- #include debugfuncs.lua


-- draw_hitboxes=false

--[[
	current dev high scores
	3,361,210
	4,362,050

	1,343,570
]]



function _init()

	cartdata"kalika_v1_01"
	dset(63,0)
	highscore=tostr(dget"0",0x2).."0"

	save("t,player_lerpx_1,player_lerpy_1,player_lerpx_2,player_lerpy_2,player_lerp_perc,player_lerp_speed,player_lerp_delay,player_lerp_type,combo_on_frame,map_progress,map_speed,moon_y,score_in_combo,bullet_cancel_origin,bullet_cancel,shot_pause,max_rank,speed_target,final_boss_phase,draw_particles_above,spiral_lerpperc,spiral_pause,coin_chain_timer,coin_chain_amount","0,64,150,63,95,0,2,0,easeout,0,128,2,-64,0,0,0,0,1100,2,1,-1,0,0,0,0")

	init_baseshmup(enemy_data)

	init_player()

	init_sprfuncs(spr_library,anim_library)
	init_mapfuncs(enemy_spawns,crumb_lib,shot_lib)
	init_bulfuncs(bul_library)
	init_expfuncs()

	music(0,5000)

	palt(0,false)

	-- index, rate, direction, ox, oy, rate offset

	-- all bletters have 8,13 w/h
	turret_data,combo_big_letters,pickup_colours,speed_changes,spiral_exit,slow_motion=parse_data"11,120,?,0,0,0|16,90,-1,0,0,0|15,15,?,-10,4,0|15,15,-?,10,4,0|19,120,.75,0,0,45|27,50,.75,0,-2,0|16,160,-1,-10,-10,0|16,160,-1,10,-10,90|27,50,.25,0,-2,25|36,120,.75,0,0,30|60,45,.75,0,0,0|64,25,-1,0,0,0|68,76,.75,0,0,0|70,45,.75,0,0,0|71,120,-1,0,0,23|72,120,-1,0,0,0|76,200,-1,0,0,100|77,3,.75,0,0,0|80,30,.75,0,0,0|41,8,.75,0,0,0|83,90,-1,0,0,0|83,90,-1,0,0,45|67,75,.75,0,0,0|88,75,-1,0,0,23|72,120,-1,0,0,60|74,30,.75,0,0,0|89,5,.75,0,0,0",parse_data"89,39|78,52|86,52|94,52|102,50|115,73|57,39|65,39|73,39|81,39",parse_data"0,8,9|10,11,12|1,2,3",parse_data"1000,3.5|2000,6|3250,0|3252,-.5|7650,.001|7950,0|15000,6969",false,false
	meter_colours,combo_colours,map_segments=unpack(parse_data"8,8,9,9,2,2,2,3,3,12,12|0,8,9,1,2,3,10,11,12,10,12,10,7,7,7|1, 1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1, 12,1,9,1,0,1,9,1,12,1,9,1,0,1,9,1,12,1,9,1,0,1,9,1,1,1,9,1,1,1,9,1, 13,1,1,1,12,1,1,1,13,1,1,1,12,1,1,1,13,1,1,1,12,1,1,1,13,1,1,1,12,1,1,1,13,1,1,1,13,1,1,1,13,1,1,1,13,1,1,1, 13,1,1,13,1,1,13,1,1,13,1,1,13,1,1,13,1,1, 13,1,13,1,13,1,13,1,13,1,13,1,13,1,13,1,13,1, 2,3,3,3,3,3,3,3,3,3,3, 3,3,4,5,6,7,6,5,6,7,6,6,7,6,6,10, 3,3,3,3,3, 14,15,15,15,15,16,15,15,16,15,15,16,17,18,19,18")
end

function _update60()
	t+=1
	if(slow_motion and t%3!=0)return -- slow motion 

	
	combo_on_frame-=1
	if coin_chain_timer>1 then 
		coin_chain_timer-=1
	else
		if(coin_chain_amount>10)new_text(player_x+10,player_y-7,"X"..coin_chain_amount.." combo!",120)
		coin_chain_amount=1
	end


	if(text_effect_pause>0)text_effect_pause-=1

	map_progress+=map_speed
	shot_pause,global_flash,anchors=max(shot_pause-1,0),t%8<=4,{}
	
	local target_obj,new_speed=unpack(speed_changes[1])
	if map_timeline>=target_obj then
		if(new_speed<=0)map_speed=abs(new_speed) 
		speed_target=abs(new_speed)
		deli(speed_changes,1)
	end
	map_speed=lerp(map_speed,speed_target,.001)


	if max_rank>=0 then
		max_rank-=1
		if(combo_num>50)max_rank=-1
	end

	upd_mapfuncs()
	upd_bulfuncs()

	foreach(enems,upd_enem)					-- update enemies

	update_player()

	if(not input_disabled and player_lerp_perc<0)player_shoot()
	
	-- camera stuff
	cam_x=mid(-16,flr((player_x-64)*0.25),16)
	camera(cam_x,0)

	if(player_immune>0)player_immune-=1

	foreach(buls,check_bulcol)					-- enemy bullet collisions

	foreach(puls,upd_pul)						-- update player bullets
	foreach(opuls,upd_pul)						-- update option bullets

	if(bullet_cancel_origin>0)upd_bulcancel()

	upd_combo()
	foreach(exp_queue,upd_expqueue)
end


function _draw()
	cls(13)

	if(screen_flash>0)rectfill(0+cam_x,0,128+cam_x,128,7)screen_flash-=1 return
	
	
	draw_map()

	if(draw_particles_above<0)foreach(parts,drw_part)

	foreach(pickups,drw_pickup)					-- draw pickups

	foreach(enems,drw_enem)						-- draw the enemies
	foreach(anchors,drw_enem)

	if(draw_particles_above>=0)draw_particles_above-=1 foreach(parts,drw_part)

	draw_player()
	
	foreach(hitregs,drw_hitreg)

	foreach(buls,drw_bulfunc)								-- enemy projectiles
	
	draw_ui()

	if(spiral_pause>0)spiral_pause-=1
	spiral_anim(lerp(tonum(spiral_exit),tonum(not spiral_exit),spiral_lerpperc))
end

-->8
-- stage specific enemy functions

--8151
function spawn_enem(_path, _type, _spawn_x, _spawn_y, _ox, _oy)
	local enemy=setmetatable({},{__index=_ENV})
	local _ENV=enemy
	s,health,hb,deathmode,sui_shot,value,elite,exp,coin_value=unpack(enemy_data[_type])
	hb,elite,active,type,sx,sy,ox,oy,x,y,t,shot_index,perc,flash,path_index,pathx,pathy,anchors,patterns,turrets,lerpperc,intropause=gen_hitbox(hb),elite==1,true,_type,_spawn_x,_spawn_y,_ox or 0, _oy or 0,63,-18,0,1,0,0,_path,{},{},{},{},{},-1,0

	if(_path)depth,path=gen_path(crumb_lib[_path])
	-- if(_type==5)active=false spawn_anchor(_ENV,3,-3,-2)spawn_anchor(_ENV,4,3,-2)

	return add(enems,_ENV)
end

function draw_map()
	-- draw map
	palt(cur_transparent,false)
	palt(15,true)

	for i,mapseg in inext,map_segments do
		map(mapseg\4*20,(3-mapseg%4)*8,-16,map_progress-i*64,20,8)
	end
	palt(cur_transparent,true)
	palt(15,false)
	-- draw map
end

-- drawing reorganisation
function draw_ui()
	-- boss health bar
	if boss_active and boss.health>0 then 
		local x_position=cam_x+3
		rectfill(x_position,3,x_position+121*(boss.health/boss_maxhealth),4,7)
	end

	local ox,oy,str_combo=3+cam_x,3,tostr(combo_num\1)
	if(boss_active)oy+=6	
	if(combo_num==0)score_in_combo=0

	highest_combo=tostr(max(highest_combo,str_combo))

	--local score_text=t%720<180 and score_in_combo>5000 and "+"..tostr(score_in_combo,0x2).."0" or t%720>540 and "max  "..highest_combo.."HIT" or tostr(score,0x2).."0" 

	local is_highscore_text=t%720>480 and not boss_active
	local score_text=is_highscore_text and "HIGH "..highscore or tostr(score,0x2).."0" 

	?score_text,ox+125-#score_text*4,oy-1,global_flash and 13 or 0
	?score_text,ox+125-#score_text*4,oy-2,is_highscore_text and 6 or 7

	if combo_num>50 and t%5<4 then 
		local _x,_y=ox,oy+17
		if(boss_active)_x,_y=40+cam_x,7

		palt(3,true)

		for i=0,2 do 
			pal(i,combo_colours[i+1 + min(combo_num\250,4)*3])
		end

		if(combo_on_frame>0)pal(13,5)
		for i=1,#str_combo do 
			local sx,sy=unpack(combo_big_letters[tonum(str_combo[i])+1])
			sspr(sx,sy,8,13,_x+i*9-3,_y)
		end
		sspr(110,53,16,10,#str_combo*9+_x+6,_y)

		pal(13,13)
		palt(3,false)


		allpal()
	end

	local clamped_counter,text,combo_text=min(combo_counter,100),"\f2"..str_combo.."HIT","+"..tostr(score_in_combo,0x2).."0"


	if(boss_active)goto skip_ui

	oy+=15
	ox-=1
	rectfill(ox,oy - clamped_counter/5.9,3+ox,oy,meter_colours[1+clamped_counter\10])

	sspr_obj(61,cam_x-1,-1)

	-- ?"_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\n_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\n_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\f4\|5\r_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\n_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\n_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_\-d_",cam_x+7,-3,5

	?"⁶x3_____________\n_____________\n_____________\f4\|5\r_____________\n_____________\n_____________",cam_x+7,-3,5
	sspr_obj(62,cam_x-5,-1)


	rect(ox+4,14,ox+15,17,4)
	rect(ox+4,14,ox+15,16,5)



	if t%500<150 then 
		?"MAX",ox+6,2,7
		text=highest_combo.."\f7HIT"
	end

	?text,ox+51-#text*4,2,3

	?combo_text,ox+43-#combo_text*4,8,7

	?"|\n\|f|\n\|f|",ox+3,1,5

	::skip_ui::

	-- bomb UI
	local num=bombs+bomb_preview_offset
	for i=1,num do
		if bomb_flash>0 and i==num then 
			bomb_flash-=1
			if(bomb_flash==0)bomb_preview_offset=0
			if(global_flash)goto fuck_tokens
		end
		sspr_obj(60,ox+9*i-6,122)
	end
	::fuck_tokens::

	-- lives UI
	ox+=128
	local num=lives+live_preview_offset
	for i=1,num do
		if live_flash>0 and i==num then 
			live_flash-=1
			if(live_flash==0)live_preview_offset=0
			if(global_flash)goto skip_this_bullshit
		end
		sspr_obj(21,ox-9*i,122)
	end
	::skip_this_bullshit::

end

-->8
-- player lerp

function lerp_player()
	if(t<45)return
	if(player_lerp_delay>0)player_lerp_delay-=1 return			-- adds a delay to the start of a lerp

	if(not input_disabled and inbtn>0 and player_lerp_perc>50)player_lerp_perc=100		-- allows you to animation cancel the respawn
	if(player_lerp_perc>=100)player_lerp_perc=-1 return			-- deletes the lerp from existence if needs must

	player_lerp_perc+=player_lerp_speed

	local new_t=easeoutquad(player_lerp_perc*0.01)
	player.x,player.y=lerp(player_lerpx_1,player_lerpx_2,new_t),lerp(player_lerpy_1,player_lerpy_2,new_t)
end

function easeoutquad(t)
    t-=1
    return 1-t*t
end

function easeinoutquad(t)
    if(t<.5) return t*t*2
	t-=1
	return 1-t*t*2
end

-- lerps to position , and then lerps back again - for explosion reaction
function easeoutovershoot(t)
	return 6.6*t*(1-t)^2
end

-->8
-- combo meter

function add_ccounter(number_add, maximum_clamp)
	if(combo_counter>100 or player_lerp_delay>0)return
	local val=combo_counter+number_add
	combo_counter,combo_on_frame=combo_num<=0 and 0 or min(val,max(maximum_clamp or val, combo_counter)),2
end


function upd_combo()
	if pause_combo!=0 then
		if(pause_combo>0)pause_combo-=1
		return
	end

	if combo_freeze>0 then
		combo_freeze-=1
	else
		if combo_counter>0 then 
			combo_counter-=1
		else
			combo_num=0
		end
	end
end

-->8
-- point management

-- make the player immune or max out
function new_bulcancel(_speed, _stop_shots_amount, _spawn_coins)
	bullet_cancel_origin,bullet_cancel,cancel_start_y,spawn_pickups,player_immune=_speed,0,0,_spawn_coins,max(_speed, player_immune)

	-- find the lowest bullet and start from there
	-- makes it look nicer
	-- TOKENS if I want to get rid of this effect
	for bul in all(buls) do 
		if(bul.y>cancel_start_y)cancel_start_y=bul.y
	end

	-- shot pause stuff
	if(_stop_shots_amount)shot_pause,spawners=_stop_shots_amount,{}
end


function upd_bulcancel()
	local current_perc=cancel_start_y-(bullet_cancel/bullet_cancel_origin)*200

	for bul in all(buls) do
		if bul.y>current_perc then
			if(spawn_pickups)spawn_pickup(bul.x,bul.y)
			spawn_oneshot(9,5,bul.x,bul.y)
			del(buls,bul)
		end
	end
	bullet_cancel+=1
	if(bullet_cancel>=bullet_cancel_origin)bullet_cancel_origin=0
end


--8191
function spawn_pickup(_originx,_originy,_amount,_speed,_type)
	for _=1,_amount or 1 do
		add(pickups,{
			x=_originx,
			y=_originy,

			ox=0,
			oy=0,

			dir=rnd(),
			spd=rnd(_speed) or .5,

			t=t,
			life=0,
			type=_type or 1,
		})
	end
end

function drw_pickup(pickup)
	local pickup_x,pickup_y=pickup.x+pickup.ox,pickup.y+pickup.oy
	local dist=sqrt(abs(pickup_x-player_x)^2+abs(pickup_y-player_y)^2)

	pickup.life+=1
	local type,life,bonus_type,visual_anim,collect_range,y_spd=pickup.type,pickup.life,-1,14,50,.35
	is_bonus=type==2
	if type==2 or type==3 then 
		collect_range=20

		y_spd=.15
		if not pickup.dont_wave then 
			local sin_offset=life*.001
			pickup.ox,pickup.oy=sin(sin_offset)*25,cos(sin_offset*2)*10
		end

		if(type==2)visual_anim,bonus_type=13,(pickup.t+life\90)%3
		if(type==3)visual_anim,bonus_type,y_spd=14,4,.1
	end

	if player_lerp_delay<=0 and dist<collect_range then
		pickup.seek,pickup.dont_wave,pickup.ox,pickup.oy=true,true,0,0				-- break the follow if the player is respawning
	end
	
	

	if dist<10 then
		spawn_oneshot(15,3,pickup_x,pickup_y)
		del(pickups,pickup)

		local _text="+bomb"

		if bonus_type==0 or bonus_type==4 then
			-- red
			
			if bombs>=3 then
				give_score(5000, 1)
				new_text(pickup_x,pickup_y-7,"bombs full",60)
				new_text(pickup_x+4,pickup_y,"50000",90)
				return
			else
				bombs+=1
			end
		elseif bonus_type==1 then
			-- green
			lives+=1
			live_flash,_text=60,"extend"
		elseif bonus_type==2 then
			-- yellow
			give_score(1000, 1)
			combo_num+=30
			combo_counter,_text=160,"10000"
		else
			coin_chain_timer=20
			coin_chain_amount+=1
			local num=50*min(coin_chain_amount,10)
			give_score(num, 1)
			new_text(pickup_x,pickup_y,num.."0",45,true)
			sfx(61,2)
			return
		end

		new_text(pickup_x,pickup_y,_text,90)
		return
	end	

	pickup.x+=sin(pickup.dir)*pickup.spd
	pickup.y+=cos(pickup.dir)*pickup.spd+y_spd
	pickup.spd*=.95

	if(pickup.seek)pickup.x,pickup.y=lerp(pickup_x,player_x,0.2),lerp(pickup_y,player_y,0.2)

	if is_bonus then
		local flash,index=life%90<5,1
		for src in all(flash and split"1,2,3,4,5,6,7" or split"1,2,3") do 
			pal(src,flash and 7 or pickup_colours[bonus_type+1][index]) 
			index+=1
		end
	end
	sspr_anim(visual_anim,pickup_x,pickup_y,pickup.t)
	if(is_bonus)allpal()
end

-- _multi is the optional capped multipler
-- coins cap out at 100x 
function give_score(value, multiplier)

	-- score+=_amount*(combo_num==0 and 1 or combo_num\2) -- tokens
	--limit of 99 999 999
	local mult=multiplier or max(.25*combo_num^1.25,1)
	local value=value*mult

 	if score <152.58788 then
		score+=value>>>16
		score_in_combo+=value>>>16
		if score>=152.58788 then
			score,score_in_combo=152.58788,152.58788
		end
	end
end

-->8
-- boss information


function spawn_boss(spawn_timeline, _data)
	if(map_timeline!=spawn_timeline)return

	map_timeline+=1 -- this is a cringe way to stop it spawning over and over | I know it's bad

	local boss_data=split(_data,"\n")
	local init_info=parse_data(boss_data[1])
	local enem,sx,sy,brain=unpack(init_info[1])
	
	boss=spawn_enem(nil,enem,sx,sy)
	boss_maxhealth,boss_active,boss.brain,boss.intropause,boss.boss_data,boss.stage,pause_timeline=boss.health,true,brain,120,boss_data,0,true

	if init_info[2][1]!="none" then
		for i=2,#init_info do 
			local type,ox,oy,turret=unpack(init_info[i])
			local anchor=spawn_anchor(boss,type,ox,oy,true,nil,turret)
			anchor.intropause=120
		end
	end

	boss_incriment_stage(boss,1)
end



-- boss lerping stuff
function upd_lerp(object)
	-- tokens tokens tokens
	object.lerpperc+=object.lerprate or 1

	local lerp_perc_proper=object.lerpperc*.01
	local new_t=object.lerptype=="overshootout" and easeoutovershoot(lerp_perc_proper) or easeinoutquad(lerp_perc_proper)
	object.sx,object.sy=lerp(object.originx,object.tx,new_t),lerp(object.originy,object.ty,new_t)

	-- tokens
	if object.lerpperc>=100 then
		local outx,outy=object.tx,object.ty
		if(object.lerptype == "overshootout")outx,outy=object.sx,object.sy
		object.lerpperc,object.sx,object.sy=-1,outx,outy
	end
end

-- iterate forward is incredibly unsexy , but it's basically for the previous boss
-- basically makes the boss only change to stages in a forwards direction
function boss_incriment_stage(_boss, _index, _only_iterate_forward)
	if(_only_iterate_forward and _index<=_boss.stage)return
	
	_boss.stage = _index
	local index=_boss.stage

	--lerp stuff
	local lerpdata,shotdata=unpack(parse_data(_boss.boss_data[index+1]))
	_boss.lerpcounter=0
	if #lerpdata>0 then
		_boss.lerpchangerate,_boss.lerprate,_boss.lerpindex=lerpdata[1],lerpdata[2],1

		local lerp_positions={}
		for i=3,#lerpdata,2 do
			add(lerp_positions,{lerpdata[i],lerpdata[i+1]})
		end

		local tx,ty=unpack(lerp_positions[1])
		new_lerpbrain(_boss,tx,ty,_boss.lerprate)
		boss.lerp_positions=lerp_positions
	end

	if(shotdata[1]=="delete")_boss.turrets={}
	-- for turret in all(shotdata) do add_turret(_boss,turret) end
	for i=2,#shotdata do 
		add_turret(_boss,shotdata[i])
	end
end


function upd_brain(enemy, _index)
	if _index==1 then
		-- enemy brain at _index == 1
	end
end



-->8
-- exit / load animation

function spiral_anim(_perc)
	if(spiral_exit and spiral_lerpperc==1)load("kalikan_menu.p8",nil,"died|1|"..score.."|"..highest_combo.."|2")

	if(spiral_lerpperc==1 and not spiral_exit or spiral_pause>0)return
	spiral_lerpperc=mid(0,spiral_lerpperc+.015,1)

	for i=0,63 do 
		local x,y,fadeperc=i%8*16+cam_x,i\8*16,mid(1,-64+split"1,2,3,4,5,6,7,8,28,29,30,31,32,33,34,9,27,48,49,50,51,52,35,10,26,47,60,61,62,53,36,11,25,46,59,64,63,54,37,12,24,45,58,57,56,55,38,13,23,44,43,42,41,40,39,14,22,21,20,19,18,17,16,15"[i+1]+_perc*70,5)\1
		fillp(split"0x0.8,0xa5a5.8,0x7d7d.8,0x7fff.8,0xffff.8"[fadeperc])
		rectfill(x-1,y,x+15,y+17,13)
	end
	fillp""
end



__gfx__
ffffffffeeeeeeeeeeeeeeeeeeeeeee4e4ee4e4444ee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ffffffffeeeeeeeeee44444eeeeeeee4e4ee4e4444ee44eeee4444eee44ee44eeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeee4444eeeeeeeeeeeee7e7eeeee777ee
ffffffffeeeeeeeeee44444eeeeeeee4e4ee4ee444eee4eee444444ee4ee444eeeeeeeeeeeeeeeeeeeeeeeeeee444eeee44ee44eeeeeeeeeeee7e7eeeee7eeee
ffffffffeeeeeeeeeeeee44eeeeeeee4e4ee4e4444ee45eee44ee44eeee444eee44ee44eeeeeeeeeeeeeeeeeeee44eeeeeeee44eee444eeeeee777eeeee777ee
ffffffffeeeeeeeeeeeee44eeeeeeee4e4ee4e4444ee44eee444444eee444eeee44ee44eeeeeeeeeeeeeeeeeeee44eeeee4444eeee444eeeeeeee7eeeeeee7ee
ffffffffeeeeeeeeeeeee44eeeeeeee4e4444e44eeee44eee44ee44ee444ee4eeeeeeeeeeeeeeeeeeeeeeeeeeee44eeee44eeeeeeee44eeeeeeee7eeeee777ee
ffffffffeeeeeeeeeeeeeeeeeee4e4e4e4444e44eeeeeeeee44ee44ee44ee44eeeeeeeeeeeeeeee55eeeeeeeee4444eee444444eeeeeeeee7eeeeeee7eeeeeee
ffffffffeeeeeeeeeeeeeeeeeeeeeee4e444455555555544eeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555eeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee77eeeeee
eeeeeeeeeeeeeeeeeeeeeeee4eeeeeeee444e5ee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee4eeeeeeee444e5ee44444eeee44444eee44444eeeee44eeeee5555eeeee44eeeee4444ee44eeee44eeeeeeeeeee777eeeee777ee
eeee4444444444444444eeee4eeeeeeee444e55555555544e44ee44ee44444eeeee44eeeee4444eeeee44eeee44ee44e44e44e44eeeeeeeeeee7e7eeeee7e7ee
ee44ffffffffffffffff44ee4eeeeeeee444eeeeeeeeeeeee44444eee44eeeeeeeeeeeeeeeeeeeeeeee44eeee44eeeee44e44e44eee444eeeee777eeeee7e7ee
e4ffffffffffffffffffff4e4eeeeeeee444eeeeeeeeeeeee44ee44ee44eeeeeeeeeeeeeeeeeeeeeeee44eeee44eeeee44eeee44eee444eeeeeee7eeeee7e7ee
4ffffffffffffffffffffff44eeeeeeee4444e4444eee4eee44ee44ee44eeeeeeee44eeeeeeeeeeeeee44eeee44ee44e44e44e44eee44eeeeeeee7eeeee777ee
4ffffffffffffffffffffff44e4e4eeee4444e4444ee45eee44444eeeeeeeeeeeee44eeeeeeeeeeeeee44eeeee4444eeeee44eeeeeeeeeee7eeeeeee7eeeeeee
4ffffffffffffffffffffff44eeeeeeee4444ee444ee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeeeeee44eeeeeeeeeee77eeeeee77eeeeee
4ffffffffffffffffffffff45444ee45ee44ee4444e4ee4e55555555e444444eeeeeee5555eeeeee4555555555555554eeeee444444eeeee4eee4effffe4eee4
4f5f5fff5fff5fff5fff5f645444ee45ee44ee4444e4ee4e55555555e444444eeeeeee5555eeeeee5555555555555555ee55ee4444ee55ee4eee4effffe4eee4
466f5f5f5f5f5f5f5f5f56645e44ee45ee4eee444ee4ee4eeeeeeeee55555555eeeeee5555eeeeee555eeeeeeeeee555eee45ee44ee54eee4eee4eeffee4eee4
e4666f5f5f5f5f5f5f56664e5e44ee45ee54ee4444e4ee4eeeeeeeeeeeeeeeeeeeeeee5555eeeeee55eeeeeeeeeeee5544ee45e44e54ee444eee4e5445e4eee4
ee44666666666666666644ee54e4ee45ee44ee4444e4ee4eeeeeeeee4e4444e4eeeeee5555eeeeee55eeeeeeeeeeee55ee4ee5e44e5ee4ee4eee4e5445e4eee4
eeee4444444444444444eeee54e4ee45ee44eeee44e4444eeeeeeeee444ee444eeeeee5555eeeeee55eeeeeeeeeeee55eee4e4e44e4e4eee4eee4eeffee4eee4
eeeeeeeeeeeeeeeeeeeeeeee544eee45eeeeeeee44e4444eeeeeeeee44444444eeeeee5555eeeeee55eeeeeeeeeeee55eee4eee44eee4eee444e4effffe4e444
eeeeeeeeeeeeeeeeeeeeeeee544eee45445555555554444eeeeeeeeeeeeeeeeeeeeeee5555eeeeee55eeeeeeeeeeee55eee4eee44eee4eee54ee4effffe4ee45
e454ede44ede454effffffff5444ee45eee44444ee5e444e4444444455eeeeeeeeeeeeeeeeeeee554444444444444444ffe4eeeeeeee4effe44d45dddd54d44e
e444edeeeede444effffffff5444ee45eee44444ee5e444e4444444455eeeeeeeeeeeeeeeeeeee554e4e4e4eeeeeeeeeffe4eeeeeeee4effe44d445dd544d44e
e46555eeee55564effffffff54e4ee4544555555555e444e4444444455eeeeeeeeeeeeeeeeeeee55eeeeeeeeeeeeeeeeffee4eeeeee4eeffe44de445544ed44e
e56555444455565effffffff54e4ee45eeeeeeeeeeee444e4444444455eeeeeeeeeeeeeeeeeeee554444444444444444ffeee444444eeeffe44dde4444edd44e
55eeee4dd4eeee55ffffffff54e4ee45eeeeeeeeeeee444e4444444455eeeeeeeeeeeeeeeeeeee55eeeeeeeeeeeeeeeeffeeeeeeeeeeeeffe44ddd4e44ddd44e
545444d44d444545ffffffff54e4ee45ee4eee4444e4444e44444444555eeeeeeeeeeeeeeeeee555eeeeeeeeeeeeeeeeffeeeeeeeeeeeeffe44dd544445dd44e
4e5ee4d44d4ee5e4555555555444ee45ee54ee4444e4444eeeeeeeee555555555555555555555555eeeeeeeeeeeeeeeeffeeeeeeeeeeeeffe44d544ee445d44e
ee54eed44dee45ee555555555444ee45ee44ee444ee4444eeeeeeeee455555555555555555555554eeeeeeeeeeeeeeeefffeeeeeeeeeefffe44d44edde44d44e
e454ede44ede454ede4456666665e4ed48994444408980444000044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444bbb44444aa44444aaaa44
e454ede44ede454ede45566ee66544ed89ff8444489f98408899880eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bcccb44aabbaa44abccba4
ee4eede44edee4eede456665566544ed9f77f84409f7f9089977998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bc373cbabbccbba4ab77ba4
e454eddee4de454ede455665566544ed9f777f8409f7f9097777779eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc3777cbac3333caabc77cba
e454ede44ede454ede4e5665566544ed48f777f909f7f9089977998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc7773cbac3333caabc77cba
e454ede44ede454ede445665566554ed448f77f909f7f9008899880eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc373cb4abbccbba4ab77ba4
e454ede44ede454ede445665566654ed4448ff98489f98444000044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bcccb444aabbaa44abccba4
e454ede44ede454ede445666666554ed444499844089804eeeeeeeeee3300000300000000300000033000000330000003eeeeeee44bbb444444aa44444aaaa44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee300ddd030dddddd000dddd0000dddd0000dddd00eeeeeee444111444440044444000044
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00dd00030000ddd00ddd00d00d00ddd00ddd00d0eeeeeee441222144001100440122104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1dd31dd3ddd133311d3311d11d1133d11d3311d1eeeeeee412373210112211040177104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdddddddbdddddddbdddddddb2d332223dd223332233322322322333223332d32eeeeeee123777210233332001277210
bb6666bbbb5555bbeeeeeeeeeeeeeeeedd08880ddd00d88ddd8d888dd2333dd22332d33222233dd2222dd33322333dd32eeeeeee127773210233332001277210
b666666bb555555beeeeeeeeeeeeeeeed0977790d5668996d4089776d233322d2322d332d2d3322d2d22233322333d232eeeeeee123732140112211040177104
666bb666555bb555bb5555bbeeeeeeeed8979798d5068997d5089796d233322d232d3322d2d3322d2ddd2333223332232eeeeeee412221444001100440122104
66bbbb6655bbbb5555555555eeeeeeeed8977998d5688997d5089779d1333113131d331d3133311313111333113331131eeeeeee441114444440044444000044
66bbbb6655bbbb55554bb455b444444bd8979798d5068997d5089796d0033dd00303330d30033dd0030dd33000033dd00eeeeeeeeeeeeeeee488044989449884
666bb666555bb555554bb455444bb444d0977790d5668996d4089776dd000000d30000033d000000d3000000dd000000deeeeeeeeeeeeeeee0ff080777989770
b666666bb555555b5555555554444445dd08880ddd00d88ddd8d888dddddddddd3ddddd33dddddddd3dddddddddddddddeeeee00000000eee8fff88777887778
bb6666bbbb5555bbbb5555bbb555555bbdddddddbdddddddbdddddddb3dddddd33ddddd333dddddd33dddddd33dddddd3eeeee0d00ddd0eee80ff09777007798
bbbbbbbbbbbbddbddbbbbbbbbddddbbbbbbbbddebbbbbbbbbbbbbdddddbbbbbbbbbbbbbbbbbddd0000003330000003300000030d00ddd0eee408844989448894
bbbbbbbbbbbd99bd7dbbbbbbd7667dbbbbbbd7debbbbbbbbbbbbdd9999bbbbbbbbbbdddbbbdd000dddd03300dddd0000dddd00131133310030030000000000ee
bbbbbbbbbbd877bd0dbbbbbd86996dbbbbbd777ebbbbbbbbbbbdd99888bbbbbbbbbd788dbdd06700ddd0330d00ddd00d00ddd023223332113113d11ddd11ddee
bbbbbbbbbbd677bd8dbbbbd889999dbbbbbd767ebbbbbbbbbbdd998999bbbbbbbbd7788ddd0667d1333133111133d1111133d123dd33322232233223332233ee
bbbbbbbbbbd677bd98dbbbd889999dbbbbbd666ebbbbbbbdddd8999999bbbbbbbd977888005667d2333233dd223332d2223332222233322232233223332233ee
bbbbbbbbbbd699bd99dbddd889999dbbddbd676ebbbbbbdd9999999999bbbbbbd897788884566732333233d22d3322d2dd3322ddd233322222233223332233ee
bbbdddddddd899d7898dd9d889999dbd77dd677ebbbbbdd99999999999bbbbbd889778888456673233323322dd322d322233d2ddd1333122d2233223332233ee
bbd6688888d807d6709d87d889999dbd776d655ebbbbdd999999999999bbbdd888977888845667323332332dd322dd222233d2333033301131133113331133ee
bd66888880d707d9679567d886996dd67769966ebbbdd8989999999999bbbd8888977888845667113331111d3311111d113331333000000030033003330033ee
d7709990006707d8960769d886996dd67769966ebbbd88989999999999bbbd88899778888456670d3333d00333ddd000dd3300333ddddd0030030000330033ee
d009990ddd6707bd897d80d887667dd67768866ebbbd88989999999999bbbd88999778888456670000000000000000d000000d333ddddddd3dd3dddd33dd33ee
d99999d4446705bd05dd05d885005dd65568666ebbbd80989999999999bbbd8999977888805667ddddddddddddddddddddddddeebddbbbbbbbbeeeeeeeeeeeee
d00000477d6508bd56dbd0d800000dd58850676ebbbd00909999999999bbbd8999977888005668dddddddddddddddd3dddddd3eebd7dbbbbbbbeeeeeeeeeeeee
d00999d776e587bd6dbbbdd000000dd50050677ebbbd09909999999999bbd88999777888005887dddbbbbbbbbbbbbbbbbbbbbbbbbd0dbbbbbbbeeeeeeeeeeeee
bd98886776e603bddbbbbbd0000ddbd50050655ebbbd89999999999999bd888999668880008767d0dbbbbbbbbbbbbbbbbbbbbbbbbd8dbbbbbbbeeeeeeeeb5555
bd888867768740bb45b66bd000dbbbbd66d0666ebbd889009009999999bd888996668808087669d0dbbbbbbbbbbbbbbbbbbbbbbbbd98dbbbbbbeeeeeeee555b5
bbd00067768574b4446555d000dbbbbbddbd767ebbd889889889999999d9888976688888066697d8dbbbbbbbbbbbbbbbbbbbbbbbbd998dbbbddeeeeeeee55bb5
bbd000655608544444565bbdddbbbbbbbbbd777ebbd889889889999999d9888776888888056862d8dbbbbbbbbbbbbbbbbbbbbbbbd78998dbdd9eeeeeeee5bbb5
bbbddd5885d00d444b3b5bb545545bbbbbbd575ebbd889999999999999d9886778888888056063d9dbbbbbbbbbbbbbbbbdbbbbbbd78099dbd87eeeeeeee5bbb5
bbbbbd5005dddbb4bb355554bb4454bbbbbd565ebdd800000009999999d9866790000888005706d7dbbbbbbbbbbbbbbbd9bbbbbbd68809dbd67eeeeeeee5bbb5
bbbbbd5005dbbb5bb44655333333b4bbbbbdd6dedd4000000000999999d7666884554888000670d7dbbbbbbbbbbbbbbbd9bbbbbbd67880dbd69eeeeeeee5bbb5
bbbbbbd66dbbbb65554b6b44444444bbbbbbddded44000000000000000d7668887667888600055d9dbbbbdddddbbbbbbd9bbbbbbd568808dd89000000035bbb5
bbbbbbbddbbbbb3355b3335555555533bbbbddbbd44077777770055777d7688880000888760000d9dbbbdd979ddbbbbd87bbbbbbbd5780880980ddddd035bbb5
bbbbbddddbbbbbbbbbbbdddbbbbbbbbbbbbd99ddd44765656567455555d9888888888888776000d8dbbdd99799ddbbbd87bbbbbbbbd560880900ddd00035bbb5
bbbbd0766dbbbbbbbbbd766dddbbbbbbbdd899d6d447767676774d5555d9888888888800007666d8dbdd8997998ddbd887bbbbbbbbbd568890713331dd35bbb5
bbbd990066dbbbbbbbd9006688ddbbbbd6089986d445555555554dd555d9888888888800000777d85dd089979980ddd889bbbbbbbbbd0554903233322235bbb5
bbd90999988dbbbbbd9999088888ddbbbd089985d4589977799854dd4dbd888000008800000557d068d089979980dd8860bbbbbbbbbd00854802333dd225bbb5
bbd990dd0088dbbbbd099dd0088886dbbbd8778dd5488999998845dd44bbd80000000880000555d0788089979980888660bbbbbbbbbd98800892222ddd25bbb5
bd889044d0088dbbd990044d0098866dbbd6776dd5488989898845ddddbbbd000000088000ddd5d07880899799809866600bbbbbbbd98540098222233d25bbb5
bd888d744d0986dbd8899644d099986dbbd6556dd5408888888045dbbbbbbbd0000000880dddddd068808997998077668800bbbbbd9864d70801d1133315bb55
d088877744d9966dd08887744d99907dbbd5005dd5400808080045dbbbbbbbbd0000008dddddddd0688089777980777888800bbbbd865dd680500dd33005b555
d008777764d9906dd08867776009990dbbbd55dbdd50080808005ddbbbbbbbbbd0000dddbbbbbbd06880877777809999888800bbbd65dbbd6d0d000000d55555
d00777766009907dd00877766990990dbbbbddbbbdd555555555ddbbbbbbbbbbd000ddbbbbbbbbd068806797976099999888800bbd5dbbbdddbdddddddd55554
d07777669990990dd00677768889000dbbb6beeebbdddddddddddbbbbbbbbbbbdddddbbbbbbbbbbd588069979960999999888800bddbbbbbbbb3dddddd34444b
d45776688899000dbd555764880000dbbb656eeeebddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddbd588089666980999999988880bbbdddbbbbdddbbbbdddbeee
d5006688888000dbbd50056000000dbbb5555eeeed0dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd67bbd8808644468099999999000dbbd800dbbd980dbbd998deee
d600540000000dbbbd600540000ddbbb5555beeeed0dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd567bbd8805657565099999900dddbbd94554bd94550bd94558eee
bd654000000ddbbbbbd655dddddbbbbb455bbeeeed8dbbbbbbbbbbbbbbbbbbbbbbbbddddddd556bbd08800666009999900ddbbbbd845660d945668d945668eee
bbdddddddddbbbbbbbbdddbbbbbbbbbbb4bbbeeeed8dbbbbbbbbbbbbbbbbbbbbbbddd897799997bbd088800000999900ddbbbbbbd056678d856678d956679eee
3337777333bbbddbbbbd000dbeeeeeeeeeeeeeeeed9ddbbbbbbbbbbbbbbbbbbbbdd88897799997bbbd088888889900ddbbbbbbbbd056789d056789d856789eee
3733773373bbd33dbbd87778deeeeeeeeeeeeeeeed78dbbbbbbbbbbbbbbbbbbbd9988897799997bbbd0888888000ddbbbbbbbbbbbd40897ed08897ed88997eee
3773773773bb0220bb0878780eeeeeeeeeeeeeeeed78ddbbbbbbbbbbbbbbbbbd89988997799997bbbbd566666500dbbbbbbbbbbbd056789d056789d856789eee
3333773333bd3113db0877880eeeeeeeeeeeeeeeed988dbbbbbbbbbbbbbbbbd889988997799997bbbbd566666550dbbbbddddddbd056678d856678d956679eee
b22333322bb027720b0878780eeeeeeeeeeeeeeeed988dddbbbbbbbbbbbbbd8889988997799906bbbbbd08888055dddddd8888dbd845660d945668d945668eee
bb123321bbd317713dd87778deeeeeeeeeeeeeeeed08889dddddbbbbbbbbd88889989997799045bbbbbd088880056888888888dbbd94554bd94550bd94558eee
bbb1221bbb02700720bd000dbeeeeeeeeeeeeeeeed088999999ddddbbbdd888809899977790456bbbbbbd08880006888888888dbbbd800dbbd980dbbd998deee
eeeeeeeeeed164461deeeeeeeeeeeeeeeeeeeeeeed0899999999779ddd99880088999777990557bbbbbbd00000006688888800dbbbbdddbbbbdddbbbbdddbeee
eeeeeeeeeeb04dd40beeeeeeeeeeeeeeeeeeeeeeed069999999777999999008888997779980567bbbbbbbd08800066888800ddbbbbbddddddbbbeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed858888899779999999888888997799980567bbbbbbbd088000668800ddbbbbbbd622225dbbeeeeeeeeeeee
bbb77777bbbbbb77777bbbbbb33333bbbbbbbbbeedd5ddddd88679999999888888997799950567bbbbbbbbd080006000ddbbbbbbbd72332226dbeeeeeeeeeeee
bb7777777bbbb7777777bbbb3777773bbbbbbbbeebdddbbbdddd68999999888888997799958679bbbbbbbbd08000ddddbbbbbbbbd7137332216deeeeeeeeeeee
b777777777bb777333777bb377bbb773bbbbbbbeebbbbbbbbbbddd888899888888997799985697bbbbbbbbbd0000dbbbbbbbbbbbd6133332216deeeeeeeeeeee
7777777777777733333777377bbbbb773bbbbbbeebbbbbbbbbbbbddddd88088888997799985862bbbbbbbbbd0000dbbbbbbbbbbbd6123322215deeeeeeeeeeee
7777737777777333b3337737bbbbbbb73bbbbbbeebbbbbbbbbbbbbbbbdddd00088997799985063bbbbbbbbbbd000dbbbbbbbbbbbd6412222145deeeeeeeeeeee
777733377777733bbb337737bbbbbbb73b7777beebbbbbbbbbbbbbbbbbbbdd5500897799980706bbbbbbbbbbd000dbbbbbbbbbbbd6741111465deeeeeeeeeeee
7777737777777333b3337737bbbbbbb73777777eebbbbbbbbbbbbbbbbbbbbd6765d86699900560bbbbbbbbbbbd00dbbbbbbbbbbbd5674444654deeeeeeeeeeee
7777777777777733333777377bbbbb773773377eebbbbbbbbbbbbbbbbbbbbd6556dddd89908055bbbbbbbbbbbd00dbbbbbbbbbbbbd56667754dbeeeeeeeeeeee
b777777777bb777333777bb377bbb773b773377eebbbbbbbbbbbbbbbbbbbbdd44ddbbdd8908dddbbbbbbbbbbbbdddbbbbbbbbbbbbbd555544dbbeeeeeeeeeeee
bb7777777bbbb7777777bbbb3777773bb777777eebbbbbbbbbbbbbbbbbbbbbddddbbbbdd80ddddeeeeeeeeeeeeeeeeeeeeeeeeeebbbddddddbbbeeeeeeeeeeee
bbb77777bbbbbb77777bbbbbb33333bbbb7777beebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddbbeeeeeeeeeeeeeeeeeeeeeebbbbbbbbb7bbbbbbbb7bbbbbeeee
bbbbbddbbbbbbbbbbbbddbbbbbbbbbbbbbdbbbbbbbbbbbbbbb11bbbbb11bbb11beeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbb7bbbbb7bbbbbbbbbbbbbbeeee
bbbbd33dbbbbbbbbbbd33dbbbbbbbbbbbd3bbbbbbbbbbbbbb1771bbb1771b1771eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbb7bbbbb7bbbbbbbbbbbbbbeeee
bbbbd22dbbbbbbbbbbd220bbbbbbbbbbb02bbbbbbbbbbbbbb1771bbb1771b1771eee44444344434444eeeeeeeeeeeeeeeeeebb777bbbbbbbbbbbbbbbbbbbee55
bbbd3222dbbbbbbbbd3222dbbbbbbbbbd32bbbbbbbbbbbbbb1771bbb2772b1771eee44444344424444eeeeeeeeeeeeeeeeee77777777bbb777bbbbbbbbb7ee55
bbbd21120bbbbbbbb021120bbbbbbbbb021bbbbbbbbbbbbbb2772bbb2772b2772eee44444344424444bbddbbbbddbbbbddbbbb777bbbbbbbbbbbbbbbbbbbee55
bbbd20021dbbbbbbd3200220bbbbbbbd320bbbbbbbbbbbbb127721bb2772b2772eee44344344444444bd77dbbd77dbbd77dbbbb7bbbbb7bbbbbbbbbbbbbbee55
bbd3177123bbbbbb02177125dbbbbbb0217b1111bb1111bb127721b1777712772eee43343124444444dd66dddd66dddd66ddbbb7bbbbb7bbbbbbbbbbbbbbee55
bbd21771d2dbbbbd52177116dbbbbbd5217b1771bb1771b127777211777712772eee43321124444443d3333dd2333dd3333dbbbbbbbbb7bbbbbbbb7bbbbbee55
bbd12ddd723dbbb0612dd2dd3dbbbb0612db1771bb1771b22777722277772277244244111124444424d2222dd1222dd2222deeeeeeeeebbddddbbbddbbbddb55
bd3dd0076223dbd3dd2002d720dbbd3dd20127721b2772b22277222277772277242234111122444244d215ddd1222dd1551deeeeeeeeebd6777dbd67dbd67d55
bd2741146123dd0277411476230bd02774117777112772127277272277772222242131111122244444d266ddd1222dd1661deeeeeeeeed665567d6667dd67d55
d3164444201ddd316644446d123d032664427777217777127277272277772222222141111112244434d2222dd1222dd2222deeeeeeeeed656676d6576dd67d55
d21d3dd310ddbd21d63dd31d01dd321d63d27777227777227777772227722222221142111112244244d1111dd1111dd1111deeeeeeeeed656676d6576dd67d55
d10d12223ddbbd10d122223d0dddd10d12227777227777222777722227722222221144111111244444dd55dddd55dddd55ddeeeeeeeeed567766d5666dd67d55
dd0d301d4dbbbdd0d3d11d4ddbbbdd0d3d1227722277772b277772bb2222b222221144411111444444bd44dbbd44dbbd44dbeeeeeeeeebd5556dbd56dbd67d54
bbdd44d4dbbbbbbdd44dd4ddbbbbbbdd44db2772bb2772bbb2222bbbb22bbb22b42144441114444444bbddbbbbddbbbbddbbeeeeeeeeebbddddbbbddbbbddb4b
__label__
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
i5dll55llll55l5555l5llllllllllllllllllllllllllll977779llll55lllllllllllllllll477774lllllllllllllll5l5555l55llll55lld5l5ll5d5llli
i5ddddddddddddddddddddddddddddddddddddddddddddddl9999l5l5l55l5l5lllllllllllll977779lllllllllll5l5l5l5555l5577ll77ll777l777d777li
i5dddqdd55555555555555555599959995555555555555ddllllllllll55lllllllllllllllll977779lllllllllllllll5l5555ddd27dd2755722l227d727li
i5ddqqdd555lldl555l5llllllll9lll9l9l9l999l999lddllllllllll55lllllllllllllllll977779lllllllllllllll5l555ldll575557ll7775l77d7l7li
i5dqqqdd555lldl555l5llllll999l999l9l9ll9lll9llddllllllllll55llllllllllllllllll9779llllllllllllllll5l555ldll575557ll2275l27d7l7li
i5dqqqddddddddl555l5llllll9lll9lll999ll9lll9llddllllllllll55llllllllllllllllllllllllllllllllllllll5l555lddd777d77757775777d777li
i5dqqqddlllllll555l5llllll999l999l9l9l999ll9llddllllllllll544llllllllllllll44lllllllllllllllllllll5l555llll222l222l2225222d222li
i5dqqqddddddddddddddddddddddddddddddddddddddddddllllllllll4774llllllllllll4774llllllllllllllllllll5l555lllllllllllld5l5ll5d5llli
i5dqqqdd55555555555555555555557755775577757775ddllllllllll4774llllllllllll4774llllllllllllllllllll5l5555l5555lll5lld5l5ll5d5llli
i5dqqqddl5555l5555l5l5l5lll7lll7lll7ll7lllll7lddllllll5l5l4774l5llllllllll4774llllllllllllllll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dqqqddl555ll5555l5llllll777ll7lll7ll777ll77lddllllllllll9779llllllllllll9779llllllllllllllllllll5l5555ll555ll55lld555ll5d5llli
i5dqqqddl5555l5ll5l5lllllll7lll7lll7llll7lll7lddlllllllll497794llllllllll497794lllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dqqqddl5555l5ll5l5llllllllll777l777l777l777lddlllllllll497794llllllllll497794lllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dqqqddddddddddddddddddddddddddddddddddddddddd5llllllll49777794llllllll49777794llllllllllllllllll5l5ll5ll555lll5lldl55ll5d5llli
i5dqqqdd5555555555d5555555555555555555555555555lllllllll99777799llllllll99777799llllllllllllllllll5l5ll5l5555ll5dlldl55ll5d5llli
i5dqqqddddddddddddd5llllllllllllll4444llllllllllllllllll99977999llllllll99977999llllllllllllllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dqqdd5555555555555llllllllllllll4774llllllllllllllllll97977979alllllll97977979llllllllllllllllll5l5555l55llll55lld5l5ll5d5llli
i5dqdddllll55l5555l5l5l5llllllllll4774llllllllllllllll5a97977979aallllll97977979llllllllllllll5l5l5l5555l55lllllllld55lll5d5l5li
i5dddddddddddd5555l5llllllllllllll9779llllllllllll9a9lla97777779aallllll97777779llllllllllllllllll5l5555ddddddddd55d55lll5d5llli
i5dddd555522222255l222222ll22l22l2222222222lllll4aaa9a4a99777799aallllll99777799llllllllllllllllll5l555ldll55555llld555ll5d5llli
i5555555522iiii22522iiii22loolooliooiiiooiillii29a9aaa9aa9777797aa7llllll977779lllllllllllllllllll5l555ldll55555llld555ll5d5llli
i5d55dddd2i22iii252i22iii2l88l88l98877988ll2i67i9aaaaa9aa79999a7aaa77lllll9999llllllllllllllllllll5l555lddddddddd55d5l5ll5d5llli
i5dlllllloooollio5oooolliol88l88l98877988ll2i67i9aaaaa949aa7a7aa9aaaa77lllllllllllllllllllllllllll5l555lllllllllllld5l5ll5d5llli
i5dllllllii88ll585ii88lll8l88888l98877988ll2i67i4aaa9a444aaa5aaa7aaa7a7llllllllliilllliillllllllll5l555lllllllllllld5l5ll5d5llli
i5dll5llli88il5885i88ill88l88i88ll8879l88ll2i67i449a9444aaaaaaaaaa7777777lllllli88iiii88illlllllll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll88iil88i588iil88ilooloolloolllooll2i67i4444444aa77777777a77777777777iio88i77778oiilll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll8iil88ii58iil88iil22l22ll22lll22992i67il24494777a77777777777777779li62o84777777o26illllll5l5555ll555ll55lld555ll5d5llli
i5dll55lloi55oooo5oillooool22l22l2222l922ll2lii2l2ll779a9a77777777777777777lli2o4777aa77o2illlllll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll2555iii2525lliii2liiliiliiii9liillll2l2ll47449aa777777777777a777779llio4777aa77oillllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll22222222522222222lllllllll9lllllllllllll47aaa4a977777a77777aaa77779lli6977777776illllllll5l5ll5ll555lll5lld5l5ll5d5llli
i5dlld5lliiiiiiii5iiiiiiiillllllll9lllllllllllll9a7aaa4497777aaa77777a777779lli69777777d6illllllll5l5ll5l5555ll5dlld5l5ll5d5llli
i5dll55lliiiiiiii5iiiiiiiilllllll9lllllllllllll447aa9aaa477777a777777777777lllid9779id22dillllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllll9llllllllllllll49iiaaa9a9777777777777777779llll477774iddilllllllll5l5555l55llll55lld5l5ll5d5llli
iiiiillllll55l5555l5l5l5lllllll9lllllllllllllll4i67iaaaa94777777777777777llllll477774liillllll5l5l5l5555l55lllllllld555ll5d5l5li
i6777idddddddd5555l5lllllllllll9llllllllllllllli6667iaaa9457777777777777lllllll977779lllllllllllll5l5555ddddddddd55d555ll5d5llli
i6dd67i5555lldl555l5lllllllllll9llllllllllll44446d76ia9a445577777977779llllllll977779ll4444lllllll5l555ldll55555llld555ll5d5llli
id6676i5555lldl555l5lllllllllll9llllllllllll47746d76ia9a4l55lllll977779llllllll977779ll4774lllllll5l555ldll55555llld555ll5d5llli
id6676idddddddl555l5lllllllllll9llllllllllll4774d666ia44ll55lllll977779llllllll977779ll4774lllllll5l555lddddddddd55d5l5ll5d5llli
i67766illllllll555l5llllllllllll9llllllllll497794d6i774lll55lllll997799llllllll997799l497794llllll5l555lllllllllllld5l5ll5d5llli
iddd6illlllllll555l5lllllllllllll9lllllllll477774iilll777l55lllll997799llllll77997799l477774llllll5l555lllllllllllld5l5ll5d5llli
iiiii5lll5555l5555l5llllllllllllll9llllllll977779llllllll7777lllll9999lll7777lll9999ll977779llllll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5lllllllllll9lllllll977779lllll5l5l55l777777997777llllllll99lll977779ll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllll99lllll977779lllllllll55llll99llllllllllllllllllll977779llllll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllll99lll997799lllllllll55ll99llllllllllllllllllllll997799llllll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllll99999779lllllllll99999lllllllllllllllllllllllll9779lllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5lllllllllllllllllllllllll999999999999l55llllllllllllllllllllllllllllllllllllll5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllll44lllllllll44lllllllll5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll4774lllllll4774llllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll4774lllllll4774llllllll5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5lllllllllll9779lllllll9779llll5l5l5l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll9779lllllll9779llllllll5l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll9779lllllll9779llllllll5l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllll477774lllll477774lllllll5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllll477774lllll477774lllllll5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55llllllllllllll977779lllll977779lllllll5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllll3333ll444455llllllllllllll977779lllll9777794444lll5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5lllllllllllllllllllllllllll3rqqr3l477455llllllllllllll977779lllll9777794774lll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5lllllllllllllllllllllll3r77r3l477455l5l5llllllllll977779lllll9777794774l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllll3rq77qr3977945llllllllllllll997799lllll99779997794ll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllll3rq77qr3777745llllllllllllll997799lllll99779977774ll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5lllllllllllllllllllllllllll3r77r39777795lllllllllllllll9999lllllll9999977779ll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5lllllllllllllllllllllllllll3rqqr39777795llllllllllllllll99lllllllll99l977779ll5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllll3333l9777795llllllllllllllllllllllllllllll977779ll5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l5ll5l5lllllllllllllllllllllllllllllllll9977995llllllllllllllllllllllllllllll997799ll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5lllllllrrrllllllllllllllllllllllll977955lllllllllllllllllllllllllllllll9779lll5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llrqqqrlllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5555l5lllllrqa7aqrllllllllllllllllllllllllll55llllllllllllllllll44lllllll44lllllllll5l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllrqa777qrllllllllllllllllllllllllll55lllllllllllllllll4774lllll4774llllllll5l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllrq777aqrllllllllllllllllllllllllll55lllllllllllllllll4774lllll4774llllllll5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllrqa7aqrlllllllllllllllllllllllllll55lllllllllllllllll4774lllll4774llllllll5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5lllllrqqqrllllllllllllllllllllllllllll55lllllllllllllllll9779lllll9779llllllll5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllrrrlllllllllllllllllllllllllllll55lllllllllllllllll9779lllll9779llllllll5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllllll9779lllll9779llllllll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5lllllllllllll9779lllll9779llll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllllllllllllllll55ll4444lllllllllll9779lllll9779llllllll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55ll4774lllllllllll9779lllll9779lll4444l5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55ll4774lllllllllll9999lllll9999lll4774l5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllllllllllllllllllllllllllllllll55ll9779lllllllllll9999lllll9999lll4774l5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5666l666l666llllllllllllllllllllllllllllllll55l497794llllllllll9999lllll9999lll9779l5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l56l5l6l6l6l6llllllllllllllllllllllllllllllll55l477774llllllllll9999lllll9999ll4977945l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5666l6l6l6l6llllllllllllllllllllllllllllllll55l977779llllllllll9999lllll9999ll4777745l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5556l6l6l6l6llllllllllllllllllllllllllll5l5l55l977779lllllllllll99lllllll99lll9777795l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5666l666l666llllllllllllllllllllllllllllllll55l977779lllllllllllllllllllllllll9777795l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55ll9779llllllllllllllllllllllllll9777795l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllllllllllllllllllllll9779l5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllllll77lllll77llllllllllll5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55lllll77llllllll777777lii7777lllll77lll5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55llll7777llllll7777777iaai7777lll7777ll5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5llllllllllllllllllllllllllllllllllllll55llll7777llllll7777777299i7777lll7777ll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l777777llll7777777i999ai7777l777777l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllllllllllllllll55lll777777llll77777772944927777l777777l5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lll777777llll777777299229ai777l777777l5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lll777777lllll7777id947749277ll777777l5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllllllllllllllllllllllllllllllll55llll7ii7lllllll777i6447749dillll7ii7ll5l5ll5ll555lll5lld5l5ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lllli77illllllll7iaii9ii9462lllli77ill5l5ll5l5555ll5dlld5l5ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lllii66iillllllli297i9229iiaillii66iil5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllllllllllllllllllllllllllllll55llliaaaailllllll2a96754457792iliaaaail5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5li9999illllllia94i65555664aili9999il5l5555l55lllllllld555ll5d5l5li
i5d55ddddddddd5555l5llllllllllllllllllllllllllllllllllllll55llli4dd4illllllii42i4aiia6i49ili4dd4il5l5555ddddddddd55d555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llli4664illlllliii2ia99994i24ili4664il5l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llli9999illlllllllii5i44iai2iili9999il5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllllllllllllllllllllllllllllllllllll55llli4444illllllllllii5ii55iillli4444il5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55llliiddiilllllllllllllllllllllliiddiil5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55lllli55illlllllllllllllllllllllli55ill5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5llllllllllllllllllllllllllllllllllllll55llllliilllllllllllllllllllllllllliilll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555ldll5555iilld555liid5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555ldll555iaaild555iaai5llli
i5d5i222idddddl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555ldddddd29925d5l529925llli
i5dio777oilllll555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555llllllia44aid5lia44aillli
i5d2o7o7o2lllll555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555llllll297792d5l297792llli
i5d2o77oo2555l5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555l555ia4774ai5ia4774ailli
i5d2o7o7o2555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l555297227925297227925li
i5dio777oi55ll5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555ll55i465564i5i465564illi
i5dli222i5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l555525ii52d5525ii52llli
i5dll55ll5555l5ll5l5llllllllll55llllllllllllllllllllllllll55llllllllllllllllllllllllll55llllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllll55llllllllllllllllllllllllll55llllllllllllllllllllllllll55llllllllll5l5ll5ll555lll5lldl55ll5d5llli
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii

__gff__
0001010101000001000000000000000000010101010000010000010000000000000101010100010100000800000000000808090909080808000000000000010108080808080808080000000000000000080808080808080800000000000000000808080808080808000000000000000008080808080808080000000000000000
0808080808080808000000000000000008080808080808080000000000000000080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000001301011830311801010101010118303118010103000000000000000000000000000000000000000001010101011a28000000000000291a0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411809383838380a18404118010103000000000000000000000000000000000000000001010101011a28000000000000291a0101010101080808080d190701010101010107191d0808080800000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301191840411828273636272918404118190103000000000000000000000000000000000000000001010101021a28000000000000291a17010101010938380a1801010101010101010101180938380a00000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301191840411828000000002918404118190103000000000000000000000000000000000000000001010101191a28000000000000291a1901010101281c362918190101010101010101191828361c2900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301191840411828000000002918404118190103000000000000000000000000000000000000000001010101011a28000000000000291a0101010101280405291801010101010101010101182824252900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411828000000002918404118010103000000000000000000000000000000000000000001011b01011a28000000000000291a01011b0101281415291819010101010101010119182834352900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411828000000002918404118010103000000000000000000000000000000000000000001010101031a28000000000000291a1301010101280405291801010101010101010101182824252900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411802262626261718404118010803000000000000000000000000000000000000000001010101011a28000000000000291a0101010101281415291819010101010101010119182834352902000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011830311801010101010118303118010103002a2b00002a26262626262626262b00000000000101010101262800000000000029260101010101022626171801070101010101010701180226261700000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411801010101010118404118010103003739002a170101180101180101022b00000000010808080808072b000000002a07080808080801010101011819010101010101010119180101010100000000000000000000000000000000000000000000003e3f413e3f
000000000000000000000000000000000000000013010118404118190101010119184041180101033230313229382a2626262626262b38283232323238383838380a182800000000291809383838383838380a0102080d0101010101011d08170109383800000000000000000000000000000000000000003e3f414243403e3f
212121212100000000000000000000212121212113011918404118010101010101184041181901031317020938380a1901010101190938380a0102033b30313a2c291828000000002918282d3b3a3b3b363637383838180101010101011838383839363600000000000000000000000000000000000000003e3f414243403e3f
170333242520210000000000002122040533130113010218404118010101010101184041181701031301011830311807010101010718303118010103002a2b002f291b2800000000291b282e000000000405361c363618011b01011b011836361c36242500000000000000000000000000000000000000003e3f414243303e3f
010333343513012021212121220103141533130113010118404118010101010101184041180101031301011840411816080808081618404118010103003739002f373839000000003738392e0000000014152a26262601010101010101012626262b343500000000000000000000000000000000000000003e3f414243403e3f
010323242513010101010101010103040533130113010118404118010101010101184041180101031301011840411807010101010718404118010103003636003c3b3b3a000000003a3b3b3d000000002626170101011a0701010101071a01010102262600000000000000000000000000000000000000003e3f414243403e3f
01033334351301010101010101010314153313011301011840411801010101010118404118010103130101184041180101010101011840411801080300000000000000000000000000000000000000000101010101011a0708080808071a01010101010102000000000000000000000000000000000000003e3f414243403e3f
01033324251301010103130101010304052313011301010930310a0101010101010930310a010103010333242513180101031301011803040523130101033324251301010103130101010304052313010101010101011a0701010101071a01010101010100000000000000000000000000000000000000003e3f314243403e3f
0103333435130101010313010101031415331301130101262626260101010101012626262601010301033334351318010103130101180314153313010103333435130101010101010101031415331301010101010101010101010101010101010101010100000000000000000000000000000000000000003e3f414243403e3f
0103332425130101010313010101030405231301130101180217180101010101011802171801010301033324251318010103130101180304052313010103332425130707070707070707030405231301011901011901010808080808080101190101190100000000000000000000000000000000000000003e3f414243403e3f
010333343513010101031301010103141533130113010118010118011601010701180101180101030103333435131801010313010118031415331301010333343513010101010101010103141533130138383838383838380a010109383838383838383800000000000000000000000000000000000000000000000000000000
010323242513010101031301010103040533130113010118010118010101010101180101180101030103232425131801010313010118030405331301010323242513010c010101010c010304053313011c404136361c36363738383936361c363640411c00000000000000000000000000000000000000000000000000000000
010333343513010101031301010103141533130113010118010118010101010101180101180101030103333435131801010313010118031415331301010333343513010101010101010103141533130119404119011a0938273a3a27380a1a011940411900000000000000000000000000000000000000000000000000000000
010333242513010101031301010103040523130113010118170218010701011601181702180101030103332425130101010313010101030405231301010333242513070707070707070703040523130101303101011a282d3b3a3a3b2c291a010130310100000000000000000000000000000000000000000000000000000000
01033334351301010103130101010314153313011301010938380a0101010101010938380a0101030103333435130101010313010101031415331301010333343513010101010101010103141533130101262601011a283d000000003c291a010126260107000000000000000000000000000000000000000000000000000000
010323242513010101010101010103040533130138383838380a0101010101010101093838383838010333242513070808080808080703040523130101033324251301010103130101010304052313010938380a0126283232323232322926010938380a00000000000000000000000000000000000000000000000000000000
01033334351301010808080801010314153313013b30313a2c373838383838383838392d3b30313b0103333435131d1d1d1d1d1d11120314153313010103333435130101010313010101031415331301282727290118020101010101011718012827272900000000000000000000000000000000000000000000000000000000
0103332425130107101111120701030405231301004041002f363618030101131836362e0040410001033324251d1d1d00001d1d1d1d1104052313010103332425130707080808080707030405231301283031291918010801080108070118192830312900000000000000000000000000000000000000000000000000000000
0103333435130103000000001301031415331301002a2b002f250a18030101131809042e0040410001033334351d1d0000000000001d1d1415331301010333343513010110111112010103141533130128404129011b01010101010101011b012840412900000000000000000000000000000000000000000000000000000000
0103232425130103000000001301030405331301003739002f352918010101011828142e0030310001032324251d00000000000000001d04053313010103232425130603000000001306030405331301284041290118010708010801080118012840412900000000000000000000000000000000000000000000000000000000
0103333435130107202121220701031415331301003636003c2c37383838383838392d3d002a2b0001033334351d1d212121212121221d14153313010103333435130101202121220101031415331301284041291918093838383838380a18192840412900000000000000000000000000000000000000000000000000000000
010333242513010108080808010103040523130100000000002f36303136363031362e00003739000103332425131d1d01011d1d1d1d1d04052313010103332425130707080808080707030405231301284041290138282736363636272938012840412900000000000000000000000000000000000000000000000000000000
010333343513010101010101010103141533130100000000003c3a3b3b3b3b3b3b3a3d0000363600010333343513011d1d1d1d1d0101031415331301010333343513010101031301010103141533130102262617011a28000000000000291a010226261700000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a51018000404304014040350405504015040350962504015040350405504015040350404304014040350405504015040350262504015040350405504015060341000510005100051000512005100050000500000
9c1018000704307014070350705507015070350762507015070350705507015070350604306014060350605506015060350662506015060330605306015020341300510005100051000510005000000000000000
c01000181723513235102351723513235102351723513235102351723513235102351723513235102351723513235102351823513235102351823513235102350020000200002000020000200002000020000200
c11018001c23517235102351c23517235102351c23517235102351c23517235102351a235122350e2351a235122350e2351a235122350e2351a23512235132350020000200002000020000200002000020000200
01101800230351f0351c035230351f0351c035230351f0351c035230351f0351c035230351f0351c035230351f0351c035240351f0351c035240351f0351c0350c0000c0000c0000c0000c0000c0000c0000c000
0110180028035230351c03528035230351c03528035230351c03528035230351c035260351e0351a035260351e0351a035260351e0351a035260351e0351f0350c0000c0000c0000c0000c0000c0000c0000c000
c110180004235072350b235102350b2351023504235072350b235102350b2351023504235072350b2351023513235102351323517235182351723513235102350020500205002050020500205002050020500000
c1101800072350a2350e235132350e23513235072350a2350e235132350e2351323506235092350d235122350d2351223506235092350d235122350d235122350020500205002050020500205002050020500205
d51000000424004240042400424004240042400424004240032410324500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011018001003513035170351c035170351c0351003513035170351c035170351c0351003513035170351c0351f0351c0351f0352303524035230351f0351c0350c0050c0050c0050c0050c0050c0050c0050c000
0110180013035160351a0351f0351a0351f03513035160351a0351f0351a0351f0351203515035190351e035190351e0351203515035190351e035190351e0350c0050c0050c0050c0050c0050c0050c0050c005
011000000404304014040350405509625040350401504015040430401404043040550962504035040150401503043030140303503055086250303503015030150304303014030350305508625030350304303015
491000001c1351013517135101351c1351013517135101351c1351713513135171351c1351013517135101351b1350f135171350f1351b1350f135171350f1351b1351713512135171351b1350f135171350f135
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c0351303513035130351c0351303513035130351c0351303517035130351c0351303513035130351b0351203512035120351b0351203512035120351b0351203516035120351b035120351203512035
0110000017035100351003510035170351003518035100351703510035100351003517035100351803510035160350f0350f0350f035160350f035170350f03517035160350f0350f03516035120351703518035
951000000443504435044350443500435004350543505435044350443504435044350043500435054350543504435044350443504435004350043500435004350443504435044350443504435044350443504435
951000000343503435034350343500435004350443504435034350343503435034350043500435044350443503435034350343503435004350043500435004350343503435034350343503435034350343503435
011000000404304014040350405509625040350401504015040430401404043040550962504035040150401504043040140403504055096250403504015040150404304014040430405509625040350401504015
011000000304303014030350305508625030350301503015030430301403035030550862503035030430301503043030140303503055086250303503015030150304303014030350305508625030350304303015
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910c1800102350c23509235102350c23509235102350c23509235102350c23509235102350c23509235102350c23509235102350c23509235112350c235092351120000200002000020000200002000020000000
910c1800102350c23509235102350c23509235102350c23509235112350c23509235102350c23509235102350c23509235102350c23509235112350c235092351120000200002000020000200002000020000200
900c18000f2350b235082350f2350b235082350f2350b235082350f2350b235082350f2350b235082350f2350b235082350f2350b23508235102350b235082351020000200002000020000200002000020000200
910c18000f2350b235082350f2350b235082350f2350b23508235102350b235082350f2350b235082350f2350b235082350f2350b235082351023508200102000020000200002000020000200002000020000200
010c00000421504215042150421504215042150421504215042150421504215042150421504215042150421504215042150421504215042150421505215052150420004200042000420004200042000420004200
010c00000321503215032150321503215032150321503215032150321503215032150321503215032150321503215032150321503215032150321504215042150320003200032000320003200032000320003200
010c00000321503215032150321503215032150321503215032150321503215032150321503215032150321503215032150321503215032001a62503200032000320003200032000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b8040000240741c655220710e22110621160710861102611026110161101611016010161100611006110000102601000010000100001000010000100001000010000100001000010000100001000010000100001
580400000e0042a6251a0510e22110621084310863106611056110461101621046110461103611026010160100601006010060101601006010060100601006010060100001006010060100001000010000100001
580400000c6313e611106210841108611026110261101001000010200102001000010000100001026010000100001000010000100001000010000100001000010000100001000010000100001000010000000000
500400000c0541e6252e6010e22110621084110861105611046110361101611026110160100001016010000102601006010000100601000010060100601006010000100001000010000100001000010000100001
a00400000e715056100d7201d63000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
96040000124141e714067151f00000001106010d601006010a6010a6010a601006010960100601096010060109601006010960109601096010060100601006010060100601006010060100601006010060100601
d60100001d5201d5201d5240050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
910100002011500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
a1030000042240a020040030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
__music__
01 08424344
00 08424344
00 09424344
00 08424344
00 09424344
00 080a4344
00 090b4344
00 080c4344
00 090d4344
00 080e4344
00 090f4344
00 08114344
00 09124344
00 08104344
00 08104344
00 08104344
00 08104344
00 480e4344
01 080a4344
02 090b4644
00 13544747
00 13544747
00 13144747
00 13164344
00 13144747
00 13164747
00 13164747
00 13174747
00 13164747
00 13174747
00 13144747
00 13164344
00 1a184344
00 1b194344
00 13144747
00 08104344
00 08104344
00 08104344
00 08104344
00 1d504344
00 1e504344
00 1f504344
00 20504344
01 1d214344
00 1e214344
00 1f224344
02 20234344

