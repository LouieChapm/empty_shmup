pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
debug=""
version_id="V2"

function reset_data()
	local name_list={0b011100000101111,0b000100000010011,0b010110101010010,0b100110011001110,0b000000101010011,0b101100011101110,0b000001001001100,0b001011000100011,0b000111010001010,0b000100000010101,0b000110001101111}

	local default_data={
		0.5238,
		0b000000011000001,
		14981,
		0.4117,
		del(name_list,rnd(name_list)),
		01092,
		0.3086,
		del(name_list,rnd(name_list)),
		11010,
		0.3065,
		del(name_list,rnd(name_list)),
		01010,
		0.2047,
		del(name_list,rnd(name_list)),
		11399,
		0.1039,
		del(name_list,rnd(name_list)),
		11993,
		0.1032,
		del(name_list,rnd(name_list)),
		01111,
		0.1021,
		del(name_list,rnd(name_list)),
		01011,
	}

	for i=0,64 do 
		dset(i,default_data[i+1])
	end
end

function _init()
	t=0

	cartdata"kalikan"
	local menu_start_screen="highscores"
	if(dget(0)==0)reset_data()
	-- reset_data()

	is_duplicate_load=dget(63)==1

	-- the dget locations
	score_memory_locations=split"0,3,6,9,12,15,18,21"
	-- start_info=split(stat(6),"|")
	if dget(59)==1 and not is_duplicate_load then 
		menu_start_screen="highscores"

		prevrun_type = dget(50)
		prevrun_stage = dget(51)
		prevrun_maxhit = dget(52)
		prevrun_score = dget(53)
		new_score_position=score_spot_pos(prevrun_score)

		--[[
		prevrun_score=start_info[3]
		prevrun_maxhit=start_info[4]
		prevrun_type=start_info[5]
		]]--

		if new_score_position>0 then 
			menu_start_screen="submit"
		end

		dset(63,1)	-- duplicate load check
		dset(59,0) 	-- reset "did die" thing
	end

	alphabet_string=split"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z"
	add(alphabet_string,".")

	poke4(0x5600,unpack(split"0x9.0908,0x.0100,0x1100,0x7.0700,0x.0070,0x700.7000,0,0,0,0x7.0070,0,0,0x.0007,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x3f3f.3f3f,0x3f3f.3f3f,0x3f3f.3f00,0x3f.3f3f,0x333f.3f00,0x3f.3f33,0xc33.3300,0x33.330c,0x33.3300,0x33.3300,0x3333.3300,0x33.3333,0x3f3c.3000,0x30.3c3f,0x3f0f.0300,0x3.0f3f,0x303.0f0f,0,0,0x7878.6060,0x1e3f.3300,0xc3f.0c3f,0xc00,0x.000c,0,0x181c.0c0c,0,0xf0f.0f0f,0x66.7733,0,0x3e36.3e1c,0x.001c,0,0,0x1e3f.3f3f,0xc0c.001e,0x6677.3333,0,0x367f.7f36,0x367f.7f36,0x3f1b.7f7e,0x3f7f.6c7e,0x3873.6300,0x6367.0e1c,0x1f1b.1f0e,0x1e3f.737e,0xc1c.1818,0,0x307.7e7c,0x7c7e.0703,0x6070.3f1f,0x1f3f.7060,0x1c3e.3600,0x.363e,0x3f0c.0c00,0xc.0c3f,0,0xc1c.1818,0x7e00,0x.007e,0,0xc0c,0x3870.6000,0x307.0e1c,0x6b63.7f3e,0x3e7f.636b,0x181f.1f18,0x7f7f.1818,0x7e60.7f3f,0x7f7f.033f,0x7c60.7f3f,0x3f7f.603c,0x676e.7c78,0x6060.7f7f,0x3f03.7f7f,0x3f7f.607f,0x3f03.7f7e,0x3e7f.637f,0x3870.7f7f,0x307.0e1c,0x3e63.7f3e,0x3e7f.637f,0x7f63.7f3e,0x3f7f.607e,0x.1818,0x1818,0x.1818,0xc1c.1818,0x1f7c.7000,0x70.7c1f,0x7f.7f00,0x7f.7f00,0x7c1f.0700,0x7.1f7c,0x7c60.7f3f,0xc0c.003c,0x7b6b.7f3e,0x7e7f.037b,0x7e60.7e3e,0x7e7f.637f,0x3f03.0303,0x3f7f.637f,0x637f.3e00,0x3e7f.6303,0x7e60.6060,0x7e7f.637f,0x7f63.7f3e,0x7e7f.037f,0x1f66.7e3c,0x606.061f,0x3f33.7f7e,0x1f3f.381e,0x3f03.0303,0x6363.637f,0xc00.0c0c,0x181c.0c0c,0x6000.6060,0x3e7f.6360,0x7363.0303,0x6373.3f3f,0xc0c.0c0c,0x181c.0c0c,0x7f7f.3600,0x6363.636b,0x7f3f.0300,0x6363.6363,0x637f.3e00,0x3e7f.6363,0x637f.3f00,0x303.3f7f,0x637f.7e00,0x6060.7e7f,0x7f3f.0300,0x303.0363,0x77f.7e00,0x3f7f.703e,0x7f7f.0606,0x7c7e.0606,0x6363.6300,0x3e7f.6363,0x7763.6300,0x1c1c.3e3e,0x6363.6300,0x367f.7f6b,0x3e77.6300,0x6377.3e1c,0x7f63.6300,0x3f7f.607e,0x387f.7f00,0x7f7f.0e1c,0x303.7f7f,0x7f7f.0303,0xe07.0300,0x6070.381c,0x6060.7f7f,0x7f7f.6060,0x363e.1c08,0,0,0x7f7f,0x181c.0c0c,0,0x7f63.7f3e,0x6363.637f,0x3f63.7f3f,0x3f7f.637f,0x363.7f3e,0x3e7f.6303,0x6363.7f3f,0x3f7f.6363,0x3f03.7f7f,0x7f7f.033f,0x3f03.7f7f,0x303.033f,0x7b03.7f7e,0x3e7f.637b,0x7f63.6363,0x6363.637f,0xc0c.7f7f,0x7f7f.0c0c,0x3030.7e7e,0x1e3f.3330,0x1f3b.7363,0x6373.3b1f,0x303.0303,0x7f7f.0303,0x7f7f.3636,0x6363.636b,0x7f6f.6763,0x6363.737b,0x6363.7f3e,0x3e7f.6363,0x6363.7f3f,0x303.3f7f,0x6363.7f3e,0xfeff.7363,0x6363.7f3f,0x6373.3f7f,0x3f03.7f7e,0x3f7f.607e,0xc0c.7f7f,0xc0c.0c0c,0x6363.6363,0x3e7f.6363,0x3677.6363,0x81c.1c3e,0x6b63.6363,0x3636.7f7f,0x3e77.6363,0x6363.773e,0x7f63.6363,0x3f7f.607e,0x3870.7f7f,0x7f7f.0e1c,0x706.7e7c,0x7c7e.0607,0x1818.1818,0xc0c.0c0c,0x7030.3f1f,0x1f3f.3070,0x3b7f.7f6e,0,0x3e36.3e3e,0x.003e,0xffff.ffff,0xffff.ffff,0xcccc.3333,0xcccc.3333,0x497f.6300,0x3e63.777f,0x7777.3e00,0x3e77.6341,0x3030.0303,0x3030.0303,0xfcfc.0c0c,0x3030.3f3f,0x4f4f.3e00,0x3e7f.7f7f,0x7f7f.3600,0x81c.3e7f,0x7f7f.3e00,0x3e7f.7f77,0x7f1c.1c00,0x363e.1c7f,0x3e1c.0800,0x3636.3e7f,0x7377.3e00,0x3e77.7341,0x497f.3e00,0x3e63.417f,0x1818.7838,0xe1f.1f1e,0x637f.3e00,0x3e7f.6349,0x7f7f.3e00,0x3e7f.7f7f,0x3300,0x.0033,0x6777.3e00,0x3e77.6741,0x7f1c.0800,0x6377.3e7f,0x3e7f.7f00,0x7f7f.3e1c,0x6377.3e00,0x3e77.7741,0x40e.1f1b,0x2070.f8d8,0xeec7.8301,0x10.387c,0x6b5d.3e00,0x3e5d.6b77,0x.ffff,0x.ffff,0x3333.3333,0x3333.3333"))

	pal(split"-3,9,10,5,13,6,7,136,8,3,139,138,130,133,0,2",1)
	-- poke(0x5f2e,1)

	palt(0,false)
	palt(11,true)


	_upd=nil
	_drw=nil

	button_drwdat=parse_data"0,0,12,10|12,0,12,10"


	time_since_input=0
	is_idle=true

	highest_score=tostr(dget(0),0x2).."0"

	lerp_objects={}

	logo_obj={}
	new_lerpobj(logo_obj,28,16)


	sides_obj={}
	new_lerpobj(sides_obj,-4,0)

	menu_goto(menu_start_screen)
end

function _update60()
	t+=1

	swapped_this_frame=false
	time_since_input+=1

	frame_progress+=1

	foreach(lerp_objects,upd_lerpobj)

	if(btnp_any())time_since_input=0

	_upd()
end



function _draw()
	cls(13)
	
	_drw()

	print(debug,1,1,7)
end

-->8
-- submit highscore

function init_submit()
	cursor={
		cx=0,
		cy=0,
	}

	grid_x,grid_y=15,50
	grid_w,grid_h=15,15

	local x,y=index_2_pos(0,0)
	new_lerpobj(cursor,x,y)

	selection_index=1
	player_name={0,0,0}

	submit_finished=false

end

function index_2_pos(_x,_y)
	return grid_x+_x*grid_w,grid_y+_y*grid_h
end

function submit_data(_pos)
	local char_a,char_b,char_c=convert_to_binary(player_name[1]),convert_to_binary(player_name[2]),convert_to_binary(player_name[3])
	local binary = "0b"..char_a ..char_b ..char_c

	for i=#score_memory_locations-1,_pos,-1 do 
		local start_loc,end_loc=score_memory_locations[i],score_memory_locations[i+1]
		dset(end_loc,dget(start_loc))
		dset(end_loc+1,dget(start_loc+1))
		dset(end_loc+2,dget(start_loc+2))

		if(end_loc<9)dset(end_loc+2,dget(start_loc+2))
	end

	dset(score_memory_locations[_pos],prevrun_score)
	dset(score_memory_locations[_pos]+1,tonum(binary))
	
	local clamped_score=min(prevrun_maxhit,999)
	local save_score=sub("000"..clamped_score,-3)
	dset(score_memory_locations[_pos]+2,tonum(prevrun_type..prevrun_stage..save_score))

	highest_score=tostr(dget(0),0x2).."0"

	menu_goto("highscores")
end

-- returns the index "position" that a players high score will be
function score_spot_pos(_number)
	local position=-1
	for i=#score_memory_locations,1,-1 do 
		if(_number>dget(score_memory_locations[i]))position=i
	end
	return position
end

-- this is cringe please don't just me I wrote this when I was very tired
-- convert 0-31 number to 5 bit binary
function convert_to_binary(_num)
	local cur=_num
	local out=""
	for i=0,5 do
		if cur>0 then
			out..=cur%2
			cur=flr(cur*0.5)
		end
	end

	out = sub(out.."00000",1,5)

	local n_out=""
	for i=#out,0,-1 do
		n_out..=sub(out,i,i)
	end

	return n_out
end

function update_submit()
	local button_pressed=false
	local newx,newy=cursor.cx,cursor.cy
	if(btnp"0")newx-=1 	button_pressed=true
	if(btnp"1")newx+=1	button_pressed=true
	if(btnp"2")newy-=1	button_pressed=true
	if(btnp"3")newy+=1	button_pressed=true
	cursor.cx=mid(0,newx,6)
	cursor.cy=mid(0,newy,3)

	if button_pressed then
		local nx,ny=index_2_pos(cursor.cx,cursor.cy)
		new_lerp(cursor,nx,ny,.2)
		submit_finished=false
	end

	if btnp(❎) then
		if cursor.cx==6 and cursor.cy==3 then 
			submit_data(new_score_position)
			return
		end


		if selection_index==3 then 
			player_name[selection_index]=min(cursor.cx+cursor.cy*7,26)

			cursor.cx,cursor.cy=6,3
			local nx,ny=index_2_pos(cursor.cx,cursor.cy)
			new_lerp(cursor,nx,ny,.2)
			submit_finished=true
			return
		end

		player_name[selection_index]=min(cursor.cx+cursor.cy*7,26)
		selection_index=min(selection_index+1,3)
	end

	if btnp(🅾️) then 
		player_name[selection_index]=min(cursor.cx+cursor.cy*7,26)
		selection_index=max(selection_index-1,1)
	end
end

function draw_submit()
	local letters=parse_data"a,b,c,d,e,f,g|h,i,j,k,l,m,n|o,p,q,r,s,t,u|v,w,x,y,z,.,"

	for i=0,#letters-1 do 
		local row=letters[i+1]
		for n=0,#row-1 do 
			local x,y=grid_x+n*grid_w,grid_y+i*grid_h
			print("\014"..row[n+1],x,y+1,5)
			print("\014"..row[n+1],x,y,7)
		end
	end
	sspr(8,119,9,9,grid_x+89,grid_y+45)

	local curs_x,curs_y=cursor.cx*grid_w,cursor.cy*grid_h
	rect(grid_x-3+curs_x,grid_y-3+curs_y,grid_x+9+curs_x,grid_y+11+curs_y,5)

	local curs_x,curs_y=cursor.x,cursor.y
	rect(curs_x-3,curs_y-3,curs_x+9,curs_y+11,6)

	local topx,topy=50,20
	for i=0,2 do 
		local _x=topx+i*10
		local char=alphabet_string[player_name[i+1]+1]
		if(not submit_finished and i+1==selection_index)char=alphabet_string[cursor.cx+cursor.cy*7+1] or " "
		print("\014"..char,_x,topy+1,5)
		print("\014"..char,_x,topy,7)
		-- print(player_name[i+1],_x,topy,5)
	end
	local current_score=tostr(prevrun_score,0x2).."0"

	print(hcentre(current_score,topy+13,t%8<4 and 5 or 4))
	print(hcentre(current_score,topy+12,7))

	local bx=topx-2+(selection_index-1)*10
	if(not submit_finished)rect(bx,topy-2,bx+10,topy+10,5)

	-- line(63,0,63,128,8)
end


-->8
-- high scores
function init_highscores()
	fade_perc,fade_rate=1,-0.03

	new_lerp(sides_obj,-6,0,.05)	
end

function update_highscores()
	if(frame_progress>1000)menu_goto("basic")
	if(btnp(❎))menu_goto("basic")sfx(62)
end

function draw_highscores()
	cls(13)

	do_fade(fade_perc)

	local _y=4 + min(0,sin(frame_progress*.001-.2)*70)
	local oy=_y
	drw_hs_big(23,_y,1,6)
	_y+=30
	for i=2,3 do
		drw_hs_big(24,oy+3+(i-1)*32,i,4)
		_y+=28
	end

	_y+=0
	for i=4,8 do
		drw_hs_small(24,_y+2+(i-4)*19,i,4)
	end

	-- borders
	map(0,0,0+sides_obj.x,0,2,16)
	map(0,0,128-16-sides_obj.x,0,2,16)
end

function mem_2_string(_binary)
	-- five bytes each which is a max of 31
	-- 00000 00001 00010 = cba
	-- oh yeah its also backwards ?? maybe not anymore
	-- alphabet (26) + , . - 
	local z=_binary&31
	local y=(_binary>>5)&31
	local x=(_binary>>10)&31

	local letter_a=alphabet_string[min(z,26)+1]
	local letter_b=alphabet_string[min(y,26)+1]
	local letter_c=alphabet_string[min(x,26)+1]

	return letter_c..letter_b..letter_a
end

function drw_hs_small(_x,_y,_num)
	local bg_col=12

	local ox,oy=_x+9,_y
	rndrect(ox,oy+11,80,14+2,3,5)
	rndrect(ox,oy+11,80,14,3,6)
	rrectfill(ox+2,oy+12+1,80-4,12-2,bg_col)

	-- score number
	local score_x,score_y=ox+31,oy+14
	rrectfill(score_x,score_y,46,8,13)
	print("88888888888",score_x+2,score_y+2,4)
	
	-- memory region
	local mem_region=9+(_num-4)*3

	-- high score
	local highscore=tostr(dget(mem_region),0x2).."0"
	print(highscore,score_x+46-(#highscore*4),score_y+2,7)

	-- area indicator
	local area_x,area_y=ox+14,oy+14
	rrectfill(area_x,area_y,14,8,13)
	print("888",area_x+2,area_y+2,4)
	print(mem_2_string(dget(mem_region+1)),area_x+2,area_y+2,7)


	--number
	local num_x,num_y=ox-12,oy+16
	sspr(6,62,10,7,num_x,num_y)
	sspr(0,62+(_num-4)*7,5,7,num_x-6,num_y)

	local combo=sub("0"..dget(mem_region+2),-5)
	local ship_index=tonum(sub(combo,1,1))+1

	if ship_index==1 then 
		palt(9,true)
		palt(11,false)
	end

	local sx,sy=unpack(split(ship_index==1 and "0,110" or ship_index==2 and "0,119"))
	sspr(sx,sy,8,9,ox+4,oy+14)

	if ship_index==1 then 
		palt(9,false)
		palt(11,true)
	end

	-- print(dget(mem_region+1) .. " " .. ship_index,area_x+40,area_y-7,10)
end

function drw_hs_big(_x,_y,_num,_height)
	local bg_col=12
	local border_col,shadow_col=unpack(split(_num == 1 and "3,2" or _num == 2 and "1,11" or "9,8"))

	local ox,oy=_x,_y
	rndrect(ox+4,oy+11,89-4,13+_height,3,shadow_col)
	rndrect(ox+4,oy+11,89-4,14,3,border_col)
	rndrect(ox+37,oy,52,23,3,border_col)

	
	rrectfill(ox+6,oy+12+1,89-4-6,12-2,bg_col)
	rrectfill(ox+38+1,oy+2,52-4,23-2,bg_col)

	pal(7,border_col)
	sspr(72,0,4,4,ox+35,oy+9)
	pal(7,7)

	-- score number
	local score_x,score_y=ox+40,oy+3
	rrectfill(score_x,score_y,46,8,13)
	print("88888888888",score_x+2,score_y+2,4)

	local mem_location=(_num-1)*3
	local highscore=tostr(dget(mem_location),0x2).."0"
	print(highscore,score_x+46-(#highscore*4),score_y+2,7)

	local combo=sub("0"..dget(mem_location+2),-5)
	local ship_index=tonum(sub(combo,1,1))+1
	local max_combo=tostr(tonum(sub(combo,-3)))

	
	-- area indicator
	local area_x,area_y=ox+18,oy+14
	rrectfill(area_x,area_y,23,8,13)
	print("AREA",area_x+2,area_y+2,7)
	print("8",area_x+19,area_y+2,4)
	print(tonum(sub(combo,2,2)),area_x+19,area_y+2,7)

	


	-- max hit
	local area_x,area_y=ox+44,oy+14

	rrectfill(area_x,area_y,42,8,13)
	print("MAX \-eHIT",area_x+2,area_y+2,7)
	print("888",area_x+30,area_y+2,4)

	
	print(max_combo,area_x+42-tostr(#max_combo*4),area_y+2,7)

	-- number and name
	local sx,sy,sw,sh=unpack(split(_num==1 and "16,46,19,11" or _num==2 and "16,57,21,10" or "16,67,21,10"))
	if(_num==2)palt(11,false)palt(9,true)
	local _x,number_y=ox-11,oy-1
	if(_num==1)_x+=2 number_y-=1
	sspr(sx,sy,sw,sh,_x,number_y)
	if(_num==2)palt(11,true)palt(9,false)

	-- sspr(35,46,23,11,ox+12,oy-1)
	print("\014"..mem_2_string(dget(mem_location+1)),ox+12,oy+1,5)
	print("\014"..mem_2_string(dget(mem_location+1)),ox+12,oy,7)

	-- little ship icon
	
	if ship_index==1 then 
		palt(9,true)
		palt(11,false)
	end

	local sx,sy=unpack(split(ship_index==1 and "0,110" or ship_index==2 and "0,119"))
	sspr(sx,sy,8,9,ox+8,oy+14)

	if ship_index==1 then 
		palt(9,false)
		palt(11,true)
	end
end

function rndrect(_x,_y,_w,_h,_rad,_c)
	_x+=_rad
	_y+=_rad

	_w-=_rad*2
	_h-=_rad*2

	rectfill(_x,_y-_rad,_x+_w,_y+_h+_rad,_c)
	rectfill(_x-_rad,_y,_x+_w+_rad,_y+_h,_c)

	circfill(_x,_y,_rad,_c)
	circfill(_x+_w,_y,_rad,_c)
	circfill(_x,_y+_h,_rad,_c)
	circfill(_x+_w,_y+_h,_rad,_c)
end

-->8
-- basic menu

function menu_goto(_target)
	if(swapped_this_frame)return

	frame_progress=0

	pal(split"-3,9,10,5,13,6,7,136,8,3,139,138,130,133,0,2",1)
	-- poke(0x5f2e,1) -- keeps the colours on quit

	menu_mode=_target
	if(_target=="basic")init_bbasic()_upd,_drw=update_bbasic,draw_bbasic
	if(_target=="shipsel")init_shipsel()_upd,_drw=update_shipsel,draw_shipsel
	if(_target=="ramcheck")init_ramcheck()_upd,_drw=update_ramcheck,draw_ramcheck
	if(_target=="highscores")init_highscores()_upd,_drw=update_highscores,draw_highscores
	if(_target=="submit")init_submit()_upd,_drw=update_submit,draw_submit
	swapped_this_frame=true
end

function init_bbasic()
	new_lerp(logo_obj,28,16,.03)
	new_lerp(sides_obj,-4,0,.03)

	fade_perc,fade_rate=1,-0.05
end

function update_bbasic()
	if(btnp(❎))menu_goto("shipsel")sfx(61)

	time_since_input=min(time_since_input+1,1000)
	is_idle=time_since_input>600

	if(frame_progress>600)menu_goto("highscores")
	if(btnp(🅾️))menu_goto("highscores")sfx(61)
end

function draw_bbasic()
	do_fade(fade_perc)


	local width=22
	rectfill(63-width,0,64+width-1,128,8)

	drw_logo(logo_obj.x,logo_obj.y)
	drw_start_button(36,78)

	local flash_length=60
	if(t%flash_length<(flash_length*.6666))print_thick(hcentre(t%(flash_length*4)<(flash_length*2) and "please insert coin" or "press any button",56,7))

	local text_y=105
	print(hcentre("@0Xffb3/LOUIE 2023",text_y,6))
	print(hcentre("SALE BY LOUIE",text_y+6,6))

	print(version_id,14,121,0)

	map(0,0,0+flr(sides_obj.x),0,2,16)
	map(0,0,128-16-flr(sides_obj.x),0,2,16)
	
	print_thick(hcentre("HIGH "..highest_score,2,6))	
end

-->8
-- ship select

function init_shipsel()
	new_lerp(sides_obj,-16,0,.04)

	fade_perc,fade_rate=1,-0.05

	shipsel_frame_x,shipsel_frame_y=7,15

	ship_sel_ready=false

	shipsel_selection=2
	shipsel_cursor={}
	new_lerpobj(shipsel_cursor,shipsel_frame_x+19,19)

	type_a={}
	new_lerpobj(type_a,shipsel_frame_x+20,-10)

	type_b={}
	new_lerpobj(type_b,shipsel_frame_x+20,shipsel_frame_x+55)

	type_c={}
	new_lerpobj(type_c,shipsel_frame_x+20,-10)

	ships={type_a,type_b,type_c}

	text_draw=0

	out_progress=-1
end

 	
function update_shipsel()
	if(out_progress>=0)out_progress+=1

	if(out_progress==35)sfx(60) 
	if(out_progress and out_progress==60)fade_backwards,fade_perc,fade_rate=true,0,.1
	if out_progress and out_progress>80  then 
		start_game()
	end
	text_draw+=1

	if frame_progress>1800 or out_progress>=0 then 

	elseif frame_progress>1500 then 
		if(frame_progress%15==0)sfx(63)
	elseif frame_progress>1200 then
		if(frame_progress%30==0)sfx(63)
	else
		if(frame_progress%60==0)sfx(63)
	end

	if btnp(❎) and shipsel_selection<=2 and out_progress<0 or frame_progress==1800 then 
		ship_sel_ready=true

		local ship=ships[shipsel_selection]
		new_lerp(ship,ship.x,-10,.02,"EaseInOvershoot")
		out_progress=0
	end

	if btnp(🅾️) then 
		menu_goto("basic")sfx(62)
	end

	local new_pos=shipsel_selection
	if(btnp(⬅️) and out_progress<0)new_pos-=1
	if(btnp(➡️) and out_progress<0)new_pos+=1

	if(frame_progress>1680)new_pos=mid(1,new_pos,2)

	if mid(1,new_pos,3)!=shipsel_selection then 
		local ship=ships[shipsel_selection]
		new_lerp(ship,ship.x,-10,.05)

		text_draw=0

		shipsel_selection=new_pos
		ship_sel_ready=false

		local x_values=split"0,19,37"
		local height_values=split"21,19,22"
		new_lerp(shipsel_cursor,shipsel_frame_x+x_values[shipsel_selection],height_values[shipsel_selection],.1)

		local ship=ships[shipsel_selection]
		ship.y=120 new_lerp(ship,ship.x,shipsel_frame_x+55,.05)
	end

end

function draw_shipsel()
	do_fade(fade_perc)


	local frame_x,frame_y=shipsel_frame_x,shipsel_frame_y
	drw_mapbackground(frame_x+1)

	palt(11,false)
	palt(9,true)
	local sx,sy=type_a.x,type_a.y+sin(t*.005)*3
	sspr(5,77,14,19,sx+1,sy-2)
	palt(11,true)
	palt(9,false)

	-- rotors
	local rt=t\4
	if(rt%3==2)sspr(72,72,18,16,sx-1,sy-3)
	if(rt%3==1)sspr(91,72,18,16,sx-1,sy-3)


	local sx,sy=type_b.x,type_b.y+sin(t*.005)*3
	sspr(0,46,16,16,sx,sy)

	local sx,sy=type_c.x,type_c.y+sin(t*.005)*3
	sspr(47,108,14,20,sx+1,sy-2)

	local bg_col=8
	rectfill(0,0,128,frame_y,bg_col)
	rectfill(0,0,frame_x,128,bg_col)
	rectfill(frame_x+8*7-1,0,128,128,bg_col)
	rectfill(0,frame_y+8*10-1,128,128,bg_col)

	

	map(4,0,frame_x,frame_y,7,11)

	

	local text="HIGH "..highest_score
	print_thick(text,127-#text*4,2,6)

	-- ship selection boxes
	local ox,oy=frame_x+20,frame_y+87
	local width=19
	sspr(17,108,14,20,ox-width+1,oy)
	sspr(31,108,16,18,ox,oy)
	sspr(47,108,14,20,ox+width,oy)

	-- shipsel cursor thing
	oy-=1
	ox-=1

	local sox=sin(t*.01)*1.1
	local width,height=16,shipsel_cursor.y

	if ship_sel_ready==false then 
		local cursor_ox,cursor_oy=shipsel_cursor.x,shipsel_frame_y+85
		sspr(61,120,3,4,cursor_ox+sox,cursor_oy+sox)
		sspr(64,120,3,4,cursor_ox+width-sox,cursor_oy+sox)
		sspr(61,124,3,4,cursor_ox+sox,cursor_oy+height-sox)
		sspr(64,124,3,4,cursor_ox+width-sox,cursor_oy+height-sox)
	end
	
	-- counter
	local number=max(0,30-frame_progress\60) 
	show_nums=true
	
	if number<=5 then 
		if(frame_progress%30>15)show_nums=false
	elseif number<=10 then 
		if(frame_progress%60>30)show_nums=false
	end

	if show_nums then 
		local text,x,y,c=hcentre("\014"..sub("000"..tostr(number),-2),3,7)
		x-=30
		print(text,x,y+1,t%8<3 and 1 or 5)
		print(text,x,y,c)
	end

	-- ship data stuff

	local tx=shipsel_frame_x+59
	local ty=20

	local type,country,speed,options,secondary,cost=unpack(split(shipsel_selection==1 and "type a,pERU,fAST,3,bURST,63.9B" or shipsel_selection==2 and "type b,uNITED kINGDOM,mEDIUM,2,lASER,48.2B" or "type c,jAPAN,???,?,???,???"))

	print_text_slow(type,tx,ty,7) -- drawn

	print("COUNTRY ORIGIN:",tx,ty+10,6)
	print_text_slow(country,tx+5,ty+16,7,3) -- drawn

	print("SPEED:",tx,ty+26,6)
	print_text_slow(speed,tx+24,ty+26,7,8) -- drawn

	print("OPTIONS:",tx,ty+36,6)
	print_text_slow(options,tx+32,ty+36,7,10) -- drawn

	print("SECONDARY FIRE:",tx,ty+46,6)
	print_text_slow(secondary,tx+5,ty+53,7,11) -- drawn

	print("COST:",tx,ty+62,6)
	print_text_slow(cost,tx+5,ty+68,7,14) -- drawn
	

	map(0,0,0+sides_obj.x,0,2,16)
	map(0,0,128-16-sides_obj.x,0,2,16)
end

function print_text_slow(_text,_x,_y,_c,_delay,_speed)
	local delay,speed=_delay or 0,_speed or 3
	local _text=sub(_text,1,max(0,(text_draw\speed)-delay*speed))
	print(_text,_x,_y,_c) -- drawn
end

function drw_mapbackground(_x)
	local celx,cely,sx,celw,celh,ry=2,0,_x,2,2,.5
	for y=-8*celh,128,celh*8 do
		map(celx,cely,sx,y+(t*ry)%(celh*8),celw,celh)
	end

	sx+=38
	for y=-8*celh,128,celh*8 do
		map(celx,cely,sx,y+(t*ry)%(celh*8),celw,celh)
	end

	celx,cely,sx,celw,celh,ry=11,0,sx-35,6,8,.75
	for y=-8*celh,128,celh*8 do
		map(celx,cely,sx,y+(t*ry)%(celh*8),celw,celh)
	end
end

-->8
-- swag intro

function init_ramcheck()
	pal(split"0,7",1)
end

function update_ramcheck()
	if(frame_progress==500)menu_goto("highscores")
end

function draw_ramcheck()
	cls(1)

	if frame_progress<300 and rnd"10">.2 then 
		local width=13
		for x=-1,min(t*4,128),width do 
			for y=-1,128,width do
				if(t*5>x+y*2 or rnd"10"<2)rect(x,y,x+width,y+width,7)
			end
		end

		rectfill(13,26,115,63,1)

		local text,x,y,col=hcentre(frame_progress<150 and "checking memory....." or "checking ram....", 30,7)
		print(text,x,y,col)
		print("code area "..rnd(split"000b4000,000e4000,000f8000,000ffaa2,002ffa3a,fe0af000"), x,y+10,col)

		-- print(intro_progress,1,1)
	end

	local hex=split"0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f"
	if frame_progress>325 and frame_progress<450 then 
		local amount=frame_progress-325

		for y=-3,min(amount*2,100),6 do 
			print("port:"..tostr(y\6)..hex[1+(y*9)%16]..hex[1+(y*23)%16],4,y)
			if(amount*2>y*2+30)print("success!",50,y)
		end
	end

	--[[
	if(intro_progress>455 and intro_progress<460)rectfill(0,0,128,128,9)
	if(intro_progress>462 and intro_progress<480)rectfill(0,0,128,128,11)
	if(intro_progress>490 and intro_progress<510)rectfill(0,0,128,128,3)
	if(intro_progress==520)rectfill(0,0,128,128,9)
	]]--

end

-->8
-- lerp stuff

function new_lerpobj(_table, _origin_x, _origin_y)
	_table.lerpt=1
	_table.lerprate=.02

	_table.lerptype="EaseInOutQuad"


	_table.lerpx1,_table.lerpy1=_origin_x,_origin_y+50
	_table.lerpx2,_table.lerpy2=_origin_x,_origin_y

	add(lerp_objects,_table)
	upd_lerpobj(_table)
end

function upd_lerpobj(_table)
	_table.lerpt=mid(0,_table.lerpt+_table.lerprate,1)

	local new_t=_table.lerpt
	if(_table.lerptype=="EaseOutQuad")new_t=easeoutquad(new_t)
	if(_table.lerptype=="EaseInOutQuad")new_t=easeinoutquad(new_t)
	if(_table.lerptype=="EaseInOvershoot")new_t=easeinovershoot(new_t)

	_table.x=lerp(_table.lerpx1,_table.lerpx2,new_t)
	_table.y=lerp(_table.lerpy1,_table.lerpy2,new_t)
end

function new_lerp(_table, _tx,_ty, _speed, _type)
	_table.lerpt=0
	_table.lerprate=_speed or 0.01

	_table.lerptype=_type or "EaseInOutQuad"

	_table.lerpx1,_table.lerpy1=_table.x,_table.y
	_table.lerpx2,_table.lerpy2=_tx,_ty
end



function lerp(a,b,t) 
	return a+(b-a)*t 
end

function easeoutquad(t)
    t-=1
    return 1-t*t
end

function easeinoutquad(t)
    if(t<.5) return t*t*2
	t-=1
	return 1-t*t*2
end

function easeinovershoot(t)
    return 2.7*t*t*t-1.7*t*t
end

-- lerps to position , and then lerps back again - for explosion reaction
function easeoutovershoot(t)
	return 6.6*t*(1-t)^2
end

-->8
-- grahipcs

function print_thick(_text,_x,_y,_c)
	print(_text,_x,_y+1,t%8<4 and 0 or 1)
	print(_text,_x,_y,_c or 7)
end

function hcentre(_text,_y,_c)
	return _text,64-(#_text*2),_y,_c
end

function drw_logo(_x,_y)
	sspr(0,10,73,29,_x,_y+sin(t*.01)*1.5)
end

function drw_start_button(_x,_y)
	local sx,sy,sw,sh=unpack(button_drwdat[1+(t\60)%2])
	local dx,dy=_x,_y
	sspr(sx,sy,sw,sh,dx,dy)
	sspr(24,0,36,8,dx+16,dy+1)

	if((t\60)%2==0)sspr(60,0,6,8,dx+3,dy-9)
end

function drw_demonstration(_x,_y)
	local x,y=_x,_y
	local shape_list=split"0,7,8,6,15,8,24,7,32,7,40,7,48,6,55,6,62,7,70,6,77,6,84,7,92,7"
	local colours=split"7,9,9,9,8,8,0"

	local width=0
	for i=1,#shape_list/2 do 
		pal(7,colours[1+(i-t\6)%#colours])
		local index=i*2-1
		sspr(0+shape_list[index],39,shape_list[index+1],7,x+width,y)--+sin(t*.02+i*.1)*1.5)
		width+=shape_list[index+1]+1
	end
	pal(7,7)

	line(x+2,y-3,x+width-4,y-3,6)
	line(x+2,y+9,x+width-4,y+9,6)
end

-->8

function rrectfill(_x,_y,_w,_h,_c)
	rectfill(_x+1,_y,_x+_w-1,_y+_h,_c)
	rectfill(_x,_y+1,_x+_w,_y+_h-1,_c)
end

function do_fade(_amount)
	fade_perc=mid(0,fade_perc+fade_rate,1)
	if fade_perc==0 then 
		if menu_mode=="highscores" then
			pal(split"138,9,10,5,13,6,7,136,8,3,139,134,133,4,0,2",1) 
		else
			pal(split"-3,9,10,5,13,6,7,136,8,3,139,138,130,133,0,2",1) 
		end
		return
	end


	
	
	
	local fade_table={
		{2,130,128,128,0},
		{141,133,130,128,128},
		{9,137,4,132,128},
		{138,9,137,4,128},
		{5,133,130,128,128},
		{13,141,133,130,128},
		{143,134,5,133,128},
		{6,143,134,5,130},
		{136,136,128,128,0},
		{8,8,128,0,0},
		{3,131,133,129,128},
		{3,3,5,133,128},
		{142,5,133,132,128},
		{130,128,128,128,0},
		{130,130,128,128,0},
		{0,0,0,0,0}
	   }

	
	if menu_mode=="highscores" then fade_table={
		{2,130,130,128,128},
		{138,138,132,128,128},
		{9,9,128,128,0},
		{10,138,132,128,128},
		{133,133,130,128,128},
		{134,141,5,130,128},
		{13,134,141,133,128},
		{6,13,134,5,129},
		{136,132,132,128,128},
		{136,132,132,128,128},
		{3,129,129,128,128},
		{139,139,129,128,0},
		{141,5,133,130,128},
		{130,130,128,128,0},
		{132,132,128,128,128},
		{0,0,0,0,0}
	   }
	end

	if fade_backwards then fade_table={
		{2,2,133,130,130},
		{141,2,2,133,133},
		{9,137,4,132,132},
		{10,138,4,4,133},
		{5,5,133,133,133},
		{13,141,141,141,133},
		{6,13,134,141,5},
		{6,15,13,141,5},
		{136,136,2,130,130},
		{8,136,136,130,130},
		{3,131,131,133,133},
		{139,3,3,133,133},
		{134,141,5,5,133},
		{130,130,130,130,130},
		{133,133,130,130,130},
		{0,128,128,128,130}
	   }
	end

	local step=mid(0,_amount*#fade_table[1],#fade_table[1])\1

	for c=0,15 do
		if flr(step+1)>=#fade_table[1] then
			pal(c,fade_backwards and 130 or 0,1)
		else
			pal(c,fade_table[c+1][flr(step+1)],1)
		end
	end
end

function parse_data(_data, _delimeter)
    local out,delimeter={},_delimeter or "|"
    for step in all(split(_data,delimeter)) do
        add(out,split(step))
    end
    return out
end

function btnp_any()
	for i=0,5 do
		if(btnp(i))return true
	end
	return false
end

function start_game()
	if shipsel_selection==1 then
		load("../stage_2/stage_2b.p8")
	elseif shipsel_selection==2 then 
		load("../stage_2/stage_2b.p8")
	end
end
__gfx__
bbbbbbbbbbbbbbb799999bbbb77777bb777777bb77777bb77777bb777777bb77bbffffffbb77ffffffffffffffffffffbbbbbbdeedbbbbbbeeeeeee44eeeeeee
bbb799999bbbbb79999999bb7755577b777777b7777777b777777b777777bb77bbffffffb777ffffffffffffffffffffbbbbbbdeedbbbbbbeeeeeee44eeeeeee
b8799999998bb8999999998b777bb55b557755b7755577b775577b557755bb77bbffffff7777ffffffffffffffffffffbbbbbbdeedbbbbbbeeeeeee44eeeeeee
809999999908809999999908577777bbbb77bbb77bbb77b77bb77bbb77bbbb77bbffffff777cffffffffffffffffffffbbbbbbdeedbbbbbbeeeeeee44eeeeeee
909999999909908999999809b555777bbb77bbb7777777b77777bbbb77bb777777ffffffffffffffffffffffffffffffbbbbbbdeedbbbbbbeeeeeee44eeeeeee
90899999980990888888880977bb577bbb77bbb7777777b777777bbb77bb777777ffffffffffffffffffffffffffffffbbbbbbdeedbbbbbbeeeeeee44eeeeeee
9908888880999908888880995777775bbb77bbb77bbb77b77b777bbb77bbb7777bffffffffffffffffffffffffffffffbbbbbbdeedbbbbbbeee4e4e44e4e4eee
099779996990099779999990b55555bbbb55bbb55bbb55b55b555bbb55bbbb77bbffffffffffffffffffffffffffffffbbbbbbdeedbbbbbbeeeeeee44eeeeeee
b0999999990bb0999999990bffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeeeeeeeeeeeeeeee
bb00000000bbbb00000000bbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe44ee44eeeeeeeee
bbbbbbbbbbbbbbbbbbbbbbbbbbb111bb111bb111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbfffffffffffffffffffffffffffffffffffffffe4ee444eeeeeeeee
b11111bbbbbbbbbbbbbbbbbbbb111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbfffffffffffffffffffffffffffffffffffffffeee444eeeeeeeeee
1111111bbbbbbb11111111bbb11171111711117111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbfffffffffffffffffffffffffffffffffffffffee444eeeeeeeeeee
1177711bbbbbb1111111111b1117711177711177111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbfffffffffffffffffffffffffffffffffffffffe444ee4eeeeeeeee
1177711bbb1111177777711111777117777711777111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbfffffffffffffffffffffffffffffffffffffffe44ee44eeeeeeeee
1177711bb1111177777777111777711977791177771111bbbb11111111bbbbbbbbbbbbbbbfffffffffffffffffffffffffffffffffffffffeeeeeeeeeeeeeeee
1177711bb11711779997777117777118979811777711111bb1111111111b1111111111bbbfffffffffffffffffffffffffffffffffffffffe44d45dddd54d44e
1177711bb11771998889777717779110898011977777711111177777711111111111111bbfffffffffffffffffffffffffffffffffffffffe44d445dd544d44e
117771111117778800087777177787777777118777777711117777777711177117777111bfffffffffffffffffffffffffffffffffffffffe44de445544ed44e
1177771111777700777777771777077777777107779777711177999777711771777777111fffffffffffffffffffffffffffffffffffffffe44dde4444edd44e
1177777117777907777777771777077777777707778977771199888977771777777777711fffffffffffffffffffffffffffffffffffffffe44ddd4e44ddd44e
1177777777779877779977771777177777777717770897777188000877771777777777711fffffffffffffffffffffffffffffffffffffffe44dd544445dd44e
1177777777798777798877771777177777777717770087777100777777771777799777711fffffffffffffffffffffffffffffffffffffffe44d544ee445d44e
1177777777780777780077771777177777777717777007777107777777771777788977711fffffffffffffffffffffffffffffffffffffffe44d44edde44d44e
1177777777700777700077771777177777777717777707779177799777771777700877711fffffffffffffffffffffffffffffffffffffff77bbbbbb77777777
1177777777770977700777771777177777777717777777798777788977771777700077711fffffffffffffffffffffffffffffffffffffff77bbbbbb77777777
1177797777777897777777771777177777777717777777780777700877771777711077711fffffffffffffffffffffffffffffffffffffff77bbbbbb55555555
1177789777777789777779971777177777777717777777700777700077771777711177711fffffffffffffffffffffffffffffffffffffff77bbbbbb55555555
1177708977777708999998891777177777777717779777770977770077771777711177711fffffffffffffffffffffffffffffffffffffff77bbbbbbbbbbbbbb
1177700897777700888880081777177777777717778977777897777777771777711177711fffffffffffffffffffffffffffffffffffffff77bbbbbbbbbbbbbb
1177710089777710000000001777197777777717770897777089777779971777711177711fffffffffffffffffffffffffffffffffffffff77bbbbbbbbbbbbbb
1177711008977711000001101777189777777717770087777008999998891777711177711fffffffffffffffffffffffffffffffffffffff77bbbbbbbbbbbbbb
1177711100897711111111111777108999999917771007777100888880081999911199911fffffffffffffffffffffffe454ede44ede454ebbbbbbbbbbbbbb77
1199911110089911111111111999100888888819991109999110000000001888811188811fffffffffffffffffffffffe454ede44ede454ebbbbbbbbbbbbbb77
1188811111008811bbbbbbb11888110000000018881118888111000001101000011100011fffffffffffffffffffffffee4eede44edee4eebbbbbbbbbbbbbb77
1100011b11100011bbbbbbb11000111000000010001110000111111111111000011100011fffffffffffffffffffffffe454eddee4de454ebbbbbbbbbbbbbb77
1100011bb1110011bbbbbbb11000111111111110001110000111111111111111111111111fffffffffffffffffffffffe454ede44ede454ebbbbbbbbbbbbbb77
1111111bbb111111bbbbbbb1111111111111111111111111111bbbbbbbbb111111111111bfffffffffffffffffffffffe454ede44ede454e77777777bbbbbb77
b11111bbbbb1111bbbbbbbbb11111bbbbbbbbb111111111111bbbbbbbbbbbbbbbbbbbbbbbfffffffffffffffffffffffe454ede44ede454e77777777bbbbbb77
777777bb777777bb77bb77bbb77777bb77bbb77bb77777bb777777b77777bbb77777bb777777b777ffffffffffffffffe454ede44ede454e55555555bbbbbb77
777bb77b777777b77777777b777bb77b777bb77b77bbb77b777777b777777b7777777b777777b777ffffffffffffffffe454ede44ede454ebb777777777777bb
77bbb77b77bbbbb77777777b77bbb77b7777b77b777bbbbbbb77bbb77bb77b77bbb77bbb77bbbbb7ffffffffffffffffe444edeeeede444eb77777777777777b
77bbb77b77777bb77b77b77b77bbb77b7777777bb77777bbbb77bbb77bb77b77bbb77bbb77bbbbb7ffffffffffffffffe46555eeee55564e7777555555557777
77bbb77b77bbbbb77bbbb77b77bbb77b77b7777bbbbb777bbb77bbb77777bb7777777bbb77bbbbb7ffffffffffffffffe56555444455565e7775555555555777
77bb777b777777b77bbbb77b77bb777b77bb777b77bbb77bbb77bbb777777b7777777bbb77bbb777ffffffffffffffff55eeee4dd4eeee557755bbbbbbbb5577
777777bb777777b77bbbb77bb77777bb77bbb77bb77777bbbb77bbb77b777b77bbb77bbb77bbb777ffffffffffffffff545444d44d444545775bbbbbbbbbb577
bbbbbbbddbbbbbbb333bbbbbbbbbbbbbbbbb77777bbb77777bb777777bffffffffffffffffffffffffffffffffffffff4e5ee4d44d4ee5e477bbbbbbbbbbbb77
bbbbbbd33dbbbbbb2333bbbbbbbbbbbbbbb7777777b7777777b7777777ffffffffffffffffffffffffffffffffffffffee54eed44dee45ee77bbbbbbbbbbbb77
bbbbbb0220bbbbbbb333bbbbbbbbbbbbbbb7744477b7744477b7744477ffffffffffffffffffffffffffffffffffffffde4456666665e4ed77bbbbbbbbbbbb77
bbbbbd3223dbbbbbb333bbbbbbbbbb333bb77bbb77b77bbb44b77bbb77ffffffffffffffffffffffffffffffffffffffde45566ee66544ed77bbbbbbbbbbbb77
bbbbb020020bbbbbb333bbb33333bb333bb77bbb77b777777bb77bbb77ffffffffffffffffffffffffffffffffffffffde456665566544ed77bbbbbbbbbbbb77
bbbbd320023dbbbbb333bb333222bb3333377bbb77b4777777b77bbb77ffffffffffffffffffffffffffffffffffffffde455665566544ed777bbbbbbbbbb777
bbbb02077020bbbbb333bb233333bb3332277bbb77bb444477b77bbb77ffffffffffffffffffffffffffffffffffffffde4e5665566544ed7777bbbbbbbb7777
bbbd52077025dbbbb333bbb222333b333bb77bbb77b77bbb77b77bbb77ffffffffffffffffffffffffffffffffffffffde445665566554ed5777777777777775
bbb0602dd2060bbb33333b3333332b233337777777b7777777b7777777ffffffffffffffffffffffffffffffffffffffde445665566654ed0577777777777750
bbd3dd2002dd3dbb22222b2222222b222224777774b4777774b7777774ffffffffffffffffffffffffffffffffffffffde445666666554ed0055555555555500
bd027740047720db22222b222222bbb2222b44444bbb44444bb444444bffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000
d03266444466230d9111199999999999999999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00bbb000000000bb
d320d63dd36d023d1111119999999999999999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0bbbbbbbb00000bb
dd00d022220d00dd11b1119999999999999999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0bbbbbbbbbb00bbb
bdd0d3d00d3d0ddbbb91119999999999999111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbb0bbbb
bbbdd44dd44ddbbb99111b9999999999999111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbb0bbbb
66b66b66bbb66bbb9111b99111111999111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
66b66b66bbb66bbb111b999111b1119111b111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
66b66b6666b6666b1119999111911191119111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000bb000bbbb
66666b6655b66566111111911191119b111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbb00bbbbbbbbbbbb
55566b66bbb66b66bbbbbb9bbb9bbb99bbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
bbb66b5666b66b66b9999bbbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
bbb55bb555b55b55999999bbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
66666fffffffffff998899bbbbbbbbbbbbbbbbffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
66555fffffffffff88b999bbbbbbbbbbbbb999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
6666bfffffffffffbbb998bbbbbbbbbbbbb999ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbbbbbbbbbbbb
55566fffffffffffbbb899bb99999bbb999999ffffffffffffffffffffffffffffffffffbbbbbb777777bbbbbbbbbbbbb777777bbbbbbfffffffffffffffffff
bbb66fffffffffff99bb99b9998999b9998999ffffffffffffffffffffffffffffffffffbbbb77bbbbbb77bbbbbbbbb777bbbbb77bbbbfffffffffffffffffff
66665fffffffffff999999b999b999b999b999ffffffffffffffffffffffffffffffffffbbb77bbbbbbbbb7bbbbbbb77777bbbbbb7bbbfffffffffffffffffff
5555bfffffffffff899998b999b888b8999999ffffffffffffffffffffffffffffffffffbb7777bbbbbbbbb7bbbbb7bb777bbbbbbb7bbfffffffffffffffffff
b6666fffffffffffb8888bb888bbbbbb888888ffffffffffffffffffffffffffffffffffb77777bbbbbbbbbb7bbb7bbbbb7bbbbbbbb7bfffffffffffffffffff
66555999999dd999999fffffffffffffffffffffffffffffffffffffffffffffffffffffb7bbb77bbbbbbbbb7bbb7bbbbb7bbbbbbbb7bfffffffffffffffffff
6666b99999dccd99999fffffffffffffffffffffffffffffffffffffffffffffffffffff7bbbbbb7bbbbbbbbb7b7bbbbbbb7bbbbbbbb7fffffffffffffffffff
66566999990bb099999fffffffffffffffffffffffffffffffffffffffffffffffffffff7bbbbbbbbbbbbbbbb7b7bbbbbbbbbbbbbbbb7fffffffffffffffffff
66b669999dcbbcd9999fffffffffffffffffffffffffffffffffffffffffffffffffffff7bbbbbbbbbbbbbbbb7b7bbbbbbbbbbbbbbbb7fffffffffffffffffff
5666599990baab09999fffffffffffffffffffffffffffffffffffffffffffffffffffff7bbbbbbbbb7bbbbbb7b7bbbbbbbb7bbbbbbb7fffffffffffffffffff
b555b99d0abaaba0d99fffffffffffffffffffffffffffffffffffffffffffffffffffffb7bbbbbbbbb77bbb7bbb7bbbbbbbb7bbbbb7bfffffffffffffffffff
666669d775b77b577d9fffffffffffffffffffffffffffffffffffffffffffffffffffffb7bbbbbbbbbb77777bbb7bbbbbbbb7bbbbb7bfffffffffffffffffff
5556690664b77b46609fffffffffffffffffffffffffffffffffffffffffffffffffffffbb7bbbbbbbbbb777bbbbb7bbbbbbb777bb7bbfffffffffffffffffff
b6666dc764bddb467cdfffffffffffffffffffffffffffffffffffffffffffffffffffffbbb7bbbbbbbbb77bbbbbbb7bbbbbb77777bbbfffffffffffffffffff
66655db765a55a567bdfffffffffffffffffffffffffffffffffffffffffffffffffffffbbbb77bbbbbb77bbbbbbbbb77bbbbb777bbbbfffffffffffffffffff
665bbda550aaaa055adfffffffffffffffffffffffffffffffffffffffffffffffffffffbbbbbb777777bbbbbbbbbbbbb777777bbbbbbfffffffffffffffffff
66bbb9044ddaadd4409fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
55bbb99dddd55dddd99fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
b666b99999d77d99999fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
6656699990d66d09999fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
66666999d0b66b0d999fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
66566999daa44aad999fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
66b669990cddddc0999fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5666599990999909999fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
b555bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddbbbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffbbbbbbddbbbbbbbbbbbbbddbbbbbbbbbbbbd44dbbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
999dd999fffffffffbbbbbd44dbbbbbbbbbbbd44dbbbbbbbbbbbe44ebbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99d11d99fffffffffbbbbbe44ebbbbbbbbbbbe44ebbbbbbbbbbbe44ebbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
90abba09fffffffffbbbbd4444dbbbbbbbbbd4444dbbbbbbbbbbe44ebbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
9d5775d9fffffffffbbbbe4ee4ebbbbbbbbbe4ee4ebbbbbbbbbd4444dbbbbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d657756dfffffffffbbdde4ee4eddbbbbbbd44ee44dbbbbbddbe4ee4ebddbfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d7baab7dfffffffffbd4ed4774de4dbbbbbe4e77e4ebbbbde4dee77eed4edfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
9d0660d9fffffffffbe4ed4774de4ebbbbd44e77e44dbbbde4ed4774de4edfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
90a55a09fffffffffd444d4dd4d444dbbbe4e4dd4e4ebbbde44e4dd4e44edfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
99d00d99fffffffffde444e44e444edbbd4dd4ee4dd4dbbde44e4ee4e44edfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bbbddbbb777bbbbbbde44dedded44edbde4444ee4444edbd444de44ed444dfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bbd33dbb7bbbbbbbbbdeeddeeddeedbde444444444444edbe44d4444d44ebb7777bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bb0220bb77bb77bbbbbdddd44ddddbbd44ed44dd44de44dbde4e4dd4e4edb755557fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bd3ee3db7bb6b7bbbbbbbbd44dbbbbbddeede4444edeeddbde4edeede4edb7bbbb7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
b027720b7776b767bbbbbdd44ddbbbbbbded4deed4dedbbbbd4dbddbd4dbb5bbbb5fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
d3e77e3dbbb6b76b7bbbdd4444ddbbbbbbddeeddeeddbbbbbdedbbbbdedbb7bbbb7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
02700720bbb7b76b7bbbdee44eedbbbbbbbbbbbbbbbbbbbbbdedbbbbdedbb7bbbb7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
de6446edbbbbbb6b7bbbd4dddd4dbbbbbbbbbbbbbbbbbbbbbdedbbbbdedbb577775fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
b04dd40bbbbbbb777bbbbdbbbbdbbbbbbbbbbbbbbbbbbbbbbbdbbbbbbdbbbb5555bfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
__label__
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffdddd333dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffdddd2333ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddd333dddddddddddddddddd77777ddd777777d777777ddddd3333333333333333333333333333333333333333333333333dddddddffffffffff
ffffffffffddddd333dddddddddd333dddd7777777d7777777d7777777ddd333333333333333333333333333333333333333333333333333ddddddffffffffff
ffffffffffddddd333ddd33333dd333dddd7755577d7755555d7755577dd333ccccccccccccccccccccccccccccccccccccccccccccccc333dddddffffffffff
7000000077707770777077007770070077000770777077700700777077700700070000000ddddddddddddddddddddddddddddddddddddcc33dddddffffffffff
0700000070707070070070700700700070707000700007007000700070700070007000000dddddddddddddddddddddddddddddddddddddc33dddddffffffffff
0070000077707700070070700700700070707000770007007000777070700070007000000444d444d444d777d747d777d777d777d777ddc33dddddffffffffff
07000000700070700700707007007000707070707000070070000070707000700070000004d4d4d4d4d4d4d7d7d7d4d7d4d7d4d7d7d7ddc33dddddffffffffff
7000000070007070777070700700070077707770777007000700777077700700070000000444d444d444d477d777d477d777d447d747ddc33dddddffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000004d4d4d4d4d4d4d7d4d7d4d7d7d4d4d7d7d7ddc33dddddffffffffff
666fffffffdddddddddddddddddddddddddddddddddddddddddddddddddd33cdd444d444d444d444d444d777d447d777d777d447d777ddc33dddddffffffffff
6f6fffffffddddddddddddddddddddddddddddddddddddddddddddddddd333cdddddddddddddddddddddddddddddddddddddddddddddddc33dddddffffffffff
6f6fffffffddddddddddddddddddd333333333333333333333333333333333ccdddddddddddddddddddddddddddddddddddddddddddddcc33dddddffffffffff
6f6fffffffdddddddddddddddddd333333333333333333333333333333333cccccccccccccccccccccccccccccccccccccccccccccccccc33dddddffffffffff
666fffffffddddddddddddddddd333ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc33dddddffffffffff
ffffffffffddddddddddddddddd33cccccddccccccddddddddddddddddddddddccccdddddddddddddddddddddddddddddddddddddddddcc33dddddffffffffff
7000000077707770777077007770070077000770777077700700777077000700070000000dddddddddddddddddddddddddddddddddddddc33dddddffffffffff
0700000070707070070070700700700070707000700007007000700007000070007000000dddddddddddddddddddddddd777d777d774ddc33dddddffffffffff
0070000077707700070070700700700070707000770007007000777007000070007000000d77d7d7ddd7d7d777d777ddd7d7d7d7d474ddc33dddddffffffffff
07000000700070700700707007007000707070707000070070000070070000700070000007d7dd7dddd7d7dd7ddd7dddd777d777d474ddc33dddddffffffffff
7000000070007070777070700700070077707770777007000700777077700700070000000777dd7dddd777dd7ddd7dddd4d7d7d7d474ddc33dddddffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000007d7d7d7ddd7d7d777dd7dddd447d777d777ddc33dddddffffffffff
666fffffffddddddddddddddddd33ccde6446edccddddddddddddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddc33dddddffffffffff
6f6fffffffddddddddddddddddd33ccc04dd40ccccddddddddddddddddddddddccccdddddddddddddddddddddddddddddddddddddddddcc33dddddffffffffff
6f6fffffffddddddddddddddddd333cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc333dddddffffffffff
6f6fffffffddddddddddddddddd23333333333333333333333333333333333333333333333333333333333333333333333333333333333332dddddffffffffff
666fffffffddddddddddddddddd22333333333333333333333333333333333333333333333333333333333333333333333333333333333322dddddffffffffff
ffffffffffddddddddddddddddd22222222222222222222222222222222222222222222222222222222222222222222222222222222222222dddddffffffffff
70000000777077707770770077700700770007707770777007007770070007000000000002222222222222222222222222222222222222222dddddffffffffff
07000000707070700700707007007000707070007000070070007070007000700000000002222222222222222222222222222222222222222dddddffffffffff
0070000077707700070070700700700070707000770007007000707000700070000000000222222222222222222222222222222222222222ddddddffffffffff
070000007000707007007070070070007070707070000700700070700070007000000000022222222222222222222222222222222222222dddddddffffffffff
7000000070007070777070700700070077707770777007000700777007000700000000000dddddddddddddddddddddddddddddddddddddddddddddffffffffff
0000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddffffffffff
666fffff666d666d666d666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
6f6fffff6fdddd61116d6d6dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
6f6fffff666d6661166d666dddddddddddddd77777ddd77777dd77ddd77dddd1111111111111111111111111111111111111111111111111ddddddffffffffff
6f6fffffff6d611b116d6d6ddddddddddddd7777777d7777777d77ddd77ddd111111111111111111111111111111111111111111111111111dddddffffffffff
666ff6ff666d666d666d666ddddddddd11dd7755577d7755577d777d777dd111ccccccccccccccccccccccccccccccccccccccccccccccc111ddddffffffffff
ffffffffffddddd111bddddddddddddd11dd77ddd55d7777777d577d775dd11ccdddddddddddddddddddddddddddddddddddddddddddddcc11ddddffffffffff
7000000000000d111bdd111111ddd11111dd77dddddd7777777dd77777ddd11cdddddddddddddddddddddddddddddddddddddddddddddddc11ddddffffffffff
0700000000000111bddd111b111d111b11dd77ddd77d7755577dd57775ddd11cdd444d444d444d444d444d777d744d777d777d774d777ddc11ddddffffffffff
0070000000000111dddd111d111d111d11dd7777777d77ddd77ddd777dddd11cdd4d4d4d4d4d4d4d4d4d4d4d7d7d4d7d7d7d7d474d7d7ddc11ddddffffffffff
0700000000000111111d111d111db11111dd5777775d77ddd77ddd575dddd11cdd444d444d444d444d444d777d777d777d777d474d747ddc11ddddffffffffff
7000000000000bbbbbbdbbbdbbbddbbbbbddd55555dd55ddd55dddd5ddddd11cdd4d4d4d4d4d4d4d4d4d4d7d4d7d7d4d7d7d7d474d7d7ddc11ddddffffffffff
0000000000000dddddddddddddddddddddddddddddddddddddddddddddddd11cdd444d444d444d444d444d777d777d447d777d777d777ddc11ddddffffffffff
ffffffffffdddddddddddddddddddddddddddddddddddddddddddddddddd111cdddddddddddddddddddddddddddddddddddddddddddddddc11ddddffffffffff
ffffffffffdddddddddddddddddddd111111111111111111111111111111111ccdddddddddddddddddddddddddddddddddddddddddddddcc11ddddffffffffff
ffffffffffddddddddddddddddddd111111111111111111111111111111111cccccccccccccccccccccccccccccccccccccccccccccccccc11ddddffffffffff
ffffffffffdddddddddddddddddd111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11ddddffffffffff
ffffffffffdddddddddddddddddd11cccccddccccccddddddddddddddddddddddccccdddddddddddddddddddddddddddddddddddddddddcc11ddddffffffffff
ffffffffffdddddddddddddddddd11ccccd11dccccddddddddddddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddc11ddddffffffffff
ffffffffffdddddddddddddddddd11ccc0abba0cccddddddddddddddddddd774ddccdddddddddddddddddddddddddddddd444d777d777ddc11ddddffffffffff
ffffffffffdddddddddddddddddd11cccd5775dcccddd77d77dd777dd77dd474ddccdd777dd77d7d7ddd7d7d777d777ddd4d4d7d7d4d7ddc11ddddffffffffff
ffffffffffdddddddddddddddddd11ccd657756dccdd7d7d7d7d77dd7d7dd474ddccdd777d7d7dd7dddd7d7dd7ddd7dddd444d777d777ddc11ddddffffffffff
ffffffffffdddddddddddddddddd11ccd7baab7dccdd777d77dd7ddd777dd474ddccdd7d7d777dd7dddd777dd7ddd7dddd4d4d4d7d7d4ddc11ddddffffffffff
ffffffffffdddddddddddddddddd11cccd0660dcccdd7d7d7d7dd77d7d7dd777ddccdd7d7d7d7d7d7ddd7d7d777dd7dddd444d447d777ddc11ddddffffffffff
ffffffffffdddddddddddddddddd11ccc0a55a0cccddddddddddddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddc11ddddffffffffff
ffffffffffdddddddddddddddddd11ccccd00dcccccddddddddddddddddddddddccccdddddddddddddddddddddddddddddddddddddddddcc11ddddffffffffff
ffffffffffdddddddddddddddddd111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc111ddddffffffffff
ffffffffffddddddddddddddddddb111111111111111111111111111111111111111111111111111111111111111111111111111111111111bddddffffffffff
ffffffffffddddddddddddddddddbb1111111111111111111111111111111111111111111111111111111111111111111111111111111111bbddddffffffffff
ffffffffffddddddddddddddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddffffffffff
ffffffffffdddddddddddddddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbdddddffffffffff
ffffffffffddddddddddddddddddddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffdddd9999ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddd999999dddddddddddddddddd77777ddd777777dd77d77ddddd9999999999999999999999999999999999999999999999999ddddddffffffffff
ffffffffffddd998899ddddddddddddddddd7777777d7777777dd77d77dddd999999999999999999999999999999999999999999999999999dddddffffffffff
ffffffffffddd88d999ddddddddddddd99dd7755577d7755555d7777777dd999ccccccccccccccccccccccccccccccccccccccccccccccc999ddddffffffffff
ffffffffffdddddd998ddddddddddddd99dd7777777d777777dd7777777dd99ccdddddddddddddddddddddddddddddddddddddddddddddcc99ddddffffffffff
ffffffffffdddddd899dd99999ddd99999dd7777777d5777777d7757577dd99cdddddddddddddddddddddddddddddddddddddddddddddddc99ddddffffffffff
ffffffffffddd99dd99d9998999d999899dd7755577dd555577d77d5d77dd99cdd444d444d444d444d444d777d777d777d777d747d777ddc99ddddffffffffff
ffffffffffddd999999d999d999d999d99dd77ddd77d7777777d77ddd77dd99cdd4d4d4d4d4d4d4d4d4d4d4d7d7d7d4d7d4d7d7d7d7d7ddc99ddddffffffffff
ffffffffffddd899998d999d888d899999dd77ddd77d7777775d77ddd77dd99cdd444d444d444d444d444d777d747d777d777d777d747ddc99ddddffffffffff
ffffffffffdddd8888dd888dddddd88888dd55ddd55d555555dd55ddd55dd99cdd4d4d4d4d4d4d4d4d4d4d7d4d7d7d7d4d7d4d4d7d7d7ddc99ddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddd99cdd444d444d444d444d444d777d777d777d777d447d777ddc99ddddffffffffff
ffffffffffdddddddddddddddddddddddddddddddddddddddddddddddddd999cdddddddddddddddddddddddddddddddddddddddddddddddc99ddddffffffffff
ffffffffffdddddddddddddddddddd999999999999999999999999999999999ccdddddddddddddddddddddddddddddddddddddddddddddcc99ddddffffffffff
ffffffffffddddddddddddddddddd999999999999999999999999999999999cccccccccccccccccccccccccccccccccccccccccccccccccc99ddddffffffffff
ffffffffffdddddddddddddddddd999ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc99ddddffffffffff
ffffffffffdddddddddddddddddd99cccccddccccccddddddddddddddddddddddccccdddddddddddddddddddddddddddddddddddddddddcc99ddddffffffffff
ffffffffffdddddddddddddddddd99ccccd33dccccddddddddddddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddc99ddddffffffffff
ffffffffffdddddddddddddddddd99cccc0220ccccddddddddddddddddddd774ddccdddddddddddddddddddddddddddddd444d774d777ddc99ddddffffffffff
ffffffffffdddddddddddddddddd99cccd3ee3dcccddd77d77dd777dd77dd474ddccdd777dd77d7d7ddd7d7d777d777ddd4d4d474d7d7ddc99ddddffffffffff
ffffffffffdddddddddddddddddd99ccc027720cccdd7d7d7d7d77dd7d7dd474ddccdd777d7d7dd7dddd7d7dd7ddd7dddd444d474d747ddc99ddddffffffffff
ffffffffffdddddddddddddddddd99ccd3e77e3dccdd777d77dd7ddd777dd474ddccdd7d7d777dd7dddd777dd7ddd7dddd4d4d474d7d7ddc99ddddffffffffff
ffffffffffdddddddddddddddddd99cc02700720ccdd7d7d7d7dd77d7d7dd777ddccdd7d7d7d7d7d7ddd7d7d777dd7dddd444d777d777ddc99ddddffffffffff
ffffffffffdddddddddddddddddd99ccde6446edccddddddddddddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddc99ddddffffffffff
ffffffffffdddddddddddddddddd99ccc04dd40ccccddddddddddddddddddddddccccdddddddddddddddddddddddddddddddddddddddddcc99ddddffffffffff
ffffffffffdddddddddddddddddd999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc999ddddffffffffff
ffffffffffdddddddddddddddddd89999999999999999999999999999999999999999999999999999999999999999999999999999999999998ddddffffffffff
ffffffffffdddddddddddddddddd88999999999999999999999999999999999999999999999999999999999999999999999999999999999988ddddffffffffff
ffffffffffdddddddddddddddddd88888888888888888888888888888888888888888888888888888888888888888888888888888888888888ddddffffffffff
ffffffffffddddddddddddddddddd888888888888888888888888888888888888888888888888888888888888888888888888888888888888dddddffffffffff
ffffffffffdddddddddddddddddddd8888888888888888888888888888888888888888888888888888888888888888888888888888888888ddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddddddddddddddddddddddd66666666666666666666666666666666666666666666666666666666666666666666666666666ddddddffffffffff
ffffffffffdddddddddddddddddddddddd6666666666666666666666666666666666666666666666666666666666666666666666666666666dddddffffffffff
ffffffffffddddddddddddddddddddddd666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666ddddffffffffff
ffffffffffddddddddddddddddddddddd66cccccddccccccdddddddddddddccccdddddddddddddddddddddddddddddddddddddddddddddcc66ddddffffffffff
ffffffffffddddddddddddddddddddddd66ccccd11dccccdddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddddddc66ddddffffffffff
ffffffffffddddd66d66d66ddd66ddddd66ccc0abba0cccdd777d477d477ddccdd444d444d444d444d444d777d777d777d777d744d777ddc66ddddffffffffff
ffffffffffddddd66d66d66ddd66ddddd66cccd5775dcccdd474d7d4d7d7ddccdd4d4d4d4d4d4d4d4d4d4d4d7d7d7d7d7d7d7d7d4d7d7ddc66ddddffffffffff
ffffffffffddddd66d66d6666d6666ddd66ccd657756dccdd474d744d747ddccdd444d444d444d444d444d777d747d747d777d777d747ddc66ddddffffffffff
ffffffffffddddd66666d6655d66566dd66ccd7baab7dccdd474d7d7d7d7ddccdd4d4d4d4d4d4d4d4d4d4d7d4d7d7d7d7d7d7d7d7d7d7ddc66ddddffffffffff
ffffffffffddddd55566d66ddd66d66dd66cccd0660dcccdd474d777d774ddccdd444d444d444d444d444d777d777d777d777d777d777ddc66ddddffffffffff
ffffffffffdddddddd66d5666d66d66dd66ccc0a55a0cccdddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddddddc66ddddffffffffff
ffffffffffdddddddd55dd555d55d55dd66ccccd00dcccccdddddddddddddccccdddddddddddddddddddddddddddddddddddddddddddddcc66ddddffffffffff
ffffffffffddddddddddddddddddddddd666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666ddddffffffffff
ffffffffffddddddddddddddddddddddd566666666666666666666666666666666666666666666666666666666666666666666666666666665ddddffffffffff
ffffffffffddddddddddddddddddddddd556666666666666666666666666666666666666666666666666666666666666666666666666666655ddddffffffffff
ffffffffffdddddddddddddddddddddddd5555555555555555555555555555555555555555555555555555555555555555555555555555555dddddffffffffff
ffffffffffddddddddddddddddddddddddd55555555555555555555555555555555555555555555555555555555555555555555555555555ddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddffffffffff
ffffffffffddddddddddddddddddddddddd66666666666666666666666666666666666666666666666666666666666666666666666666666ddddddffffffffff
ffffffffffdddddddddddddddddddddddd6666666666666666666666666666666666666666666666666666666666666666666666666666666dddddffffffffff
ffffffffffddddddddddddddddddddddd666ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc666ddddffffffffff
ffffffffffddddddddddddddddddddddd66cccccddccccccdddddddddddddccccdddddddddddddddddddddddddddddddddddddddddddddcc66ddddffffffffff
ffffffffffddddddddddddddddddddddd66ccccd33dccccdddddddddddddddccdddddddddddddddddddddddddddddddddddddddddddddddc66ddddffffffffff
ffffffffffddddd66666d66ddd66ddddd66cccc0220ccccdd777d747d777ddccdd444d444d444d444d444d774d777d747d774d777d777ddc66ddddffffffffff

__map__
ff1f11fffdff11fffdff11ffdf1f22fffffd2f21fffdff3223ffdfff3223fffd21f1fd10f3ddddddddddddddddddddddddddddddddddddddddddddff0f11f0ffff2122f1fd1f22f7fd1f22f1df2133f1fffd3732f7fd3f7777f3df3f7777f31d32123d3707ddddddddddddddddddddddddddddddddddddddddddddff212212ff
1f323712fd3177f2fd2f37f2df327713ff2d737323fd73233237df722332272d33231d7313dddddddddddddddddddddddddddddddddddddddddddd1f323323f121737712fd7237f1fd3f77f3df327737f11d3237122d37122173d2731221371d32120d3737dddddddddddddddddddddddddddddddddddddddddddd2003113002
21773712fd2712fffd3f77f3df1f7377232d7373233d27011072d373122137fd21f1fd13f0dddddddddddddddddddddddddddddddddddddddddddd2113113112217323f1fd1ff1fffd2f73f2dfff317723fd3732f73d27011072d372233227fd32f2fd13f1dddddddddddddddddddddddddddddddddddddddddddd2113113112
1f2212fffdfffffffd1f22f1dfff1f3312fd2f21ff2d37122173d23f7777f32d73231d2333dddddddddddddddddddddddddddddddddddddddddddd2003113002ff11f1fffd2127f1fdff11ffdfffff22f1fd0f01fffd73233237dfff3223ff3d77371d2212dddddddddddddddddddddddddddddddddddddddddddd1f323323f1
ff0ff0ff1d323712fdffffffdfff1012f0fd2022f0fd3f7777f3dfff2112ff2d73233d2313ddddddddddddddddddddddddddddddddddddddddddddff212212ff0f1001f01d323712fdff1f01dfff2123f11d323712fdff3223ffdf2f7777f2fd32f2fd11f3ddddddddddddddddddddddddddddddddddddddddddddff0f11f0ff
10211201fd2127f1fdff2201df0f3237023d777737fdff2112ffdf71122117fd73f3fd32f1dddddddddddddddddddddddddddddddddddddddddddddddddddddd20333302fdfffffffd2f33f1df0f3237021d323712fd2f7777f2df720110273d27371d3020dddddddddddddddddddddddddddddddddddddddddddddddddddddd
20333302fd1ff1fffd1f33f2df0f323702fd2022f0fd72122127df720110277d22723d7333dddddddddddddddddddddddddddddddddddddddddddddddddddddd10211201fd2712fffd1022ffdf0f323702fd0f01ff1d27011072d1711221173d27372d3010dddddddddddddddddddddddddddddddddddddddddddddddddddddd
0f1001f0fd7237f1fd10f1ffdfff2123f1fd0f21ff2d17000071d22f7777f2fd73f3fd31f2ddddddddddddddddddddddddddddddddddddddddddddddddddddddff0ff0fffd3177f2fdffffffdfff1012f0fd2032f72d17000071d2ff2112fffd23f3fd31f3dddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff11f1fffd1f22f7fdffffffdfffff22f10d3277231d27011072d1ff1001ff3d12323d2717dddddddddddddddddddddddddddddddddddddddddddddddddddddd1f2212fffdff11fffdffffffdfff1f33121d727712fd72122127df1f3333f12d11213d7232dddddddddddddddddddddddddddddddddddddddddddddddddddddd
217323f1fd1f13fffd213312dfff3177230d733702fd2f7777f2df301221033d12321d2737dddddddddddddddddddddddddddddddddddddddddddddddddddddd21773712fd2127f11d327727d11f737723fd3722f0fdff2112ffdf31311313fd23f3fd33f1dddddddddddddddddddddddddddddddddddddddddddddddddddddd
21737712fd3237f21d727723d1327737f1fd2f11fffdff1001ffdf31311313dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1f323712fd3237f2fd213312df327713fffd1f13fffd1f3333f1df30122103dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff2122f1fd2127f1fdffffffdf2133f1fffd2027f0fd31022013df1f3333f1ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddff1f11fffd1f13fffdffffffdf1f22ffff0d3237020d23100132d0ff1001ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff0000ffddddddddfdffffffdfffffffff1d7277121d03311330d1ff1001ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0f2112f0ddddddddfd21f2ffdfff0000ff0d3237021d03311330d11f2222f1dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
0f7117f0ddddddddfd2133ffdf10211201fd2027f00d23100132d020377302dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd10722701ddddddddfd2f77f3df21722712fd1f13fffd31022013df21233212dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
10722701ddddddddfd3f77f2df72777727ddddddddfd1f3333f1df21233212dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0f7117f0ddddddddfdff3312df21722712ddddddddfdff1dd1ffdf20377302dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
0f2112f0ddddddddfdff2f12df10211201dddddddddddddddddddd1f2222f1ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddff0000ffddddddddfdffffffdfff0000ffddddddddddddddddddddff1001ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff111fffdff1227fdffffffffdffff221fd0237732d1721001271dff0110ffd32123d37271dddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f12221ffdfff11ffdffffffffdfff13321d1277721df27211272fdf133331fd21112d32723dddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1237321fdff131ffdf123321fdff137732d0377320dff277772ffd03211230d32123d17273dddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12777321df12721fd12377721df1377732df73220fdfff1221fffd13133131df323fdf331fdddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
12377721df23732fd12777321d2377731fdff211ffdfff0110fffd13133131dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f1237321df23732fdf123321fd237731ffdff131ffdff133331ffd03211230dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff12221fdf12721fdffffffffd12331fffdf02720fdf13200231fdf133331fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff111ffdff131ffdffffffffdf122ffffd0237320d0320110230dff0110ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0000ffdddddddddffffffffdffffffffd1277721d1301331031dff0110ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f012210fdddddddddf122ffffdff0000ffd0237320d1301331031df122221fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f017710fdddddddddf1233fffd01122110df02720fd0320110230d02733720dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01277210dddddddddff2773ffd12277221dff131ffdf13200231fd12322321dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01277210dddddddddff3772ffd27777772dddddddddff133331ffd12322321dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f017710fdddddddddfff3321fd12277221dddddddddfff0110fffd02733720dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f012210fdddddddddffff221fd01122110dddddddddfff0110fffdf122221fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ff0000ffdddddddddffffffffdff0000ffddddddddddddddddddddff0110ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a51018000404304014040350405504015040350962504015040350405504015040350404304014040350405504015040350262504015040350405504015060341000510005100051000512005100050000500000
9d1018000704307014070350705507015070350762507015070350705507015070350604306014060350605506015060350662506015060330605306015020341300510005100051000510005000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000d010160201d0302104024050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000472005731067410c75110761137610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000b6240b634100140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 08424344
00 08424344
02 09424344

