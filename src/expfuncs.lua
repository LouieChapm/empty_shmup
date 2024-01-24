--lint: func::_init
function init_expfuncs()
	parts,exp_fadeout,exp_default,exp_queue={},parse_data"222,224|221,222|221",parse_data"115|50,55|35,50|18,35|1,18|213",{}
end

-- time, x offset, y offset
function add_expqueue(_ox, _oy, _size, _data)
	for item in all(parse_data(_data)) do 
		local time,x,y=unpack(item)
		add(exp_queue,{time,x+_ox,y+_oy,_size})
	end
end

function upd_expqueue(exp_item)
	local time,x,y,size=unpack(exp_item)
	exp_item[1]-=delta_time
	if(time>0)return
	new_explosion(x,y,size,false,5)
	del(exp_queue,exp_item)
end


-- 8178 tokens
-- 8138 tokens after _env
function drw_part(_p)
	_p=setmetatable(_p,{__index=_ENV})
	local _ENV=_p
	if(slow_motion and t%3!=0)func(_ENV)return
	if(life==0)ox,oy=x,y

	life+=delta_time
	if(life<0)return

	local tospd=tospd or .1
	if(toy)x,y=lerp(x,tox,tospd),lerp(y,toy,tospd)
	if(torad)rad=lerp(rad,torad,toradspd or 0.5)

	local vdrift=vdrift or .15
	y-=vdrift * delta_time
	if(toy)toy-=vdrift * delta_time
	if(hdrift)x-=hdrift * delta_time

	func(_ENV)

	if(rad and rad<0)del(parts,_ENV)

	if(not step_points)goto skip
	for step_point in all(step_points) do 
		if(life==step_point)colstep+=1
	end
	::skip::

	if life>maxlife then 
		if onend=="return" then
			onend=nil
			maxlife+=life
			torad=-1

			toy,tospd,colstep,colour_lut,step_points,toradspd=y-3,.05,1,exp_fadeout,{5+life,12+life},0.02
		else
			del(parts,_ENV)
		end
	end
end

function p_wave(data)
	local x,y,size,life=data.x,data.y+5,data.rad,data.life
	local w,h=size,size*.5
	local x1,y1=x-w*.5,y-h*.5

	oval(x1,y1,x1+w,y1+h,life>18 and 2 or life>7 and 3 or 7 )
end

function p_grape(data)
	local x,y,size,colour_tab,rads,pat=data.x,data.y,data.rad,data.colour_lut or parse_data"50,55",split"1,.95,.85,.7",split"0b1111111111110111,0b1010101010101010,0b1010101000000000,0b1000001000000000"
	local coltab=colour_tab[data.colstep or 1]

	if(size<6)rads=split"1,.9,.7"deli(pat,3)

	for i=1,#rads do  
		local nsize=size*rads[i]
		fillp(pat[i])
		circfill(x,y+nsize-size,nsize,coltab[i] or coltab[#coltab])
	end

	fillp""
end

--8165
function pnew_circ(_x, _y, _spawn_offset, _maxage, _size)
	local segs,rot_offset=3+_size,rnd"1"

	local iter=1/segs
	for i=1,segs do
		local ang=i*iter+rot_offset
		local angx,angy=sin(ang),cos(ang)

		local part=new_basepart(_x+angx*2,_y+angy*2,0,0.1+rnd".05",p_grape,_maxage+eqrnd(10)\1)

		part=setmetatable(part,{__index=_ENV})
		local _ENV=part
		tox,toy,rad,torad,toradspd,colstep,step_points,colour_lut,onend,life=_x+angx*6+eqrnd(1+_size*2),_y+angy*6+eqrnd(1),0,4+rnd"2"\1 + rnd(_size*.5)+_size,1,1,split"3,5,7,16",exp_default,"return",-rnd"10"\1-_spawn_offset
	end
end

function new_basepart(_x,_y,_hdrift,_vdrift,_func,_maxlife)
	return add(parts,
	{
		x=_x,	-- xpos
		y=_y,	-- ypos

		hdrift=_hdrift,
		vdrift=_vdrift,

		func=_func,

		life=0,
		maxlife=_maxlife,
	})
end

function new_explosion(_originx,_originy,_size,_maxage)
	local originy,maxlife,size=_originy+eqrnd(3),_maxage or 20,_size or 0

	sfx(rnd(split"56,57,58"),3)

	local part=new_basepart(_originx,originy,0,0,p_grape,1)
	part.rad=15+size*6

	local part=new_basepart(_originx,originy,0,0,p_wave,maxlife)
	part.rad,part.torad,part.toradspd=1,40+size*8,0.25

	
	for i=0,1+size do
		pnew_circ(_originx+eqrnd(1+i*6),originy-i*6,i,maxlife,size)
	end
end