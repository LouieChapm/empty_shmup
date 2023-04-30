pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

bg_col=13
ln_col=5

-- things to make the numbers nicer
dtime=1/60
speed_offset=0.25 -- added to speed so that I can stick to using small number s;):):):):)
rot_offset=0.01

show_ui=true

debug=""
debug_time=0

types=split"init,tspd,tdir,wait,goto"
numbers=split("0,1,2,3,4,5,6,7,8,9,-,.",",",false)
#include info_path_editor.txt
#include inf_sprites.txt
#include inf_patterns.txt
#include inf_crumbs.txt

#include ../src/bulfuncs.lua
#include ../src/sprfuncs.lua

function my_menu_item(b)
    if(b&1 > 0) game_rank=mid(1,game_rank-1,3) 
    if(b&2 > 0) game_rank=mid(1,game_rank+1,3)
	menuitem(_,"⬅️ rank:"..game_rank.." ➡️")
    return true -- stay open
end

function _init()
	t=0
	temp=""

	game_rank=2


	shot_info=split"spawn frame,rank binary,shot index,direction"
	inst_info=split_split("init direction,init speed|target speed,accel rate|target direction,turn rate|wait duration,does nothing|goto index,does nothing")


	menuitem(1, "export data", function() export_data() end)
	menuitem(2, "⬅️ rank:2 ➡️", my_menu_item)

	init_sprfuncs(spr_library, anim_library)
	init_bulfuncs(bul_library)

	crumbs_list={}
	for data in all(parse_data(crumb_lib)) do
		path={}
		for i=2,#data,2 do
			add(path,{data[i],data[i+1]})
		end
		add(crumbs_list,path)
	end

	editor_library=parse_info_editor(editor_path_library)


	poke(0x5f2d, 1)
	reset_info=false
	
	nav={
		vert=0,
		hori=1,

		mode="select",
		lib_index=1,
	}
	is_depth_type=false
	cur_data={}
	update_cur_data()

	-- start recording straight away if you want
	if(crumbs_list[nav.lib_index<3])new_crumbs()

	
	
	pal({[0]=140,1,2,3,4,5,6,7,8,9,10,138,12,13,139,136},1)
	palt(0,false)
	
	init_player()

	init_enem()
	save_state=copy(enem)
	calc_vehicle=true
	

	enem.x,enem.y=spawn_x,spawn_y

	cscroll=0
end


function _update60()
	t+=1
	cscroll+=0.25

	update_input()
	upd_bulfuncs()

	if(calc_vehicle)update_reader()
	if(calc_vehicle)update_enem()



	if(debug_time>=0)debug_time-=1
	if(debug_time==0)debug=""
end


function _draw()
	cls(bg_col)
	draw_bg()

	draw_crumbs()

	sspr_obj(1,enem.x,enem.y)
	local x,y=enem.x,enem.y
	local tx,ty=sin(enem.dir),cos(enem.dir)
	local dist=10
	x,y=x+(tx*dist)+0.5,y+(ty*dist)+0.5
	line(x,y,x+(tx*enem.spd*1),y+(ty*enem.spd*1),11)

	drw_bulfuncs()

	if(show_ui)draw_information()

	printbg(debug,127-(#tostring(debug)*4),121,7)
end


-->8
-- init

function init_player()
	player={
		x=63,
		y=118,
	}
end

function init_enem()
	enem={
		x=63,
		y=-16,
		
		dir=1,
		ddir=0,
		tdir=0,

		spd=1,
		dspd=0,
		tspd=0,

		step=1,
		wait_time=0,
		frame=0,

		shot_step=1,
	}
end
-->8
-- upd

function update_enem()	
	enem.frame+=1

	if(do_record and (t-crumb_frame)%cur_data[2][1]==0)add(crumbs,{enem.x-spawn_x,enem.y-spawn_y})

	enem_update_dir()
	enem_update_spd()
	
	enem_update_shots()


	local tx,ty=sin(enem.dir),cos(enem.dir)
	local dx,dy=tx*enem.spd,ty*enem.spd

	enem.x+=dx*speed_offset
	enem.y+=dy*speed_offset
	
	if(enem.y>150 or enem.y<-40 or enem.x<-20 or enem.x>150)reset_vehicle()
end


function update_input()
	local had_input=stat(30)
	local char = had_input and stat(31) or nil

	if(char=="\t")show_ui = not show_ui

	local mode=nav.mode
	if mode=="select" then
		if btnp(⬆️) then 
			nav.vert-=1
			if(reset_info)reset_vehicle(true)
		end
		if btnp(⬇️) then
			if(nav.lib_index==#editor_library+1 and nav.vert==-1)new_instruction()

			nav.vert+=1
			if(reset_info)reset_vehicle(true)
		end

		if nav.is_setup then
			nav.vert=mid(0,nav.vert,2)

			if btnp(🅾️) then
				nav.is_setup=false
				return
			end

			if btnp(❎) then
				if nav.vert==0 then
					nav.is_setup=false
					return
				end
			end

		elseif nav.hori<4 then
			nav.vert=mid(-1,nav.vert,#cur_data[3]+2)
		else
			nav.vert=mid(-1,nav.vert,#cur_data[1]+2)
		end

		if nav.is_setup then
			if nav.vert>=1 then
				if(btnp(⬅️))cur_data[2][nav.vert==1 and 2 or 3]-=5
				if(btnp(➡️))cur_data[2][nav.vert==1 and 2 or 3]+=5

				if(btnp(⬅️) or btnp(➡️))spawn_x,spawn_y=cur_data[2][2],cur_data[2][3]reset_vehicle(true)
			end
		elseif nav.vert==-1 then
			local temp=nav.lib_index+(#editor_library+1)-1
			if(btnp(⬅️))temp-=1
			if(btnp(➡️))temp+=1



			nav.lib_index=temp%(#editor_library+1)+1 -- todo might be broken i dunno
			update_cur_data()

			if(btnp(⬅️) or btnp(➡️))new_vehicle()
		elseif nav.vert==0 then
			if btnp(❎) then
				nav.is_setup=true
			end
		else
			if btnp(⬅️) then 
				nav.hori-=1
				if(nav.hori>3 and nav.vert>=#cur_data[1]+1)nav.hori=3

				-- ignore
				if nav.hori<4 then
					nav.vert=mid(0,nav.vert,#cur_data[3]+1)
				else
					nav.vert=mid(0,nav.vert,#cur_data[1]+1)
				end

				if(reset_info)reset_vehicle(true)
			end
			if btnp(➡️) then
				nav.hori+=1
				if(nav.hori<4 and nav.vert>=#cur_data[3]+1)nav.hori=4
				
				-- ignore
				if nav.hori<4 then
					nav.vert=mid(0,nav.vert,#cur_data[3]+1)
				else
					nav.vert=mid(0,nav.vert,#cur_data[1]+1)
				end
				if(reset_info)reset_vehicle(true)
			end
			nav.hori=mid(1,nav.hori,7)

			if char=="\b" then
				if(nav.hori<4)del(editor_library[nav.lib_index][3],editor_library[nav.lib_index][3][nav.vert])
				if(nav.hori>3)del(editor_library[nav.lib_index][1],editor_library[nav.lib_index][1][nav.vert])
				update_cur_data()
				reset_vehicle(true)
				return
			end

			-- if you press 'x' then change mode to type
			if btnp(❎) then
				-- add new instruction
				if nav.hori<4 and nav.vert==#cur_data[3]+1 then
					add(cur_data[3],{"init",1,1})
					return
				elseif nav.hori>3 and nav.vert==#cur_data[1]+1 then
					-- frame , rank , type , direction
					add(cur_data[1],{60,1,1,-1})
					return
				end

				-- if its the depth mode thing
				if nav.hori<4 and nav.vert==#cur_data[3]+2 or nav.hori>3 and nav.vert==#cur_data[1]+2 then
					is_depth_type=true
					nav.mode="type"
					temp=""
					return
				end

				if nav.hori>1 then
					nav.mode="type"
					temp=""
					return
				end

				local type_index=index_in_list(types,cur_data[3][nav.vert][1])+#types
				cur_data[3][nav.vert][1]=types[(type_index%#types+1)]
				reset_info=true
			elseif nav.hori==1 and btnp(🅾️) then
				local type_index=index_in_list(types,cur_data[3][nav.vert][1])+#types-2
				cur_data[3][nav.vert][1]=types[(type_index%#types+1)]
				reset_info=true
			end
		end
	elseif mode=="type" then
		if(not had_input) return

		if(char=="p")poke(0x5f30,1) -- ignore pause

		if(char=="\b")temp=sub(temp,1,#tostring(temp)-1) return

		if char=="\r" then
			poke(0x5f30,1)  -- ignore pause
			

			nav.mode="select"

			if is_depth_type then
				editor_library[nav.lib_index][2][1]=temp
				is_depth_type=false
				reset_vehicle(true)
				return
			end

			--editor_library[nav.lib_index][nav.vert][3][nav.hori]=tonum(temp)
			if nav.hori<4 then
				editor_library[nav.lib_index][3][nav.vert][nav.hori]=tonum(temp)
			else
				editor_library[nav.lib_index][1][nav.vert][nav.hori-3]=tonum(temp)
			end

			reset_vehicle(true)
			return
		end

		if is_in_list(numbers,char) then
			temp..=char
		end 
	end
end


-->8
-- drw

function draw_information()
	local x=2
	local y=20

	draw_module("⬅️ path #"..nav.lib_index.." ➡️",x,2,nav.vert==-1)

	if nav.is_setup then
		local text="spawn x:"..cur_data[2][2]
		if(nav.vert==1)text="⬅️ "..text.." ➡️"
		draw_module(text, 2,y+7,nav.vert==1)

		local text="spawn y:"..cur_data[2][3]
		if(nav.vert==2)text="⬅️ "..text.." ➡️"
		draw_module(text, 2,y+14,nav.vert==2)
	else
		local inst=cur_data[3]
		for i=1, #inst do
			local _x=x

			local selected=nav.vert==i and nav.hori==1
			local text=inst[i][1]
			if enem.step==i+1 and enem.step<=#inst then
				text="|"..text
			end
			draw_module(text,_x,y+i*8,selected)

			if enem.step==i+1 and enem.step<=#inst then
				_x+=4
			end
			
			local selected=nav.vert==i and nav.hori==2
			local text2=nav.mode=="type" and selected and temp or inst[i][2]
			draw_module(text2,_x+18,y+i*8,selected)

			local selected=nav.vert==i and nav.hori==3
			local text3=nav.mode=="type" and selected and temp or inst[i][3]
			draw_module(text3,_x+20+#tostring(text2)*4,y+i*8,selected)
		end

		if nav.lib_index<#editor_library+1 then
			draw_module(" + ",x,y+(#inst+1)*8,nav.hori<4 and nav.vert==#inst+1)
		end
	end

	local shots=cur_data[1]
	local rx=127
	for i=1,#shots do
		local _x=rx

		local selected=nav.vert==i and nav.hori==7
		local text4=nav.mode=="type" and selected and temp or shots[i][4]
		_x-=#tostring(text4)*4 -- offset
		draw_module(text4,_x,y+i*8,selected)

		local selected=nav.vert==i and nav.hori==6
		local text3=nav.mode=="type" and selected and temp or shots[i][3]
		_x-=#tostring(text3)*4+2 -- offset
		draw_module(text3,_x,y+i*8,selected)

		local selected=nav.vert==i and nav.hori==5
		local text2=nav.mode=="type" and selected and temp or shots[i][2]
		_x-=#tostring(text2)*4+2 -- offset
		draw_module(text2,_x,y+i*8,selected)

		local selected=nav.vert==i and nav.hori==4
		local text1=nav.mode=="type" and selected and temp or shots[i][1]
		_x-=#tostring(text1)*4+2 -- offset
		draw_module(text1,_x,y+i*8,selected)
	end

	if nav.lib_index<#editor_library+1 then
		draw_module(" + ",rx-12,y+(#shots+1)*8,nav.hori>3 and nav.vert==#shots+1)
	end


	local text=is_depth_type and "depth: "..temp or "depth: "..cur_data[2][1]
	local selected=nav.hori<4 and nav.vert>#cur_data[3]+1 or nav.hori>3 and nav.vert>#cur_data[1]+1
	draw_module(text, 64-(#text*4)*0.5, 121,selected)


	if nav.vert>=1 and nav.hori>3 and nav.vert<=#cur_data[1] then
		local text=shot_info[nav.hori-3]
		draw_module(text, 127-#text*4,2,false)
	end

	if nav.vert>=1 and nav.hori<4 and nav.vert<=#cur_data[3] and nav.hori>1 then
		local index=index_in_list(types,cur_data[3][nav.vert][1])
		local text=inst_info[index][nav.hori-1]
		draw_module(text, 127-#text*4,2,false)
	end

	local text="setup"
	if(nav.lib_index==#editor_library+1)text="{empty}"
	draw_module(text, 2,10,nav.vert==0)
end

function draw_module(_text,_x,_y,_is_on)
	printbg(_text,_x,_y,_is_on and 5+(t\10)%3 or 7)
end

function printbg(text,x,y,c)
	print("\#1"..tostring(text),x,y,c or 7)
end

function draw_bg()
	local gap=16
	local ypos=cscroll
	
	fillp(▥)
	for y=ypos%16,128,gap do
		line(0,y,128,y,ln_col)
	end
	fillp()
	
	for x=0,128,gap do
		for y=cscroll%2,128,2 do
			pset(x,y,ln_col)
		end
	end
end


function draw_crumbs()
	local list=do_record and crumbs or crumbs_list[nav.lib_index]
	
	if(#list<=1)return

	for crumb in all(list) do
		local x,y=unpack(crumb)
		x+=spawn_x
		y+=spawn_y
		rect(x,y,x+1,y+1,2)
	end
end


-->8
-- data handling

function new_crumbs()
	crumbs={}
	do_record=true
	crumb_frame=t
end

function new_instruction()
	add(editor_library,{{},{15,63,-16},{}})

	debug="new instruction"
	debug_time=60

	add(crumbs_list,{})
end

function split_split(_list)
	local out={}
	for item in all(split(_list,"|")) do
		add(out,split(item))
	end
	return out
end


function split_split(_list)
	local out={}
	for item in all(split(_list,"|")) do
		add(out,split(item))
	end
	return out
end


function sgn0(_v)
	return _v==0 and 0 or sgn(_v)
end

function copy(tab)
 local new={}
 for k,v in pairs(tab) do
  new[k]=v
 end
 return new
end

function is_in_list(_list,_thing)
	for item in all(_list) do
		if(item==_thing)return true
	end
	return false
end

function index_in_list(_list, _thing)
	for index=1,#_list do
		if(_list[index]==_thing)return index
	end
	return nil
end

function update_cur_data()
	cur_data=editor_library[nav.lib_index] or {{},{15,63,-16},{}}
	spawn_x,spawn_y=cur_data[2][2],cur_data[2][3]
end

--[[

	5,30,-1,10,25,0.5|5|init,1,10,tspd,-10,-0.5,tdir,1,0.1

	-- shots
	-- depth
	-- instructions

--]]

function parse_info_editor(_rawdata)
	local out={}

	for dataset in all(split(_rawdata,"\n")) do
		local data_raw=split(dataset,"|")

		if #data_raw>1 then
			local data={{},split(data_raw[2]),{}}

			local shot_data=split(data_raw[1])
			if shot_data[1]!="" then
				for i=1,#shot_data,4 do
					-- frame , rank , type , direction
					local shot={shot_data[i],shot_data[i+1],shot_data[i+2], shot_data[i+3]}
					add(data[1],shot)
				end
			end

			local path_data=split(data_raw[3])
			if path_data[1]!="" then
				for i=1,#path_data,3 do
					local path={path_data[i],path_data[i+1],path_data[i+2]}
					add(data[3],path)
				end
			end
			add(out,data)
		else
			add(out,{{},10,{}})
		end

		add(crumbs_list,{})
	end

	add(crumbs_list,{}) -- a cute little last one just for hmm-ing
	return out
end

function parse_data(_data)
	local out={}
	for step in all(split(_data,"|")) do
		add(out,split(step))
	end
	return out
end

function export_data()
	local out="editor_path_library=[["
	for n=1,#editor_library do
		local dataset=editor_library[n]
		-- do shots
		for i=1,#dataset[1] do
			local shot=dataset[1][i]
			out..=shot[1]..","..shot[2]..","..shot[3]..","..shot[4]
			if(i<#dataset[1])out..=","
		end

		-- do depth
		out..="|"
		local dat=dataset[2]
		out..=dat[1]..","..dat[2]..","..dat[3]
		out..="|"

		-- do instructions
		for i=1,#dataset[3] do
			local inst=dataset[3][i]
			out..=inst[1]..","..inst[2]..","..inst[3]
			if(i<#dataset[3])out..=","
		end

		if(n<#editor_library)out..="\n"
	end
	out..="]]"

	printh(out)
	printh(out, "info_path_editor.txt", true)

	export_crumbs()
end

function export_crumbs()
	local out="crumb_lib=[["

	for n=1,#editor_library do
		local crumb_set=crumbs_list[n]

		out..=editor_library[n][2][1]..","
		for point in all(crumb_set) do
			local p1,p2=point[1],point[2]
			p1=flr(p1)
			p2=flr(p2)

			out..=p1..","..p2
			if(point!=crumb_set[#crumb_set])out..=","
		end

		if(n<=#editor_library-1)out..="|"
	end

	out..="]]\nshot_lib=[["
	
	-- shots
	for n=1,#editor_library do
		local dataset=editor_library[n]
		-- do shots
		for i=1,#dataset[1] do
			local shot=dataset[1][i]
			out..=shot[1]..","..shot[2]..","..shot[3]..","..shot[4]
			if(i<#dataset[1])out..=","
		end
		if(n<#editor_library)out..="|"
	end

	out..="]]"

	printh(out, "inf_crumbs.txt", true)
end

-->8
-- movement handling
function reset_vehicle(_new_recording)
	reset_info=false

	enem=copy(save_state)

	enem.step=1
	enem.frame=0


	if _new_recording then
		new_crumbs()
	elseif do_record then
		crumbs_list[nav.lib_index]=crumbs
		do_record=false
	end


	enem.x,enem.y=spawn_x,spawn_y
end

function new_vehicle()


	update_cur_data()
	init_enem()

	buls={}
	spawners={}


	crumbs={}
	if(#crumbs_list[nav.lib_index]==0)new_crumbs()
	do_record=#crumbs_list[nav.lib_index]==0

	--debug=#crumbs_list[nav.lib_index]

	--debug=tostring(do_record)..t


	enem.x,enem.y=spawn_x,spawn_y
end

function update_reader()
	-- if there's a wait time then just hang fire pls
	if enem.wait_time>0 then 
		enem.wait_time-=1 
		goto escape_reader
	end

	local inst=cur_data[3]

	while enem.step<=#inst do
		local is_pause=do_action(inst[enem.step])

		enem.step+=1

		if is_pause then
			goto escape_reader
		end
	end

	::escape_reader::
end


function do_action(_instruction)
	local type,para_a,para_b=unpack(_instruction)
	para_a=tonum(para_a)
	para_b=tonum(para_b)

	if(para_a=="" or para_a==nil)para_a=0
	if(para_b=="" or para_b==nil)para_b=0

	if type=="init" then
		enem.dir=para_a
		enem.spd=para_b
	end

	if type=="wait" then
		enem.wait_time=para_a
		return true
	end

	if type=="tdir" then
		enem.tdir=para_a
		enem.ddir=para_b
	end

	if type=="tspd" then
		enem.tspd=para_a
		enem.dspd=para_b
	end

	if type=="goto" then
		enem.step=para_a
	end
end

function enem_update_spd()
	local original_spd=enem.spd
	enem.spd+=enem.dspd*speed_offset

	-- change speed only when there is a target
	if enem.dspd!=0 then
		if sgn0(enem.dspd)==1 then
			local target=enem.tspd
			if enem.spd > target then
				enem.spd = enem.tspd
				enem.dspd = 0
			end
		elseif sgn0(enem.dspd)==-1 then
			local target=enem.tspd
			if enem.spd < target then
				enem.spd = enem.tspd
				enem.dspd = 0
			end
		end
	end
end

function enem_update_dir()
	local original_dir=enem.dir
	enem.dir=(enem.dir+enem.ddir*dtime)%1
	if enem.tdir!=-1 then
		if enem.tdir==0 or enem.tdir==1 then
			if ((original_dir)\1!=(original_dir+(enem.ddir*dtime))\1) then
				enem.dir = enem.tdir
				enem.ddir = 0
			end
		elseif sgn0(enem.ddir)==1 then
			local target=enem.tdir
			if(original_dir>target)target+=1
			if enem.dir > target then
				enem.dir = enem.tdir
				enem.ddir = 0
			end
		elseif sgn0(enem.ddir)==-1 then
			local target=enem.tdir
			if(original_dir<target)target-=1
			if enem.dir < target then
				enem.dir = target
				enem.ddir = 0
			end
		end
	end
end

function enem_update_shots()
	local fr=enem.frame
	local step=enem.shot_step
	local shot_data=cur_data[1]

	if(enem.shot_step>#shot_data)return

	if enem.frame>shot_data[enem.shot_step][1] then
		local frame,rank,type,direction=unpack(shot_data[step])
		local origin=enem
		if(type<0)origin={x=enem.x,y=enem.y}
		create_spawner(abs(type),origin,direction)
		enem.shot_step+=1
	end

	-- get shot at current step

end
__gfx__
000000006666666666666666666666660111151000000000000000000ddddddd0000000000000000000000000000000000000000000000000000000000000000
000000006666666666666666666666665151151100000000000000000ddddddd0000000000000000000000000000000000000000000000000000000000000000
0070070066777777777777777777776615111d211000000000000555dddddddd0000000000000000000000000000000000000000000000000000000000000000
0007700066777777777777777777776655511d121122222222222d5ddddddddd0000000000000000000000000000000000000000000000000000000000000000
0007700066776666666666666666776655511d2121242424242425d5dddddddd0000000000000000000000000000000000000000000000000000000000000000
0070070066776666666666666666776655511d2212424242424246d6dddddddd0000000000000000000000000000000000000000000000000000000000000000
00000000667766666666666666667766555117222149494949494d7dd555555d0000000000000000000000000000000000000000000000000000000000000000
00000000667767777777777777767766555117222294949494944676d55555550000000000000000000000000000000000000000000000000000000000000000
0000000066776777777777777776776655511722229999999977467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000667767777777777777767766555117d2229999997777467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000667766666666666666667766555117dd229999777777467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555117ddd29977777777467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555117dddd7777777777467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555117dddd7777777779467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555117dddd7777777999467d000000000000000000000000000000000000000000000000000000000000000000000000
000000006677667766776677777777665551172ddd7777799999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000066777777777777777777776655511722dd7779999999467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555117222d7999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000066776677667766777777776655511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000066777777777777777777776655511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000066777777777777777777776655511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000066776677667766777777776655511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000066777777777777777777776655511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000066777777777777777777776655511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000055511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000055511722229999999999467d000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000011000000000000110000000000000100000000000000044444344434444000440000044000440000000444aa44444444444001100001100001100000000
00001aa100000000001aa1000000000001a0000000000000004444434442444400477400047740477400000044aaaa4444444444017710017710017710000000
000019910000000000199200000000000290000000000000004444434442444400477400047740477400000044aaaa4444477444116611116611116611000000
0001a9991000000001a99910000000001a9000000000000000443443444444440047740009779047740000004aa7aaa4444774441aaaa119aaa11aaaa1000000
00019449200000000294492000000000294000000000000000433431244444440097790009779097790000004aa7aaa444777744199991149991199991000000
00019229410000001a92299200000001a92000000000000000433211244444430497794009779097790000004aa77aa444777744194d1114999114dd41000000
001a47749a0000002947749d10000002947000000000000000441111244444240497794047777497790000004aa77aa444777744196611149991146641000000
0019477419100001d94774461000001d9470000000000000003411112244424449777794477774977900000044a7aa4444477444199991149991199991000000
0014911179a1000264911911a1000026491000000000000000311111222444449977779997777997790000000000000000000000144441144441144441000000
01a11227699a101a11922917921001a119200000000000000041111112244434999779999777799779000000000000000000000011dd1111dd1111dd11000000
01975445649a1129775445769a201297754000000000000000421111122442449797797997777999990000000000000000000000015510015510015510000000
1a465555924111a46655556149a12a96655000000000000000441111112444449797797997777999990000000000000000000000001100001100001100000000
1941a11a4211019416a11a412411a9416a1000000000000000444111114444449777777999779999990000000000000000000000000000000000000000000000
14214999a1100142149999a121111421499000000000000000444411144444449977779999779999990000000000000000000000000000000000000000000000
1121a241510001121a14415110001121a14000000000000000000000000000000977779009999099990000000000000000000000000000000000000000000000
00115515100000011551151100000011551000000000000000000000000000000099990000990009900000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000044440044440000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000047740047740000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000047740047740000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000497794097790000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000477774497794000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000977779477774000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000977779977779000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000977779977779000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000997799977779000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000097790097790000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55533355555335555533335500000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
553eee35533ee33553ebbe3500000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
53eb7be33eebbee353e77e350000000055522555555ff555555885555554455555599555555aa555000000000000000000000000000000000000000000000000
3eb777e33b7777b33eb77be300000000552ff25555f88f555582285555499455559aa95555a44a55000000000000000000000000000000000000000000000000
3e777be33b7777b33eb77be300000000552ff25555f88f555582285555499455559aa95555a44a55000000000000000000000000000000000000000000000000
3eb7be353eebbee353e77e350000000055522555555ff555555885555554455555599555555aa555000000000000000000000000000000000000000000000000
53eee355533ee33553ebbe3500000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
55333555555335555533335500000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
55511155555115555511115500000000555335555553355555533555551111555511115555111155000000000000000000000000000000000000000000000000
5510001551100115510cc01500000000553bb355553ee355553333555100001551cccc1551cccc15000000000000000000000000000000000000000000000000
510c7c01100cc001510770150000000055e77e5555ebbe55553bb355100cc0011cc00cc11c0000c1000000000000000000000000000000000000000000000000
10c777011c7777c110c77c010000000055e77e5555e77e5555e77e5510c00c011c0000c11c0000c1000000000000000000000000000000000000000000000000
10777c011c7777c110c77c010000000055e77e5555e77e5555e77e5510c00c011c0000c11c0000c1000000000000000000000000000000000000000000000000
10c7c015100cc001510770150000000055e77e5555ebbe55553bb355100cc0011cc00cc11c0000c1000000000000000000000000000000000000000000000000
5100015551100115510cc01500000000553bb355553ee355553333555100001551cccc1551cccc15000000000000000000000000000000000000000000000000
55111555555115555511115500000000555335555553355555533555551111555511115555111155000000000000000000000000000000000000000000000000
55522255555225555522225500000000555501001c7777c111000000000000000000000000000000000000000000000000000000000000000000000000000000
552fff25522ff22552f88f2500000000555c7000100000010c000000000000000000000000000000000000000000000000000000000000000000000000000000
52f878f22ff88ff252f77f250000000055c705000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
2f8777f2287777822f8778f2000000005c7055000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
2f7778f2287777822f8778f200000000070555000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
2f878f252ff88ff252f77f2500000000105555000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
52fff255522ff22552f88f250000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000
55222555555225555522225500000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000
55544455555445555544445500000000555335555555555555555555555555555555444555544455544444450000000000000000000000000000000000000000
5549994554499445549aa94500000000553ee35555553335555555555333555554449a945549a94549a94a940000000000000000000000000000000000000000
549a7a94499aa994549779450000000055e7be5555ebbe3553ebbe3553ebbe5549a4a7a4554a7a454a7a47a40000000000000000000000000000000000000000
49a777944a7777a449a77a940000000055b77b5555b77b553eb777b355b77b554a7444945444444549a94a940000000000000000000000000000000000000000
49777a944a7777a449a77a940000000055b77b5555b77b553b777be355b77b554949a94549a49a94544444450000000000000000000000000000000000000000
49a7a945499aa994549779450000000055eb7e5553ebbe5553ebbe3555ebbe35544a7a454a74a7a454a7a4550000000000000000000000000000000000000000
5499945554499445549aa94500000000553eb355533e5555555555555555e3355549a94549a49a94549a94550000000000000000000000000000000000000000
55444555555445555544445500000000555335555555555555555555555555555554445554444445554445550000000000000000000000000000000000000000
44111440bbb7777bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41e31140b7bb77bb7b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e35d610b77b77b77b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
135d66d0bbbb77bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11d667e05eebbbbee500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
416673b0553ebbe35500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
441deb705553ee355500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
416673b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11d667e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
135d66d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e35d610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41e31140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44111440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
511111111111111111111111111111111111111111111111111111dddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
d11777771111117771777177717171111171717111111117777711dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5177711771111171717171171171711111777171111111771177715d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
d17711177111117771777117117771111171717771111177111771dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
517771177111117111717117117171111177717171111177117771dddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
d11777771111117111717117117171111171717771111117777711dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
511111111111111111111111111111111111111111111111111111dddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5111111111111111111111dddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
d117717771777171717771dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5171117111171171717171dddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
d177717711171171717771dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5111717111171171717111dddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
d177117771171117717111dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5111111111111111111111dddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd22dddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddd22dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
511111111111111111d11111111111111111d11111dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd111111111d11111d11111d111111111d
d17771771177717771d17771111177717771d17771dddddddddddddddddddddddddddddddddddddddddddddddddddddd177717771d17711d17771d111117711d
511711717117111711d17171111171717111d11171dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd171117171d11711d11171d111111711d
d11711717117111711d17171111177717771d11771dddddddddddddddddddddddddddddddddddddddddddddddddddddd177717171d11711d17771d177711711d
511711717117111711d17171111111711171211171dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd111717171d11711d17111d111111711d
d17771717177711711d17771171111717771217771dddddddddddddddddddddddddddddddddddddddddddddddddddddd177717771d17771d17771d111117771d
511111111111111111d11111111111111111d11111dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd111111111d11111d11111d111111111d
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
51111111111111111151111111115111115d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d1111111111111d11111d11111d111111111d
d17171777177717771d177717771d17711dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1771177717771d17711d17771d111117711d
517171717117111711d171717171d11711dddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddd1171171117171d11711d11171d111111711d
d17171777117111711d177717171d11711dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1171177717171d11711d17771d177711711d
517771717117111711d111717171d11711dddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddd1171111717171d11711d17111d111111711d
d17771717177711711d111717771d17771dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1777177717771d17771d17771d111117771d
511111111111111111d111111111d11111dddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddd1111111111111d11111d11111d111111111d
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
511111111111111111d11111111111111111d111111111111111111111dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5d1111111111111d
d17771771177717771d17771111177717771d111117771111177117771dddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111111111111d
511711717117117171d17171111111717111d111117171111117117111dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5d1111117111111d
d11711717117117711d17171111111717771d177717171111117117771dddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111177711111d
511711717117117171d17171111111711171d111117171111117111171dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5d1111117111111d
d11711777177717171d17771171111717771d111117771171177717771dddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111111111111d
511111111111111111d11111111111111111d111111111111111111111dddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5d1111111111111d
dddddddddddddddddddddddddddddddddddddddddddd11dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
511111111111115d5d5d5d5d5d5d5d5d5d5d5d5d5d51aa1d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
d1111111111111ddddddddddddddddddddddddddddd2992ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
51111117111111dd5ddddddddddddddd5ddddddddd1a99a15ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
d1111177711111dddddddddddddddddddddddddddd294492dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
51111117111111dd5ddddddddddddddd5dddddddd1a9229a1ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
d1111111111111ddddddddddddddddddddddddddd29477492ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
51111111111111dd5ddddddddddddddd5ddddddd1d947749d1dddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddd2649119462dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5dddddd1a11922911a1ddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddd12977544577921dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5dddd12a9665555669a21ddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddd1a9416a11a6149a1ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5dddd1142149999412411ddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddd1121a1441a1211dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddd11551155q1dddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddqddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5q5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
dddddddddddddddddddddddddddddddddddddddddddddddddqdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddd22ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5dddddd22ddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5dd22ddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd22ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
ddddddddddddddddddddddddddddddddddddddddddddddddddddd333dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddd3rrr3ddddddd5ddddddddddddddd522ddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddd3rq7qr3ddddddddddddddddddddddd22ddddddddddddd22ddddddddddddd22ddddddddddddd22
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5d3rq777r3dddddd5ddddddddddddddd5ddddddddddddddd22ddddddddddddd22ddddddddddddd22
dddddddddddddddddddddddddddddddddddddddddddddddddd3r777qr3dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5d3rq7qr3ddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddd3rrr3dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddd333ddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddd1111111111111111111111111111111111111dddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5dddddddddddd1771177717771777171711111111177717771dddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddd1717171117171171171711711111111717171dddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5dddddddddddd1717177117771171177711111111177717171dddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddd1717171117111171171711711111171117171dddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5dddddddddddd1777177717111171171711111111177717771dddddddddddddd5ddddddddddddddd5ddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddd1111111111111111111111111111111111111dddddddddddddddddddddddddddddddddddddddddddddd
5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd5ddddddddddddddd

__map__
2221222321222223111201020312010203000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0321010321220102032211121322111213000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1321110102031112132221222322212223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2321211112010322010202020322212223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103212122111322111212120102032223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1113212101020322212222221112132223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2123212111121322210102032122232223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2123010203222322211112010202032223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2123111213222322212122111212132223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202032223222322212122212222232223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212132223220102020203212222232223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222232223221112121213212222232223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2201020323222122222201020323010203000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0211121323222122222211121323111213000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1221222301020203222221222323212223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2221222311121213010203220102032223000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414141414141414141414141414141414140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
