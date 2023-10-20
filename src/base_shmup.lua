

-- written by LokiStriker
-- this is nutty
function save(_a,_b)
    local a,b=split(_a),split(_b)
    for i=1,#a do 
		local dat=b[i]
        _𝘦𝘯𝘷[a[i]]=dat=="true" and true or dat=="false" and false or dat
    end
end

--lint: func::_init
function init_baseshmup(_enemy_data)
	-- player shot speed / shot rate / shot limit

	save("score,lives,live_preview_offset,live_flash,bombs,bomb_preview_offset,bomb_flash,pmuz,pause_combo,combo_num,combo_counter,combo_freeze,disable_timer,player_immune,player_flash,ps_held_prev,screen_flash,bnk,bnkspd,plast,op_perc","0,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0.3,0,1")

	enems,puls,options,opuls,hitregs,pickups,turret_sprites={},{},{},{},{},{},split"37,38,39,40,41"
	enemy_data=parse_data(_enemy_data,"\n")

	-- ?"\^!5f10249:5=67☉83⬅️⌂🐱ˇ>"
	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,14},1)
end




function player_bomb()
	if(bombs<=0 or bomb_flash>0)return
	
	bombs-=1
	save("bomb_flash,bomb_preview_offset,screen_flash,player_immune,player_flash,combo_freeze","30,1,3,150,90,30")

	new_bulcancel(5, 75)

	for enem in all(enems) do 
		damage_enem(enem, 30, true)
	end

	new_explosion(63,63,2,false,20)
	add_expqueue(63,63,0,"0,0,-40|4,40,0|8,0,40|12,-40,0")
end

function new_bul(_option, _x, _y,_type,_dir)
	return add(_option and opuls or puls,{x=_x,
	y=_y,
	aox=t,
	type=_type,
	hb=gen_hitbox(2),
	dir=_dir,
	opt=_option})
end


-- draws a single bullet
-- designed to be used with foreach
function drw_pul(bul)
	sspr_anim(bul.type,bul.x,bul.y,bul.aox,8)
end

-- updates a single bullet
-- designed to be used with foreach
-- defaults to vertically upwards
function upd_pul(pul)
	if pul.alt==1 and target_stance==1 then
		local ox=pul.ox or pul.opt.x - player_x
		pul.x=player_x+ox
	else 
		pul.x+=sin(pul.dir)*psp
	end
	pul.y+=cos(pul.dir)*psp

	
	-- TOKENS
	local delete_item
	if abs(pul.y-64)>=80 or abs(pul.x-64)>=90 then
		delete_item=true
	end

	local hit=rnd(enem_col(pul))
	if hit then
		spawn_oneshot(8,3,pul.x+eqrnd"3",pul.y-rnd"3"-3) 	
			
		damage_enem(hit,hit.elite and 1.3 or 1.8)
		add_ccounter(3)
		
		delete_item=true
	end

	-- extra steps for if there are options
	if delete_item then
		if(pul.opt)pul.opt.shot_count-=1
		del(puls,pul)
		del(opuls,pul)
	end
end

-- any one shot animation
function spawn_oneshot(_index,_speed,_origin_x,_origin_y)
	local length=#anim_library[_index]

	add(hitregs,{index=_index,

		x=_origin_x,
		y=_origin_y,

		o=t%length,
				
		life=length*_speed,
		speed=_speed})
	-- NOTE "life" needs to be #frames*frame_rate
	-- here there are 4 frames , and it's at speed 2
end

function drw_hitreg(_hitreg)
	_hitreg.life-=1
	sspr_anim(_hitreg.index,_hitreg.x,_hitreg.y,_hitreg.o,_hitreg.speed)
	if(_hitreg.life<0)del(hitregs,_hitreg)
end

-- checks item against every enemy
-- returns object if there is one
function enem_col(item)
	local hits={}

	for enemy in all(enems) do
		if(enemy.active==false)goto continue
		if(col(item,enemy))add(hits,enemy)
		::continue::
	end
	return hits
end

function check_bulcol(_bullet)
	if(player_col(_bullet))player_hurt(_bullet)
end

function player_col(item) -- tokens maybe ?
	if(player_immune>0 or item.inactive)return false
	return col(item,player)
end

-- draw a single enemy

function drw_enem(e)
	if(e.disabled and global_flash)return
	local flash=e.flash>0 or e.anchor and e.anchor.flash>0
	if(flash and t%4<2)allpal(9)
	


	local drw_data=pack(abs(e.s),e.sx+e.ox,e.sy+e.oy,15,6)
	if e.s>0 then
		sspr_obj(unpack(drw_data))
	else 
		sspr_anim(unpack(drw_data))
	end

	
	if(e.flash>-1)allpal()e.flash-=1
	if(e.anchor and e.anchor.flash>0)allpal()
end

-- replaces every colour with a colour
-- used for sprite flash
function allpal(_col)
	for i=0,15 do
		pal(i, _col or i)
	end
end


-- basic aabb collisions
function col(a,b)
    local ahb,bhb=a.hb,b.hb
    local ax,ay,bx,by=a.x+ahb.ox,a.y+ahb.oy,b.x+bhb.ox,b.y+bhb.oy

    return ay<=by+bhb.h-1
       and by<=ay+ahb.h-1
       and ax<=bx+bhb.w-1
       and bx<=ax+ahb.w-1
end

function gen_hitbox(_index, _separate_list)
	local hb,list={},_separate_list or hitboxes

	hb.ox,hb.oy,hb.w,hb.h=unpack(list[_index])
	return hb
end

-- returns a random float between -num and +num
function eqrnd(_number)
	return rnd(_number*2)-_number
end

-- required for basically everything
function parse_data(_data, _delimeter)
    local out,delimeter={},_delimeter or "|"
    for step in all(split(_data,delimeter)) do
        add(out,split(step))
    end
    return out
end

function lerp(a,b,t) 
	return a+(b-a)*t 
end

function avg(_tab)
	local total=0
	for item in all(_tab) do
		total+=item
	end
	return total/#_tab
end

-- ENEMY FUNCTIONS --
function spawn_anchor(_parent, _type, _origin_x, _origin_y, _is_active, _brain, _turret)
	local unit=spawn_enem(nil,_type,0,0,_origin_x,_origin_y)
	unit.active,unit.brain,unit.anchor=_is_active,_brain,_parent

	if(_turret)add_turret(unit,_turret)
	add(_parent.anchors,unit)

	return unit
end


-- generates a path for the enemy to follow
-- required reading for spawn_enem()
function gen_path(_path_index)
	local depth,path=tonum(_path_index[1]),{}

	for i=2,#_path_index,2 do
		add(path,{x=_path_index[i],y=_path_index[i+1]})
	end
	
	return depth,path
end


function kill_enem(_enemy)
	if(_enemy.exp>=0)new_explosion(_enemy.x,_enemy.y,_enemy.exp)

	spawn_pickup(_enemy.x,_enemy.y,_enemy.coin_value,1.5)
	
	give_score(_enemy.value*(max_rank<0 and 1 or .8))

	local is_elite=_enemy.elite
	combo_num+=is_elite and 3 or 1
	
	-- give full combo if you're in regular stance
	-- and less if you're in the laser one
	add_ccounter(is_elite and 100 or 30,100)
	delete_enem(_enemy)
end

function enem_sub_health(_enemy)
	local deathmode,ex,ey,parent=_enemy.deathmode,_enemy.x,_enemy.y,_enemy.anchor
	if deathmode==1 then
		-- deathmode data for a specific enemy
	end

	-- used to delay the sprite disappearing for bosses
	if _enemy.death_delay then 
		_enemy.death_delay-=1
		if _enemy.death_delay<0 then
			kill_enem(_enemy)
			boss_active,pause_timeline=false,false
		end
	else
		kill_enem(_enemy)
	end
	
end


-- start x/y 
-- target x/y
function new_lerpbrain(_enemy,_target_x,_target_y, _spd, _type)
	_enemy.originx,_enemy.originy,_enemy.tx,_enemy.ty,_enemy.lerpspeed,_enemy.lerpperc,_enemy.lerptype=_enemy.sx,_enemy.sy,_target_x,_target_y,_spd,0,_type or "easeOutIn"
end

function enem_path_shoot(_enemy)
	-- for shots todo move to its own function
	if _enemy.shot_index*4<=#shot_lib[_enemy.path_index] then
		if _enemy.t==shot_lib[_enemy.path_index][_enemy.shot_index*4-3] then
			local data=shot_lib[_enemy.path_index]
			local t=_enemy.shot_index*4-3

			if(max_rank<0 or rnd"1"<tonum(data[t+1]))add(_enemy.patterns, create_spawner(data[t+2],_enemy,data[t+3]))
			_enemy.shot_index+=1
		end
	end
end

-- foreach(enem,follow_path)
-- put in update , used for enemy "ai"
function follow_path(_enemy)
	local path,rate = _enemy.path,1/_enemy.depth
	_enemy.perc+=rate

	local step,tlerp=(_enemy.perc\1)%(#path-1)+1,_enemy.perc%1

	local x,y=lerp(path[step].x,path[step+1].x,tlerp),lerp(path[step].y,path[step+1].y,tlerp)

	add(_enemy.pathx,x)
	if(#_enemy.pathx>2)deli(_enemy.pathx,1)
	add(_enemy.pathy,y)
	if(#_enemy.pathy>2)deli(_enemy.pathy,1)

	_enemy.ox=avg(_enemy.pathx)
	_enemy.oy=avg(_enemy.pathy)

	-- reached the end of its path
	if _enemy.perc>#path-1 then
		delete_enem(_enemy)
	end
end


function delete_enem(_enem)
	for anchor in all(_enem.anchors) do anchor.dead=true del(enems,anchor) end -- remove all anchors if the object dies
	foreach(_enem.patterns,del_spawners)
	del(enems,_enem)
end

-- called like foreach(_enem.spawners,del_spawners)
function del_spawners(_item) 
	del(spawners,_item)
end

-- turrets

-- add information to turret
function add_turret(_enem, _data)
	local new_turret={_enem}
	for item in all(turret_data[_data]) do add(new_turret, item) end
	add(_enem.turrets, new_turret)
end

function upd_turret(_data)	
	local enem,index,rate,dir,ox,oy,rox=unpack(_data)
	
	if(boss_active)goto skip
	if(enem.y>64 or enem.y<5)return
	::skip::

	if (enem.t+rox)%rate==0 then 
		-- shot index , shot rate
		-- direction , offset x/y , rate offset
		local tdir = dir

		if(dir=="?")tdir=enem.dir
		if(dir=="-?")tdir=-enem.dir

		add(enem.patterns, create_spawner(index,enem,tdir,nil,ox,oy))
	end
end


------------------------------- pickups

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