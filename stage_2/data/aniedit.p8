pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
bg_col=5
ln_col=4

show_ui=true

debug=""
debug_time=0

-- PUT THE LEVEL COLOUR PALETTE HERE
palette=split"2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,14"


alphabet=split"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,_" -- letters and underscore 
numbers=split("0,1,2,3,4,5,6,7,8,9,-,., ",",",false)

info_types=split"sspr,offset,palt,mirror,flip,spr_stack"
anim_info_types=split"frames"

#include inf_sprites.txt
#include inf_enems.txt

#include ../../src/sprfuncs.lua
#include ../../src/base_shmup.lua

#include ../debugfuncs.lua


function _init()
	cartdata"kalikan_aniedit"

	--[[
		0: library index
		1: animation index
	]]

    add(numbers,",")

	t=0
	temp=""

    menuitem(1, "export sprites", function() export_sprites() end)

	init_baseshmup(enemy_data)
	poke(0x5f2e,1)
	
	init_sprfuncs(spr_library,anim_library)


    change_frame=0
    global_mode="sprite"
    mouse_control=false
    nav={
        vert=1,
        hori=1,

        mode="select",
        editor="normal",

        lib_index=dget(0)~=0 and dget(0) or 1,
        ani_index=dget(1)~=0 and dget(1) or 1,
    }

	poke(0x5f2d, 1) -- keyboard access


	
	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,14},1)
	palt(0,false)

	old_transparent=-1
end


function _update60()
	dset(0,nav.lib_index)
	dset(1,nav.ani_index)

	t+=1
    

    had_input=stat(30)
	char = had_input and stat(31) or nil

    if(had_input and char=="\t")global_mode = global_mode=="sprite" and "anim" or "sprite"

    if(nav.editor=="normal")update_input()
    if(nav.editor=="sspr")update_sspr()
    if(nav.mode=="offset")update_offset()

	if debug_time>0 then
		debug_time-=1
		if(debug_time==0)debug=""
	end


    cur_data=spr_library[nav.lib_index]
    cur_frames=anim_library[nav.ani_index]

    if(global_mode=="sprite")info_not_empty=#cur_data>1 -- crude but I hate you so... ://// 
    if(global_mode=="anim")info_not_empty=#anim_library[nav.ani_index]>1 -- crude but I hate you so... ://// 


end


function _draw()
	cls(bg_col)

	draw_bg()

    if info_not_empty then
        if(global_mode=="sprite")sspr_obj(nav.lib_index,63,63)
        if global_mode=="anim" then
            if(nav.vert<=1)sspr_anim(nav.ani_index, 63, 63)
            if(nav.vert>1)sspr_obj(cur_frames[nav.vert-1], 63, 63)
        end
    end


    if(nav.editor=="sspr")draw_sspr()
    if(nav.editor=="normal")draw_information()

    pset(63,63,pget(63,63)+7)

	printbg(debug,127-(#tostring(debug)*4),121,7)
end

-->8
-- init
-->8
-- update

function update_offset()
    if change_frame!=t then
        if char=="\r" or btnp(❎) then  
            
            if(char=="\r")poke(0x5f30,1)
            nav.mode="select"
            return
        end
    end

    local ox,oy=cur_data[5],cur_data[6]

    if(btnp(⬆️))oy-=1
    if(btnp(⬇️))oy+=1
    if(btnp(⬅️))ox-=1
    if(btnp(➡️))ox+=1

    cur_data[5]=ox
    cur_data[6]=oy


end

function update_sspr()
    if(btnp(🅾️) and nav.mode=="select")nav.editor="normal" return

    if nav.mode=="select" then
        if(btnp(⬆️))nav.vert-=1
		if(btnp(⬇️))nav.vert+=1

        nav.vert=mid(1,nav.vert,3)

        if char=="\r" or btnp(❎) then  
            if(change_frame==t)return
            if(nav.vert==3)mouse_control=not mouse_control return

			if(char=="\r")poke(0x5f30,1)
            nav.mode="type"
        end
    else
        if char=="\r" or btnp(❎) or mouse_control and stat(34)==0x1 then  
			if(char=="\r")poke(0x5f30,1)
            nav.mode="select"
        end

        if nav.vert==1 then
            local sx,sy,sw,sh=unpack(cur_data)

            if(btnp(⬆️))sy-=1
            if(btnp(⬇️))sy+=1
            if(btnp(⬅️))sx-=1
            if(btnp(➡️))sx+=1

            if(mouse_control)sx,sy=stat(32),stat(33)
            cur_data[1]=sx
            cur_data[2]=sy
            cur_data[3]=sw
            cur_data[4]=sh
            return
        end

        if nav.vert==2 then
            local sx,sy,sw,sh=unpack(cur_data)

            if(btnp(⬆️))sh-=1
            if(btnp(⬇️))sh+=1
            if(btnp(⬅️))sw-=1
            if(btnp(➡️))sw+=1

            if(mouse_control)sw,sh=stat(32)-sx,stat(33)-sy
            cur_data[1]=sx
            cur_data[2]=sy
            cur_data[3]=sw
            cur_data[4]=sh
            return
        end
    end
end

function update_input()
    if nav.mode=="select" then
		if(btnp(⬆️))nav.vert-=1
		if(btnp(⬇️))nav.vert+=1

        if nav.vert==0 then
            local lib_ind=global_mode=="sprite" and nav.lib_index+#spr_library or nav.ani_index+#anim_library
            if(btnp(⬅️))lib_ind-=1
            if(btnp(➡️))lib_ind+=1


            if(global_mode=="sprite")nav.lib_index=(lib_ind-1)%#spr_library+1
            if(global_mode=="anim")nav.ani_index=(lib_ind-1)%#anim_library+1

			if char=="\b" then 				
				spr_library[nav.lib_index]={}
			end
        else
            if(btnp(⬅️))nav.hori-=1
            if(btnp(➡️))nav.hori+=1
        end

        local max= global_mode=="sprite" and 6 or info_not_empty and #cur_frames+1 or 2
		nav.vert=mid(0,nav.vert,info_not_empty and max or 1)
		nav.hori=mid(1,nav.hori,3)

        -- enter into type mode
        if btnp(❎) then  
			if(char=="\r")poke(0x5f30,1)

            -- only if the box has information inside it
            if info_not_empty then
                if nav.vert==1 then
                    if global_mode=="sprite" then
                        nav.editor="sspr"
                        change_frame=t
                        return
                    end

                    if global_mode=="anim" then
                        nav.mode="type" 
                        temp=""
                        change_frame=t
                    end
                end

                if global_mode=="anim" and nav.vert>1 then
                    global_mode="sprite"
                    nav.lib_index=cur_frames[nav.vert-1]
                    change_frame=t
                    return
                end


                if nav.vert == 2 then
                    nav.mode="offset" 
                    change_frame=t
                end

                if nav.vert >= 3 then
                    nav.mode="type" 
                    temp=""
                    change_frame=t
                end
            else
                if global_mode=="sprite" then
                    spr_library[nav.lib_index]=split"0,0,16,16,0,0,0,0,0,0"
                else
                    anim_library[nav.ani_index]=split"1,2,3,4"
                end
            end
		end

    elseif nav.mode=="type" then
        if(not had_input) return

        if(char=="p")poke(0x5f30,1) -- ignore pause

        if(char=="\b")temp=sub(temp,1,#tostring(temp)-1) return

        if char=="\r" then
            poke(0x5f30,1)  -- ignore pause

            if(global_mode=="sprite")spr_library[nav.lib_index][nav.vert+4]=tonum(temp)
            if(global_mode=="anim")anim_library[nav.ani_index]=split(temp)

            nav.mode="select"
            return
        end

        if is_in_list(numbers,char) then
            temp..=char
        end
    end
end

-->8
-- draw


function draw_sspr()
    sspr(0,0,128,128)
    local x=2
    local y=80

    draw_module("⬅️ #"..nav.lib_index.." ➡️",x,2,false)

    local sx,sy,sw,sh=unpack(cur_data)

    if(sy>50)y=30

    if(nav.mode!="type" or (t\6)%2==0)rect(sx,sy,sx+sw-1,sy+sh-1)

    draw_module("x:"..sx.." / y:"..sy,x,y,nav.vert==1)
    draw_module("w:"..sw.." / h:"..sh,x,y+8,nav.vert==2)
    
    local txt=mouse_control and "on" or "off"
    draw_module("cursor mode: "..txt,x,121,nav.vert==3)
end

function draw_information()

    if(global_mode=="sprite")drw_inst_sprite()
    if(global_mode=="anim")drw_inst_anim()

    local x=40
    if(global_mode=="anim")x+=4
    draw_module("-> "..global_mode.." <-",x,120)
end

function drw_inst_anim()
    local x=2
    local y=15

    draw_module("⬅️ #"..(nav.ani_index).." ➡️",x,2,nav.vert==0)

    if info_not_empty then
        local txt=nav.mode=="type" and nav.vert==1 and temp or anim_library[nav.ani_index][1]
        draw_module(nav.mode=="type" and nav.vert==1 and temp or "set frames", x, 23, nav.vert==1)
        for i=1,#cur_frames do
            local frame=cur_frames[i]
            draw_module("#"..i..": "..frame, x, 23+i*8, nav.vert==i+1)
        end
    else
        draw_module("{empty}", x, 23, nav.vert==1)
    end
end

function drw_inst_sprite()
    local x=2
    local y=15

    local data=spr_library[nav.lib_index]

    draw_module("⬅️ #"..(nav.lib_index).." ➡️",x,2,nav.vert==0)

    if info_not_empty then
        draw_module("set sspr",x,y+8,nav.vert==1)
        draw_module("set offset",x,y+16,nav.vert==2)
        for i=3,#info_types do
            local is_on=nav.vert==i
            local text = nav.mode=="type" and is_on and temp or data[i+4] or 0
            draw_module(info_types[i]..": "..text,x,y+i*8,is_on)
        end
    else
        draw_module("{empty}",x,y,nav.vert==1)
    end
end

function draw_module(_text,_x,_y,_is_on)
    printbg(_text,_x,_y,_is_on and 5+(t\10)%3 or 7)
end

function draw_bg()
    fillp(0x33cc.8)
    rectfill(0,0,128,128,ln_col)

	local line_col = 14

    fillp(▤)
    line(63,0,63,60,line_col)
    line(63,66,63,128,line_col)
    fillp(▥)
    line(0,63,60,63,line_col)
    line(66,63,128,63,line_col)
    fillp()
end
-->8
-- tool

function add_commar(_list)

end

function is_in_list(_list,_thing)
	for item in all(_list) do
		if(item==_thing)return true
	end
	return false
end

function get_player_dir(_x,_y)
	return atan2(player.x - _x, player.y - _y)
end

function printbg(text,x,y,c)
	print("\#e"..tostring(text),x,y,c or 7)
end

function parse_data(_data)
    local out={}
    for step in all(split(_data,"|")) do
        add(out,split(step))
    end
    return out
end

-->8
-- input

-->8
-- data

function export_sprites()
    debug="sprites exported" 
    debug_time=90

    -- sprite stuff
	local out="spr_library=[["
	for sprite in all(spr_library) do
        if #sprite>1 then
            for i=1,#sprite do
                out..=sprite[i]
                if(i!=#sprite)out..=","
            end
        end
        out..="|"
	end

    out=sub(out,1,-2)
	out..="]]\n"
    
    -- animation stuff
    out..="anim_library=[["
    for anim in all(anim_library) do
        if #anim>1 then
            for i=1,#anim do
                out..=anim[i]
                if(i!=#anim)out..=","
            end
        end
        out..="|"
	end

    out=sub(out,1,-2)
    out..="]]"

    printh(out, "inf_sprites.txt", true)
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
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
8111111111111111111111111111111111oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o11777771111117171771111111777771188oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o17771177111117771171111117711777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
8177111771111171711711111177111771oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
8177711771111177711711111177117771oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o11777771111117171777111111777771188oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o11111111111111111111111111111111188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o11111111111111111111111111111111188oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o11771777177711111177117717771777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
8171117111171111117111711171717171oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
8177717711171111117771777177717711oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o11171711117111111117111717111717188oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o17711777117111111771177117111717188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
8111111111111111111111111111111111oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o1111111111111111111111111111111111111111188oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o1177177717771111117717771777117717771777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
817111711117111111717171117111711171111711oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
817771771117111111717177117711777177111711oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o1117171111711111171717111711111717111171188oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o1771177711711111177117111711177117771171188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
811111111111111111111111111111111111111111oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o1111111111111111111111111111188oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o1777177717111777111111111777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
817171717171111711171111117171oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
817771777171111711111111117171oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o1711171717111171117111111717188oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o1711171717771171111111111777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
811111111111111111111111111111oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o111111111111111111111111111111111111188oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o177717771777177711771777111111111777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
81777117117171717171717171171111117171oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
81717117117711771171717711111111117171oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o171711711717171717171717117111111717188oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o171717771717171717711717111111111777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
81111111111111111111111111111111111111oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o1111111111111111111111111111188oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o1777171117771777111111111777188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
817111711117117171171111117171oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
817711711117117771111111117171oo88oo88oo88oo88oo88oo88oo88oo88o118oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o1711171111711711117111111717188oo88oo88oo88oo88oo88oo88oo88oo1aa188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o1711177717771711111111111777188oo88oo88oo88oo88oo88oo88oo88oo199188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
811111111111111111111111111111oo88oo88oo88oo88oo88oo88oo88oo81a9991o88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo8194492o88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o111111111111111111111111111111111111111111111111188oo88oo88o1922941oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
21177177717771111117717771777117717171111111117771282o282o281a4r749a2o282o282o282o282o282o282o282o282o282o282o282o282o282o282o28
81711171717171111171111711717171117171171111117171oo88oo88oo1947741918oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
81777177717711111177711711777171117711111111117171oo88oo88oo14911179a1oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
o111717111717111111171171171717111717117111111717188oo88oo81a11227699a18oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
o177117111717177717711171171711771717111111111777188oo88oo81975445649a18oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
81111111111111111111111111111111111111111111111111oo88oo881a46555592411o88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo881941a11a4211oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo14214999a11o88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo1121a24151oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo1155151o88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88o288oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo81111111111111111111111111111111111111111111111111oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88o111117111111117717771777177717771777111111171111188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88o111111711111171117171717117111711711111111711111188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo81777111711111777177717711171117117711111171117771oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo81111117111111117171117171171117117111111117111111oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
88oo88oo88oo88oo88oo88oo88oo88oo88oo88o111117111111177117111717177711711777111111171111188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
88oo88oo88oo88oo88oo88oo88oo88oo88oo88o111111111111111111111111111111111111111111111111188oo88oo88oo88oo88oo88oo88oo88oo88oo88oo
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo82oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88
oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88oo88

