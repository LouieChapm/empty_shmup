--lint: func::_init
function init_mapfuncs(_spawns,_crumbs,_shots)
	crumb_lib=parse_data(_crumbs)
	shot_lib=parse_data(_shots)
    enemy_spawns=parse_data(_spawns)

    map_timeline,pause_timeline,map_spawnstep,map_nextspawn,map_spawnpreps=0,false,1,enemy_spawns[1],{}

	
	-- ground objects
	grounds = {}
end

function upd_mapfuncs()
    if(not pause_timeline)map_timeline+=1 -- iterate level progress

    while map_nextspawn and map_timeline>tonum(map_nextspawn[1]) do
        prepare_spawn(map_nextspawn)
    end

	foreach(grounds,upd_ground)

	foreach(map_spawnpreps,check_spawn)
end


--[[
	prepare spawn edited from base

	edited to allow for "grounded spawns"
	basically disables player hitbox and moves them at a set rate , 
	optionally can spawn a background decal to move alongside
]]
function prepare_spawn(_data)
    map_spawnstep+=1

	-- local ground_data = #_data[7]>1 and new_ground(_data[7],_data[5]) or nil
	local ground_data,time_offset = nil, 0 
	if #_data[7]>1 then 
		local gdata = split(_data[7],":")
		time_offset = gdata[3] or 0
		ground_data = new_ground(gdata[1],gdata[2],_data[5])
	end
	add(map_spawnpreps,{0 + time_offset,map_nextspawn,nil,nil,ground_data})

	-- looped spawn
	if #tostr(_data[6])>1 then
		local limit,rate,offset_x,offset_y=unpack(split(_data[6],":"))
		local ox,oy=offset_x or 0,offset_y or 0
		for i=1,limit do
			add(map_spawnpreps,{i*rate + time_offset,map_nextspawn,ox*i,oy*i,ground_data})
		end
	end

    map_nextspawn = map_spawnstep<=#enemy_spawns and enemy_spawns[map_spawnstep] or nil
end


function check_spawn(_spawn)
	if _spawn[1]<=0 then
		local frame,path,unit, sx,sy=unpack(_spawn[2])
		local offset_x,offset_y,ground_data=_spawn[3] or 0,_spawn[4] or 0, _spawn[5]
		if(ground_data)sy = ground_data[3]
		spawn_enem(path,unit, sx + offset_x,sy + offset_y, nil,nil, ground_data)
		del(map_spawnpreps,_spawn)
	else
		_spawn[1]-=1
	end
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
	if(_type==5)add_turret(_ENV,1)

	return add(enems,_ENV)
end


-- just a simple map ground object that is a speed and type
function new_ground(_type, _speed, _yspawn)
	return add(grounds,{_type, _speed, _yspawn})	-- eventual goal
end

-- todo might be able to get rid of this
function upd_ground(_ground)
	_ground[3]+=_ground[2] == 0 and map_speed or _ground[2] -- if speed is 0 then match whatever the map speed is
end

-- map_x,map_y, map_w,map_h, map_x, offset_y
map_ground_data=parse_data"108,28,20,1,-16,0|108,30,20,2,-16,-5"
function drw_ground(_ground)
	local sx,sy,sw,sh,dx,oy = unpack(map_ground_data[_ground[1]])
	map(sx,sy,dx,flr(_ground[3] + oy),sw,sh)

	if(_ground[3] > 160)del(grounds,_ground)		-- delete the object if it goes off screen
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


-- draw a single enemy
function drw_enem(e)
	if(e.disabled and global_flash)return
	local flash=e.flash>0 or e.anchor and e.anchor.flash>0
	if(flash and t%4<2)allpal(9)
	

	local drw_data=pack(abs(e.s),e.sx+e.ox,e.sy+e.oy,e.t,15)
	if e.s>0 then
		sspr_obj(unpack(drw_data))
	else 
		sspr_anim(unpack(drw_data))
	end

	
	if(e.flash>-1)allpal()e.flash-=1
	if(e.anchor and e.anchor.flash>0)allpal()
end