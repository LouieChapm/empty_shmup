pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
fmenu_cart_address="shmup_menu.p8"

#include data/inf_crumbs.txt
#include data/inf_spawns.txt
#include data/inf_patterns.txt
#include data/inf_sprites.txt
#include data/inf_enems.txt

#include ../src/mapfuncs.lua
#include ../src/sprfuncs.lua
#include ../src/bulfuncs.lua
#include ../src/expfuncs.lua

#include ../src/base_shmup.lua
#include ../src/ships/type_a.lua

#include debugfuncs.lua


-- draw_hitboxes=false

--[[
	current dev high scores
	3,361,210
	4,362,050

	1,343,570
]]




function _init()
	stage = 3

	hitboxes = parse_data"0,0,2,2|-3,-4,8,8|-2,-16,8,12"

	cartdata"kalikan"
	dset(63,0)
	highscore=tostr(dget"0",0x2).."0"

	save("t,player_lerpx_1,player_lerpy_1,player_lerpx_2,player_lerpy_2,player_lerp_perc,player_lerp_speed,player_lerp_delay,player_lerp_type,combo_on_frame,map_progress,map_speed,score_in_combo,bullet_cancel_origin,bullet_cancel,shot_pause,max_rank,speed_target,final_boss_phase,draw_particles_above,spiral_lerpperc,spiral_pause,coin_chain_timer,coin_chain_amount","0,64,150,63,95,0,2,0,easeout,0,128,2,0,0,0,0,1100,2,1,-1,0,0,0,0")
	save("ground_open_perc",".5")

	init_baseshmup(enemy_data)

	init_player()

	init_sprfuncs(spr_library,anim_library)
	init_mapfuncs(enemy_spawns,crumb_lib,shot_lib)
	init_bulfuncs(bul_library)
	init_expfuncs()

	-- music(0,5000)

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
	cls(14)

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

	print(debug, 64, 64)
end

-->8
-- stage specific enemy functions

--8151
function spawn_enem(_path, _type, _spawn_x, _spawn_y, _ox, _oy, _ground_data)

	local enemy=setmetatable({},{__index=_ENV})
	local _ENV=enemy
	s,health,hb,deathmode,sui_shot,value,elite,exp,coin_value=unpack(enemy_data[_type])
	hb,elite,active,type,sx,sy,ox,oy,x,y,t,shot_index,perc,flash,path_index,pathx,pathy,anchors,patterns,turrets,lerpperc,intropause,ground_data=gen_hitbox(hb),elite==1,true,_type,_spawn_x,_spawn_y,_ox or 0, _oy or 0,63,-18,0,1,0,0,_path,{},{},{},{},{},-1,0,_ground_data

	inactive = ground_data and true or false

	if(_path)depth,path=gen_path(crumb_lib[_path])

	-- custom enemy spawn info vvvv
	-- if(_type==5)active=false spawn_anchor(_ENV,3,-3,-2)spawn_anchor(_ENV,4,3,-2)  -- _ENV is self not global

	return add(enems,_ENV)
end

-- update each enemy
function upd_enem(_enemy)		
	if _enemy.health<=0 then
		enem_sub_health(_enemy)
		return
	end

	-- move the enemy along the ground
	if(_enemy.ground_data)_enemy.sy = _enemy.ground_data[3]

	_enemy.t+=1

	if(_enemy.lerpperc>=0)upd_lerp(_enemy)
	if(_enemy.brain)upd_brain(_enemy,_enemy.brain)
	if _enemy.intropause<=0 then
		foreach(_enemy.turrets,upd_turret)
	else 
		_enemy.intropause-=1
	end
	if(_enemy.path)follow_path(_enemy)

	_enemy.x,_enemy.y=_enemy.ox+_enemy.sx,_enemy.oy+_enemy.sy

	for anchor in all(_enemy.anchors) do 	-- add all of these guys to a list , so that you can draw them last
		add(anchors,anchor)
		anchor.sx,anchor.sy=_enemy.x,_enemy.y
	end

	-- controls the hit-flash
	_enemy.flash-=1 
	
	if(_enemy.path and player_lerp_delay<=0)enem_path_shoot(_enemy)
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

function draw_ground()
	
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
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed06666744766660d888888888888888888888888
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed56669744796665d888888888888888888888888
00700700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed56689744798665d888888888888888888888888
00077000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed56889744798865d888888888888888888888888
00077000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed58889744798885d888888888888888888888888
00700700eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed08886744768880d888888866666666668888888
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed08866744766880d888888677777777776888888
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed08666744766680d8888867dddddddddd7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867dddddddddd7688888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888880677777777776088888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888880066666666660088888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888000000000000888888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888800000000008888888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888888888888888888888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888888888888888888888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888888888888888888888
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444bbb44444aa44444aaaa44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bcccb44aabbaa44abccba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bc373cbabbccbba4ab77ba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc3777cbac3333caabc77cba
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc7773cbac3333caabc77cba
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc373cb4abbccbba4ab77ba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bcccb444aabbaa44abccba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bbb444444aa44444aaaa44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444111444440044444000044
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441222144001100440122104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412373210112211040177104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123777210233332001277210
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee127773210233332001277210
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123732140112211040177104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412221444001100440122104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441114444440044444000044
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd000db
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed87778d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0878780
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0877880
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbddbbeeeeeee0878780
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbd99ddeeeeeeed87778d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdd899d6eeeeeeebd000db
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6089986eeeeebdddddddb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbdddbbd089985eeeeedd08880dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd800dbbd8778deeeeed0977790d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd94554bbd6776deeeeed8979798d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed845660bbd6556deeeeed8977998d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056678bbd5005db5555d8979798d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056789bbbd55db555b5d0977790d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd40897bbbbddbb55bb5dd08880dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056789b444444b5bbb5bdddddddb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056678444bb4445bbb5dd00d88dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed845660544444455bbb5d5668996d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd94554b555555b5bbb5d5068997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd800dbb6666bb5bbb5d5688997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbeeeeeeeeeeebbbdddbb666666b5bbb5d5068997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeeeeeeb54bb5555bb666bb6665bbb5d5668996d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeee55454b5555555566bbbb665bbb5dd00d88dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeeeb44b5b554bb45566bbbb665bbb5bdddddddb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7bbbbbbbbb7eeeeb44555554bb455666bb6665bbb5dd8d888dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbb66b55465555555555b666666b5bbb5d4089776d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb655555bb6bbb5555bbbb6666bb5bbb5d5089796d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb565bbbb6beebbbbb3bbb3bbbbe5bb55d5089779d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbbb45bb6565bbbbbb3bbb2bbbbe5b555d5089796d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbddbbbbddbbbbddbbb444b555554bbbbb3bbb2bbbbe55555d4089776d
88888888888888888888888888888888888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd77dbbd77dbbd77db44445555bb4bb3bb3bbbbbbbbe55554dd8d888dd
88888888888888888888888888888888888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd66dddd66dddd66dd444b455bb5bb33b312bbbbbbbe4444bbdddddddb
8888888888888888888888888888888888888888888888888888888888888888888888d3333dd2333dd3333db4bbb4bbb65b332112bbbbbb3bbbddddddbbbeee
8888888888888888888888888888888888888888888888888888888888888888888888d2222dd1222dd2222dbb5555bbbb2bb11112bbbbb2bbbd622225dbbeee
bbbbbddbbbbbbbbbbbbddbbbbbbbbbbbbbd888bbbbbbbbbbbbbbb11bbbbb11bbb11b88d215ddd1222dd1551db555555bb223b111122bbb2bbbd72332226dbddb
bbbbd33dbbbbbbbbbbd33dbbbbbbbbbbbd3888bbbbbbbbbbbbbb1771bbb1771b177188d266ddd1222dd1661d555bb555b21311111222bbbbbd7137332216d67d
bbbbd22dbbbbbbbbbbd220bbbbbbbbbbb02888bbbbbbbbbbbbbb1771bbb1771b177188d2222dd1222dd2222d55bbbb55221b11111122bbb3bd6133332216d67d
bbbd3222dbbbbbbbbd3222dbbbbbbbbbd32888bbbbbbbbbbbbbb1771bbb2772b177188d1111dd1111dd1111d55bbbb55211b21111122bb2bbd6123322215d67d
bbbd21120bbbbbbbb021120bbbbbbbbb021888bbbbbbbbbbbbbb2772bbb2772b277288dd55dddd55dddd55dd555bb555211bb1111112bbbbbd6412222145d67d
bbbd20021dbbbbbbd3200220bbbbbbbd320888bbbbbbbbbbbbb127721bb2772b277288bd44dbbd44dbbd44dbb555555b211bbb11111bbbbbbd6741111465d67d
bbd3177123bbbbbb02177125dbbbbbb0217888b1111bb1111bb127721b177771277288bbddbbbbddbbbbddbbbb5555bbb21bbbb111bbbbbbbd5674444654d67d
bbd21771d2dbbbbd52177116dbbbbbd5217888b1771bb1771b12777721177771277288bbbb3bbbbe8888888888888888bbb33333bbbbbbbbbbd56667754dbddb
bbd12ddd723dbbb0612dd2dd3dbbbb0612d888b1771bb1771b22777722277772277288bbbb1bbbbe8888888888888888bb3777773bbbbbbbbbbd555544dbbeee
bd3dd0076223dbd3dd2002d720dbbd3dd20888127721b2772b22277222277772277288bbbb1bbbbe8888888888888888b377bbb773bbbbbbbbbbddddddbbbeee
bd2741146123dd0277411476230bd02774188817777112772127277272277772222288bbb222bbbe8888888888888888377bbbbb773bbbbbbbbddddbbbddbbee
d3164444201ddd316644446d123d032664488827777217777127277272277772222288311222113e888888888888888837bbbbbbb73bbbbbbbd6777dbd67dbee
d21d3dd310ddbd21d63dd31d01dd321d63d88827777227777227777772227722222288bbb222bbbe333777733388888837bbbbbbb73b7777bd665567d6667dee
d10d12223ddbbd10d122223d0dddd10d12288827777227777222777722227722222288bbbb1bbbbe373377337388888837bbbbbbb73777777d656676d6576dee
dd0d301d4dbbbdd0d3d11d4ddbbbdd0d3d1888227722277772b277772bb2222b222288bbbb1bbbbe3773773773888888377bbbbb773773377d656676d6576dee
bbdd44d4dbbbbbbdd44dd4ddbbbbbbdd44d888b2772bb2772bbb2222bbbb22bbb22b88bbbb3bbbbe3333773333888888b377bbb773b773377d567766d5666d55
000000bbb000000bb000000b000000000000000bbb00000b00000000b000000bb000000bb000000bb22333322b888888bb3777773bb777777bd5556dbd56db55
0dddd0bb00dddd0000dddd000d00ddd00ddddd0bb00ddd0b0dddddd000dddd0000dddd0000dddd00bb123321bb888888bbb33333bbbb7777bbbddddbbbddbb55
00ddd0bb0d00ddd00d00ddd00d00ddd00ddd000b00dd000b0000ddd00ddd00d00d00ddd00ddd00d0bbb1221bbb888888bbb77777bbbbbb77777bbb4444444455
d1bbb1bb1111bbd11111bbd11b11bbb11bbb1ddb1ddb1ddbddd1bbb11dbb11d11d11bbd11dbb11d100b00b0000000000bb7777777bbbb7777777bb5555555555
d2bbb2bbdd22bbb2d222bbb22b22bbb22bbb222b2dbb222bdd22bbb22bbb22b22b22bbb22bbb2db211b11bd11ddd11ddb777777777bb777333777bbbbddbbb55
b2bbb2bbd22dbb22d2ddbb222bddbbb22bbbdd222bbbdd22bb2dbb2222bbdd2222ddbbb22bbbddb222b22bb22bbb22bb7777777777777733333777bbd33dbb55
b2bbb2bb22ddb22db222bbd22222bbb22222ddd22bbb22d2b22dbb2d2dbb22d2d222bbb22bbbd2b222b22bb22bbb22bb7777737777777333b33377bb0220bb55
b2bbb2bb2ddb22dd2222bbd2ddd2bbb22222bbd22bbb22d2b2dbb22d2dbb22d2ddd2bbb22bbb22b222222bb22bbb22bb777733377777733bbb3377bd3113db55
11bbb1111dbb11111d11bbb1ddd1bbb11d11bbb11bbb11b1b1dbb1db1bbb11b1b111bbb11bbb11b122d22bb22bbb22bb7777737777777333b33377b027720b55
0dbbbbd00bbbddd000ddbb00bbb0bbb000ddbb0000bbdd00b0bbb0db00bbdd00b0ddbb0000bbdd0011b11bb11bbb11bb7777777777777733333777d317713d55
0000000000000000d000000dbbb00000d000000dd000000db00000bbd000000db000000dd000000d00b00bb00bbb00bbb777777777bb777333777b0270072055
ddddddddddddddddddddddddbbbdddddddddddddddddddddbdddddbbddddddddbddddddddddddddd00b00b0000bb00bbbb7777777bbbb7777777bbd164461d54
ddddddddddddddddbddddddbbbbdddddbddddddbbddddddbbdddddbbbddddddbbddddddbbddddddbddbddbddddbbddbbbbb77777bbbbbb77777bbbb04dd40b4b
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
0001010101000001000000000100000001010101010000010000010000000000000101010100010100000800000000000808090909080808000000000000010108080808080808080000000000000000080808080808080800000000000000000808080808080808000000000000000008080808080808080000000000000000
0808080808080808000000000000000008080808080808080000000000000000080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d0b
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d0b
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d0b
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d0b
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c1f
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
00010000270501e050250502f05031050290501905018050350503805035050220501b05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

