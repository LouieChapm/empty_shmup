speeda=1.4
bnk,bnkspd=0,.25

-- player shot speed / shot rate / shot limit
psp,pr8,plm=5,3,15
pmuz=0 -- muzzle flash
psoff=split"-3,-12,-3,-15,4,-15,4,-12"

psdir=split"0.48,0.5,0.5,0.52"

puls={}
plast=0

hitregs={}


function init_baseshmup(_enemy_data)
	hitboxes=parse_data("0,0,2,2|-2,0,5,8|-9,-7,20,15|-3,-4,8,8")

	enemy_data=parse_data(_enemy_data)
	
	player={x=63,y=63,hb=gen_hitbox(1),}
end

enems={} -- enemies

function player_movement()
	player_x,player_y=player.x,player.y
	delx,dely=delx or player_x, dely or player_y

	-- movement input
	local lr=tonum(btn"1")-tonum(btn"0")
	local ud=tonum(btn"3")-tonum(btn"2")
	inbtn=btn()

	-- anti-cobblestone
	if inbtn&15!=last_btn then
		player_x,player_y=player_x\1,player_y\1
	end
	last_btn=inbtn&15

	--normalized movement
	local nrm=lr!=0 and ud!=0 and 0.717 or 1
	player_x+=lr*nrm*speeda
	player_y+=ud*nrm*speeda
	player_x=mid(2,player_x,124)
	player_y=mid(2,player_y,124)

	-- add data back to table for niceties
	player.x,player.y=player_x,player_y

	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.2),lerp(dely,player_y,0.2) -- tokens

	-- banking
	bnk=mid(-2,mid(bnk-bnkspd,0.5,bnk+bnkspd)+lr*bnkspd*2.5,2.95)
end

function player_shoot()
	if(plast>0 or #puls>plm)plast-=1 return -- don't shoot if the timer isn't zero or if above shot limit

	if(not btn"4" and not btn"5")return

	pmuz=4
	bnk_offset=tonum(bnk<-1)*-1+tonum(bnk>1)

	local index=1
	for i=1,#psoff,2 do
		local newpul={x=player_x+psoff[i]+bnk_offset,y=player_y+psoff[i+1],aox=t,type=2,hb=gen_hitbox(2),dir=psdir[index]+flr(bnk)*0.02}
		if i==1 then
			if(bnk_offset<0)newpul.x-=bnk_offset*4
		else
			if(bnk_offset>0)newpul.x-=bnk_offset*4
		end

		index+=1
		add(puls,newpul)
	end

	plast=pr8 -- set last shot to shot rate
	sfx(62)
end



function muzzle_flash()
	if pmuz>0 then
		pmuz-=0.5 -- "decount" muzzle flash animation
		for i=-4,4,8 do
			local _x=player_x-i
			if(bnk_offset>0 and i<0)_x-=3		-- change muzzle positions if the player is shooting
			if(bnk_offset<0 and i>0)_x+=3		-- seperate check for each muzzle , bad but this is staying
			sspr_obj(split"15,16,15,14,13"[4-pmuz\1],_x,player_y-5)
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
	local dx,dy=0,-1
	if(pul.dir)dx,dy=sin(pul.dir),cos(pul.dir)

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
		hit.health-=1 
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

	if delete_item then
		del(puls,pul)
	end
end

function spawn_hitreg(_x,_y)
	add(hitregs,{x=_x+eqrnd(3),y=_y+5+eqrnd(3),o=t%4+rnd(2)\1,life=12})

	-- NOTE "life" needs to be #frames*frame_rate
	-- here there are 4 frames , and it's at speed 2
end

function drw_hitreg(_hr)
	_hr.life-=1
	sspr_anim(7,_hr.x,_hr.y,_hr.o,3)
	if(_hr.life<0)del(hitregs,_hr)
end


-- checks item against every enemy
-- returns object if there is one
function enem_col(item)
	for enemy in all(enems) do
		if(not enemy.active)goto continue
		local hit=col(item,enemy)
		if(hit)return enemy

		::continue::
	end
	return false
end

-- draw a single enemy

rotor_pos=split"-13,-4,13,-4"
function drw_enem(e)
	if(e.below!=enem_draw_under)return

	if(e.flash>0)allpal(7)
	local _x,_y=e.sx+e.ox,e.sy+e.oy
	sspr_anim(e.s,_x,_y) -- eventually replace this with "ship data"
	if(e.flash>0)allpal()e.flash-=1

	--[[
	if e.s==4 then
		for i=1,#rotor_pos,2 do
			sspr_anim(8,_x+rotor_pos[i],_y+rotor_pos[i+1],0,2)
		end
	end
	]]--
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

function gen_hitbox(_index)
	local hb={}
	hb.ox,hb.oy,hb.w,hb.h=unpack(hitboxes[_index])
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

-- enemy functions
function spawn_enem(_path, _type, _x, _y)
	local anim,below,health,hb,death_mode,suicide_shot=unpack(enemy_data[_type])

	local enemy={
		active=true, 			-- when disabled the enemy can't be shot
		deathmode=death_mode, 	-- controls effects on death
		below=below==1,			-- whether the enemy is below the player
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
	}
	enemy.depth,enemy.path=gen_path(crumb_lib[_path])
	
	add(enems,enemy)
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


	-- controls the hit-flash
	_e.flash-=1 

	-- for shots todo move to its own function
	_e.t+=1
	if _e.shot_index*4<=#shot_lib[_e.path_index] then
		if _e.t==shot_lib[_e.path_index][_e.shot_index*4-3] then
			local data=shot_lib[_e.path_index]
			local t=_e.shot_index*4-3

			create_spawner(data[t+2],_e,data[t+3])
			_e.shot_index+=1
		end
	
		--
	end


	-- health stuff
	-- kill enemy on zero health
	-- todo completely move this to it's own "damage_enemies()" function
	if _e.health<=0 then
		local deathmode=_e.deathmode
		if deathmode==1 then
			_e.s=6
			_e.active=false
		else
			del(enems,_e)
		end
	end
end