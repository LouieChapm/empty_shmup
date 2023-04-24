speeda,speedb=1.7,0.8
bnk,bnkspd=0,0.3

-- player shot speed / shot rate / shot limit
psp,pr8,plm=5,3,30
pmuz=0 -- muzzle flash
psoff=split"-4,-2,4,-2"

puls={}
plast=0


function init_baseshmup()
	debug=""
	t=0

	hitboxes=parse_data("0,0,2,2|-3,-8,8,8|-7,-7,15,15")
end

enems={} -- enemies

function player_movement()
	player_x,player_y=player.x,player.y
	delx,dely=delx or player_x, dely or player_y

	-- movement input
	local lr=tonum(btn"1")-tonum(btn"0")
	local ud=tonum(btn"3")-tonum(btn"2")
	inbtn=btn()

	-- define stance a or stance b
	target_stance=tonum(btn"4")
	local mspeed=target_stance==1 and speedb or speeda	

	-- anti-cobblestone
	if inbtn&15!=last_btn then
		player_x,player_y=player_x\1,player_y\1
	end
	last_btn=inbtn&15

	--normalized movement
	local nrm=lr!=0 and ud!=0 and 0.717 or 1
	player_x+=lr*nrm*mspeed
	player_y+=ud*nrm*mspeed
	player_x=mid(2,player_x,124)
	player_y=mid(2,player_y,124)

	-- add data back to table for niceties
	player.x,player.y=player_x,player_y

	-- delayed x/y
	delx,dely=lerp(delx,player_x,0.2),lerp(dely,player_y,0.2)

	-- banking
	bnk=mid(-2,mid(bnk-bnkspd,0.5,bnk+bnkspd)+lr*bnkspd*2.5,2.95)
end

function player_shoot()
	if(plast>0 or #puls>plm)plast-=1 return -- don't shoot if the timer isn't zero or if above shot limit

	if(not btn"4" and not btn"5")return

	pmuz=4
	for i=1,#psoff,2 do
		add(puls,{x=player_x+psoff[i],y=player_y+psoff[i+1],aox=t,type=8,hb=gen_hitbox(2)})
	end

	plast=pr8 -- set last shot to shot rate
end

function muzzle_flash()
	if pmuz>0 then
		pmuz-=1
		for i=-4,4,8 do
			sspr_obj(split"22,23,24,25"[4-pmuz\1],player_x-i,player_y)
		end
	end
end

-- draws a single bullet
-- designed to be used with foreach
function drw_puls(bul)
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

	if(enem_col(pul))delete_item=true

	if delete_item then
		if(pul.opt)pul.opt.shot_count-=1
		del(puls,pul)
		del(opuls,pul)
	end
end


-- checks item against every enemy
-- returns object if there is one
function enem_col(item)
	for enemy in all(enems) do
		local hit=col(item,enemy)
		if(hit)enemy.health-=1 enemy.flash=2 return enemy
	end
	return false
end


-- basic aabb collisions
function col(a,b)
	local ahb,bhb=a.hb,b.hb
	
	local ax=a.x+ahb[1]
	local ay=a.y+ahb[2]
	local axw,ayh=ax+ahb[3]-1,ay+ahb[4]-1

	local bx=b.x+ahb[1]
	local by=b.y+ahb[2]
	local bxw,byh=bx+ahb[3]-1,by+ahb[4]-1

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
	local enemy={
		s=_type, -- sprite

		sx=_x,	-- spawn x/y
		sy=_y,

		ox=0,	-- offset x/y
		oy=0, 
		
		x=63,
		y=-18,
		
		t=0,
		shot_index=1,

		perc=0,

		hb=gen_hitbox(3),

		health=3,
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
	if(_e.health<=0)del(enems,_e)
end