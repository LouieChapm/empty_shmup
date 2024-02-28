function init_bulfuncs(_bul_library)
	bul_library,spawners,buls=parse_data(_bul_library),{},{}
end

function upd_bulfuncs()
	foreach(buls,upd_bul)

	if(shot_pause>0)spawners={}
	foreach(spawners,upd_spawner)
end


b_sprite_aspeed = 4

bul_hitboxes = parse_data"-1,-1,3,3"

function drw_buls()
	palt(15,true)

	col1,col2,col3 = 4,6,7

	for bul in all(buls) do
		circfill(bul.x,bul.y,bul.anim,bul.life%8<4 and col1 or col2)
	end

	for bul in all(buls) do
		circfill(bul.x+eqrnd(2),bul.y+eqrnd(2),bul.anim-1,bul.life%8<6 and col2 or col3)
	end

	for bul in all(buls) do 
		circfill(bul.x,bul.y,(bul.anim-3) + sin(bul.life*0.05)*1,11)
	end

	palt(15,false)
end

-- filters
function iterate_filters(_ENV)
 	for filter in all(filters) do
		local kill_filter,ftype,fstart,d3,d4,d5,d6=false,unpack(filter)

		if life>fstart then
			if ftype=="fspeed" then
				spd = spd<0.1 and 0 or spd*d4
				if(d3!=-1 and life>d3)kill_filter=true
			elseif ftype=="fspawn" then 
				if(life%d5~=0)return 

				if(y<128)create_spawner(d3,{x=x,y=y},dir)
				
				filter[4]-=1

				if(d4<=1)del(buls,_ENV)
			elseif ftype=="ftarget" then 
				if life>fstart+d3 then 
					local new_dir = d4 == -1 and get_player_dir(x,y) or d4==0 and dir or d4
					dir,kill_filter = new_dir + d5,true
					spd = d6
				end
			end

		end

		if(kill_filter)del(filters,filter)
 	end
end

-- tokens
function do_filter(bul, ref)
	local type,d2,d3,d4,d5,d6,d7=unpack(bul_library[ref])
	if(type=="ftarget")d4=rnd(d4)\1

	if(d2!=0)do_filter(bul,d2)

	add(bul.filters,{type,d3,d4,d5,d6,d7})
end

-- bullet upd/draw
function upd_bul(_ENV)
    life+=1

    -- move ya boy
    wx+=cos(dir)*spd
    wy+=sin(dir)*spd

    iterate_filters(_ENV)

    if circ_data then   
        circ_data.pos+=circ_data.rate*0.001
        circ_data.scale=min(circ_data.scale+circ_data.dscale*0.01,1)

        local scale,si=circ_data.radius*circ_data.scale,sin(circ_data.pos)
        ox,oy=si*scale,cos(circ_data.pos)*scale+si
    end

    x,y=wx+ox,wy+oy

    if(abs(y-64)>=80 or abs(x-64)>=90)del(buls,_ENV)
end


-->8
-- tool

function spawn_bul(_origin_x,_origin_y,_type,_dir,_speed,_ani_speed)
	return add(buls,make("x,wx,ox,y,wy,oy,hb,anim,anim_speed,dir,spd,spawn,life,filters",_origin_x,_origin_x,0,_origin_y,_origin_y,0,gen_hitbox(1,bul_hitboxes),_type,_ani_speed,_dir==-1 and get_player_dir(_origin_x,_origin_y) or _dir,_speed,t,0,{})) -- add to list
end

-- 114
function create_spawner(_index, _origin, _dir, _parent, _origin_x, _origin_y)
	if(_index<0)_origin,_index={x=_origin.x,y=_origin.y},abs(_index)

	local origin_x,origin_y=_origin_x or 0, _origin_y or 0

	return add(spawners, merge(make("ox,oy,enemy,dir,spd,duration,index,parent_origin_time,instructions",origin_x,origin_y,_origin,_dir==-1 and get_player_dir(_origin.x + origin_x,_origin.y + origin_y) or _dir,1,0,_index,_parent and _parent.parent_origin_time or t,bul_library[_index]),_parent and make("spd,dir,ox,oy,circ_data",_parent.spd,_parent.instructions[1]=="loop" and get_player_dir(_origin.x + origin_x,_origin.y + origin_y) or _parent.dir,_parent.ox,_parent.oy,_parent.circ_data)))
end

--8186
--8174

-- called every frame
function upd_spawner(s)
	local _ENV=setmetatable(s,{__index=_ENV})

    -- if spawner type is sprite then spawn the bullet
    local type,d2,d3,d4,d5,d6,d7=unpack(instructions)

    duration+=1
    local sdir,stime,delete_spawner=dir,duration,false

    if type=="sprite" then
		local bul = spawn_bul(enemy.x + ox, enemy.y + oy, d3, sdir, d2*spd, d4)
		bul.life-=parent_origin_time-t
		if(circ_data)bul.circ_data = circ_data
		if(d5!=0)do_filter(bul,d5)
		delete_spawner=true
    elseif type=="burst" then
		if(sdir==-1)sdir=get_player_dir(enemy.x + ox,enemy.y, oy)
		for _=1,d3 do
			local shot = create_spawner(d2, enemy, sdir, s)
			shot.dir+=rnd(d4)-d4*0.5
			shot.spd+=rnd(d5)
		end
		delete_spawner=true
    elseif type=="circ" then
        for i=0,d3-1 do
            local shot = create_spawner(d2, enemy, sdir, s)
            local rpos=((1/d3)*i)-sdir
            if d6!=0 then
                shot.circ_data={pos=rpos, radius=d4, scale=0, dscale=d6, rate=d5}
            else
                shot.wx+=cos(rpos-0.25)*d4
                shot.wy+=sin(rpos-0.25)*d4
            end
        end
        delete_spawner=true
    elseif type=="array" or type=="loop" then 
        if d5==0 then
            for index=d3,d4 do
                local shot=create_spawner(d2, enemy, sdir, s)
                shot.dir+=index*d6
                shot.spd+=(index-d3)*d7
            end
            delete_spawner=true
        elseif stime%d5==0 then
            local index,shot=stime\d5-1,create_spawner(d2, enemy, sdir, s)
            shot.parent_origin_time,shot.dir=t,shot.dir + (index+d3)*d6
            shot.spd+=index*d7


            if(index>=d4-d3)delete_spawner=true
        end
    elseif type=="combo" then
        for i=1,3 do
            if(instructions[1+i]!=0)create_spawner(instructions[1+i], enemy, sdir, s)
        end
        delete_spawner=true
    end

	if(delete_spawner)del(spawners,s)
end


-- tools
function get_player_dir(_origin_x,_origin_y)
	return atan2(player.x - _origin_x, player.y - _origin_y)
end