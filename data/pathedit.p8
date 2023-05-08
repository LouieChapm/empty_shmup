pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

bg_col=14
ln_col=13

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
#include inf_enems.txt

#include ../src/bulfuncs.lua
#include ../src/sprfuncs.lua

#include ../base_shmup.lua
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
	inst_info=split_split("init direction,init speed|target speed,accel rate|target direction,turn rate|wait duration,does nothing|goto index,does nothing")


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

	sspr_obj(34,enem.x,enem.y)
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
	
	if(enem.y>160 or enem.y<-42 or enem.x<-40 or enem.x>160)reset_vehicle()
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
eeeeeeeeeeeeeeeeeeeeeeee44e55e44e44eee4454e444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee4eeeeeee55eeee55e4eeee444ee444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee777eeeee777eeeee7e7eeeee777ee
eeeeeeeeeeeeeeee4eeeeeee55e44e55e5eeee4454e4445eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeee7eeeeeee7eeeee7e7eeeee7eeee
eeeeeeeeeeeeeeee4eeeeeee44e44e44e4eeee4444e4444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeee777eeeeee77eeeee777eeeee777ee
eeeeeeeeeeeeeeee4ee4eeee55e44e55e44eeeeee444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeee7eeeeeeeee7eeeeeee7eeeeeee7ee
eeeeeeeeeeeeeeee4ee4eeee55544555e44eeeeeee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeee777eeeee777eeeeeee7eeeee777ee
eeeeeeeeeeeeeeeeeeeeeeee55e44e554555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee
eeeeeeeeeeeeeeeeeeeeeeee55e44e54e555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee77eeeeee77eeeeee77eeeeee77eeeeee
eeeeeeeeeeeeeeeeeeeeeeeecccccd6ee555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeee4cccccd6e4555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee777eeeee777eeeee777eeeee777ee
eeeeeeeeeeeeeeeeeeeeeee4cccccd6ee44eeeeeee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeee7eeeee7e7eeeee7e7eeeee7e7ee
eeeeeeeeeeeeeeeeeeeeeee4cccccd6ee44eeeeee444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeeeee7eeeee777eeeee777eeeee7e7ee
eeeeeeeeeeeeeeeeeeee4ee4cccccd6ee4eeee4444e4444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7e7eeeeeee7eeeee7e7eeeeeee7eeeee7e7ee
eeeeeeeeeeeeeeeeeeee4ee4cccccd6ee5eeee4454e4445eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeeeee7eeeee777eeeeeee7eeeee777ee
eeeeeeeeeeeeeeeeeeeeeeeecccccd6ee4eeee444ee444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee
eeeeeeeeeeeeeeeeeeeeeeeecccccd6ee44eee4454e444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee77eeeeee77eeeeee77eeeeee77eeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dcccccee444e4544eee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dcccccee444ee444eeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dccccce5444e4544eeee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dccccce4444e4444eeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dccccce444444eeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dccccce44444eeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dccccce44444eee5555554eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeee6dccccce44444eee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44444eee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44444eee5555554eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44444eeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444444eeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4444e4444eeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5444e4544eeee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444ee444eeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444e4544eee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444aaa44444aa44444aaaa44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44abbba44aabbaa44abccba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4abc7cbaabbccbba4ab77ba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeabc777baac7777caabc77cba
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeab777cbaac7777caabc77cba
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeabc7cba4abbccbba4ab77ba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4abbba444aabbaa44abccba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44aaa444444aa44444aaaa44
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbbbddbddbbbbbbbbddddbbbbbbbbddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbbd99bd7dbbbbbbd7667dbbbbbbd7deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd877bd0dbbbbbd86996dbbbbbd777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd677bd8dbbbbd889999dbbbbbd767eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd677bd98dbbbd889999dbbbbbd666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd699bd99dbddd889999dbbddbd676eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbdddddddd899d7898dd9d889999dbd77dd677eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd6688888d807d6709d87d889999dbd776d655eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd66888880d707d9679567d886996dd67769966eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d7709990006707d8960769d886996dd67769966eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d009990ddd6707bd897d80d887667dd67768866eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99999d4446705bd05dd05d885005dd65568666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d00000477d6508bd56dbd0d800000dd58850676eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d00999d776e587bd6dbbbdd000000dd50050677eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd98886776e603bddbbbbbd0000ddbd50050655eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd888867768740eeeeeeeed000dbbbbd66d0666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd00067768574eeeeeeeed000dbbbbbddbd767eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd00065560854eeeeeeeebdddbbbbbbbbbd777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbddd5885d00deeeeeeeeeeeeeeeebbbbbd575eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbd5005dddbeeeeeeeeeeeeeeeebbbbbd565eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbd5005dbbbeeeeeeeeeeeeeeeebbbbbdd6deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbd66dbbbbeeeeeeeeeeeeeeeebbbbbbdddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbddbbbbbeeeeeeeeeeeeeeeeeebbbbddbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbddddbbbbbbbbbbbdddbbbbbbbbbbbbd99ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbd0766dbbbbbbbbbd766dddbbbbbbbdd899d6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbd990066dbbbbbbbd9006688ddbbbbd6089986eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd90999988dbbbbbd9999088888ddbbbd089985eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd990dd0088dbbbbd099dd0088886dbbbd8778deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd889044d0088dbbd990044d0098866dbbd6776deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd888d744d0986dbd8899644d099986dbbd6556deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d088877744d9966dd08887744d99907dbbd5005deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d008777764d9906dd08867776009990dbbbd55dbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d00777766009907dd00877766990990dbbbbddbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d07777669990990dd00677768889000deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d45776688899000dbd555764880000dbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d5006688888000dbbd50056000000dbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d600540000000dbbbd600540000ddbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd654000000ddbbbbbd655dddddbbbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbdddddddddbbbbbbbbdddbbbbbbbbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
eee77777eeeeeee77777eeeeeee33333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee7777777eeeee7777777eeeee3777773eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e777777777eee777333777eee377eee773eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
77777777777e77733333777e377eeeee773eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
77777377777e77333e33377e37eeeeeee73eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
77773337777e7733eee3377e37eeeeeee73ee7777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
77777377777e77333e33377e37eeeeeee73e777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
77777777777e77733333777e377eeeee773e773377eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e777777777eee777333777eee377eee773ee773377eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee7777777eeeee7777777eeeee3777773eee777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee77777eeeeeee77777eeeeeee33333eeeee7777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
99999dd999999999999dd9999999999999d999999999999999119999911999119eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
9999d33d9999999999d33d99999999999d3999999999999991771999177191771eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
9999d22d9999999999d2209999999999902999999999999991771999177191771eee44444344434444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
999d3222d99999999d3222d999999999d32999999999999991771999277291771eee44444344424444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
999d2112099999999021120999999999021999999999999992772999277292772eee4444434442444499dd9999dd9999dd99eeeeeeeeeeeeeeeeeeeeeeeeeeee
999d20021d999999d32002209999999d320999999999999912772199277292772eee443443444444449d77d99d77d99d77d9eeeeeeeeeeeeeeeeeeeeeeeeeeee
99d317712399999902177125d9999990217911119911119912772191777712772eee43343124444444dd66dddd66dddd66ddeeeeeeeeeeeeeeeeeeeeeeeeeeee
99d21771d2d9999d52177116d99999d5217917719917719127777211777712772eee43321124444443d3333dd2333dd3333deeeeeeeeeeeeeeeeeeeeeeeeeeee
99d12ddd723d9990612dd2dd3d99990612d91771991771922777722277772277244244111124444424d2222dd1222dd2222d999ddd999eeeeeeeeeeeeeeeeeee
9d3dd0076223d9d3dd2002d720d99d3dd2012772192772922277222277772277242234111122444244d215ddd1222dd1551d99dbbbd99eeeeeeeeeeeeeeeeeee
9d2741146123dd02774114762309d02774117777112772127277272277772222242131111122244444d266ddd1222dd1661d9d7ccb6d9eeeeeeeeeeeeeeeeeee
d3164444201ddd316644446d123d032664427777217777127277272277772222222141111112244434d2222dd1222dd2222dd7accba6deeeeeeeeeeeeeeeeeee
d21d3dd310dd9d21d63dd31d01dd321d63d27777227777227777772227722222221142111112244244d1111dd1111dd1111dd64bbb46deeeeeeeeeeeeeeeeeee
d10d12223dd99d10d122223d0dddd10d12227777227777222777722227722222221144111111244444dd55dddd55dddd55ddd67aaa75deeeeeeeeeeeeeeeeeee
dd0d301d4d999dd0d3d11d4dd999dd0d3d1227722277772927777299222292222211444111114444449d44d99d44d99d44d99d66665d9eeeeeeeeeeeeeeeeeee
99dd44d4d999999dd44dd4dd999999dd44d9277299277299922229999229992294214444111444444499dd9999dd9999dd9999ddddd99eeeeeeeeeeeeeeeeeee
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
