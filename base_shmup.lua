

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

	enems,puls,options,opuls,hitregs,pickups,turret_sprites,hitboxes={},{},{},{},{},{},split"37,38,39,40,41",parse_data"0,0,2,2|-3,-8,8,8|-9,-7,20,8|-3,-4,8,8|-4,-5,9,13|-5,-5,11,13|-13,-8,27,16|-15,-15,31,30|-9,-15,18,15|-32,-18,66,15"
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

--[[
function muzzle_flash()
	if pmuz>0 then
		pmuz-=0.5 -- "decount" muzzle flash animation
		for i=-5,5,10 do
			local x_position=player_x-i
			if(bnk_offset>0 and i<0)x_position-=3		-- change muzzle positions if the player is shooting
			if(bnk_offset<0 and i>0)x_position+=3		-- seperate check for each muzzle , bad but this is staying
			sspr_obj(split"13,14,15,16"[4-pmuz\1],x_position,player_y+2)
		end
	end
end
]]--

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
	if(player_immune>0)return false
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
    local ax,ay=a.x+ahb.ox,a.y+ahb.oy
    local bx,by=b.x+bhb.ox,b.y+bhb.oy

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
	unit.active,unit.brain,unit.anchor=_is_active,_brain or nil,_parent

	if(_turret)add_turret(unit,_turret)
	add(_parent.anchors,unit)

	return unit
end

-- enemy functions
--8151
function spawn_enem(_path, _type, _spawn_x, _spawn_y, _ox, _oy)
	
	local enemy=setmetatable({},{__index=_ENV})
	local _ENV=enemy
	s,health,hb,deathmode,sui_shot,value,elite,exp=unpack(enemy_data[_type])
	hb,elite,active,type,sx,sy,ox,oy,x,y,t,shot_index,perc,flash,path_index,pathx,pathy,anchors,patterns,turrets,lerpperc,intropause=gen_hitbox(hb),elite==1,true,_type,_spawn_x,_spawn_y,_ox or 0, _oy or 0,63,-18,0,1,0,0,_path,{},{},{},{},{},-1,0

	if(_path)depth,path=gen_path(crumb_lib[_path])
	if(_type==5)active=false spawn_anchor(_ENV,3,-3,-2)spawn_anchor(_ENV,4,3,-2)
	if(_type==7)spawn_anchor(_ENV,8,0,-1,false,4,1)

	return add(enems,_ENV)
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

	spawn_pickup(_enemy.x,_enemy.y,coin_amounts[_enemy.type],1.5)
	
	give_score(_enemy.value*(max_rank<0 and 1 or .8))

	local is_elite=_enemy.elite
	combo_num+=is_elite and 3 or 1
	
	-- give full combo if you're in regular stance
	-- and less if you're in the laser one
	add_ccounter(is_elite and 100 or 30,100)
	delete_enem(_enemy)
end

function upd_enem(_enemy)
	-- health stuff
	-- kill enemy on zero health
	-- todo completely move this to it's own "damage_enemies()" function
		
	if _enemy.health<=0 then

		local deathmode,ex,ey,parent=_enemy.deathmode,_enemy.x,_enemy.y,_enemy.anchor
		if deathmode==1 then
			del(parent.anchors,_enemy)
			if(#parent.anchors<=0)parent.active=true
		elseif deathmode==2 then
			new_bulcancel(30, 30)
			new_lerpbrain(parent,parent.x-sgn(_enemy.ox)*15,30+eqrnd"10", 2, "overshootout")
			del(parent.anchors,_enemy)
			del(enems,_enemy)

		elseif deathmode==3 or deathmode==4 then
			if(t%4==0)spawn_pickup(_enemy.x,_enemy.y,1,3.5) -- tokens

			if not _enemy.death_delay then

				new_bulcancel(30, 75, true) 

				_enemy.disabled,_enemy.death_delay=true,120
				save("combo_freeze,combo_counter,boss_active","160,100,false")

				give_score(10000,1)

				for anchor in all(_enemy.anchors) do 
					anchor.disabled,anchor.turrets=true,{}
				end

				if deathmode==4 then
					spawn_pickup(90,-20,1,0,2)
					add_expqueue(ex,ey,0,"0,-40,10|10,-25,4|20,-12,-5|30,12,13|40,25,0|50,30,-10|60,-40,10|70,-25,4|80,-12,-5|90,12,13|100,25,0|110,30,-10")
					poke(0x314d, peek(0x314d)&127)
				end

				if(deathmode==3)save("spiral_lerpperc,spiral_exit,spiral_pause","0,true,240")
			end
		elseif deathmode==5 then
			spawn_pickup(ex,ey,1,1,3) -- spawns an "add bomb" pickup
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
		
		return
	end

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