function init_bulfuncs(_bul_library)
	bul_library,spawners,buls=parse_data(_bul_library),{},{}
end

function upd_bulfuncs()
	foreach(buls,upd_bul)

	if(shot_pause>0)spawners={}
	foreach(spawners,upd_spawner)
end

b_sprite_aspeed = 6
bul_hitboxes = parse_data("-2,-2,4,4|-1,-1,3,2|-1,-1,4,4|-1,-1,4,4|-1,-2,3,5|-2,-2,6,6|-1,-1,4,4|-1,-1,3,3|-1,-1,3,3")

function drw_buls()
	palt(15,true)

	for bul in all(buls) do
		sspr_anim(10, bul.x, bul.y, bul.spawn, b_sprite_aspeed)
	end

	palt(15,false)
end


-- bullet upd/draw
function upd_bul(bul)
    bul.life+=1

    -- move ya boy
    bul.wx+=cos(bul.dir)*0.5*bul.spd
    bul.wy+=sin(bul.dir)*0.5*bul.spd

    if bul.circ_data then   
        local cd=bul.circ_data
        bul.circ_data.pos+=cd.rate*0.001
        bul.circ_data.scale=min(cd.scale+cd.dscale*0.01,1)

        local scale=cd.radius*cd.scale
        bul.ox,bul.oy=sin(cd.pos)*scale,cos(cd.pos)*scale+sin(cd.pos)
    end

    bul.x,bul.y=bul.wx+bul.ox,bul.wy+bul.oy

    if(abs(bul.y-64)>=80 or abs(bul.x-64)>=90)del(buls,bul)

    -- TODO : check collisions
    -- if(col(player,bul))sfx(62)
end


-->8
-- tool
function spawn_bul(_origin_x, _origin_y, _type, _dir, _speed)
    -- creates bullet at location , of type , with direction / speed , and set animation speed
	local bul={

		x=_origin_x,
		wx=_origin_x,
		ox=0,
        
		y=_origin_y,
		wy=_origin_y, -- wy/oy is used for circles and such
		oy=0,

		hb=gen_hitbox(_type, bul_hitboxes),

		anim=_type, -- animation reference || CANNOT be used with single sprites as of now

		dir=_dir==-1 and get_player_dir(_origin_x,_origin_y) or _dir, -- if the bul is spawned and still has a direction of -1 , then it is set to the player direction
		spd=_speed,

		spawn=t, -- frame it was spawned on
		life=0,  -- frames that it has been spawned for  -- probably could be condensed , but I can't be bothered
	}
	add(buls,bul) -- add to list

 return bul
end

function create_spawner(_index, _origin, _dir, _parent, _origin_x, _origin_y)
	if(_index<0)_origin,_index={x=_origin.x,y=_origin.y},abs(_index)

	local origin_x,origin_y=_origin_x or 0, _origin_y or 0

	-- create a spawner object with default values
	-- send new spawner object to spawners "list"
	local new_spawner = {
		ox=origin_x,
		oy=origin_y,

		enemy=_origin,

		dir=_dir,
		spd=1,

		time=0,

		index=_index,
		parent_origin_time=_parent and _parent.parent_origin_time or t,
		instructions=bul_library[_index],
	}
	
	if(_dir==-1)new_spawner.dir=get_player_dir(_origin.x + origin_x,_origin.y + origin_y)

	-- if there is a parent , then copy over their settings
	if _parent then
		new_spawner.spd=_parent.spd
		new_spawner.dir=_parent.instructions[1]=="loop" and get_player_dir(_origin.x + origin_x,_origin.y + origin_y) or _parent.dir

		new_spawner.ox,new_spawner.oy=_parent.ox,_parent.oy

		if(_parent.circ_data)new_spawner.circ_data=_parent.circ_data		
	end

	add(spawners, new_spawner)
	return new_spawner
end


-- called every frame
function upd_spawner(s)
    -- if spawner type is sprite then spawn the bullet
    local inst=s.instructions
    local type,d2,d3,d4,d5,d6,d7=unpack(inst)

    s.time+=1
    local sdir,stime=s.dir,s.time

    if type=="sprite" then
		local bul = spawn_bul(s.enemy.x + s.ox, s.enemy.y + s.oy, d3, sdir, d2*s.spd)
		bul.life-=s.parent_origin_time-t
		if(s.circ_data)bul.circ_data = s.circ_data
		if(d5!=0)do_filter(bul,d5)
		del(spawners,s)
    elseif type=="burst" then
		if(sdir==-1)sdir=get_player_dir(s.enemy.x + s.ox,s.enemy.y, s.oy)
		for _=1,d3 do
			local shot = create_spawner(d2, s.enemy, sdir, s)
			shot.dir+=rnd(d4)-d4*0.5
			shot.spd+=rnd(d5)
		end
		del(spawners, s)
    elseif type=="circ" then
        for i=0,d3-1 do
            local shot = create_spawner(d2, s.enemy, sdir, s)
            local rpos=((1/d3)*i)-sdir
            if d6!=0 then
                shot.circ_data={pos=rpos, radius=d4, scale=0, dscale=d6, rate=d5}
            else
                shot.wx+=cos(rpos-0.25)*d4
                shot.wy+=sin(rpos-0.25)*d4
            end
        end
        del(spawners,s)
    elseif type=="array" or type=="loop" then 
        if d5==0 then
            for index=d3,d4 do
                local shot=create_spawner(d2, s.enemy, sdir, s)
                shot.dir+=index*d6
                shot.spd+=(index-d3)*d7
            end
            del(spawners,s)
        elseif stime%d5==0 then
            local index,shot=stime\d5-1,create_spawner(d2, s.enemy, sdir, s)
            shot.parent_origin_time,shot.dir=t,shot.dir + (index+d3)*d6
            shot.spd+=index*d7


            if(index>=d4-d3)del(spawners,s)
        end
    elseif type=="combo" then
        for i=1,3 do
            if(inst[1+i]!=0)create_spawner(inst[1+i], s.enemy, sdir, s)
        end
        del(spawners,s)
    end
end


-- tools
function get_player_dir(_origin_x,_origin_y)
	return atan2(player.x - _origin_x, player.y - _origin_y)
end