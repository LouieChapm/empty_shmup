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

#include ../../src/base_shmup.lua
#include ../../src/bulfuncs.lua
#include ../../src/sprfuncs.lua

#include ../debugfuncs.lua


function my_menu_item(b)
    if(b&1 > 0) game_rank=mid(1,game_rank-1,3) 
    if(b&2 > 0) game_rank=mid(1,game_rank+1,3)
    return true -- stay open
end

function _init()
	cartdata"kalikan_pathedit"
	if(peek(-0x2000)~=255)reload(-0x2000,0,0x2000,"../../kalikan_spritesheet.p8")
	b_sprite_colour = parse_data"10,11,12,3|0,1,2,3|0,8,9,15|14,4,5,6"

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

	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,14},1)
	poke(0x5f2d, 1)
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

	-- foreach(buls,drw_bulfunc)
	drw_buls()	

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
	
	local current_action = cur_data[3][enem.step-1] and cur_data[3][enem.step-1][1]
	debug = current_action=="wait" and enem.wait_time
	if current_action=="wait" and enem.wait_time>0 then
		--
	else
		if(enem.y>160 or enem.y<-42 or enem.x<-40 or enem.x>160 or new_reset)new_reset = false reset_vehicle()
	end
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
	print("\#e"..tostring(text),x,y,c or 7)
end

function draw_crumbs()
	local list=do_record and crumbs or crumbs_list[nav.lib_index]
	
	if(#list<=1)return

	for crumb in all(list) do
		local x,y=unpack(crumb)
		x+=spawn_x
		y+=spawn_y
		rect(x,y,x+1,y+1,12)
	end
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
000000004dddddd44444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555555d06666744766660d888888888888888888888888
00000000deeeeeed4444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5ee44ee5d56669744796665d888888888888888888888888
00700700eeeeeeee4444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5ee44ee5d56689744798665d888888888888888888888888
00077000444444444444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555555d56889744798865d888888888888888888888888
000770004dd44dd44444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed58889744798885d888888888888888888888888
00700700effeeffe4444444444444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeed08886744768880d888888866666666668888888
00000000eeeeeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44e44e44d08866744766880d888888677777777776888888
00000000eeeeeeeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4d08666744766680d8888867dddddddddd7688888
dededededededededededede444ede5665ede444ddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeeeeeeeeeee8888867deeeeeeeed7688888
dededddddddddddddddedede444eee4444eee44444444444ddddddddeeeeeeeeeeeeeeeeeeeeeeee44e44e44eeeeeeeeeeeeeeee8888867deeeeeeeed7688888
dedddddddddddddddddddede4d44444ee44444d4dedddddeddddddddeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee8888867deeeeeeeed7688888
ddddd3333333333333dddddd4d44444dd44444d4eeeeeeee33333333eeeeeeeeeeeeeeeeeeeeeeee4e4444e4eeeeeeeeeeeeeeee8888867deeeeeeeed7688888
ddd33333333333333333dddd4d444564465444d4eddddddd33333333eeeeeeeeeeeeeeeeeeeeeeee4e4444e4eeeeeeeeeeeeeeee8888867deeeeeeeed7688888
3333333333333333333333334444ede44ede4444eddeeedd33333333eeeeeeeeeeeeeeeeeeeeeeee4e4444e4eeeeeeeeeeeeeeee8888867deeeeeeeed7688888
3333333333333333333333334556ddd66ddd65544444444433333333eeeeeeeeeeeeeeeeeeeeeeee4e4444e4eeeeeeeeeeeeeeee8888867deeeeeeeed7688888
333333333333333333333333ddddee4444eeddddeeeeeeee33333333eeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee8888867deeeeeeeed7688888
d4de45566554ed4dde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee8888867dddddddddd7688888
dedde454454eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee888880677777777776088888
dede445ee544ededde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee888880066666666660088888
dedde456654eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee888888000000000000888888
d4de45566554ed4dde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee888888800000000008888888
dedde454454eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee888888888888888888888888
dede445ee544ededde444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4ee44ee4eeeeeeeeeeeeeeee888888888888888888888888
dedde456654eddedede444edeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44e44e44eeeeeeeeeeeeeeee888888888888888888888888
eeeeeeee3333333ddeddddedd3333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee333333ddde6556eddd333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee333333d4464444644d333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee33333346e44ee44e64333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee33333356e44ff44e65333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee333333544644446445333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee3333334ddd6556ddd4333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeee333333ddd4deed4ddd333333eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bdddddbbbbbbbbbbbbddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
dd8888bbbbbbbbbbbd99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d08888bbbbbbbbbbd999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d09999bbbbbbbbbd8999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99889bbbbbbbbbd8999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d98999bbbbbbbbbd8999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d98999bbbbbbbbbd8990eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99999bbbdddddd88998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99998bbd99977988999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99998bd899777988999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99988d8897779980909eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99988d88977999009d8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99988d889779990d999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99998d889779900d899eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99998d880660000d489eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99999d80066000dd568eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d90999d0054ee45ed567eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d98999d0ee5445eed567eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99889bddeeeeeedd675eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
dd9999bbbbbbbbbbd75deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bde54ebbbbbbbbbbd5ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bdee54bbbbbbbbbbd5ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbdeeebbbbbbbbbbd65deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbbd65eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbbbddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbbd99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbd877bddbbbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbd677bd7dbbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbd677bd0dbbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbdddbeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbd699bd8dbbbbeebbbbbbbbbbbddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd800deeeeeeeeeeeeeeeeeeeeee
eeeeeebbbdddddddd899bd98dbbbeebbbbbbbbbbd99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd94554eeeeeeeeeeeeeeeeeeeeee
eeeeeebbd6688888d807bd99dbddeebbbbbbbbbd899eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed845660eeeeeeeeeeeeeeeeeeeeee
eeeeeebd66888880d707d7898dd9eebbbbbbbbbd899eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056678eeeeeeeeeeeeeeeeeeeeee
eeeeeed7709990006707d6709d87eebbbbbbbbbd877eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056789eeeeeeeeeeeeeeeeeeeeee
eeeeeed009990ddd6707d9679567eebbbbbbbbbd677eeeeeeeeeeeeeeeeebbbbbbbbbbbbbbbbeeeeeeeeeeeeeeeeeeeeeeebd40897eeeeeeeeeeeeeeeeeeeeee
eeeeeed99999d4446705d8960769eebbbbddbbbd677eeeeeeeeeeeeeeeeebbbbbbbdbbbbbbbbeeeeeeeeeeeeeeeeeeeeeeed056789b444444beeeeeeeeeeeeee
eeeeeed00000477d6508bd897d80eebbbd9dbbbd699eeeeeeeeeeeeeeeeebbbbbbd9dbbbbbbbeeeeeeeeeeeeeeeeeeeeeeed056678444bb444eeeeeeeeeeeeee
eeeeeed00999d7764587bd05dd05eebbbd9ddddd899bbbbbbbbbbdbbbbbbbbbbbd090dbbbd0beeeeeeeeeeeeeeeeeeeeeeed84566054444445eeeeeeeeeeeeee
eeeeeebd988867764603bd56dbd0eebbbd9dd99d890bbbbbbbb0d9dbbbbbbbbbd090ddbbd9dbeeeeeeeeeeeeeeeeeeeeeeebd94554b555555beeeeeeeeeeeeee
eeeeeebd888867768740bd6dbbbdeebbd89d8990898bbbbbbdd890dbbbbbbbbd089089dd98dbeeeeeeeeeeeeeeeeeeeeeeebbd800dbb6666bbeeeeeeeeeeeeee
eeeeeebbd00067768574bddbbbbbeebbd89d8770898bbbbbd08908dbbbbbbbd08908998098dbeeeeeeeeeeeeeeeeeeeeeeebbbdddbb666666beeeeeeeeeeeeee
eeeeeebbd00065560854bbbddbbbddbbd8946779899bbbd08890899db0dbbd0889577809880beeeeeeeeeeeeeeeeeeeb54bb5555bb666bb666eeeeeeeeeeeeee
eeeeeebbbddd5885d00dbbd89bbd08bd88946799890bbd0889457998dd9dd098947776d9880beeeeeeeeeeeeeeee55454b5555555566bbbb66eeeeeeeeeeeeee
eeeeeebbbbbd5005dddbbd89fbd089bd88946799898bd0989457778809d0d9889577659880bbeeeeeeeeeeeeeeeeb44b5b554bb45566bbbb66eeeeeeeeeeeeee
eeeeeebbbbbd5005dbbbd89f7d089fbd88946799899d89894577765098dbd8894777649880bbeeeeeeeeeeeeeeeeb44555554bb455666bb666eeeeeeeeeeeeee
eeeeeebbbbbbd66dbbbbd89f7d089fd9889d6799800d009d5777654988dbd009577659888dbbbbbbddbbeeeeb66b55465555555555b666666beeeeeeeeeeeeee
eeeeeebbbbbbbddbbbbbd889fd0089d9889d6799006d00d57776549880bbd005777649880dbbbbbd99ddeeee655555bb6bbb5555bbbb6666bbeeeeeeeeeeeeee
bbbbddbbbbddbbbbddeedd889dd008dd80046700067d0d47776549888dbbd0d6776598880dbbbdd899d6eeee565bbbb6beeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbd77bbbd88bbbd99eebd488bd400bdd00d6550007bd455765d98880bbbbd4557d088809dbbd6089986eeeebb45bb6565beeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd977bbd988bbd999eebbd44bbd44bbdd0d5885000bd50854098888dbbbbd50850d0889dbbbbd089985eeeeb444b555554eeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd799bbd099bbd899eebbd56bbd56bbbddd5005dddbd70050d08880bbbbbd7005d0008dbbbbbbd8778deeee44445555bb4eeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd777bbd000bbd888eebbd56bbd56bbbbbd4774dbbbd4754d00889dbbbbbd4754d00ddbbbbbbbd6776deeee444b455bb5beeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd777bbd080bbd898eebbd56bbd56bbbbbbd44dbbbbdd44dd0009dbbbbbbbd44dddddbbbbbbbbd6556deeeeb4bbb4bbb65eeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd777bbd088bbd899eebbd56bbd56bbbbbbbddbbbbbbdddddddddbbbbbbbbbdddbbbbbbbbbbbbd5005deeeebb5555bbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd777bbd088bbd899eebd656bd656eeeeeeeebbb77777bbbbbb77777bbbbbb66666bbbeeeeebbbd55dbeeeeb555555beeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd4777bd5088bd5899eed7756d7756eeeeeeeebb7777777bbbb7777777bbbb6777776bbeeeeebbbbddbbeeee555bb555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d45777d56088d56899eed7756d7756eeeeeeeeb777777777bb777666777bb677bbb776beeeeeebbbbb7bbbbb55bbbb55eeeeeeeeeeeeeeeebd000dbeeeeeeeee
d74777d67088d67899eed7756d7756eeeeeeee7777777777777766666777677bbbbb776eeeeeebbbbbbbbbbb55bbbb55eebbbbb3bbb3bbbbd87778deeeeeeeee
d67466d56700d56788eed6677d6677eeeeeeee7777767777777666b6667767bbbbbbb76eeeeeebbbbbbbbbbb555bb555eebbbbb3bbb2bbbb0878780eeeeeeeee
d56777d45666d45666eed5677d5677eeeeeeee777766677777766bbb667767bbbbbbb76b7777bbbbbbbbbbbbb555555beebbbbb3bbb2bbbb0877880eeeeeeeee
dd5666dd4555dd4555eed5566d5566eeeeeeee7777767777777666b6667767bbbbbbb767777777bbbbbbbbb7bb5555bbeebb3bb3bbbbbbbb0878780bbbb3bbbb
bdd555bdd444bdd444eedd566dd566eeeeeeee7777777777777766666777677bbbbb776776677bbbbbbbbbbbeeeeeeeeeeb33b312bbbbbbbd87778dbbbb1bbbb
bbddddbbddddbbddddeebddddbddddeeeeeeeeb777777777bb777666777bb677bbb776b776677bbbbbbbbbbbeeeeeeeeeeb332112bbbbbb3bd000dbbbbb1bbbb
bbbbddbbbbbbbbbbddbbbbbbbbbbbbd8888888bb7777777bbbb7777777bbbb6777776bb777777bbbbbbbbbbbeeeeeeebb2bb11112bbbbb2beb5555ebbb222bbb
bbbe77ebbbbbbbbe77ebbbbbbbbbbe78888888bbb77777bbbbbb77777bbbbbb66666bbbb7777bbbbbb7bbbbbeeeeeeeb223b111122bbb2bbe555b5e311222113
bbbe66dbbbbbbbbd66dbbbbbbbbbbd68888888888888888888888888888888888888888888888888888888888888888b21311111222bbbbbe55bb5ebbb222bbb
bbbd66dbbbbbbbbd66dbbbbbbbbbbd68888888888888888888888888888888888888888888888888888888888888888221b11111122bbb3be5bbb5ebbbb1bbbb
bbbd555ebbbbbbbd554ebbbbbbbbbd58888888bbbbbbbbbbbbbbb55bbbbb55bbb55b888888888888888888888888888211b21111122bb2bbe5bbb5ebbbb1bbbb
bbd6556ddebbbbd6556dbdebbbbbe658888888bbbbbbbbbbbbbb5775bbb5775b5775888888888888888888888888888211bb1111112bbbbbe5bbb5ebbbb3bbbb
bed5446e6debedd5446de5debedbd648888888bbbbbbbbbbbbbb5775bbb5775b5775888888888888888888888888888211bbb11111bbbbbbe5bbb5eeeeeeee55
e4e4774475ded5e47744475ded5ed478888888bbbbbbbbbbbbbb5775bbb6776b5775888888888888888888888888888b21bbbb111bbbbbbbe5bbb5eeeeeeee55
d565775477dd46557754577dd5744578888888bbbbbbbbbbbbbb6776bbb6776b6776888888888888888888888888888bbddbbbbddbbbbddbb5bbb5eeeeeeee55
d5e5ee5467dd56e5ee54567dd77545e8888888bbbbbbbbbbbbb567765bb6776b6776888888888888888888888888888bd77dbbd77dbbd77db5bbb54444444455
d4e5675465dd5ee5775e565dd7654578888888bb66bbbb66bbb567765b5777756776888888888888888888888888888dd66dddd66dddd66dd5bbb55555555555
e4ee567e75de45e4667e67ebd565e768888888b6776bbb77bb567777655777756776888888888888888888888888888d7777dd6777dd7777d5bbb5bbbddbbb55
dde44564ddbdd6ee556d4edbbe76e658888888b7777bb6776b667777666777766776888888888888888888888888888d6666dd5666dd6666d5bbb5bbd66dbb55
bdd5dd754ebbddd5dd7e54dbbde4d7d8888888b7667bb7777b666776666777766776886667777666888888888888888d644ddd5666dd4ee4d5bbb5bbe55ebb55
be4ee4e6dbbbbe4ee4de6dbbbd45dd48888888676676b7667b676776766777766666886766776676888888888888888d655ddd5666dd4554d5bbb5bd6446db55
bd5edde6dbbbbd5eddbd6dbbbbe6ebd8888888776677676676676776766777766666886776776776888888888888888d6666dd5666dd6666d5bb55be5775eb55
bd6dbbd7dbbbbd6dbbbd6dbbbbd6ebb8888888766667776677677777766677666666886666776666888888888888888d5555dd4555dd5555d5b555d6e77e6d55
bd6dbbd7dbbbbd6dbbbd7dbbbbd6dbb888888876666777667766777766667766666688b55666655b888888888888888dd55dddd55dddd55dd55555e57ee75e55
bd6dbbbdbbbbbd6dbbbbdbbbbbd7dbb8888888776677776677b677776bb6666b666688bb456654bb888888888888888bd44dbbd44dbbd44db55554d454454d54
bbdbbbbbbbbbbbdbbbbbbbbbbbbdbbb8888888b7777bb7777bbb6666bbbb66bbb66b88bbb4554bbb888888888888888bbddbbbbddbbbbddbb4444bbe4dd4eb4b
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
