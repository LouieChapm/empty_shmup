pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

bg_col=10
ln_col=11

-- things to make the numbers nicer
dtime=1/60
speed_offset=0.25 -- added to speed so that I can stick to using small number s;):):):):)
rot_offset=0.01

show_ui=true

debug=""
debug_time=0

shot_pause=0

types=split"init,tspd,tdir,wait,stop"
numbers=split("0,1,2,3,4,5,6,7,8,9,-,.",",",false)


new_reset = false

#include info_path_editor.txt
#include inf_sprites.txt
#include inf_patterns.txt
#include inf_crumbs.txt
#include inf_enems.txt

#include ../../src/bulfuncs.lua
#include ../../src/sprfuncs.lua
#include ../../src/base_shmup.lua

#include ../debugfuncs.lua


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
	inst_info=split_split("init direction,init speed|target speed,accel rate|target direction,turn rate|wait duration,does nothing|does nothing,does nothing")


	menuitem(1, "export data", function() export_data() end)
	menuitem(2, "⬅️ rank:2 ➡️", my_menu_item)

	init_baseshmup(enemy_data)
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

	sspr_obj(100,enem.x,enem.y)
	local x,y=enem.x,enem.y
	local tx,ty=sin(enem.dir),cos(enem.dir)
	local dist=10
	x,y=x+(tx*dist)+0.5,y+(ty*dist)+0.5
	line(x,y,x+(tx*enem.spd*1),y+(ty*enem.spd*1),11)

	foreach(buls,drw_bulfunc)	

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
	
	if(enem.y>160 or enem.y<-42 or enem.x<-40 or enem.x>160 or new_reset)new_reset = false reset_vehicle()
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

	if type=="stop" then
		new_reset = true
		return true
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
000000004dddddd44444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed06666744766660d888888888888888888888888
00000000deeeeeed4444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed56669744796665d888888888888888888888888
00700700eeeeeeee4444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed56689744798665d888888888888888888888888
00077000444444444444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed56889744798865d888888888888888888888888
000770004dd44dd44444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed58889744798885d888888888888888888888888
00700700eddeedde4444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed08886744768880d888888866666666668888888
00000000eeeeeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed08866744766880d888888677777777776888888
00000000eeeeeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed08666744766680d8888867dddddddddd7688888
dededededededededededede444ede5665ede444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
dededddddddddddddddedede444eee4444eee444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
dedddddddddddddddddddede4d44444ee44444d4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
dddddddddddddddddddddddd4d44444dd44444d4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
dddddddddddddddddddddddd4d444564465444d4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
dddddddddddddddddddddddd4444ede44ede4444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
dddddddddddddddddddddddd4556ddd66ddd6554eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
ddddddddddddddddddddddddddddee4444eeddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867d00000000d7688888
d4de45566554ed4dde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888867dddddddddd7688888
dedde454454eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888880677777777776088888
dede445ee544ededde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888880066666666660088888
dedde456654eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888000000000000888888
d4de45566554ed4dde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888800000000008888888
dedde454454eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888888888888888888888
dede445ee544ededde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888888888888888888888
dedde456654eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888888888888888888888888
eeeeeeeeeeeeeeeededdddedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeede6556edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee46444464eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee44ee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeee44dd44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee46444464eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeedd6556ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeed4deed4deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bdddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444bbb44444aa44444aaaa44
dd8888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bcccb44aabbaa44abccba4
d08888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bc373cbabbccbba4ab77ba4
d09999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc3777cbac3333caabc77cba
d99889eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc7773cbac3333caabc77cba
d98999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc373cb4abbccbba4ab77ba4
d98999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bcccb444aabbaa44abccba4
d99999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bbb444444aa44444aaaa44
d99998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444111444440044444000044
d99998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441222144001100440122104
d99988eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412373210112211040177104
d99988eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123777210233332001277210
d99988eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee127773210233332001277210
d99998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123732140112211040177104
d99998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412221444001100440122104
d99999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441114444440044444000044
d90999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d98999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99889eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
dd9999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bde54eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bdee54eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbdeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd000db
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed87778d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0878780
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0877880
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbddbbeeeeeee0878780
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbd99ddeeeeeeed87778d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdd899d6eeeeeeebd000db
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6089986eeeeebdddddddb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbdddbbd089985eeeeedd08880dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd800dbbd8778deeeeed0977790d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd94554bbd6776deeeeed8979798d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed845660bbd6556deeeeed8977998d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056678bbd5005db5555d8979798d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056789bbbd55db555b5d0977790d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd40897bbbbddbb55bb5dd08880dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056789b444444b5bbb5bdddddddb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056678444bb4445bbb5dd00d88dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed845660544444455bbb5d5668996d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd94554b555555b5bbb5d5068997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd800dbb6666bb5bbb5d5688997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbeeeeeeeeeeebbbdddbb666666b5bbb5d5068997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeeeeeeb54bb5555bb666bb6665bbb5d5668996d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeee55454b5555555566bbbb665bbb5dd00d88dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeeeb44b5b554bb45566bbbb665bbb5bdddddddb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7bbbbbbbbb7eeeeb44555554bb455666bb6665bbb5dd8d888dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbb66b55465555555555b666666b5bbb5d4089776d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb655555bb6bbb5555bbbb6666bb5bbb5d5089796d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb565bbbb6beebbbbb3bbb3bbbbe5bb55d5089779d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbbb45bb6565bbbbbb3bbb2bbbbe5b555d5089796d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbddbbbbddbbbbddbbb444b555554bbbbb3bbb2bbbbe55555d4089776d
88888888888888888888888888888888888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd77dbbd77dbbd77db44445555bb4bb3bb3bbbbbbbbe55554dd8d888dd
88888888888888888888888888888888888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd66dddd66dddd66dd444b455bb5bb33b312bbbbbbbe4444bbdddddddb
8888888888888888888888888888888888888888888888888888888888888888888888d3333dd2333dd3333db4bbb4bbb65b332112bbbbbb3bbbddddddbbbeee
8888888888888888888888888888888888888888888888888888888888888888888888d2222dd1222dd2222dbb5555bbbb2bb11112bbbbb2bbbd622225dbbeee
bbbbbddbbbbbbbbbbbbddbbbbbbbbbbbbbd888bbbbbbbbbbbbbbb11bbbbb11bbb11b88d215ddd1222dd1551db555555bb223b111122bbb2bbbd72332226dbddb
bbbbd33dbbbbbbbbbbd33dbbbbbbbbbbbd3888bbbbbbbbbbbbbb1771bbb1771b177188d266ddd1222dd1661d555bb555b21311111222bbbbbd7137332216d67d
bbbbd22dbbbbbbbbbbd220bbbbbbbbbbb02888bbbbbbbbbbbbbb1771bbb1771b177188d2222dd1222dd2222d55bbbb55221b11111122bbb3bd6133332216d67d
bbbd3222dbbbbbbbbd3222dbbbbbbbbbd32888bbbbbbbbbbbbbb1771bbb2772b177188d1111dd1111dd1111d55bbbb55211b21111122bb2bbd6123322215d67d
bbbd21120bbbbbbbb021120bbbbbbbbb021888bbbbbbbbbbbbbb2772bbb2772b277288dd55dddd55dddd55dd555bb555211bb1111112bbbbbd6412222145d67d
bbbd20021dbbbbbbd3200220bbbbbbbd320888bbbbbbbbbbbbb127721bb2772b277288bd44dbbd44dbbd44dbb555555b211bbb11111bbbbbbd6741111465d67d
bbd3177123bbbbbb02177125dbbbbbb0217888b1111bb1111bb127721b177771277288bbddbbbbddbbbbddbbbb5555bbb21bbbb111bbbbbbbd5674444654d67d
bbd21771d2dbbbbd52177116dbbbbbd5217888b1771bb1771b12777721177771277288bbbb3bbbbe8888888888888888bbb33333bbbbbbbbbbd56667754dbddb
bbd12ddd723dbbb0612dd2dd3dbbbb0612d888b1771bb1771b22777722277772277288bbbb1bbbbe8888888888888888bb3777773bbbbbbbbbbd555544dbbeee
bd3dd0076223dbd3dd2002d720dbbd3dd20888127721b2772b22277222277772277288bbbb1bbbbe8888888888888888b377bbb773bbbbbbbbbbddddddbbbeee
bd2741146123dd0277411476230bd02774188817777112772127277272277772222288bbb222bbbe8888888888888888377bbbbb773bbbbbbbbddddbbbddbbee
d3164444201ddd316644446d123d032664488827777217777127277272277772222288311222113e888888888888888837bbbbbbb73bbbbbbbd6777dbd67dbee
d21d3dd310ddbd21d63dd31d01dd321d63d88827777227777227777772227722222288bbb222bbbe333777733388888837bbbbbbb73b7777bd665567d6667dee
d10d12223ddbbd10d122223d0dddd10d12288827777227777222777722227722222288bbbb1bbbbe373377337388888837bbbbbbb73777777d656676d6576dee
dd0d301d4dbbbdd0d3d11d4ddbbbdd0d3d1888227722277772b277772bb2222b222288bbbb1bbbbe3773773773888888377bbbbb773773377d656676d6576dee
bbdd44d4dbbbbbbdd44dd4ddbbbbbbdd44d888b2772bb2772bbb2222bbbb22bbb22b88bbbb3bbbbe3333773333888888b377bbb773b773377d567766d5666d55
000000bbb000000bb000000b000000000000000bbb00000b00000000b000000bb000000bb000000bb22333322b888888bb3777773bb777777bd5556dbd56db55
0dddd0bb00dddd0000dddd000d00ddd00ddddd0bb00ddd0b0dddddd000dddd0000dddd0000dddd00bb123321bb888888bbb33333bbbb7777bbbddddbbbddbb55
00ddd0bb0d00ddd00d00ddd00d00ddd00ddd000b00dd000b0000ddd00ddd00d00d00ddd00ddd00d0bbb1221bbb888888bbb77777bbbbbb77777bbb4444444455
d1bbb1bb1111bbd11111bbd11b11bbb11bbb1ddb1ddb1ddbddd1bbb11dbb11d11d11bbd11dbb11d100b00b0000000000bb7777777bbbb7777777bb5555555555
d2bbb2bbdd22bbb2d222bbb22b22bbb22bbb222b2dbb222bdd22bbb22bbb22b22b22bbb22bbb2db211b11bd11ddd11ddb777777777bb777333777bbbbddbbb55
b2bbb2bbd22dbb22d2ddbb222bddbbb22bbbdd222bbbdd22bb2dbb2222bbdd2222ddbbb22bbbddb222b22bb22bbb22bb7777777777777733333777bbd33dbb55
b2bbb2bb22ddb22db222bbd22222bbb22222ddd22bbb22d2b22dbb2d2dbb22d2d222bbb22bbbd2b222b22bb22bbb22bb7777737777777333b33377bb0220bb55
b2bbb2bb2ddb22dd2222bbd2ddd2bbb22222bbd22bbb22d2b2dbb22d2dbb22d2ddd2bbb22bbb22b222222bb22bbb22bb777733377777733bbb3377bd3113db55
11bbb1111dbb11111d11bbb1ddd1bbb11d11bbb11bbb11b1b1dbb1db1bbb11b1b111bbb11bbb11b122d22bb22bbb22bb7777737777777333b33377b027720b55
0dbbbbd00bbbddd000ddbb00bbb0bbb000ddbb0000bbdd00b0bbb0db00bbdd00b0ddbb0000bbdd0011b11bb11bbb11bb7777777777777733333777d317713d55
0000000000000000d000000dbbb00000d000000dd000000db00000bbd000000db000000dd000000d00b00bb00bbb00bbb777777777bb777333777b0270072055
ddddddddddddddddddddddddbbbdddddddddddddddddddddbdddddbbddddddddbddddddddddddddd00b00b0000bb00bbbb7777777bbbb7777777bbd164461d54
ddddddddddddddddbddddddbbbbdddddbddddddbbddddddbbdddddbbbddddddbbddddddbbddddddbddbddbddddbbddbbbbb77777bbbbbb77777bbbb04dd40b4b
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
