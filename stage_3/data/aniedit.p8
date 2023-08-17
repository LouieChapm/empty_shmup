pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
bg_col=8
ln_col=9

show_ui=true

debug=""
debug_time=0

max_sprites=30

alphabet=split"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,_" -- letters and underscore 
numbers=split("0,1,2,3,4,5,6,7,8,9,-,., ",",",false)

info_types=split"sspr,offset,palt,mirror,flip,spr_stack"
anim_info_types=split"frames"

#include inf_sprites.txt
#include inf_enems.txt

#include ../src/sprfuncs.lua

#include ../base_shmup.lua
#include ../debugfuncs.lua


function _init()
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

        lib_index=1,
        ani_index=1,
    }

	poke(0x5f2d, 1) -- keyboard access

	palt(0,false)

	old_transparent=-1
end


function _update60()
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

    fillp(▤)
    line(63,0,63,60,2)
    line(63,66,63,128,2)
    fillp(▥)
    line(0,63,60,63,2)
    line(66,63,128,63,2)
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
	print("\#1"..tostring(text),x,y,c or 7)
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444bbb44444aa44444aaaa44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bcccb44aabbaa44abccba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bc373cbabbccbba4ab77ba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc3777cbac3333caabc77cba
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc7773cbac3333caabc77cba
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc373cb4abbccbba4ab77ba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bcccb444aabbaa44abccba4
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bbb444444aa44444aaaa44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444111444440044444000044
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441222144001100440122104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412373210112211040177104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123777210233332001277210
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee127773210233332001277210
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee123732140112211040177104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee412221444001100440122104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee441114444440044444000044
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbbd94554b555555b5bbb5d5068997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbbbd800dbb6666bb5bbb5d5688997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbbbbdddbb666666b5bbb5d5068997d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbbb5555bb666bb6665bbb5d5668996d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7bbbbbbbbb7555555566bbbb665bbb5dd00d88dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb54bb45566bbbb665bbb5bdddddddb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb54bb455666bb6665bbb5dd8d888dd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbbbbbbbb5555555b666666b5bbb5d4089776d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbb7bbbbbb5555bbbb6666bb5bbb5d5089796d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbb6beeeeeebbbbb3bbb3bbbbe5bb55d5089779d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebb656bb45eebbbbb3bbb2bbbbe5b555d5089796d
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbddbbbbddbbbbddbbb5555b444eebbbbb3bbb2bbbbe55555d4089776d
88888888888888888888888888888888888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd77dbbd77dbbd77db5555b4444eebb3bb3bbbbbbbbe55554dd8d888dd
88888888888888888888888888888888888888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd66dddd66dddd66dd455bb444beeb33b312bbbbbbbe4444bbdddddddb
8888888888888888888888888888888888888888888888888888888888888888888888d3333dd2333dd3333db4bbbb4bbeeb332112bbbbbb3bbbddddddbbbeee
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
d21d3dd310ddbd21d63dd31d01dd321d63d88827777227777227777772227722222288bbb222bbbe888888888888888837bbbbbbb73b7777bd665567d6667dee
d10d12223ddbbd10d122223d0dddd10d12288827777227777222777722227722222288bbbb1bbbbe888888888888888837bbbbbbb73777777d656676d6576dee
dd0d301d4dbbbdd0d3d11d4ddbbbdd0d3d1888227722277772b277772bb2222b222288bbbb1bbbbe8888888888888888377bbbbb773773377d656676d6576dee
bbdd44d4dbbbbbbdd44dd4ddbbbbbbdd44d888b2772bb2772bbb2222bbbb22bbb22b88bbbb3bbbbe8888888888888888b377bbb773b773377d567766d5666d55
000000bbb000000bb000000b000000000000000bbb00000b00000000b000000bb000000bb000000b8888888888888888bb3777773bb777777bd5556dbd56db55
0dddd0bb00dddd0000dddd000d00ddd00ddddd0bb00ddd0b0dddddd000dddd0000dddd0000dddd008888888888888888bbb33333bbbb7777bbbddddbbbddbb55
00ddd0bb0d00ddd00d00ddd00d00ddd00ddd000b00dd000b0000ddd00ddd00d00d00ddd00ddd00d08888888888888888bbb77777bbbbbb77777bbbeeeeeeee55
d1bbb1bb1111bbd11111bbd11b11bbb11bbb1ddb1ddb1ddbddd1bbb11dbb11d11d11bbd11dbb11d100b00b0000000000bb7777777bbbb7777777bbeeeeeeee55
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

