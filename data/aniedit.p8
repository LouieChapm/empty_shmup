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
ffffffffeeeeeeeeeeeeeeeeeeeeeee4e4ee4e4444ee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ffffffffeeeeeeeeee44444eeeeeeee4e4ee4e4444ee44eeee4444eee44ee44eeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeee4444eeeeeeeeeeeee7e7eeeee777ee
ffffffffeeeeeeeeee44444eeeeeeee4e4ee4ee444eee4eee444444ee4ee444eeeeeeeeeeeeeeeeeeeeeeeeeee444eeee44ee44eeeeeeeeeeee7e7eeeee7eeee
ffffffffeeeeeeeeeeeee44eeeeeeee4e4ee4e4444ee45eee44ee44eeee444eee44ee44eeeeeeeeeeeeeeeeeeee44eeeeeeee44eee444eeeeee777eeeee777ee
ffffffffeeeeeeeeeeeee44eeeeeeee4e4ee4e4444ee44eee444444eee444eeee44ee44eeeeeeeeeeeeeeeeeeee44eeeee4444eeee444eeeeeeee7eeeeeee7ee
ffffffffeeeeeeeeeeeee44eeeeeeee4e4444e44eeee44eee44ee44ee444ee4eeeeeeeeeeeeeeeeeeeeeeeeeeee44eeee44eeeeeeee44eeeeeeee7eeeee777ee
ffffffffeeeeeeeeeeeeeeeeeee4e4e4e4444e44eeeeeeeee44ee44ee44ee44eeeeeeeeeeeeeeee55eeeeeeeee4444eee444444eeeeeeeee7eeeeeee7eeeeeee
ffffffffeeeeeeeeeeeeeeeeeeeeeee4e444455555555544eeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555eeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeeeee77eeeeee
eeeeeeeeeeeeeeeeeeeeeeee4eeeeeeee444e5ee44444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeee44444444eeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee4eeeeeeee444e5ee44444eeee44444eee44444eeeee44eeeee5555eeeee44eeeee4444ee44eeee44eeeeeeeeeee777eeeee777ee
eeee4444444444444444eeee4eeeeeeee444e55555555544e44ee44ee44444eeeee44eeeee4444eeeee44eeee44ee44e44e44e44eeeeeeeeeee7e7eeeee7e7ee
ee44ffffffffffffffff44ee4eeeeeeee444eeeeeeeeeeeee44444eee44eeeeeeeeeeeeeeeeeeeeeeee44eeee44eeeee44e44e44eee444eeeee777eeeee7e7ee
e4ffffffffffffffffffff4e4eeeeeeee444eeeeeeeeeeeee44ee44ee44eeeeeeeeeeeeeeeeeeeeeeee44eeee44eeeee44eeee44eee444eeeeeee7eeeee7e7ee
4ffffffffffffffffffffff44eeeeeeee4444e4444eee4eee44ee44ee44eeeeeeee44eeeeeeeeeeeeee44eeee44ee44e44e44e44eee44eeeeeeee7eeeee777ee
4ffffffffffffffffffffff44e4e4eeee4444e4444ee45eee44444eeeeeeeeeeeee44eeeeeeeeeeeeee44eeeee4444eeeee44eeeeeeeeeee7eeeeeee7eeeeeee
4ffffffffffffffffffffff44eeeeeeee4444ee444ee44eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44eeeeeeeeeeeeee44eeeeeeeeeee77eeeeee77eeeeee
4ffffffffffffffffffffff45444ee45ee44ee4444e4ee4e55555555e444444eeeeeee5555eeeeee4555555555555554eeeee444444eeeee4eee4effffe4eee4
4f5f5fff5fff5fff5fff5f645444ee45ee44ee4444e4ee4e55555555e444444eeeeeee5555eeeeee5555555555555555ee55ee4444ee55ee4eee4effffe4eee4
466f5f5f5f5f5f5f5f5f56645e44ee45ee4eee444ee4ee4eeeeeeeee55555555eeeeee5555eeeeee555eeeeeeeeee555eee45ee44ee54eee4eee4eeffee4eee4
e4666f5f5f5f5f5f5f56664e5e44ee45ee54ee4444e4ee4eeeeeeeeeeeeeeeeeeeeeee5555eeeeee55eeeeeeeeeeee5544ee45e44e54ee444eee4e5445e4eee4
ee44666666666666666644ee54e4ee45ee44ee4444e4ee4eeeeeeeee4e4444e4eeeeee5555eeeeee55eeeeeeeeeeee55ee4ee5e44e5ee4ee4eee4e5445e4eee4
eeee4444444444444444eeee54e4ee45ee44eeee44e4444eeeeeeeee444ee444eeeeee5555eeeeee55eeeeeeeeeeee55eee4e4e44e4e4eee4eee4eeffee4eee4
eeeeeeeeeeeeeeeeeeeeeeee544eee45eeeeeeee44e4444eeeeeeeee44444444eeeeee5555eeeeee55eeeeeeeeeeee55eee4eee44eee4eee444e4effffe4e444
eeeeeeeeeeeeeeeeeeeeeeee544eee45445555555554444eeeeeeeeeeeeeeeeeeeeeee5555eeeeee55eeeeeeeeeeee55eee4eee44eee4eee54ee4effffe4ee45
e454ede44ede454effffffff5444ee45eee44444ee5e444e4444444455eeeeeeeeeeeeeeeeeeee554444444444444444ffe4eeeeeeee4effe44d45dddd54d44e
e444edeeeede444effffffff5444ee45eee44444ee5e444e4444444455eeeeeeeeeeeeeeeeeeee554e4e4e4eeeeeeeeeffe4eeeeeeee4effe44d445dd544d44e
e46555eeee55564effffffff54e4ee4544555555555e444e4444444455eeeeeeeeeeeeeeeeeeee55eeeeeeeeeeeeeeeeffee4eeeeee4eeffe44de445544ed44e
e56555444455565effffffff54e4ee45eeeeeeeeeeee444e4444444455eeeeeeeeeeeeeeeeeeee554444444444444444ffeee444444eeeffe44dde4444edd44e
55eeee4dd4eeee55ffffffff54e4ee45eeeeeeeeeeee444e4444444455eeeeeeeeeeeeeeeeeeee55eeeeeeeeeeeeeeeeffeeeeeeeeeeeeffe44ddd4e44ddd44e
545444d44d444545ffffffff54e4ee45ee4eee4444e4444e44444444555eeeeeeeeeeeeeeeeee555eeeeeeeeeeeeeeeeffeeeeeeeeeeeeffe44dd544445dd44e
4e5ee4d44d4ee5e4555555555444ee45ee54ee4444e4444eeeeeeeee555555555555555555555555eeeeeeeeeeeeeeeeffeeeeeeeeeeeeffe44d544ee445d44e
ee54eed44dee45ee555555555444ee45ee44ee444ee4444eeeeeeeee455555555555555555555554eeeeeeeeeeeeeeeefffeeeeeeeeeefffe44d44edde44d44e
e454ede44ede454ede4456666665e4ed48994444408980444000044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee444bbb44444aa44444aaaa44
e454ede44ede454ede45566ee66544ed89ff8444489f98408899880eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee44bcccb44aabbaa44abccba4
ee4eede44edee4eede456665566544ed9f77f84409f7f9089977998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bc373cbabbccbba4ab77ba4
e454eddee4de454ede455665566544ed9f777f8409f7f9097777779eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc3777cbac3333caabc77cba
e454ede44ede454ede4e5665566544ed48f777f909f7f9089977998eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc7773cbac3333caabc77cba
e454ede44ede454ede445665566554ed448f77f909f7f9008899880eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebc373cb4abbccbba4ab77ba4
e454ede44ede454ede445665566654ed4448ff98489f98444000044eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4bcccb444aabbaa44abccba4
e454ede44ede454ede445666666554ed444499844089804eeeeeeeeee3300000300000000300000033000000330000003eeeeeee44bbb444444aa44444aaaa44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee300ddd030dddddd000dddd0000dddd0000dddd00eeeeeee444111444440044444000044
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00dd00030000ddd00ddd00d00d00ddd00ddd00d0eeeeeee441222144001100440122104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee1dd31dd3ddd133311d3311d11d1133d11d3311d1eeeeeee412373210112211040177104
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebdddddddbdddddddbdddddddb2d332223dd223332233322322322333223332d32eeeeeee123777210233332001277210
bb6666bbbb5555bbeeeeeeeeeeeeeeeedd08880ddd00d88ddd8d888dd2333dd22332d33222233dd2222dd33322333dd32eeeeeee127773210233332001277210
b666666bb555555beeeeeeeeeeeeeeeed0977790d5668996d4089776d233322d2322d332d2d3322d2d22233322333d232eeeeeee123732140112211040177104
666bb666555bb555bb5555bbeeeeeeeed8979798d5068997d5089796d233322d232d3322d2d3322d2ddd2333223332232eeeeeee412221444001100440122104
66bbbb6655bbbb5555555555eeeeeeeed8977998d5688997d5089779d1333113131d331d3133311313111333113331131eeeeeee441114444440044444000044
66bbbb6655bbbb55554bb455b444444bd8979798d5068997d5089796d0033dd00303330d30033dd0030dd33000033dd00eeeeeeeeeeeeeeee488044989449884
666bb666555bb555554bb455444bb444d0977790d5668996d4089776dd000000d30000033d000000d3000000dd000000deeeeeeeeeeeeeeee0ff080777989770
b666666bb555555b5555555554444445dd08880ddd00d88ddd8d888dddddddddd3ddddd33dddddddd3dddddddddddddddeeeee00000000eee8fff88777887778
bb6666bbbb5555bbbb5555bbb555555bbdddddddbdddddddbdddddddb3dddddd33ddddd333dddddd33dddddd33dddddd3eeeee0d00ddd0eee80ff09777007798
bbbbbbbbbbbbddbddbbbbbbbbddddbbbbbbbbddebbbbbbbbbbbbbdddddbbbbbbbbbbbbbbbbbddd0000003330000003300000030d00ddd0eee408844989448894
bbbbbbbbbbbd99bd7dbbbbbbd7667dbbbbbbd7debbbbbbbbbbbbdd9999bbbbbbbbbbdddbbbdd000dddd03300dddd0000dddd00131133310030030000000000ee
bbbbbbbbbbd877bd0dbbbbbd86996dbbbbbd777ebbbbbbbbbbbdd99888bbbbbbbbbd788dbdd06700ddd0330d00ddd00d00ddd023223332113113d11ddd11ddee
bbbbbbbbbbd677bd8dbbbbd889999dbbbbbd767ebbbbbbbbbbdd998999bbbbbbbbd7788ddd0667d1333133111133d1111133d123dd33322232233223332233ee
bbbbbbbbbbd677bd98dbbbd889999dbbbbbd666ebbbbbbbdddd8999999bbbbbbbd977888005667d2333233dd223332d2223332222233322232233223332233ee
bbbbbbbbbbd699bd99dbddd889999dbbddbd676ebbbbbbdd9999999999bbbbbbd897788884566732333233d22d3322d2dd3322ddd233322222233223332233ee
bbbdddddddd899d7898dd9d889999dbd77dd677ebbbbbdd99999999999bbbbbd889778888456673233323322dd322d322233d2ddd1333122d2233223332233ee
bbd6688888d807d6709d87d889999dbd776d655ebbbbdd999999999999bbbdd888977888845667323332332dd322dd222233d2333033301131133113331133ee
bd66888880d707d9679567d886996dd67769966ebbbdd8989999999999bbbd8888977888845667113331111d3311111d113331333000000030033003330033ee
d7709990006707d8960769d886996dd67769966ebbbd88989999999999bbbd88899778888456670d3333d00333ddd000dd3300333ddddd0030030000330033ee
d009990ddd6707bd897d80d887667dd67768866ebbbd88989999999999bbbd88999778888456670000000000000000d000000d333ddddddd3dd3dddd33dd33ee
d99999d4446705bd05dd05d885005dd65568666ebbbd80989999999999bbbd8999977888805667ddddddddddddddddddddddddeebddbbbbbbbbeeeeeeeeeeeee
d00000477d6508bd56dbd0d800000dd58850676ebbbd00909999999999bbbd8999977888005668dddddddddddddddd3dddddd3eebd7dbbbbbbbeeeeeeeeeeeee
d00999d776e587bd6dbbbdd000000dd50050677ebbbd09909999999999bbd88999777888005887dddbbbbbbbbbbbbbbbbbbbbbbbbd0dbbbbbbbeeeeeeeeeeeee
bd98886776e603bddbbbbbd0000ddbd50050655ebbbd89999999999999bd888999668880008767d0dbbbbbbbbbbbbbbbbbbbbbbbbd8dbbbbbbbeeeeeeeeb5555
bd888867768740bb45b66bd000dbbbbd66d0666ebbd889009009999999bd888996668808087669d0dbbbbbbbbbbbbbbbbbbbbbbbbd98dbbbbbbeeeeeeee555b5
bbd00067768574b4446555d000dbbbbbddbd767ebbd889889889999999d9888976688888066697d8dbbbbbbbbbbbbbbbbbbbbbbbbd998dbbbddeeeeeeee55bb5
bbd000655608544444565bbdddbbbbbbbbbd777ebbd889889889999999d9888776888888056862d8dbbbbbbbbbbbbbbbbbbbbbbbd78998dbdd9eeeeeeee5bbb5
bbbddd5885d00d444b3b5bb545545bbbbbbd575ebbd889999999999999d9886778888888056063d9dbbbbbbbbbbbbbbbbdbbbbbbd78099dbd87eeeeeeee5bbb5
bbbbbd5005dddbb4bb355554bb4454bbbbbd565ebdd800000009999999d9866790000888005706d7dbbbbbbbbbbbbbbbd9bbbbbbd68809dbd67eeeeeeee5bbb5
bbbbbd5005dbbb5bb44655333333b4bbbbbdd6dedd4000000000999999d7666884554888000670d7dbbbbbbbbbbbbbbbd9bbbbbbd67880dbd69eeeeeeee5bbb5
bbbbbbd66dbbbb65554b6b44444444bbbbbbddded44000000000000000d7668887667888600055d9dbbbbdddddbbbbbbd9bbbbbbd568808dd89000000035bbb5
bbbbbbbddbbbbb3355b3335555555533bbbbddbbd44077777770055777d7688880000888760000d9dbbbdd979ddbbbbd87bbbbbbbd5780880980ddddd035bbb5
bbbbbddddbbbbbbbbbbbdddbbbbbbbbbbbbd99ddd44765656567455555d9888888888888776000d8dbbdd99799ddbbbd87bbbbbbbbd560880900ddd00035bbb5
bbbbd0766dbbbbbbbbbd766dddbbbbbbbdd899d6d447767676774d5555d9888888888800007666d8dbdd8997998ddbd887bbbbbbbbbd568890713331dd35bbb5
bbbd990066dbbbbbbbd9006688ddbbbbd6089986d445555555554dd555d9888888888800000777d85dd089979980ddd889bbbbbbbbbd0554903233322235bbb5
bbd90999988dbbbbbd9999088888ddbbbd089985d4589977799854dd4dbd888000008800000557d068d089979980dd8860bbbbbbbbbd00854802333dd225bbb5
bbd990dd0088dbbbbd099dd0088886dbbbd8778dd5488999998845dd44bbd80000000880000555d0788089979980888660bbbbbbbbbd98800892222ddd25bbb5
bd889044d0088dbbd990044d0098866dbbd6776dd5488989898845ddddbbbd000000088000ddd5d07880899799809866600bbbbbbbd98540098222233d25bbb5
bd888d744d0986dbd8899644d099986dbbd6556dd5408888888045dbbbbbbbd0000000880dddddd068808997998077668800bbbbbd9864d70801d1133315bb55
d088877744d9966dd08887744d99907dbbd5005dd5400808080045dbbbbbbbbd0000008dddddddd0688089777980777888800bbbbd865dd680500dd33005b555
d008777764d9906dd08867776009990dbbbd55dbdd50080808005ddbbbbbbbbbd0000dddbbbbbbd06880877777809999888800bbbd65dbbd6d0d000000d55555
d00777766009907dd00877766990990dbbbbddbbbdd555555555ddbbbbbbbbbbd000ddbbbbbbbbd068806797976099999888800bbd5dbbbdddbdddddddd55554
d07777669990990dd00677768889000dbbb6beeebbdddddddddddbbbbbbbbbbbdddddbbbbbbbbbbd588069979960999999888800bddbbbbbbbb3dddddd34444b
d45776688899000dbd555764880000dbbb656eeeebddbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddbd588089666980999999988880bbbdddbbbbdddbbbbdddbeee
d5006688888000dbbd50056000000dbbb5555eeeed0dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd67bbd8808644468099999999000dbbd800dbbd980dbbd998deee
d600540000000dbbbd600540000ddbbb5555beeeed0dbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd567bbd8805657565099999900dddbbd94554bd94550bd94558eee
bd654000000ddbbbbbd655dddddbbbbb455bbeeeed8dbbbbbbbbbbbbbbbbbbbbbbbbddddddd556bbd08800666009999900ddbbbbd845660d945668d945668eee
bbdddddddddbbbbbbbbdddbbbbbbbbbbb4bbbeeeed8dbbbbbbbbbbbbbbbbbbbbbbddd897799997bbd088800000999900ddbbbbbbd056678d856678d956679eee
3337777333eeeeeeeebd000dbeeeeeeeeeeeeeeeed9ddbbbbbbbbbbbbbbbbbbbbdd88897799997bbbd088888889900ddbbbbbbbbd056789d056789d856789eee
3733773373eeeeeeeed87778deeeeeeeeeeeeeeeed78dbbbbbbbbbbbbbbbbbbbd9988897799997bbbd0888888000ddbbbbbbbbbbbd40897ed08897ed88997eee
3773773773eeeeeeee0878780eeeeeeeeeeeeeeeed78ddbbbbbbbbbbbbbbbbbd89988997799997bbbbd566666500dbbbbbbbbbbbd056789d056789d856789eee
3333773333eeeeeeee0877880eeeeeeeeeeeeeeeed988dbbbbbbbbbbbbbbbbd889988997799997bbbbd566666550dbbbbddddddbd056678d856678d956679eee
b22333322beeeeeeee0878780eeeeeeeeeeeeeeeed988dddbbbbbbbbbbbbbd8889988997799906bbbbbd08888055dddddd8888dbd845660d945668d945668eee
bb123321bbeeeeeeeed87778deeeeeeeeeeeeeeeed08889dddddbbbbbbbbd88889989997799045bbbbbd088880056888888888dbbd94554bd94550bd94558eee
bbb1221bbbeeeeeeeebd000dbeeeeeeeeeeeeeeeed088999999ddddbbbdd888809899977790456bbbbbbd08880006888888888dbbbd800dbbd980dbbd998deee
bbb77777bbbbbb77777bbbbbb33333bbbbbbbbbeed0899999999779ddd99880088999777990557bbbbbbd00000006688888800dbbbbdddbbbbdddbbbbdddbeee
bb7777777bbbb7777777bbbb3777773bbbbbbbbeed069999999777999999008888997779980567bbbbbbbd08800066888800ddbbbbbddddddbbbbbbddbbbeeee
b777777777bb777333777bb377bbb773bbbbbbbeed858888899779999999888888997799980567bbbbbbbd088000668800ddbbbbbbd622225dbbbbd33dbbeeee
7777777777777733333777377bbbbb773bbbbbbeedd5ddddd88679999999888888997799950567bbbbbbbbd080006000ddbbbbbbbd72332226dbbb0220bbeeee
7777737777777333b3337737bbbbbbb73bbbbbbeebdddbbbdddd68999999888888997799958679bbbbbbbbd08000ddddbbbbbbbbd7137332216dbd3113dbeeee
777733377777733bbb337737bbbbbbb73b7777beebbbbbbbbbbddd888899888888997799985697bbbbbbbbbd0000dbbbbbbbbbbbd6133332216db027720beeee
7777737777777333b3337737bbbbbbb73777777eebbbbbbbbbbbbddddd88088888997799985862bbbbbbbbbd0000dbbbbbbbbbbbd6123322215dd317713deeee
7777777777777733333777377bbbbb773773377eebbbbbbbbbbbbbbbbdddd00088997799985063bbbbbbbbbbd000dbbbbbbbbbbbd6412222145d02700720eeee
b777777777bb777333777bb377bbb773b773377eebbbbbbbbbbbbbbbbbbbdd5500897799980706bbbbbbbbbbd000dbbbbbbbbbbbd6741111465dd164461deeee
bb7777777bbbb7777777bbbb3777773bb777777eebbbbbbbbbbbbbbbbbbbbd6765d86699900560bbbbbbbbbbbd00dbbbbbbbbbbbd5674444654db04dd40beeee
bbb77777bbbbbb77777bbbbbb33333bbbb7777beebbbbbbbbbbbbbbbbbbbbd6556dddd89908055bbbbbbbbbbbd00dbbbbbbbbbbbbd56667754dbeeeeeeeeeeee
99999dd9999999999dd999999999999deeeeeeeeebbbbbbbbbbbbbbbbbbbbdd44ddbbdd8908dddbbbbbbbbbbbbdddbbbbbbbbbbbbbd555544dbbeeeeeeeeeeee
9999dccd99999999dccd9999999999dceeeeeeeeebbbbbbbbbbbbbbbbbbbbbddddbbbbdd80ddddeeeeeeeeeeeeeeeeeeeeeeeeeebbbddddddbbbeeeeeeeeeeee
99990bb0999999990bb099999999990beeeeeeeeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddbbeeeeeeeeee977999799999bbbbbbbbb7bbbbbbbb7bbbbbeeee
999dcbbcd999999dcbbcd99999999dcbeee999999999999999bb99999bb999bb9eeeeeeeeeeeeeeeeeeeeeee777799977999bbb7bbbbb7bbbbbbbbbbbbbbeeee
9990baab0d999990baab0dd9999990baeee99999999999999b77b999b77b9b77beeeeeeeeeeeeeeeeeeeeeee777799997777bbb7bbbbb7bbbbbbbbbbbbbbeeee
99dabaa577d999dabaaba77d999d0abaeee99999999999999b77b999b77b9b77beee44444344434444eeeeee999779999777bb777bbbbbbbbbbbbbbbbbbbee55
9d75a77566099d75b77b566099d775b7eee99999999999999b77b999c77c9b77beee44444344424444eeeeee99999799977777777777bbb777bbbbbbbbb7ee55
9064a77567cd9064a77b467c090664b7eee99999999999999c77c999c77c9c77ceee4444434442444499dd9999dd9999dd99bb777bbbbbbbbbbbbbbbbbbbee55
d764add567bd0764addb467bddc764bdeee9999999999999bc77cb99c77c9c77ceee443443444444449d77d99d77d99d77d9bbb7bbbbb7bbbbbbbbbbbbbbee55
d665a556554dd665a55b555addb765a5eee9cbbc99cbbc99bc77cb9b7777bc77ceee43343124444444dd66dddd66dddd66ddbbb7bbbbb7bbbbbbbbbbbbbbee55
d65daaab44d9d65daaab044d9da550aaeee9c77c99c77c9bc7777cbb7777bc77ceee43321124444443dccccddbcccddccccdbbbbbbbbb7bbbbbbbb7bbbbbee55
054ddabd0d99d54d0ab0ddd999044ddaeee9b77b99b77b9cc7777ccc7777cc77c44244111124444424dbbbbddabbbddbbbbde77999999bbddddbbbddbbbddb55
9dddd56d999990ddd56d9999999dddd5eeebb77bb9b77b9ccc77cccc7777cc77c42234111122444244dba5dddabbbdda55ade77799999bd6777dbd67dbd67d55
9999d67d99999999d67d9999999999d7eeeb7777bbb77bbc7c77c7cc7777ccccc42131111122244444db66dddabbbdda66ade77797999d665567d6667dd67d55
9999d56d09999999d56dd999999990d6eeeb7777bb7777bc7c77c7cc7777ccccc22141111112244434dbbbbddabbbddbbbbde99799799d656676d6576dd67d55
9999d56bd9999999d56ba0999999d0b6eeec7777cb7777bc777777ccc77cccccc21142111112244244daaaaddaaaaddaaaade99799799d656676d6576dd67d55
9990a44cd9999990a44acd999999daa4eeec7777cc7777ccc7777cccc77cccccc21144111111244444dd55dddd55dddd55dde99979777d567766d5666dd67d55
999dcdd09999999dcdddd99999990cddeeecc77ccc7777c9c7777c99cccc9cccc211444111114444449d44d99d44d99d44d9e99999777bd5556dbd56dbd67d54
9999d99999999999d999999999999099eee9c77c99c77c999cccc9999cc999cc94214444111444444499dd9999dd9999dd99e79999977bbddddbbbddbbbddb4b
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

