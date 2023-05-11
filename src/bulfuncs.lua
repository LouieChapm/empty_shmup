pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--[[
    TOKENS
    968 tokens
]]--

function init_bulfuncs(_bul_library)
	bul_library=parse_data(_bul_library)
	spawners,buls={},{}

	bul_hitboxes=parse_data("-1,-1,4,4|-3,-3,6,6")
end

function upd_bulfuncs()
	foreach(buls,upd_bul)
	if(shot_pause>0)spawners={}
	foreach(spawners,upd_spawner)
end

function drw_bulfuncs()
	for bul in all(buls) do
		sspr_anim(bul.anim,bul.x,bul.y, bul.spawn, bul.anim_speed)
	end
end

-- filters
function iterate_filters(bul)
 	for filter in all(bul.filters) do
		local fstart,fend=filter.f_start,filter.f_end
		if bul.life>fstart then
			local ftype=filter.type
			if ftype=="fspeed" then
				bul.spd = bul.spd<0.1 and 0 or bul.spd*filter.rate
			elseif ftype=="ftarget" then
				bul.dir=filter.direction==-1 and get_player_dir(bul.x,bul.y) or filter.direction
				bul.spd=filter.speed
				if(bul.circ_data)bul.circ_data.rate=0
				del(bul.filters,filter)
			elseif ftype=="fspawn" then
				create_spawner(filter.spawn, {x=bul.x,y=bul.y}, bul.dir)
				del(bul.filters,filter)
				del(buls,bul)
			end
		end
		if(fend!=-1 and bul.life>fend)del(bul.filters,filter)
 	end
end

function do_filter(bul, ref)
	local type,d2,d3,d4,d5,d6,d7=unpack(bul_library[ref])
	
	local new_filter={
		f_start=d3,
		f_end=-1,
	}

	new_filter.type=type
	if type == "fspeed" then
		new_filter.rate=d5
		new_filter.f_end=d4
		if(d2!=0)do_filter(bul,d2)
	elseif type == "ftarget" then
		new_filter.direction=d4
		new_filter.speed=d5
		new_filter.f_start+=rnd(d6)
	elseif type == "fspawn" then
		new_filter.spawn=d4
	end

	add(bul.filters,new_filter)
end



-- bullet upd/draw
function upd_bul(bul)
    bul.life+=1

    -- move ya boy
    bul.wx+=cos(bul.dir)*0.5*bul.spd
    bul.wy+=sin(bul.dir)*0.5*bul.spd

    iterate_filters(bul)

    if bul.circ_data then   
        local cd=bul.circ_data
        bul.circ_data.pos+=cd.rate*0.001
        bul.circ_data.scale=min(cd.scale+cd.dscale*0.01,1)

        local scale=cd.radius*cd.scale
        bul.ox=sin(cd.pos)*scale
		bul.oy=cos(cd.pos)*scale+sin(cd.pos)
    end

    bul.x,bul.y=bul.wx+bul.ox,bul.wy+bul.oy

    if(abs(bul.y-64)>=80 or abs(bul.x-64)>=90)del(buls,bul)

    -- TODO : check collisions
    -- if(col(player,bul))sfx(62)
end


-->8
-- tool
function spawn_bul(_x,_y,_type,_dir,_speed,_ani_speed)
	local hb_index=1 -- give bullet default hurtbox

    -- creates bullet at location , of type , with direction / speed , and set animation speed
	local bul={

		x=_x,
		wx=_x,
		ox=0,
        
		y=_y,
		wy=_y, -- wy/oy is used for circles and such
		oy=0,

		hb=gen_hitbox(hb_index, bul_hitboxes),

		anim=_type, -- animation reference || CANNOT be used with single sprites as of now
		anim_speed=_ani_speed,

		dir=_dir==-1 and get_player_dir(_x,_y) or _dir, -- if the bul is spawned and still has a direction of -1 , then it is set to the player direction
		spd=_speed,

		spawn=t, -- frame it was spawned on
		life=0,  -- frames that it has been spawned for  -- probably could be condensed , but I can't be bothered
  
  		filters={},
	}
	add(buls,bul) -- add to list

 return bul
end

function create_spawner(_index, _origin, _dir, _parent, _ox, _oy)
	if(bul_library[_index]=="")debug="error: not not real" return

	if(_index<0)_origin={x=_origin.x,y=_origin.y}_index=abs(_index)

	local _ox,_oy=_ox or 0, _oy or 0

	-- create a spawner object with default values
	-- send new spawner object to spawners "list"
	local new_spawner = {
		ox=_ox,
		oy=_oy,

		enemy=_origin,

		dir=_dir,
		spd=1,

		time=0,

		index=_index,
		parent_origin_time=_parent and _parent.parent_origin_time or t,
		instructions=bul_library[_index],
	}
	
	if(new_spawner.instructions[1]!="loop" and _dir==-1)new_spawner.dir=get_player_dir(_origin.x + _ox,_origin.y + _oy)

	-- if there is a parent , then copy over their settings
	if _parent then
		new_spawner.spd=_parent.spd
		new_spawner.dir=_parent.dir

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
		local bul = spawn_bul(s.enemy.x + s.ox, s.enemy.y + s.oy, d3, sdir, d2*s.spd, d4)
		bul.life-=s.parent_origin_time-t
		if(s.circ_data)bul.circ_data = s.circ_data
		if(d5!=0)do_filter(bul,d5)
		del(spawners,s)

    elseif type=="loop" then
    if (stime)%d3==0 then
        create_spawner(d2, s.enemy, sdir, s)
        s.spd+=d5
    end
    if(stime\d3>=d4)del(spawners,s)

    elseif type=="burst" then
		if(sdir==-1)sdir=get_player_dir(s.enemy.x + s.ox,s.enemy.y, s.oy)
		for i=1,d3 do
			local shot = create_spawner(d2, s.enemy, sdir, s)
			shot.dir+=rnd(d4)-d4*0.5
			shot.spd+=rnd(d5)
		end
		del(spawners, s)
    elseif type=="circ" then
        for i=0,d3-1 do
            local shot = create_spawner(d2, s.enemy, sdir, s)
            local rpos=((1/d3)*i)-sdir-0.05
            if d6!=0 then
                shot.circ_data={pos=rpos, radius=d4, scale=0, dscale=d6, rate=d5}
            else
                shot.wx+=cos(rpos-0.25)*d4
                shot.wy+=sin(rpos-0.25)*d4
            end
        end
        del(spawners,s)
    elseif type=="array" then 
        if d5==0 then
            for index=d3,d4 do
                local shot=create_spawner(d2, s.enemy, sdir, s)
                shot.dir+=index*d6
                shot.spd+=(index-d3)*d7
            end
            del(spawners,s)
        elseif stime%d5==0 then
            local index=stime\d5-1
            local shot=create_spawner(d2, s.enemy, sdir, s)
            shot.parent_origin_time=t
            shot.dir+=(index+d3)*d6
            shot.spd+=index*d7

            if(index>=d4-d3)del(spawners,s)
        end
    elseif type=="combo" then
        for i=1,3 do
            if(inst[1+i]!=0)create_spawner(inst[1+i], s.enemy, sdir, s)
        end
        del(spawners,s)
    else
        debug="error invalid shot type"
        debug_time=90
    end
end



-- tools
function get_player_dir(_x,_y)
	return atan2(player.x - _x, player.y - _y)
end