--lint: func::_init
function init_mapfuncs(_spawns,_crumbs,_shots)
	crumb_lib=parse_data(_crumbs)
	shot_lib=parse_data(_shots)
    enemy_spawns=parse_data(_spawns)

    map_timeline,pause_timeline,map_spawnstep,map_nextspawn,map_spawnpreps=0,false,1,enemy_spawns[1],{}
end

function upd_mapfuncs()
    if(not pause_timeline)map_timeline+=delta_time -- iterate level progress

    while map_nextspawn and map_timeline>tonum(map_nextspawn[1]) do
        prepare_spawn(map_nextspawn)
    end

	foreach(map_spawnpreps,check_spawn)
end

function prepare_spawn(_data)
    map_spawnstep+=1
	add(map_spawnpreps,{0,map_nextspawn})

	-- looped spawn
	if #_data>5 then
		local limit,rate,offset_x,offset_y=unpack(split(_data[6],":"))
		local ox,oy=offset_x or 0,offset_y or 0
		for i=1,limit do
			add(map_spawnpreps,{i*rate,map_nextspawn,ox*i,oy*i})
		end
	end

    map_nextspawn = map_spawnstep<=#enemy_spawns and enemy_spawns[map_spawnstep] or nil
end

function check_spawn(_spawn)
	if _spawn[1]<=0 then
		local frame,path,unit,sx,sy=unpack(_spawn[2])
		local offset_x,offset_y=_spawn[3] or 0,_spawn[4] or 0
		spawn_enem(path,unit,sx + offset_x,sy + offset_y) -- from base_shmup -- might move :/
		del(map_spawnpreps,_spawn)
	else
		_spawn[1]-=delta_time
	end
end