

function save(_a,_b)
    local a,b=split(_a),split(_b)
    for i=1,#a do 
		local dat=b[i]
        _𝘦𝘯𝘷[a[i]]=dat=="true" and true or dat
    end
end

function save2(str)
	for kv in all(split(str)) do
		local k,v=unpack(split(kv,"="))
		_ENV[k]=v
	end
end

-- makes a table from keys and vardics
function make(_keys, ...)
    local obj,vars = {},{...}
    for k,v in ipairs(split(_keys)) do 
        obj[v]=vars[k]
    end
	return setmetatable(obj,{__index=_ENV})
end

--merges two tables
function merge(t1,t2)
    for k,v in pairs(t2) do
        t1[k]=v
    end
    return t1
end

--lint: func::_init
function init_baseshmup(_enemy_data)									-- save spritesheet to upper mem
	save("t,player_lerpx_1,player_lerpy_1,player_lerpx_2,player_lerpy_2,player_lerp_perc,player_lerp_speed,player_lerp_delay,player_lerp_type,shot_pause,draw_particles_above","0,64,150,63,95,0,2,0,easeout,0,-1")
	save("score,lives,live_preview_offset,live_flash,pmuz,pause_combo,combo_num,combo_counter,combo_freeze,disable_timer,player_immune,player_flash,ps_held_prev,screen_flash,plast,op_perc","0,2,0,0,0,0,0,0,0,0,0,0,0,0.3,0,1")

	hitboxes = parse_data"0,0,2,2|-3,-7,8,16|-2,-16,8,12"	-- this is the table that includes the hitboxes for enemies

	enems,puls,one_shots={},{},{}
	enemy_data=parse_data(_enemy_data,"\n")
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
	if pul.alt==1 then
		local ox=pul.ox or pul.opt.x - player_x
		pul.x=player_x+ox
	else 
		pul.x+=sin(pul.dir)*psp * delta_time
	end
	pul.y+=cos(pul.dir)*psp * delta_time

	
	-- TOKENS
	local delete_item = false
	if abs(pul.y-64)>=80 or abs(pul.x-64)>=90 then
		delete_item=true
	end

	local hit=rnd(enem_col(pul))
	if hit then
		spawn_oneshot(8,3,pul.x+eqrnd"3",pul.y-rnd"3"-3) 	
			
		damage_enem(hit,1.8)
		add_ccounter(3)
		
		delete_item=true
	end

	-- delete the bullets
	if delete_item then
		del(puls,pul)
	end
end

-- any one shot animation
function spawn_oneshot(_index,_speed,_origin_x,_origin_y)
	local length=_index > 0 and #anim_library[_index] or 8

	add(one_shots,{index=_index,

		x=_origin_x,
		y=_origin_y,

		o=t%length,
				
		life=length*_speed,
		speed=_speed})
	-- NOTE "life" needs to be #frames*frame_rate
	-- here there are 4 frames , and it's at speed 2
end

function drw_oneshots(_oneshot)
	_oneshot.life-=delta_time

	if _oneshot.index == -1 then 
		circfill(_oneshot.x, _oneshot.y, min(_oneshot.life,3),_oneshot.life < 6 and 10 or 11)
	else
		sspr_anim(_oneshot.index,_oneshot.x,_oneshot.y,_oneshot.o,_oneshot.speed)
	end
	if(_oneshot.life<0)del(one_shots,_oneshot)
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

function player_carcol(item)
	return col(item,{x=player.x,y=player.y,hb=player.car_hb})
end

-- replaces every colour with a colour
-- used for sprite flash
function allpal(_col)
	for i=0,15 do
		pal(i, _col or i)
		palt(i,false)
	end
	cur_transparent = -1
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

--8151
function spawn_enem(_path, _type, _spawn_x, _spawn_y, _ox, _oy)
	local enemy=setmetatable({},{__index=_ENV})
	
	local _ENV=enemy
	s,health,hb,value=unpack(enemy_data[_type])
	hb,active,type,sx,sy,ox,oy,x,y,t,shot_index,perc,flash,path_index,pathx,pathy,patterns,lerpperc,intropause=gen_hitbox(hb),true,_type,_spawn_x,_spawn_y,_ox or 0, _oy or 0,63,-18,0,1,0,0,_path,{},{},{},-1,0

	origin_x = _spawn_x
	origin_y = _spawn_y
--	mx,my = 0,0

	delta_x,delta_y = 0,0

	prevx,prevy ={},{}



	if(_path)depth,path=gen_path(crumb_lib[_path])

	return add(enems,_ENV)
end

-- update each enemy
function upd_enem(_enemy)	
	_enemy.old_x = _enemy.x 
	_enemy.old_y = _enemy.y
	
	if _enemy.health<=0 then
		enem_sub_health(_enemy)
		return
	end

	_enemy.t+=delta_time

	if(_enemy.lerpperc>=0)upd_lerp(_enemy)
	if(_enemy.path)follow_path(_enemy)

	enem_check_col(_enemy)

	_enemy.sx += _enemy.delta_x
	_enemy.origin_x += _enemy.delta_x

	_enemy.sy += _enemy.delta_y
	--_enemy.origin_y += _enemy.delta_y

	_enemy.delta_x *= 0.9
	_enemy.delta_y *= 0.9
	

	_enemy.x,_enemy.y=_enemy.ox+_enemy.sx,_enemy.oy+_enemy.sy



	-- controls the hit-flash
	_enemy.flash-=1 
	
	if(_enemy.path and player_lerp_delay<=0)enem_path_shoot(_enemy)
end

function enem_check_col(enem)
	if(enem.pushed)return
	for car in all(enems) do
		if car~=enem and not car.pushed and col(enem,car) then 
			--local dir = sgn(player_x-enem.x)
			--lr,ud = dir,0 

			local dir = get_dir(enem.x,enem.y,car.x,car.y)
			local dx,dy = cos(dir),sin(dir)


			local dirx = car.hb.w * sgn(enem.x - car.x) * 0.5
			local dirx2 = enem.hb.w * sgn(car.x - enem.x) * 0.5
			enem.sx += dirx
			car.sx += dirx2

			local enem1dir = (enem.x - dirx)-enem.old_x
			local car1dir = (car.x - dirx2)-car.old_x

			local enem1diry = enem.y-enem.old_y
			local car1diry = car.y-car.old_y

			local max_vel = 3
			local friction = 0.3
			enem.delta_x,car.delta_x = mid(-max_vel,car1dir * friction,max_vel), mid(-max_vel,enem1dir * friction + dx,max_vel)
			enem.delta_y,car.delta_y = mid(-max_vel,car1diry * friction,max_vel), mid(-max_vel,enem1diry * friction,max_vel)


			enem.pushed = true 
			car.pushed = true


			for i=1,3 do
				local x,y = enem.x+(car.x-enem.x)*0.5 + eqrnd(2),enem.y + eqrnd(6)
				new_spark(x,y,eqrnd(1),3+rnd(5))
				--spawn_oneshot(-1,1,x,y)
			end
		end
	end
end

--direction for data
function get_dir(x1,y1,x2,y2)
	return atan2(x2-x1,y2-y1)
end

function get_edelta(e)
	return e.x-e.old_x
end

-- draw a single enemy
function drw_enem(e)
	local flash=e.flash>0 or e.anchor and e.anchor.flash>0
	if(flash and t%4<2)allpal(7)	

	local x1 = e.x
	local x2 = e.pathx[#e.pathx]

	local dir = flr(mid(-2,mid(-1,get_edelta(e),1)*2,2.98))
	

	--sspr_obj(e.s,e.sx+e.ox,e.sy+e.oy,e.t)
	allpal()
	pal(14, t%16<8 and 0 or 8)
	pal(15, t%16<4 and 0 or t%16>12 and 0 or 8)
	palt(12,true)
	pd_rotate(e.x+1,e.y+1,dir*.03,6,2.7,2.6,false,1)
	allpal()

	local dx,dy = e.pathdirx,e.pathdiry
	line(e.x,e.y,e.x + dx*10, e.y + dy*10, 11)

	for i=-1,1,2 do
		local x_position=e.x-i

		if t%2==0 then 

			if(dir>0 and i<0)x_position-=3
			if(dir<0 and i>0)x_position+=3

			new_dust(x_position+4,e.y+3)
			new_dust(x_position-3,e.y+3)
		end

		if rnd"1"<.1 then 
			new_dust(x_position,e.y,true)
		end
	end

	--print(dir,e.x,e.y,t)
	--print(e.x .."\n"..e.sx , e.x,e.y,11)



	if(e.flash>-1)allpal()e.flash-=1
end

function damage_enem(hit, damage_amount, ignore_invuln)
	hit.health-=damage_amount

	-- flash enemy
	hit.flash = hit.flash<-1 and 4 or hit.flash

	if hit.health<=0 and not hit.dead then 
		hit.dead=true
	end
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
	new_explosion(_enemy.x,_enemy.y,0)

	give_score(_enemy.value)
	delete_enem(_enemy)
end

-- tokens
-- why does this exist ?
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


function enem_path_shoot(_enemy)
	-- for shots todo move to its own function
	if _enemy.shot_index*4<=#shot_lib[_enemy.path_index] then
		if _enemy.t>=shot_lib[_enemy.path_index][_enemy.shot_index*4-3] then
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


	-- reached the end of its path
	if _enemy.perc>#path-2 then
		_enemy.ox += _enemy.pathdirx
		_enemy.oy += _enemy.pathdiry

		local lower_bound, upper_bound = -20,140

		if _enemy.y < lower_bound or _enemy.y > upper_bound or _enemy.x < lower_bound or _enemy.x > upper_bound then 
			delete_enem(_enemy)
		end
	else
		-- if there's a path to follow

		_enemy.perc+=rate * delta_time

		local oldx,oldy = _enemy.ox,_enemy.oy

		local step,tlerp=(_enemy.perc\1)%(#path-1)+1,_enemy.perc%1

		local x,y=lerp(path[step].x,path[step+1].x,tlerp),lerp(path[step].y,path[step+1].y,tlerp)

		add(_enemy.pathx,x)
		if(#_enemy.pathx>2)deli(_enemy.pathx,1)
		add(_enemy.pathy,y)
		if(#_enemy.pathy>2)deli(_enemy.pathy,1)

		_enemy.ox=avg(_enemy.pathx)
		_enemy.oy=avg(_enemy.pathy)


		local dx = _enemy.ox -oldx
		local dy =  _enemy.oy -oldy
		_enemy.pathdirx = dx 
		_enemy.pathdiry = dy
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



-- is_true means score added is the same number 
	-- i.e no multiplier

-- limit of 99 999 999 
	-- means 999,999,990 in "visual" score
function give_score(value, is_true)
	if(not is_true)value*=max(.25*combo_num^1.25,1)	-- use the multipler if is_true is false

 	if score <152.58788 then
		score+=value>>>16
		score_in_combo+=value>>>16
		if score>=152.58788 then
			score,score_in_combo=152.58788,152.58788
		end
	end
end


function new_bulcancel(_spawn_coins)
	player_immune=60	-- make the player immune for 60 frames

	for bul in all(buls) do
		spawn_oneshot(15,5,bul.x,bul.y)
		del(buls,bul)
	end

	shot_pause = 60 	-- pause shots for 60 frames
	spawners = {}		-- empty out the spawners list
end

-->8
-- combo meter

function add_ccounter(number_add, maximum_clamp)
	if(combo_counter>100 or player_lerp_delay>0)return
	local val=combo_counter+number_add
	combo_counter,combo_on_frame=combo_num<=0 and 0 or min(val,max(maximum_clamp or val, combo_counter)),2
end


-- drawing reorganisation
function draw_ui()
	camera()

	local ox,oy=3,3

	local score_str = score==0 and "0" or tostr(score,0x2).."0"
	--print(score_str, ox, oy, 11)

	-- lives UI
	ox+=128
	local num=lives+live_preview_offset
	for i=1,num do
		if live_flash>0 and i==num then 
			live_flash-=1
			if(live_flash==0)live_preview_offset=0
			if(global_flash)goto skip_lives
		end
		--sspr_obj(21,ox-9*i,122)
	end
	::skip_lives::


	local x=8
	local y1,y2 = 20,110

	line(x-1,y1,x+1,y1,8)
	line(x-1,y2,x+1,y2,8)
	line(x,y1,x,y2,8)

	palt(14,true)
	sspr(98,117,5,11,x-2,y1-12)
	sspr(104,120,7,8,x-3,y2+2)

	sspr(92,120,5,8,x-2,80 - t*0.02)

	allpal()
end
