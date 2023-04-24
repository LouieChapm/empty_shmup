pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- bullet animation tool
-- made by louiechapm
-- @0xffb3 on the bird app

--[[
    TOKENS
    2374 pre changing
    2296 using unpack
    2276 changing s.wx to swx and so on...
    2267 changing filter to unpack
]]--

bg_col=14
ln_col=3

show_ui=true

debug=""
debug_time=0

alphabet=split"a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,_" -- letters and underscore 
numbers=split("0,1,2,3,4,5,6,7,8,9,-,.",",",false)

helper_types=split"none,sprite,loop,burst,circ,array,fspeed,combo,ftarget,fspawn"
helpers={split"none",split"spd mult,anim index,anim spd,filter ref",split"reference,rate,max iter,spd add",split"reference,amount,rnd dir,rnd spd", split"reference,amount,radius,rot speed,grow rate",split"reference,from,to,time add, dir add, spd add",split"chain ref,start,end,speed anim",split"ref 1,ref 2,ref 3",split"chain ref,start,dir,speed,rnd delay",split"chain ref,start,pattern reference"}


#include inf_patterns.txt
#include inf_sprites.txt

#include ../src/bulfuncs.lua
#include ../src/sprfuncs.lua

function _init()
	t=0
	temp=""


    menuitem(1, "export data", function() export_data() end)
    menuitem(2, "kill all buls", function() buls={} end)
    menuitem(3, "add 5 empty pats", function() add_new_commands(5) end)


    init_bulfuncs(bul_library) -- bulfuncs.lua
	init_sprfuncs(spr_library, anim_library) -- sprfuncs.lua

    nav={
        vert=0,
        hori=0,

        mode="select",

        lib_index=1,
    }

    enem={
        x=64,
        y=64,
    }
    mouse_input=0

    player={
        x=64,
        y=105,
    }

	poke(0x5f2d, 1) -- keyboard access
	
	pal({[0]=140,1,2,3,4,5,6,7,8,9,10,138,12,13,139,136},1)
	palt(0,false)
	

	cscroll=0
end

function find_data_type()
    data_type=1
    local data=bul_library[nav.lib_index]
    if(data[1]=="sprite")data_type=2
    if(data[1]=="loop")data_type=3
    if(data[1]=="burst")data_type=4
    if(data[1]=="circ")data_type=5
    if(data[1]=="array")data_type=6
    if(data[1]=="fspeed")data_type=7
    if(data[1]=="combo")data_type=8
    if(data[1]=="ftarget")data_type=9
    if(data[1]=="fspawn")data_type=10
end

function _update60()
	t+=1

    find_data_type()

    update_input()
    update_mouse_input()


    player.x=64+sin(time()*0.1)*40

	if debug_time>0 then
		debug_time-=1
		if(debug_time==0)debug=""
	end

    upd_bulfuncs()

	cscroll+=0.25
end


function _draw()
	cls(bg_col)

	draw_bg()


    -- "player"
    circfill(player.x,player.y,3,bg_col)
    circfill(enem.x,enem.y,3,bg_col)


    drw_buls()

    print("+",player.x-1,player.y-2,ln_col)
    print("+",enem.x-1,enem.y-2,ln_col)

    if(show_ui)draw_information()

    printbg(#buls,127-#tostring(#buls)*4,2,7)

	printbg(debug,127-(#tostring(debug)*4),121,7)
end

-->8
-- init
-->8
-- update

function update_input()
    local had_input=stat(30)
	local char = had_input and stat(31) or nil

    if(char=="\t")show_ui = not show_ui

    if nav.mode=="select" then
		if(btnp(⬆️))nav.vert-=1
		if(btnp(⬇️))nav.vert+=1

        if nav.vert==0 then
            local lib_ind=nav.lib_index+#bul_library
            if(btnp(⬅️))lib_ind-=1
            if(btnp(➡️))lib_ind+=1

            nav.lib_index=(lib_ind-1)%#bul_library+1
        else
            if(btnp(⬅️))nav.hori-=1
            if(btnp(➡️))nav.hori+=1
        end

        local max_len=#helpers[data_type]+1
        if(data_type==1)max_len=1
		nav.vert=mid(0,nav.vert,max_len)
		nav.hori=mid(1,nav.hori,3)

        if(nav.vert==0)find_data_type()

        -- enter into type mode
        if btnp(❎) then  
			if(char=="\r")poke(0x5f30,1)
			if nav.vert > 1 then
				nav.mode="type" 
				temp=""
            elseif nav.vert==1 then
                nav.mode="change"
                new_command_mode=0
            end
		end
    elseif nav.mode=="change" then
        if btnp(➡️) then
            new_command_mode+=1
        elseif btnp(⬅️) then
            new_command_mode-=1
        end
        new_command_mode=new_command_mode%(#helper_types-1)

        if char=="\r" or btnp(❎) then
            if(char=="\r")poke(0x5f30,1)

            bul_library[nav.lib_index]={helper_types[new_command_mode+2]}
            nav.mode="select"
            return
        end
    elseif nav.mode=="type" then
        if(not had_input) return

        if(char=="p")poke(0x5f30,1) -- ignore pause

        if(char=="\b")temp=sub(temp,1,#tostring(temp)-1) return

        if char=="\r" then
            poke(0x5f30,1)  -- ignore pause

            bul_library[nav.lib_index][nav.vert]=tonum(temp)

            nav.mode="select"
            return
        end

        if is_in_list(numbers,char) then
            temp..=char
        end
    end
end

function update_mouse_input()
    enem.x=stat(32) or 64
    enem.y=stat(33) or 64

    local upd_mouse=stat(34)
    if mouse_input!=upd_mouse and upd_mouse==1 then
        create_spawner((nav.lib_index)*-1, enem, -1)
    end
    mouse_input=upd_mouse
end

-->8
-- draw
function draw_information()

    local x=2
    local y=15

    local data=bul_library[nav.lib_index]

    draw_module("⬅️ pattern #"..nav.lib_index.." ➡️",x,2,nav.vert==0)
    
    local title_text=data_type==1 and "{empty}" or data[1]

    if nav.mode=="change" then
        title_text = helper_types[new_command_mode+2]
    end
    if(nav.vert==1)title_text="⬅️ "..title_text.." ➡️"
    draw_module(title_text,x,10,nav.vert==1)

    if data_type!=1 then
        local data_titles=helpers[data_type]
        for i=1,#data_titles do
            local is_on=nav.vert==i+1
            local data = nav.mode=="type" and is_on and temp or data[i+1]or "nil"
            draw_module(data_titles[i]..": "..data,x,y+i*8,is_on)
        end
    else
        -- things
    end
end

function draw_module(_text,_x,_y,_is_on)
    printbg(_text,_x,_y,_is_on and 5+(t\10)%3 or 7)
end

function drw_buls()
	for bul in all(buls) do
		sspr_anim(bul.anim, bul.x,bul.y, bul.spawn, bul.anim_speed)
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
-- tool

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

function is_in_list(_list,_thing)
	for item in all(_list) do
		if(item==_thing)return true
	end
	return false
end

function add_new_commands(_num)
    for i=1,_num do
        add(bul_library,{})
    end
end

function export_data()
    debug="data exported" 
    debug_time=90

    -- sprite stuff
	local out="bul_library=[["
	for seq in all(bul_library) do
        if #seq>1 then
            for i=1,#seq do
                out..=seq[i]
                if(i!=#seq)out..=","
            end
        end
        out..="|"
	end

    out=sub(out,1,-2)
	out..="]]"

    printh(out, "inf_patterns.txt", true)
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
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3111111111111111111111111111111111111111111111111111111111111111111111rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrr111111111r
r117777711111177717771777177717771777177111111717177717111111117777711rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr171717711r
3177711771111171717171171117117111717171711111777111717111111177117771rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrr171711711r
r177111771111177717771171117117711771171711111717177717771111177111771rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr177711711r
3177711771111171117171171117117111717171711111777171117171111177117771rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrr111711711r
r117777711111171117171171117117771717171711111717177717771111117777711rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr111717771r
3111111111111111111111111111111111111111111111111111111111111111111111rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrr111111111r
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
31111111111111111111113r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r
r117711771777177711771rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3171117171777171717171rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r171117171717177117171rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3171117171717171717171rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r117717711717177717711rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3111111111111111111111rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r1111111111111111111111111111111111111rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
31777177717771111177111111111177717771rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r1717171117111111117111711111111711171rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
317711771177111111171111111111777117713r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r
r1717171117111111117111711111171111171rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
31717177717111111177711111111177717771rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r1111111111111111111111111111111111111rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrr443rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r1111111111111111111111111111111111111rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr449944rrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
31777177717771111177711111111177717171rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrr499aa994rrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r1717171117111111111711711111111717171rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr4a7777a4rrrrrrrrrrrrrrrrrrrrrrrrrrrrr
31771177117711111177711111111177717771rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrr44a7777a4rrrrrrrrrrrrr3rrrrrrrrrrrrrrr
r1717171117111111171111711111171111171rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49499aa994r44rrrrrrrrrrrrrrrrrrrrrrrrrr
31717177717111111177711111111177711171rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrr49a7449944449944rrrrrrrr3rrrrrrrrrrrrrrr
r1111111111111111111111111111111111111rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a777944r499aa994rr44rrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrr49777a94r34a7777a4449944r3rrrrrrr3rrrrrrr
r1111111111111111111111111111111111111rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a944rr4a7777a499aa994rrrrrrr333rrrrrr
31777177717771111177711111111177717771rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrr444499949943499aa994a7777a43rrrrrrr3rrrrrrr
r1717171117111111111711711111111717111rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr4999444477a4444499444a7777a4rrrrrrrrrrrrrrrr
317711771177111111177111111111777177713r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r349a7a947777a49994443r499aa9943r3r3r3rrr3r3r3r
r1717171117111111111711711111171111171rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49777a94aa949a7a94rrrr449944rrrrrrrrrrrrrrrrr
31717177717111111177711111111177717771rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rr49a777949949a77794rrr49944rrr3rrrrrrrrrrrrrrr
r1111111111111111111111111111111111111rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a944449777a94rr49a7a94rrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrr49994rrr49a7a94rr49a77794rr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr44rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrr4449994rrr49777a94rrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrr449944rrrrrrrrrrrrrrr3rrrr44rrrrrrrrr3rr44rrrrrr4999444rrrr49a7a94rrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr499aa994rrrrrrrrrrrrrrrrr449944rrrrrrrr449944rrr49a7a94rrrr4449994rrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrr4a7777a4rrrrrrrrrrrrrr3r499aa994rrrrrr499aa994rr49777a94rr4999444rrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr4a7777a4rrrrrrrrrrrrrrrr4a7777a4rrrrrr4a7777a4rr49a77794r49a7a94rrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrr499aa994rrrrrrrrrrrrrr3r4a7777a4rrrrrr4a7777a4rrr49a7a94449777a94rrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr449944rrrrrrrrrrrrrrrrr499aa994rrrrrr499aa994rrr4499949449a77794rrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrr44r3rrrrrrrrrrrrrrr3rr449944rrrrrrr3449944rrrr49444a94r49a7a94rrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr44rrrrrrrrrrrr44rrr44r49a7a94rrr49994rrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrr4499444999444rrr444rrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444r499aa99444449944rrrrrrrrrrrrrrrrrrrrrrrrrrr
3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r444r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r499944a7777a4r499aa9943r3r3r3r3r3r3r3r3r3r3r3r3r
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a94a7777a4r4a7777a4rrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrr49a7a94rrrrrrrrrrrrr3rrrrrr444rrrr49a7779499aa994r4a7777a4rrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a77794rrrrrrrrrrrrrrrrrrr49994rrr49777a94449944rr499aa994rrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrr49777a94rrrrrrrrrrrrr3rrrr49a7a94rr49a7a94rrr4444rrr449944rrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a94rrrrrrrrrrrrrrrrrr49a77794rrr4999444rr49994r44444rrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrr49994rrrrrrrrrrrrrrr3rrr49777a94rrrr444999449a7a949994rrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrrrrrrrrrr49a7a94rrrrrr49a7a94a77794a7a94rrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrr49994rrrrrr49a77794777a94777a94rrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrr49777a94a7a949a77794rrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr49a7a9449994r49a7a94rrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49994rr444rrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3r444rrrrrrrrrr444rrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr49994rrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a94rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r349777a94r3r3r3r3r3r3r3r3r34443r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a77794rrrrrrrrrrrrrrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr49a7a94rrrrrrrrr3rrrrrr49a7a94rr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49994rrrrrrrrrrrrrrrrr49777a94rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3r444rrrrrrrrrrr3rrrrrr49a77794r3rrrrrrrrrrrr44r3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a94rrrrrrrrrrrr449944rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrr49994rr3rrrrrrrrr499aa994rrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrrr4a7777a4rrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rr444rrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrr4a7777a4rrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr499aa994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr349a7a94r44rrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrr449944rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49777a449944rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr44rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr349a77499aa994rr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a74a7777a4rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rr4994a7777a4rr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr44499aa994rrrrrrrrrrrrrr44rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3449944r3r3r3r3r3r3r4499443r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr44rrrrrrrrrrrrrr499aa994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrr4a7777a4rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr4a7777a4rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrr499aa994rrrrrrr444rrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr449944rrrrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrr44rr3rrrrr49a7a94rrr3rr444rrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrrrrr49a77794rrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3r49994rrrrrrrrr3rrrr49777a94rrr349a7a94rrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a94rrrrrrrrrrrrr49a7a94rrrrr49777a94rrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr49a77794rrrrrrrr3rrrrr49994rrrrr349a77794rrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49777a94rrrrrrrrrrrrrrr444rrrrrrrr49a7a94rrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr49a7a94rrrrrrrrr3rrrrrrrrrrrrrrr3rr49994rrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr349994rrrrrrrrrr3r444rrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrr49a7a94rrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3rr333rr3r49777a943r3r3r3r3r3r3r3r3r3r3r49994r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrr49a77794rrrrrrrrrrrrrrrrrrrrr49a7a94rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr349a7a94rrrrrrrr3rrrrrrrrrrr49a77794rrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49994rrrrrrrrrrrrrrrrrrrrr49777a94rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rr444rrrrrrrrrr3rrrrrrrrrrr49a7a94rrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrr444rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr44rrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrr4499443rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr499aa994rrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrr4a7777a4rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr4a7777a4rrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3r444rrrr499aa994rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49994rrrr449944rrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr49a7a94rrrrr44rr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49777a94rrrrrrrrrrrrrrrrrrrrrrrr
3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r443r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r3r49a777943r3r3r3r3r3r3r3r3r3r3r3r
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr449944rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr49a7a94rrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrr499aa994rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3r49994rrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr4a7777a4rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr444rrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrr4a7777a4rrrrrr444rrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr499aa994rrrrr49994rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrr4499443rrrr49a7a94rrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr

