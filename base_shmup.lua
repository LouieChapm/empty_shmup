speeda,speedb=1.8,0.8
bnk,bnkspd=0,0.3

-- player shot speed / shot rate / shot limit
psp,pr8,plm=5,3,30
pmuz=0 -- muzzle flash
psoff=split"-4,-2,4,-2"

psdir=split".5,.5"
psdir2=split".49,.51"

puls={}
plast=0

options={} -- todo : rework
opuls={} -- option buls
olm=3 -- options shot limit

hitregs={}

enems={} -- enemies


function init_baseshmup(_enemy_data)
	hitboxes=parse_data("0,0,2,2|-3,-8,8,8|-9,-7,20,8|-3,-4,8,8|-4,-5,9,13|-5,-5,11,13|-13,-8,27,16|-15,-15,31,30|-9,-15,18,15")

	enemy_data=parse_data(_enemy_data,"\n")

	enem_draw_above=false
	opt_draw_above=false
	
	player={x=63,y=63,hb=gen_hitbox(1)}
	init_options()

	disable_input=0		-- frames to take movement control from player
	player_immune=0		-- frames that the player is immune for
	player_flash=0		-- frames for the player to flash

	combo_num,combo_counter=0,0

	pickups={}

	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,0},1)
end


function init_options()
	-- options
	for i=1,2 do
		add(options,{x=10,y=10,shot_count=0,muz=0})
	end
	op_perc=0 -- options percentage
end

function upd_options()
	-- options perc
	op_perc=lerp(op_perc,target_stance,0.1,0.005)

	local formation_a=parse_data("-14,7|14,7")
	local formation_b=parse_data("-11,-4|11,-4")

	local direction_a=split".475,.525"
	local direction_b=split".5,.5"

	local iter=#options

	for i=1,iter do
		local opt=options[i]
		local ox1,oy1=unpack(formation_a[i])
		local ox2,oy2=unpack(formation_b[i])-- rot_opt(opt,(1/iter)*i,17,6,0.01)
		local ox,oy=lerp(ox1,ox2,op_perc,0.01),lerp(oy1,oy2,op_perc,0.1)

		local dir=lerp(direction_a[i],direction_b[i],op_perc,0.01)

		opt.x,opt.y=ox+delx,oy+dely
		opt.dir=dir
	end
end


function rot_opt(_opt,_rad,_w,_h,_speed)
	local pos=(_rad+t*_speed)%1
	_opt.above=true
	if(pos>0.5)_opt.above=false
	return cos(pos)*_w,sin(pos)*_h
end


function drw_option(opt)
	--if(opt.above!=opt_draw_above)return
	if(opt.muz>0)sspr_obj(split"23,24"[2-opt.muz\1],opt.x,opt.y-5)opt.muz-=0.5
	sspr_anim(4,opt.x,opt.y)
end

function player_movement()
	inbtn=btn()&15
	if(player_lerp_perc>=0)lerp_player()		-- lerp player only when ya want <3

	player_x,player_y=player.x,player.y
	delx,dely=delx or player_x, dely or player_y

	-- define stance a or stance b
	target_stance=tonum(btn"4")
	local mspeed=target_stance==1 and speedb or speeda	
	
	-- movement input
	local lr=tonum(btn"1")-tonum(btn"0")
	local ud=tonum(btn"3")-tonum(btn"2")
	

	-- anti-cobblestone
	if inbtn!=last_btn then
		player_x,player_y=player_x\1,player_y\1
	end
	last_btn=inbtn

	if disable_input>0 or player_lerp_perc>=0 then
		disable_input-=1
		bnk=0
	else
		--normalized movement
		local nrm=lr!=0 and ud!=0 and 0.717 or 1
		player_x+=lr*nrm*mspeed
		player_y+=ud*nrm*mspeed
		player_x=mid(2-player_bounds,player_x,124+player_bounds)
		player_y=mid(2,player_y,124)

		-- add data back to table for niceties
		player.x,player.y=player_x,player_y

		-- banking
		bnk=mid(-2,mid(bnk-bnkspd,0.5,bnk+bnkspd)+lr*bnkspd*2.5,2.95)
	end

	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.2),lerp(dely,player_y,0.2) -- tokens

	for enem in all(enems) do
		if(player_col(enem))player_hurt()
	end
end

function player_shoot()
	if(plast>0 or #puls>plm)plast-=1 return -- don't shoot if the timer isn't zero or if above shot limit

	if(not btn"4" and not btn"5")return

	foreach(options,opt_shoot)

	pmuz=4
	bnk_offset=tonum(bnk<-1)*-1+tonum(bnk>1)

	for i=1,#psoff,2 do
		local index=ceil(i*.5)
		local dir = lerp(psdir2[index],psdir[index],op_perc,0.005)
		add(puls,{x=player_x+psoff[i]+bnk_offset,y=player_y+psoff[i+1],aox=t,type=2,hb=gen_hitbox(2),dir=dir})
	end

	plast=pr8 -- set last shot to shot rate
	sfx(62)
end

function opt_shoot(_opt)
	if(_opt.shot_count>olm)return

	local new_bul={x=_opt.x,y=_opt.y-5,aox=t,opt=_opt,type=5,dir=_opt.dir,hb=gen_hitbox(2)}
	add(opuls,new_bul)
	_opt.shot_count+=1
	_opt.muz=2
end



function muzzle_flash()
	if pmuz>0 then
		pmuz-=0.5 -- "decount" muzzle flash animation
		for i=-5,5,10 do
			local _x=player_x-i
			if(bnk_offset>0 and i<0)_x-=3		-- change muzzle positions if the player is shooting
			if(bnk_offset<0 and i>0)_x+=3		-- seperate check for each muzzle , bad but this is staying
			sspr_obj(split"13,14,15,16"[4-pmuz\1],_x,player_y+2)
		end
	end
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
	dx,dy=sin(pul.dir),cos(pul.dir)

	pul.x+=dx*psp
	pul.y+=dy*psp

	
	-- TOKENS
	local delete_item=false
	if abs(pul.y-64)>=80 or abs(pul.x-64)>=90 then
		delete_item=true
	end

	local hit=enem_col(pul)
	if hit then
		sfx(63) 
		spawn_oneshot(8,3,pul.x+eqrnd(3),pul.y-rnd(3)-3) 	
		
		add_ccounter(20,2)
		
		-- only put up the combo if you're dealing damage
		if hit.shot_index>1 or hit.t>60 then
			combo_num+=.1  
			-- intropause means you can chain the combo off the boss before it's taking damage
			if(hit.intropause<=0)hit.health-=1 		-- hit them only if they've been alive for 1 second , OR if they're out the top of the screen
		end
		
		hit.flash,delete_item=hit.flash<-1 and 4 or hit.flash,true

		if hit.health<=0 and hit.sui_shot>0 then
			local sui=hit.sui_shot
			create_spawner(sui\1,hit,sui%1==0 and -1 or sui%1)
			
			--[[
				putting decimals in the suicide shot thing can allow for prefined angles
				4 		= pattern 4 and targeted
				4.75 	= pattern 4 and shooting down
				2.999 	= pattern 2 and shooting as close to the right as is possible
			]]--
		end
	end

	-- extra steps for if there are options
	if delete_item then
		if(pul.opt)pul.opt.shot_count-=1
		del(puls,pul)
		del(opuls,pul)
	end
end

-- any one shot animation
function spawn_oneshot(_index,_speed,_x,_y)
	local length=#anim_library[_index]

	add(hitregs,{index=_index,

		x=_x,
		y=_y,

		o=t%length,
				
		life=length*_speed,
		speed=_speed})
	-- NOTE "life" needs to be #frames*frame_rate
	-- here there are 4 frames , and it's at speed 2
end

function drw_hitreg(_hr)
	_hr.life-=1
	sspr_anim(_hr.index,_hr.x,_hr.y,_hr.o,_hr.speed)
	if(_hr.life<0)del(hitregs,_hr)
end


-- checks item against every enemy
-- returns object if there is one
function enem_col(item)
	local hits={}

	for enemy in all(enems) do
		if(not enemy.active)goto continue
		if(col(item,enemy))add(hits,enemy)
		::continue::
	end
	return #hits>0 and rnd(hits)
end


function check_bulcol(_bul)
	if(player_col(_bul))player_hurt(_bul)
end

function player_hurt(_source)
	-- move player to location
	player_lerp_perc,player_lerpx_1,player_lerpx_2,delx,dely=0,player_x,player_x+sgn(64-player_x)*min(abs(64-player_x),15),player_lerpx_1,player_lerpy_1 -- tokens

	player_lerp_delay,player_immune,player_flash=30,180,180
	player.x,player.y=player_lerpx_1,player_lerpy_1

	combo_num,combo_counter=0,0

	new_bulcancel(30, 75)
	
	-- make the pickups no longer seek 
	for pickup in all(pickups) do pickup.seek=false end
end

function player_col(item) -- tokens maybe ?
	if(player_immune>0)return false
	return col(item,player)
end

-- draw a single enemy

function drw_enem(e)
	if(e.dead)return

	if(e.flash>0 or e.anchor and e.anchor.flash>0)allpal(t%2<1 and 9 or 7) -- tokens
	
	local _x,_y=e.sx+e.ox,e.sy+e.oy
	sspr_obj(e.s,_x,_y)

	if(e.flash>-1)allpal()e.flash-=1
	if(e.anchor and e.anchor.flash>0)allpal()
end

-- replaces every colour with a colour
-- used for sprite flash
function allpal(_c)
	for i=0,15 do
		pal(i, _c or i)
	end
end


-- basic aabb collisions
function col(a,b)
	local ahb,bhb=a.hb,b.hb
	
	local ax=a.x+ahb.ox
	local ay=a.y+ahb.oy
	local axw,ayh=ax+ahb.w-1,ay+ahb.h-1

	local bx=b.x+bhb.ox
	local by=b.y+bhb.oy
	local bxw,byh=bx+bhb.w-1,by+bhb.h-1

	if(ay > byh)return false
	if(by > ayh)return false
	
	if(ax > bxw)return false
	if(bx > axw)return false

	return true
end

function gen_hitbox(_index, _separate_list)
	local hb,list={},_separate_list or hitboxes

	hb.ox,hb.oy,hb.w,hb.h=unpack(list[_index])
	return hb
end

-- returns a random float between -num and +num
function eqrnd(_num)
	return rnd(_num*2)-_num
end

-- required for basically everything
function parse_data(_data, _delimeter)
    local out,delimeter={},_delimeter or "|"
    for step in all(split(_data,delimeter)) do
        add(out,split(step))
    end
    return out
end

function lerp(a,b,t,_thresh)
	local threshold,out = _thresh or 0.5,(1-t)*a + t*b
	return abs(out-b) < threshold and b or out
end

function avg(_tab)
	local total=0
	for item in all(_tab) do
		total+=item
	end
	return total/#_tab
end

-- ENEMY FUNCTIONS --
function spawn_anchor(_parent, _type, _ox, _oy, _is_active, _brain, _turret)
	local unit=spawn_enem(nil,_type,_ox,_oy)
	unit.active=_is_active or true
	unit.brain=_brain or nil

	if(_turret)add_turret(unit,_turret)

	unit.anchor=_parent
	add(_parent.anchors,unit)

	return unit
end

-- enemy functions
function spawn_enem(_path, _type, _x, _y)
	local anim,health,hb,death_mode,suicide_shot,value=unpack(enemy_data[_type])

	local enemy={
		active=true, 			-- when disabled the enemy can't be shot
		deathmode=death_mode, 	-- controls effects on death
		sui_shot=suicide_shot,
		value=value,

		s=anim, -- sprite
		type=_type,

		sx=_x,	-- spawn x/y
		sy=_y,

		ox=0,	-- offset x/y
		oy=0, 
		
		x=63,
		y=-18,
		
		t=0,
		shot_index=1,

		perc=0,

		hb=gen_hitbox(hb),

		health=health,
		flash=0,

		path_index=_path, -- path index

		-- used for path following stuff
		-- stops jitter by averaging previous locations
		-- works a little :/
		pathx={},
		pathy={},

		anchors={},

		patterns={},		-- all of the enemy spawner things
		turrets={},

		lerpperc=-1,
		intropause=0,
	}
	if(_path)enemy.depth,enemy.path=gen_path(crumb_lib[_path])
	if(_type==5)enemy.active=false spawn_anchor(enemy,3,-3,-2)spawn_anchor(enemy,4,3,-2)
	if(_type==7)spawn_anchor(enemy,8,0,-1,true,1,1)

	add(enems,enemy)
	return enemy
end

-- generates a path for the enemy to follow
-- required reading for spawn_enem()
function gen_path(_p)
	local depth=tonum(_p[1])

	local path={}
	for i=2,#_p,2 do
		add(path,{x=_p[i],y=_p[i+1]})
	end
	
	return depth,path
end

turret_sprites=split"37,38,39,40,41"
function upd_anchor(_e)
	_e.ox=_e.anchor.sx+_e.anchor.ox
	_e.oy=_e.anchor.sy+_e.anchor.oy

	if _e.type==8 then
		local dir=(get_player_dir(_e.x,_e.y)+.03125)\.0625 -- calculate direction in seg16
		_e.dir=mid(.625, dir*.0625,.875)

		local visible=(_e.dir\.0625)-9
		if(visible<0)visible=abs(visible+2)
		if(_e.y<player_y)_e.s=turret_sprites[mid(1,visible,5)]
	end
end

function upd_enem(_e)
	-- health stuff
	-- kill enemy on zero health
	-- todo completely move this to it's own "damage_enemies()" function
	if _e.health<=0 then
		local deathmode=_e.deathmode
		local parent=_e.anchor
		if deathmode==1 then
			del(parent.anchors,_e)
			if(#parent.anchors<=0)parent.active=true
		elseif deathmode==2 then
			parent.health-=50

			new_bulcancel(30, 30, true)

			new_lerpbrain(parent,parent.x-sgn(_e.sx)*15,30, 2, "overshootout")

			if #parent.anchors>1 then
				boss_incriment_stage(boss,2)
			else
				boss_incriment_stage(boss,3)
			end

			del(parent.anchors,_e)

		elseif deathmode==3 then
			new_bulcancel(30, 30, true)
		end

		spawn_pickup(_e.x,_e.y,coin_amounts[_e.type],1.5)

		give_score(_e.value)

		combo_num+=3
		combo_counter=120

		delete_enem(_e)
		return
	end

	_e.t+=1

	if(_e.lerpperc>=0)upd_lerp(_e)
	if(_e.brain)upd_brain(_e,_e.brain)
	if _e.intropause<=0 then
		foreach(_e.turrets,upd_turret)
	else 
		_e.intropause-=1
	end
	if(_e.path)follow_path(_e)

	_e.x,_e.y=_e.ox+_e.sx,_e.oy+_e.sy

	for anchor in all(_e.anchors) do 	-- add all of these guys to a list , so that you can draw them last
		add(anchors,anchor)
	end

	-- controls the hit-flash
	_e.flash-=1 
	
	if(_e.path and player_lerp_delay<=0)enem_path_shoot(_e)
end



-- start x/y 
-- target x/y
function new_lerpbrain(_e,_tx,_ty, _spd, _type)
	_e.originx,_e.originy,_e.tx,_e.ty,_e.lerpspeed,_e.lerpperc=_e.sx,_e.sy,_tx,_ty,_spd,0
	_e.lerptype=_type or "easeOutIn"
end

function enem_path_shoot(_e)
	-- for shots todo move to its own function
	if _e.shot_index*4<=#shot_lib[_e.path_index] then
		if _e.t==shot_lib[_e.path_index][_e.shot_index*4-3] then
			local data=shot_lib[_e.path_index]
			local t=_e.shot_index*4-3

			add(_e.patterns, create_spawner(data[t+2],_e,data[t+3]))
			_e.shot_index+=1
		end
	end
end

-- foreach(enem,follow_path)
-- put in update , used for enemy "ai"
function follow_path(_e)
	local path = _e.path
	local rate = 1/_e.depth
	_e.perc+=rate

	local step,tlerp=(_e.perc\1)%(#path-1)+1,_e.perc%1

	local x=lerp(path[step].x,path[step+1].x,tlerp)
	local y=lerp(path[step].y,path[step+1].y,tlerp)

	add(_e.pathx,x)
	if(#_e.pathx>2)deli(_e.pathx,1)
	add(_e.pathy,y)
	if(#_e.pathy>2)deli(_e.pathy,1)

	_e.ox=avg(_e.pathx)
	_e.oy=avg(_e.pathy)

	-- reached the end of its path
	if _e.perc>#path-1 then
		delete_enem(_e)
	end
end


function delete_enem(_e)
	for anchor in all(_e.anchors) do anchor.dead=true del(enems,anchor) end -- remove all anchors if the object dies
	for spawn in all(_e.patterns) do del(spawners,spawn) end -- delete spawners if the baddie dies
	del(enems,_e)
end



-- turrets

-- add information to turret
function add_turret(_e, _data)
	local new_turret={_e}
	for item in all(turret_data[_data]) do add(new_turret, item) end
	add(_e.turrets, new_turret)
end

function upd_turret(_data)
	-- shot index , shot rate
	-- direction , offset x/y , rate offset
	local enem,index,rate,dir,ox,oy,rox=unpack(_data)
	local tdir = dir
	if(dir=="?")tdir=enem.dir
	if(dir=="-?")tdir=-enem.dir
	if((enem.t+rox)%rate==0)add(enem.patterns, create_spawner(index,enem,tdir,nil,ox,oy))
end