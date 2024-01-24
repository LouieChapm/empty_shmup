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

#include ../src/sprfuncs.lua
#include ../src/base_shmup.lua
#include ../src/debugfuncs.lua


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
				if(global_mode=="sprite")spr_library[nav.lib_index]={}
				if(global_mode=="anim")anim_library[nav.ani_index]={}
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
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbbddbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbd99ddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdd899d6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6089986eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd089985eeeeeeeeeeeeeeeeeeeebbb111bbbbb00bbbbb0000bb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd8778deeeeeeeeeeeeeeeeeeeebb12221bb001100bb012210b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd6776deeeeeeeeeeeeeeeeeeeeb123732101122110b017710b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd6556deeeeeeeeeeeeeeeeeeee123777210233332001277210
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd5005deeeeeeeeeeeeeeeeeeee127773210233332001277210
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbb77777bbbbbb77777bbbbbb66666bbbeeeeebbbd55dbeeeeeeeeeeeeeeeeeeee1237321b01122110b017710b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebb7777777bbbb7777777bbbb6777776bbeeeeebbbbddbbeeeeeeeeeeeeeeeeeeeeb12221bbb001100bb012210b
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb777777777bb777666777bb677bbb776beeeeeebbbbb7bbbbbeeeeeeeeeeeeeeeebb111bbbbbb00bbbbb0000bb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777777777766666777677bbbbb776eeeeeebbbbbbbbbbbeeeeeeeeeebbbbb3bbb3bbbbeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777767777777666b6667767bbbbbbb76eeeeeebbbbbbbbbbbeeeeeeeeeebbbbb3bbb2bbbbeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777766677777766bbb667767bbbbbbb76b7777bbbbbbbbbbbbeeeeeeeeeebbbbb3bbb2bbbbeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777767777777666b6667767bbbbbbb767777777bbbbbbbbb7eeeeeeeeeebb3bb3bbbbbbbbeeeeeeebbbb3bbbb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777777777766666777677bbbbb776776677bbbbbbbbbbbeeeeeeeeeeb33b312bbbbbbbeeeeeeebbbb1bbbb
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb777777777bb777666777bb677bbb776b776677bbbbbbbbbbbeeeeeeeeeeb332112bbbbbb3eeeeeeebbbb1bbbb
bbbbeebbbbbbbbbbeebbbbbbbbbbbbeeeeeeeebb7777777bbbb7777777bbbb6777776bb777777bbbbbbbbbbbeeeeeeebb2bb11112bbbbb2beeeeeeebbb222bbb
bbbe77ebbbbbbbbe77ebbbbbbbbbbe7eeeeeeebbb77777bbbbbb77777bbbbbb66666bbbb7777bbbbbb7bbbbbeeeeeeeb223b111122bbb2bbeeeeeee311222113
bbbe66dbbbbbbbbd66dbbbbbbbbbbd6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeb21311111222bbbbbeeeeeeebbb222bbb
bbbd66dbbbbbbbbd66dbbbbbbbbbbd6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee221b11111122bbb3beeeeeeebbbb1bbbb
bbbd555ebbbbbbbd554ebbbbbbbbbd5eeeeeeebbbbbbbbbbbbbbb55bbbbb55bbb55beeeeeeeeeeeeeeeeeeeeeeeeeee211b21111122bb2bbeeeeeeebbbb1bbbb
bbd6556ddebbbbd6556dbdebbbbbe65eeeeeeebbbbbbbbbbbbbb5775bbb5775b5775eeeeeeeeeeeeeeeeeeeeeeeeeee211bb1111112bbbbbeeeeeeebbbb3bbbb
bed5446e6debedd5446de5debedbd64eeeeeeebbbbbbbbbbbbbb5775bbb5775b5775eeeeeeeeeeeeeeeeeeeeeeeeeee211bbb11111bbbbbbeeeeeeeeeeeeeeee
e4e4774475ded5e47744475ded5ed47eeeeeeebbbbbbbbbbbbbb5775bbb6776b5775eeeeeeeeeeeeeeeeeeeeeeeeeeeb21bbbb111bbbbbbbeeeeeeeeeeeeeeee
d565775477dd46557754577dd574457eeeeeeebbbbbbbbbbbbbb6776bbb6776b6776eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d5e5ee5467dd56e5ee54567dd77545eeeeeeeebbbbbbbbbbbbb567765bb6776b6776eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d4e5675465dd5ee5775e565dd765457eeeeeeebb66bbbb66bbb567765b5777756776eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e4ee567e75de45e4667e67ebd565e76eeeeeeeb6776bbb77bb567777655777756776eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbbddbbbee
dde44564ddbdd6ee556d4edbbe76e65eeeeeeeb7777bb6776b667777666777766776eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbd66dbbee
bdd5dd754ebbddd5dd7e54dbbde4d7deeeeeeeb7667bb7777b666776666777766776eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbe55ebbee
be4ee4e6dbbbbe4ee4de6dbbbd45dd4eeeeeee676676b7667b676776766777766666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebd6446dbee
bd5edde6dbbbbd5eddbd6dbbbbe6ebdeeeeeee776677676676676776766777766666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebe5775ebee
bd6dbbd7dbbbbd6dbbbd6dbbbbd6ebbeeeeeee766667776677677777766677666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed6e77e6dee
bd6dbbd7dbbbbd6dbbbd7dbbbbd6dbbeeeeeee766667776677667777666677666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee57ee75eee
bd6dbbbdbbbbbd6dbbbbdbbbbbd7dbbeeeeeee776677776677b677776bb6666b6666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed454454dee
bbdbbbbbbbbbbbdbbbbbbbbbbbbdbbbeeeeeeeb7777bb7777bbb6666bbbb66bbb66beeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebe4dd4ebee
__label__
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5llllllllllllllllllllllllllllllllldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dll66666llllll6l6l666llllll66666ll55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl666ll66lllll666lll6lllll66ll666l55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5l66lll66lllll6l6ll66lllll66lll66ldd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5l666ll66lllll666lll6lllll66ll666ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dll66666llllll6l6l666llllll66666ll55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dlllllllllllllllllllllllllllllllll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlllllllllllllllllllllllllllllllll55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dll77l777l777llllll77ll77l777l777l55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5l7lll7llll7llllll7lll7lll7l7l7l7ldd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5l777l77lll7llllll777l777l777l77lldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlll7l7llll7llllllll7lll7l7lll7l7l55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl77ll777ll7llllll77ll77ll7lll7l7l55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5llllllllllllllllllllllllllllllllldd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlllllllllllllllllllllllllllllllllllllllll55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dll77l777l777llllll77l777l777ll77l777l777l55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5l7lll7llll7llllll7l7l7lll7lll7lll7llll7lldd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5l777l77lll7llllll7l7l77ll77ll777l77lll7lldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlll7l7llll7llllll7l7l7lll7lllll7l7llll7ll55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl77ll777ll7llllll77ll7lll7lll77ll777ll7ll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5llllllllllllllllllllllllllllllllllllllllldd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlllllllllllllllllllllllllllllllll55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl777l777l7lll777lllllllll77ll77ll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5l7l7l7l7l7llll7lll7lllllll7lll7lldd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5l777l777l7llll7lllllllllll7lll7lldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dl7lll7l7l7llll7lll7lllllll7lll7ll55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl7lll7l7l777ll7llllllllll777l777l55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5llllllllllllllllllllllllllllllllldd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlllllllllllllllllllllllllllllllllllll55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl777l777l777l777ll77l777lllllllll77ll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5l777ll7ll7l7l7l7l7l7l7l7ll7lllllll7lldd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5l7l7ll7ll77ll77ll7l7l77lllllllllll7lldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dl7l7ll7ll7l7l7l7l7l7l7l7ll7lllllll7ll55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl7l7l777l7l7l7l7l77ll7l7lllllllll777l55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5llllllllllllllllllllllllllllllllllllldd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlllllllllllllllllllllllllllll55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl777l7lll777l777lllllllll777l55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5l7lll7llll7ll7l7ll7llllll7l7ldd55dd55dd55dd55dd55dd55dd55dd55dii5dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5l77ll7llll7ll777lllllllll7l7ldd55dd55dd55dd55dd55dd55dd55dd55l77ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dl7lll7llll7ll7llll7llllll7l7l55dd55dd55dd55dd55dd55dd55dd55ddi66i55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl7lll777l777l7lllllllllll777l55dd55dd55dd55dd55dd55dd55dd55ddi66i55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5llllllllllllllllllllllllllllldd55dd55dd55dd55dd55dd55dd55dd55iddidd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5l6dd6ld55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlllllllllllllllllllllllllllllllllllllllllllllllll55dd55ddlidi6556i5il55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
lll77l777l777llllll77l777l777ll77l7l7lllllllll777ll5ldl5llidli5l75ildil5ldl5ldl5ldl5ldl5ldl5ldl5ldl5ldl5ldl5ldl5ldl5ldl5ldl5ldl5
5l7lll7l7l7l7lllll7llll7ll7l7l7lll7l7ll7llllll7l7ldd55dd5id755d77d557did55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
5l777l777l77llllll777ll7ll777l7lll77llllllllll7l7ldd55dd5i77d5dlld5d77id55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dlll7l7lll7l7lllllll7ll7ll7l7l7lll7l7ll7llllll7l7l55dd55di76d5d77d5d67i5dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dl77ll7lll7l7l777l77lll7ll7l7ll77l7l7lllllllll777l55dd55did6dl7667ld6di5dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
5llllllllllllllllllllllllllllllllllllllllllllllllldd55dd55l76l6dd6l67ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55il5i7ii7i5lidd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55ddi5dii55iid5i55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5l6l5iidl6ld55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55di6ldl55l6i5dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55di6idd55i6i5dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5i7i5lddi7id55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55id55dd5idd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dl55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5llllllllllllllllllllllllllllllllllllllllllllllllldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dlllll7llllllll77l777l777l777l777l777lllllll7lllll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dllllll7llllll7lll7l7l7l7ll7lll7ll7llllllll7llllll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5l777lll7lllll777l777l77lll7lll7ll77llllll7lll777ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5llllll7llllllll7l7lll7l7ll7lll7ll7llllllll7lllllldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dlllll7lllllll77ll7lll7l7l777ll7ll777lllllll7lllll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
55dd55dd55dd55dd55dd55dd55dd55dd55dd55dlllllllllllllllllllllllllllllllllllllllllllllllll55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd5ldd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55
dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55dd55

