

-- written by LokiStriker
-- this is nutty
function save(_a,_b)
    local a,b=split(_a),split(_b)
    for i=1,#a do 
		local dat=b[i]
        _𝘦𝘯𝘷[a[i]]=dat=="true" and true or dat
    end
end

--lint: func::_init
function init_baseshmup(_enemy_data)									-- save spritesheet to upper mem
	save("t,player_lerpx_1,player_lerpy_1,player_lerpx_2,player_lerpy_2,player_lerp_perc,player_lerp_speed,player_lerp_delay,player_lerp_type,shot_pause,draw_particles_above","0,64,150,63,95,0,2,0,easeout,0,-1")
	save("score,lives,live_preview_offset,live_flash,pmuz,pause_combo,combo_num,combo_counter,combo_freeze,disable_timer,player_immune,player_flash,ps_held_prev,screen_flash,bnk,bnkspd,plast,op_perc","0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0.3,0,1")

	hitboxes = parse_data"0,0,2,2|-3,-4,8,8|-2,-16,8,12"	-- this is the table that includes the hitboxes for enemies

	enems,puls,one_shots={},{},{}
	enemy_data=parse_data(_enemy_data,"\n")
end



function new_bul(_option, _x, _y,_type,_dir)
	return add(puls,{x=_x,
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
	local length=#anim_library[_index]

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
	sspr_anim(_oneshot.index,_oneshot.x,_oneshot.y,_oneshot.o,_oneshot.speed)
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
	if(player_immune>0 or item.inactive)return false
	return col(item,player)
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

--8151
function spawn_enem(_path, _type, _spawn_x, _spawn_y, _ox, _oy)
	local enemy=setmetatable({},{__index=_ENV})
	
	local _ENV=enemy
	s,health,hb,value=unpack(enemy_data[_type])
	hb,active,type,sx,sy,ox,oy,x,y,t,shot_index,perc,flash,path_index,pathx,pathy,patterns,lerpperc,intropause=gen_hitbox(hb),true,_type,_spawn_x,_spawn_y,_ox or 0, _oy or 0,63,-18,0,1,0,0,_path,{},{},{},-1,0

	if(_path)depth,path=gen_path(crumb_lib[_path])

	return add(enems,_ENV)
end

-- update each enemy
function upd_enem(_enemy)		
	if _enemy.health<=0 then
		enem_sub_health(_enemy)
		return
	end

	_enemy.t+=1

	if(_enemy.lerpperc>=0)upd_lerp(_enemy)
	if(_enemy.path)follow_path(_enemy)

	_enemy.x,_enemy.y=_enemy.ox+_enemy.sx,_enemy.oy+_enemy.sy

	-- controls the hit-flash
	_enemy.flash-=1 
	
	if(_enemy.path and player_lerp_delay<=0)enem_path_shoot(_enemy)
end

-- draw a single enemy
function drw_enem(e)
	if(e.disabled and global_flash)return
	local flash=e.flash>0 or e.anchor and e.anchor.flash>0
	if(flash and t%4<2)allpal(7)	

	sspr_obj(e.s,e.sx+e.ox,e.sy+e.oy,e.t)

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
	local ox,oy=3+cam_x,3

	local score_str = score==0 and "0" or tostr(score,0x2).."0"
	print(score_str, ox, oy, 7)

	-- lives UI
	ox+=128
	local num=lives+live_preview_offset
	for i=1,num do
		if live_flash>0 and i==num then 
			live_flash-=1
			if(live_flash==0)live_preview_offset=0
			if(global_flash)goto skip_lives
		end
		sspr_obj(21,ox-9*i,122)
	end
	::skip_lives::
end
