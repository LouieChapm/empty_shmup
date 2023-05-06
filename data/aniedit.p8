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

#include ../base_shmup.lua
#include ../debugfuncs.lua


function _init()
    add(numbers,",")

	t=0
	temp=""

    menuitem(1, "export sprites", function() export_sprites() end)

	init_baseshmup(enemy_data)
    spr_library=parse_data(spr_library)
    anim_library=parse_data(anim_library)


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
        if(global_mode=="sprite")spr_obj(nav.lib_index,63,63)
        if global_mode=="anim" then
            if(nav.vert<=1)sspr_anim(nav.ani_index, 63, 63)
            if(nav.vert>1)spr_obj(cur_frames[nav.vert-1], 63, 63)
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
                    spr_library[nav.lib_index].exists=true
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

function sspr_anim(_index, _x, _y)
    local frames = anim_library[_index]
    spr_obj(frames[t\8%#frames+1], _x, _y)
end

function spr_obj(_data, _x, _y)
    if(not spr_library[_data] or #spr_library[_data]<=1)return
    local sx,sy,sw,sh,ox,oy,transparent,mirror_mode,flip_h,stack=unpack(spr_library[_data])
    flip_h=flip_h==1

    if stack!=0 then
        for i=1,3 do pal(i,7) end
        if stack==1 then
            palt(3,true)
        else
            palt(2,true)
        end
    end
    if(transparent!=-1)palt(transparent,true)
    sspr(sx,sy,sw,sh,_x+ox,_y+oy,sw,sh,flip_h)
    -- gotta be some tokens here
    if(mirror_mode==1 or mirror_mode==3)sspr(sx,sy,sw,sh,_x+ox+sw,_y+oy,sw,sh,not flip_h)
	if(mirror_mode==4)sspr(sx,sy,sw,sh,_x+ox+sw-1,_y+oy,sw,sh,not flip_h)
    if(mirror_mode==2 or mirror_mode==3)sspr(sx,sy,sw,sh,_x+ox,_y+oy+sh,sw,sh,false,true)
    if(mirror_mode==3)sspr(sx,sy,sw,sh,_x+ox+sw,_y+oy+sh,sw,sh,not flip_h,true)
    if(transparent!=-1)palt(transparent,false)

    if stack!=0 then
        for i=1,3 do pal(i,i) palt(i,false) end
    end
end

--[[
function spr_obj(_data, _x, _y)
    local sx,sy,sw,sh=unpack(split(_data[1]))
    local ox,oy=unpack(split(_data[2]))
    local transparent=_data[3]
    local mirror_mode=_data[4]
    local flip_h=_data[5]==1
    local stack=_data[6]

    if stack!=0 then
        for i=1,3 do pal(i,7) end
        if stack==1 then
            palt(3,true)
        else
            palt(2,true)
        end
    end

    if(transparent!=-1)palt(transparent,true)
    sspr(sx,sy,sw,sh,_x+ox,_y+oy,sw,sh,flip_h)
    -- gotta be some tokens here
    if(mirror_mode==1 or mirror_mode==3)sspr(sx,sy,sw,sh,_x+ox+sw,_y+oy,sw,sh,not flip_h)
    if(mirror_mode==2 or mirror_mode==3)sspr(sx,sy,sw,sh,_x+ox,_y+oy+sh,sw,sh,false,true)
    if(mirror_mode==3)sspr(sx,sy,sw,sh,_x+ox+sw,_y+oy+sh,sw,sh,not flip_h,true)
    if(transparent!=-1)palt(transparent,false)

    if stack!=0 then
        for i=1,3 do pal(i,i) palt(i,false) end
    end
end
]]--

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
eeeeeeeeeeeeeeeeeeeeeeee44e55e44e44eee4454e444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee4eeeeeee55eeee55e4eeee444ee444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee777eeeee777eeeee7e7eeeee777ee
eeeeeeeeeeeeeeee4eeeeeee55e44e55e5eeee4454e4445eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeee7eeeeeee7eeeee7e7eeeee7eeee
eeeeeeeeeeeeeeee4eeeeeee44e44e44e4eeee4444e4444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeee777eeeeee77eeeee777eeeee777ee
eeeeeeeeeeeeeeee4ee4eeee55e44e55e44eeeeee444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeee7eeeeeeeee7eeeeeee7eeeeeee7ee
eeeeeeeeeeeeeeee4ee4eeee55544555e44eeeeeee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeee777eeeee777eeeeeee7eeeee777ee
eeeeeeeeeeeeeeeeeeeeeeee55e44e554555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee
eeeeeeeeeeeeeeeeeeeeeeee55e44e54e555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee77eeeeee77eeeeee77eeeeee77eeeeee
eeeeeeeeeeeeeeeeeeeeeeeeccccce64e555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeee4ccccce644555555eee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee777eeeee777eeeee777eeeee777ee
eeeeeeeeeeeeeeeeeeeeeee4ccccce64e44eeeeeee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeeeee7eeeee7e7eeeee7e7eeeee7e7ee
eeeeeeeeeeeeeeeeeeeeeee4ccccce64e44eeeeee444444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeeeee7eeeee777eeeee777eeeee7e7ee
eeeeeeeeeeeeeeeeeeee4ee4ccccce64e4eeee4444e4444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7e7eeeeeee7eeeee7e7eeeeeee7eeeee7e7ee
eeeeeeeeeeeeeeeeeeee4ee4ccccce64e5eeee4454e4445eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee777eeeeeee7eeeee777eeeeeee7eeeee777ee
eeeeeeeeeeeeeeeeeeeeeeeeccccce64e4eeee444ee444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee7eeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeccccce64e44eee4454e444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee77eeeeee77eeeeee77eeeeee77eeeeee
eeeeeeeeeeeeeeeeeeeeeeee46ecccccee444e4544eee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee46ecccccee444ee444eeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee46eccccce5444e4544eeee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee46eccccce4444e4444eeee4eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee46eccccce444444eeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee46eccccce44444eeeeeee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee46eccccce44444eee5555554eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee46eccccce44444eee555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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
bbbbbbbbbbbbddbddbbbbbbbbddddbbbbbbbbddebbbbbbbbbbbbbdddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbbd99bd7dbbbbbbd7667dbbbbbbd7debbbbbbbbbbbbdd9999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd877bd0dbbbbbd86996dbbbbbd777ebbbbbbbbbbbdd99888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd677bd8dbbbbd889999dbbbbbd767ebbbbbbbbbbdd998999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd677bd98dbbbd889999dbbbbbd666ebbbbbbbdddd8999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbbbbd699bd99dbddd889999dbbddbd676ebbbbbbdd9999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbdddddddd899d7898dd9d889999dbd77dd677ebbbbbdd99999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd6688888d807d6709d87d889999dbd776d655ebbbbdd999999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd66888880d707d9679567d886996dd67769966ebbbdd8989999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d7709990006707d8960769d886996dd67769966ebbbd88989999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d009990ddd6707bd897d80d887667dd67768866ebbbd88989999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d99999d4446705bd05dd05d885005dd65568666ebbbd80989999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d00000477d6508bd56dbd0d800000dd58850676ebbbd00909999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d00999d776e587bd6dbbbdd000000dd50050677ebbbd09909999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd98886776e603bddbbbbbd0000ddbd50050655ebbbd89999999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd888867768740eeeeeeeed000dbbbbd66d0666ebbd889009009999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd00067768574eeeeeeeed000dbbbbbddbd767ebbd889889889999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd00065560854eeeeeeeebdddbbbbbbbbbd777ebbd889889889999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbddd5885d00deeeeeeeeeeeeeeeebbbbbd575ebbd889999999999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbd5005dddbeeeeeeeeeeeeeeeebbbbbd565ebdd800000009999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbd5005dbbbeeeeeeeeeeeeeeeebbbbbdd6dedd4000000000999999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbd66dbbbbeeeeeeeeeeeeeeeebbbbbbddded44000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbbbddbbbbbeeeeeeeeeeeeeeeeeebbbbddbbd44077777770055777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbbddddbbbbbbbbbbbdddbbbbbbbbbbbbd99ddd44765656567455555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbbd0766dbbbbbbbbbd766dddbbbbbbbdd899d6d447767676774d5555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbbd990066dbbbbbbbd9006688ddbbbbd6089986d445555555554dd555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd90999988dbbbbbd9999088888ddbbbd089985d4589977799854dd4deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bbd990dd0088dbbbbd099dd0088886dbbbd8778dd5488999998845dd44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd889044d0088dbbd990044d0098866dbbd6776dd5488989898845ddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
bd888d744d0986dbd8899644d099986dbbd6556dd5408888888045dbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d088877744d9966dd08887744d99907dbbd5005dd5400808080045dbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d008777764d9906dd08867776009990dbbbd55dbdd50080808005ddbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d00777766009907dd00877766990990dbbbbddbbbdd555555555ddbbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
d07777669990990dd00677768889000deeeeeeeebbdddddddddddbbbbbeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
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

