speeda,speedb=1.7,0.8
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
olm=4 -- options shot limit

hitregs={}

enems={} -- enemies


function init_baseshmup(_enemy_data)
	hitboxes=parse_data("0,0,2,2|-1,-8,4,8|-9,-7,20,15|-3,-4,8,8|-4,-5,9,13|-5,-5,11,13")

	enemy_data=parse_data(_enemy_data)

	enem_draw_above=false
	opt_draw_above=false
	
	player={x=63,y=63,hb=gen_hitbox(1)}
	init_options()

	disable_input=0		-- frames to take movement control from player
	player_immune=0		-- frames that the player is immune for

	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,0,0},1)
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

	local formation_a=split("-14,7|14,7","|")
	local formation_b=split("-11,-4|11,-4","|")

	local direction_a=split"0.48,0.52"
	local direction_b=split"0.5,0.5"

	local iter=#options

	for i=1,iter do
		local opt=options[i]
		local ox1,oy1=unpack(split(formation_a[i]))
		local ox2,oy2=unpack(split(formation_b[i]))-- rot_opt(opt,(1/iter)*i,17,6,0.01)
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
	player_x,player_y=player.x,player.y
	delx,dely=delx or player_x, dely or player_y

	-- define stance a or stance b
	target_stance=tonum(btn"4")
	local mspeed=target_stance==1 and speedb or speeda	
	
	-- movement input
	local lr=tonum(btn"1")-tonum(btn"0")
	local ud=tonum(btn"3")-tonum(btn"2")
	inbtn=btn()

	-- anti-cobblestone
	if inbtn&15!=last_btn then
		player_x,player_y=player_x\1,player_y\1
	end
	last_btn=inbtn&15

	if disable_input>0 or player_lerp_perc>=0 then
		disable_input-=1
		bnk=0
	else
		--normalized movement
		local nrm=lr!=0 and ud!=0 and 0.717 or 1
		player_x+=lr*nrm*mspeed
		player_y+=ud*nrm*mspeed
		player_x=mid(2,player_x,124)
		player_y=mid(2,player_y,124)

		-- add data back to table for niceties
		player.x,player.y=player_x,player_y

		-- banking
		bnk=mid(-2,mid(bnk-bnkspd,0.5,bnk+bnkspd)+lr*bnkspd*2.5,2.95)
	end

	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.2),lerp(dely,player_y,0.2) -- tokens
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
		spawn_hitreg(pul.x,pul.y) 
		
		
		if(hit.y>10 or hit.t>30)hit.health-=1 		-- hit them only if they've been alive for 1 second , OR if they're out the top of the screen
		
		hit.flash,delete_item=4,true -- spawn_hitreg is a weird one

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

-- little hit registration sprite thing
function spawn_hitreg(_x,_y)
	add(hitregs,{x=_x+eqrnd(3),y=_y+5+eqrnd(3),o=t%4+rnd(2)\1,life=12})

	-- NOTE "life" needs to be #frames*frame_rate
	-- here there are 4 frames , and it's at speed 2
end

function drw_hitreg(_hr)
	_hr.life-=1
	sspr_anim(8,_hr.x,_hr.y,_hr.o,3)
	if(_hr.life<0)del(hitregs,_hr)
end


-- checks item against every enemy
-- returns object if there is one
function enem_col(item)
	local hits={}

	for enemy in all(enems) do
		if(not enemy.active)goto continue
		local hit=col(item,enemy)
		if(hit)add(hits,enemy)
		::continue::
	end
	return #hits>0 and rnd(hits) or false
end


function check_bulcol(_bul)
	if(player_immune>0)return
	if(player_col(_bul))player_hurt(_bul)
end

function player_hurt(_source)

	-- move player to location
	player_lerp_perc=0
	delx,dely=player_lerpx_1,player_lerpy_1

	player_lerp_delay=30
	player.x,player.y=player_lerpx_1,player_lerpy_1

	-- make player immune to damage
	player_immune=180
	
	-- maybe clear screen of bullets ?
end

function player_col(item)
	return col(item,player)
end

-- draw a single enemy

function drw_enem(e)
	if(e.flash>0)allpal(7)
	local _x,_y=e.sx+e.ox,e.sy+e.oy
	sspr_obj(e.s,_x,_y)

	if(e.flash>0)allpal()e.flash-=1
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
function parse_data(_data)
    local out={}
    for step in all(split(_data,"|")) do
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
function spawn_anchor(_parent, _type, _ox, _oy)
	local unit=spawn_enem(nil,_type,_ox,_oy)

	unit.anchor=_parent
	add(_parent.anchors,unit)
end

-- enemy functions
function spawn_enem(_path, _type, _x, _y)
	local anim,health,hb,death_mode,suicide_shot=unpack(enemy_data[_type])

	local enemy={
		active=true, 			-- when disabled the enemy can't be shot
		deathmode=death_mode, 	-- controls effects on death
		sui_shot=suicide_shot,

		s=anim, -- sprite

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

		anchors={}
	}
	if(_path)enemy.depth,enemy.path=gen_path(crumb_lib[_path])
	if(_type==5)enemy.active=false spawn_anchor(enemy,3,-3,-2)spawn_anchor(enemy,4,3,-2)

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

function upd_anchor(_e)
	_e.ox=_e.anchor.sx+_e.anchor.ox
	_e.oy=_e.anchor.sy+_e.anchor.oy

	_e.x,_e.y=_e.ox+_e.sx,_e.oy+_e.sy
end

function upd_enem(_e)
	-- health stuff
	-- kill enemy on zero health
	-- todo completely move this to it's own "damage_enemies()" function
	if _e.health<=0 then
		local deathmode=_e.deathmode
		if deathmode==1 then
			local parent=_e.anchor
			del(parent.anchors,_e)
			if(#parent.anchors<=0)parent.depth+=10 parent.active=true
		end

		del(enems,_e)
		
		return
	end

	_e.t+=1

	if(_e.anchor)return
	for anchor in all(_e.anchors) do 	-- add all of these guys to a list , so that you can draw them last
		add(anchors,anchor)
	end

	if(_e.path)follow_path(_e)

	-- controls the hit-flash
	_e.flash-=1 
	
	if(_e.path)enem_path_shoot(_e)
end

function enem_path_shoot(_e)
	-- for shots todo move to its own function
	if _e.shot_index*4<=#shot_lib[_e.path_index] then
		if _e.t==shot_lib[_e.path_index][_e.shot_index*4-3] then
			local data=shot_lib[_e.path_index]
			local t=_e.shot_index*4-3

			create_spawner(data[t+2],_e,data[t+3])
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
	if(#_e.pathx>2)del(_e.pathx,_e.pathx[1])
	add(_e.pathy,y)
	if(#_e.pathy>2)del(_e.pathy,_e.pathy[1])

	_e.ox=avg(_e.pathx)
	_e.oy=avg(_e.pathy)
	
	_e.x=_e.sx+_e.ox
	_e.y=_e.sy+_e.oy

	if(_e.perc>#path-1)del(enems,_e)
end