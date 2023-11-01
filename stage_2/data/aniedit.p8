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
	cartdata"kalikan_aniedit_2"

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
bdddddbbbbbbbbbbbbddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444bbb44444aa44444aaaa44
dd8888bbbbbbbbbbbd99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bcccb44aabbaa44abccba4
d08888bbbbbbbbbbd999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bc373cbabbccbba4ab77ba4
d09999bbbbbbbbbd8999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc3777cbac3333caabc77cba
d99889bbbbbbbbbd8999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc7773cbac3333caabc77cba
d98999bbbbbbbbbd8999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc373cb4abbccbba4ab77ba4
d98999bbbbbbbbbd8990eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bcccb444aabbaa44abccba4
d99999bbbdddddd88998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bbb444444aa44444aaaa44
d99998bbd99977988999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444111444440044444000044
d99998bd899777988999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441222144001100440122104
d99988d8897779980909eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412373210112211040177104
d99988d88977999009d8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123777210233332001277210
d99988d889779990d999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee127773210233332001277210
d99998d889779900d899eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123732140112211040177104
d99998d880660000d489eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412221444001100440122104
d99999d80066000dd568eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441114444440044444000044
d90999d0054ee45ed567eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d98999d0ee5445eed567eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99889bddeeeeeedd675eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
dd9999bbbbbbbbbbd75deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bde54ebbbbbbbbbbd5ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bdee54bbbbbbbbbbd5ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbdeeebbbbbbbbbbd65deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbbd65eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeebbbbbbbbbbbbddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ebbdddbbbbbbbbbbbd99eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ebdd77bbbbbbbbbbd877eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
edd777bbbbbbbbbbd677eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ed7777bbbbbbbbbbd677eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ed7777bbbbbbbbbbd699eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ed7777bbbdddddddd899eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
edd777bbd6688888d807eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ebd477bd66888880d707eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ebbd44d7709990006707eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd000db
ebbd56d009990ddd6707eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed87778d
ebbd56d99999d4446705eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0878780
ebbd56d00000477d6508eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0877880
ebbd56d00999d7764587eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbddbbeeeeeee0878780
ebd656bd988867764603eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbd99ddeeeeeeed87778d
ed7756bd888867768740eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdd899d6eeeeeeebd000db
ed7756bbd00067768574eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6089986eeeeebdddddddb
ed7756bbd00065560854bbdddddbbbdddddbbbdddddbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbdddbbd089985eeeeedd08880dd
ed6677bbbddd5885d00dbdd888ddbdd999ddbdd000ddbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd800dbbd8778deeeeed0977790d
ed5677bbbbbd5005dddbdd89988ddd97799ddd08800ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd94554bbd6776deeeeed8979798d
ed5566bbbbbd5005dbbbd8979988d9777799d0898800deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed845660bbd6556deeeeed8977998d
edd566bbbbbbd66dbbbbd8999988d9777799d0888800deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056678bbd5005db5555d8979798d
ebddddbbbbbbbddbbbbbd8899888d9977999d0088000deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056789bbbd55db555b5d0977790d
bbbbddbbbbddbbbbddeedd88888ddd99999ddd00000ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd40897bbbbddbb55bb5dd08880dd
bbbd77bbbd88bbbd99eebd48884dbd49994dbd40004dbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056789b444444b5bbb5bdddddddb
bbd977bbd988bbd999eebbd444dbbbd444dbbbd444dbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed056678444bb4445bbb5dd00d88dd
bbd799bbd099bbd899eebbd565dbbbd565dbbbd565dbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed845660544444455bbb5d5668996d
bbd777bbd000bbd888eebbd565dbbbd565dbbbd565dbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd94554b555555b5bbb5d5068997d
bbd777bbd080bbd898eebbd565dbbbd565dbbbd565dbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd800dbb6666bb5bbb5d5688997d
bbd777bbd088bbd899eebbd565dbbbd565dbbbd565dbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbeeeeeeeeeeebbbdddbb666666b5bbb5d5068997d
bbd777bbd088bbd899eebd65656dbd65656dbd65656dbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeeeeeeb54bb5555bb666bb6665bbb5d5668996d
bd4777bd5088bd5899eed7756577d7756577d7756577deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeee55454b5555555566bbbb665bbb5dd00d88dd
d45777d56088d56899eed7756577d7756577d7756577deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbeeeeb44b5b554bb45566bbbb665bbb5bdddddddb
d74777d67088d67899eed7756577d7756577d7756577deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7bbbbbbbbb7eeeeb44555554bb455666bb6665bbb5dd8d888dd
d67466d56700d56788eed6677766d6677766d6677766deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbb66b55465555555555b666666b5bbb5d4089776d
d56777d45666d45666eed5677765d5677765d5677765deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb655555bb6bbb5555bbbb6666bb5bbb5d5089796d
dd5666dd4555dd4555eed5566655d5566655d5566655deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb565bbbb6beebbbbb3bbb3bbbbe5bb55d5089779d
bdd555bdd444bdd444eedd56665ddd56665ddd56665ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbbb45bb6565bbbbbb3bbb2bbbbe5b555d5089796d
bbddddbbddddbbddddeebdddddddbdddddddbdddddddbeeeeeeeeeeeeeeeeeeeeeeeeebbddbbbbddbbbbddbbb444b555554bbbbb3bbb2bbbbe55555d4089776d
bbbbddbbbbbbbbbbddbbbbbbbbbbbbd8888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd77dbbd77dbbd77db44445555bb4bb3bb3bbbbbbbbe55554dd8d888dd
bbbe77ebbbbbbbbe77ebbbbbbbbbbe78888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd66dddd66dddd66dd444b455bb5bb33b312bbbbbbbe4444bbdddddddb
bbbe66dbbbbbbbbd66dbbbbbbbbbbd6888888888888888888888888888888888888888d7777dd6777dd7777db4bbb4bbb65b332112bbbbbb3bbbddddddbbbeee
bbbd66dbbbbbbbbd66dbbbbbbbbbbd6888888888888888888888888888888888888888d6666dd5666dd6666dbb5555bbbb2bb11112bbbbb2bbbd622225dbbeee
bbbd555ebbbbbbbd554ebbbbbbbbbd58888888bbbbbbbbbbbbbbb55bbbbb55bbb55b88d644ddd5666dd4ee4db555555bb223b111122bbb2bbbd72332226dbddb
bbd6556ddebbbbd6556dbdebbbbbe658888888bbbbbbbbbbbbbb5775bbb5775b577588d655ddd5666dd4554d555bb555b21311111222bbbbbd7137332216d67d
bed5446e6debedd5446de5debedbd648888888bbbbbbbbbbbbbb5775bbb5775b577588d6666dd5666dd6666d55bbbb55221b11111122bbb3bd6133332216d67d
e4e4774475ded5e47744475ded5ed478888888bbbbbbbbbbbbbb5775bbb6776b577588d5555dd4555dd5555d55bbbb55211b21111122bb2bbd6123322215d67d
d565775477dd46557754577dd5744578888888bbbbbbbbbbbbbb6776bbb6776b677688dd55dddd55dddd55dd555bb555211bb1111112bbbbbd6412222145d67d
d5e5ee5467dd56e5ee54567dd77545e8888888bbbbbbbbbbbbb567765bb6776b677688bd44dbbd44dbbd44dbb555555b211bbb11111bbbbbbd6741111465d67d
d4e5675465dd5ee5775e565dd7654578888888bb66bbbb66bbb567765b577775677688bbddbbbbddbbbbddbbbb5555bbb21bbbb111bbbbbbbd5674444654d67d
e4ee567e75de45e4667e67ebd565e768888888b6776bbb77bb56777765577775677688bbbb3bbbbe8888888888888888bbb66666bbbbbbbbbbd56667754dbddb
dde44564ddbdd6ee556d4edbbe76e658888888b7777bb6776b66777766677776677688bbbb1bbbbe8888888888888888bb6777776bbbbbbbbbbd555544dbbeee
bdd5dd754ebbddd5dd7e54dbbde4d7d8888888b7667bb7777b66677666677776677688bbbb1bbbbe8888888888888888b677bbb776bbbbbbbbbbddddddbbbeee
be4ee4e6dbbbbe4ee4de6dbbbd45dd48888888676676b7667b67677676677776666688bbb222bbbe8888888888888888677bbbbb776bbbbbbbbddddbbbddbbee
bd5edde6dbbbbd5eddbd6dbbbbe6ebd888888877667767667667677676677776666688311222113e888888888888888867bbbbbbb76bbbbbbbd6777dbd67dbee
bd6dbbd7dbbbbd6dbbbd6dbbbbd6ebb888888876666777667767777776667766666688bbb222bbbe666777766688888867bbbbbbb76b7777bd665567d6667dee
bd6dbbd7dbbbbd6dbbbd7dbbbbd6dbb888888876666777667766777766667766666688bbbb1bbbbe676677667688888867bbbbbbb76777777d656676d6576dee
bd6dbbbdbbbbbd6dbbbbdbbbbbd7dbb8888888776677776677b677776bb6666b666688bbbb1bbbbe6776776776888888677bbbbb776776677d656676d6576dee
bbdbbbbbbbbbbbdbbbbbbbbbbbbdbbb8888888b7777bb7777bbb6666bbbb66bbb66b88bbbb3bbbbe6666776666888888b677bbb776b776677d567766d5666d55
b000000b000000bbb000000bb000000b000000000000000bbb00000b00000000b000000bb000000bb55666655b888888bb6777776bb777777bd5556dbd56db55
00dddd000dddd0bb00dddd0000dddd000d00ddd00ddddd0bb00ddd0b0dddddd000dddd0000dddd00bb456654bb888888bbb66666bbbb7777bbbddddbbbddbb55
0ddd00d000ddd0bb0d00ddd00d00ddd00d00ddd00ddd000b00dd000b0000ddd00ddd00d00d00ddd0bbb4554bbb888888bbb77777bbbbbb77777bbb4444444455
1dbb11d1d1bbb1bb1111bbd11111bbd11b11bbb11bbb1ddb1ddb1ddbddd1bbb11dbb11d11d11bbd100b00b0000000000bb7777777bbbb7777777bb5555555555
2bbb2db2d2bbb2bbdd22bbb2d222bbb22b22bbb22bbb222b2dbb222bdd22bbb22bbb22b22b22bbb211b11bd11ddd11ddb777777777bb777666777bbbbddbbb55
2bbbddb2b2bbb2bbd22dbb22d2ddbb222bddbbb22bbbdd222bbbdd22bb2dbb2222bbdd2222ddbbb222b22bb22bbb22bb7777777777777766666777bbd66dbb55
2bbbd2b2b2bbb2bb22ddb22db222bbd22222bbb22222ddd22bbb22d2b22dbb2d2dbb22d2d222bbb222b22bb22bbb22bb7777767777777666b66677bbe55ebb55
2bbb22b2b2bbb2bb2ddb22dd2222bbd2ddd2bbb22222bbd22bbb22d2b2dbb22d2dbb22d2ddd2bbb222222bb22bbb22bb777766677777766bbb6677bd6446db55
1bbb11b111bbb1111dbb11111d11bbb1ddd1bbb11d11bbb11bbb11b1b1dbb1db1bbb11b1b111bbb122d22bb22bbb22bb7777767777777666b66677be5775eb55
00bbdd000dbbbbd00bbbddd000ddbb00bbb0bbb000ddbb0000bbdd00b0bbb0db00bbdd00b0ddbb0011b11bb11bbb11bb7777777777777766666777d6e77e6d55
d000000d0000000000000000d000000dbbb00000d000000dd000000db00000bbd000000db000000d00b00bb00bbb00bbb777777777bb777666777be57ee75e55
ddddddddddddddddddddddddddddddddbbbdddddddddddddddddddddbdddddbbddddddddbddddddd00b00b0000bb00bbbb7777777bbbb7777777bbd454454d54
bddddddbddddddddddddddddbddddddbbbbdddddbddddddbbddddddbbdddddbbbddddddbbddddddbddbddbddddbbddbbbbb77777bbbbbb77777bbbbe4dd4eb4b
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

