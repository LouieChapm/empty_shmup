pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function init_sprfuncs(_sprite_data, _anim_data)
	spr_library=parse_data(_sprite_data)
	anim_library=parse_data(_anim_data)
end

-- special stuff
function sspr_anim(_index, _x, _y, _offset, _speed)
    local frames = anim_library[_index]
    local _offset,_speed=_offset or 0, _speed or 8
    sspr_obj(frames[(t+_offset)\_speed%#frames+1], _x, _y)
end

function sspr_obj(_data, _x, _y)
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

__gfx__
00000000666666666666666666666666555557222299999999774670fffffff60000000000000000000000000000000000000000000000000000000000000000
00000000666666666666666666666666555557d22299999977774670ffffff660000000000000000000000000000000000000000000000000000000000000000
00700700667777777777777777777766555557dd2299997777774670fffff6670000000000000000000000000000000000000000000000000000000000000000
00077000667777777777777777777766555557ddd299777777774670ffff66770000000000000000000000000000000000000000000000000000000000000000
00077000667766666666666666667766555557dddd77777777774670fff667770000000000000000000000000000000000000000000000000000000000000000
00700700667766666666666666667766555557dddd77777777794670ff6677770000000000000000000000000000000000000000000000000000000000000000
00000000667766666666666666667766555557dddd77777779994670f66777770000000000000000000000000000000000000000000000000000000000000000
000000006677677777777777777677665555572ddd77777999994670667777770000000000000000000000000000000000000000000000000000000000000000
0000000066776777777777777776776655555722dd77799999994670677777770000000000000000000000000000000000000000000000000000000000000000
00000000667767777777777777767766555557222d799999999946707777777f0000000000000000000000000000000000000000000000000000000000000000
00000000667766666666666666667766555557222299999999994670777777ff0000000000000000000000000000000000000000000000000000000000000000
0000000066777777777777777777776655555722229999999999467077777fff0000000000000000000000000000000000000000000000000000000000000000
000000006677777777777777777777665555572222999999999946707777ffff0000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555557222299999999994670777fffff0000000000000000000000000000000000000000000000000000000000000000
0000000066777777777777777777776655555722229999999999467077ffffff0000000000000000000000000000000000000000000000000000000000000000
000000006677667766776677777777665555572222999999999946707fffffff0000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555557222299999999994670000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766555557222299999999994670000000000000000000000000000000000000000000000000000000000000000000000000
00000000667766776677667777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000667766776677667777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000667777777777777777777766000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444114444444444114444444444441000000000000000000044444344434444444944949000000000000000444aa44444444444441144441144441000000000
444188144444444188144444444441800000000000000000004444434442444444494494900000000000000044aaaa4444444444417714417714417000000000
444188144444444188144444444441800000000000000000004444434442444444974494900000000000000044aaaa4444477444116611116611116000000000
4441ff1444444441ff144444444441f000000000000000000044344344444444449749a490000000000000004aa7aaa4444774441888811f8881188000000000
4441fff144444441ff214444444441f0000000000000000000433431244444444977497490000000000000004aa7aaa4447777441ffff112fff11ff000000000
4418ff8111444418ff814114444418f00000000000000000004332112444444349774979a0000000000000004aa77aa4447777441f2d1112fff112d000000000
411f22818114111f22811811411418200000000000000000004411112444442497a79a7970000000000000004aa77aa4447777441f661112fff1126000000000
1f12772278111f12772227f1118112700000000000000000003411112244424497a79a79700000000000000044a7aa44444774441ffff112fff11ff000000000
16ff77f27611f6ff77f2f7611f722f70000000000000000000311111222444449aa79a79a0000000000000000000000000000000122221122221122000000000
162f55f2f611d62f55f2f861167f2f50000000000000000000411111122444349aa799a9a000000000000000000000000000000011dd1111dd1111d000000000
1f2f67f2f811df2f77f5f8f1168f2f70000000000000000000421111122442449a9a99a9a0000000000000000000000000000000415514415514415000000000
1f2dd6757811ff2d667587141f8f576000000000000000000044111111244444999a999990000000000000000000000000000000441144441144441000000000
1f255d651141f725dd615114417856d000000000000000000044411111444444999a999990000000000000000000000000000000000000000000000000000000
411d117d5144111d1171d51441151710000000000000000000444411144444449499999990000000000000000000000000000000000000000000000000000000
415155161444415155116144415d1150000000000000000000000000000000009449949490000000000000000000000000000000000000000000000000000000
41d11116144441d11141614444161410000000000000000000000000000000004449449490000000000000000000000000000000000000000000000000000000
41614417144441614441614444161440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41614417144441614441714444161440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41614441444441614444144444171440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44144444444444144444444444414440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55533355555355330000000000000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
553eee35533e53eb0000000000000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
53eb7be33eeb53e7000000000000000055522555555ff555555885555554455555599555555aa555000000000000000000000000000000000000000000000000
3eb777e33b773eb70000000000000000552ff25555f88f555582285555499455559aa95555a44a55000000000000000000000000000000000000000000000000
3e777be33b773eb70000000000000000552ff25555f88f555582285555499455559aa95555a44a55000000000000000000000000000000000000000000000000
3eb7be353eeb53e7000000000000000055522555555ff555555885555554455555599555555aa555000000000000000000000000000000000000000000000000
53eee355533e53eb0000000000000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
55333555555355330000000000000000555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
55511155555115555511155555111155555335555553355555533555551111555511115555111155000000000000000000000000000000000000000000000000
551000155110011551000155510cc015553bb355553ee355553333555100001551cccc1551cccc15000000000000000000000000000000000000000000000000
510c7c01100cc00110c7c0155107701555e77e5555ebbe55553bb355100cc0011cc00cc11c0000c1000000000000000000000000000000000000000000000000
10c777011c7777c110777c0110c77c0155e77e5555e77e5555e77e5510c00c011c0000c11c0000c1000000000000000000000000000000000000000000000000
10777c011c7777c110c7770110c77c0155e77e5555e77e5555e77e5510c00c011c0000c11c0000c1000000000000000000000000000000000000000000000000
10c7c015100cc001510c7c015107701555e77e5555ebbe55553bb355100cc0011cc00cc11c0000c1000000000000000000000000000000000000000000000000
510001555110011555100015510cc015553bb355553ee355553333555100001551cccc1551cccc15000000000000000000000000000000000000000000000000
55111555555115555551115555111155555335555553355555533555551111555511115555111155000000000000000000000000000000000000000000000000
55522255555225555522255555222255555501001c7777c111000000000000000000000000000000000000000000000000000000000000000000000000000000
552fff25522ff22552fff25552f88f25555c7000100000010c000000000000000000000000000000000000000000000000000000000000000000000000000000
52f878f22ff88ff22f878f2552f77f2555c705000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
2f8777f2287777822f7778f22f8778f25c7055000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
2f7778f2287777822f8777f22f8778f2070555000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
2f878f252ff88ff252f878f252f77f25105555000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
52fff255522ff225552fff2552f88f2500000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000
55222555555225555552225555222255000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000
55544455555445555544455555444455555335555555555555555555555555555555444555544455544444450000000000000000000000000000000000000000
554999455449944554999455549aa945553ee35555553335555555555333555554449a945549a94549a94a940000000000000000000000000000000000000000
549a7a94499aa99449a7a9455497794555e7be5555ebbe3553ebbe3553ebbe5549a4a7a4554a7a454a7a47a40000000000000000000000000000000000000000
49a777944a7777a449777a9449a77a9455b77b5555b77b553eb777b355b77b554a7444945444444549a94a940000000000000000000000000000000000000000
49777a944a7777a449a7779449a77a9455b77b5555b77b553b777be355b77b554949a94549a49a94544444450000000000000000000000000000000000000000
49a7a945499aa994549a7a945497794555eb7e5553ebbe5553ebbe3555ebbe35544a7a454a74a7a454a7a4550000000000000000000000000000000000000000
549994555449944555499945549aa945553eb355533e5555555555555555e3355549a94549a49a94549a94550000000000000000000000000000000000000000
55444555555445555554445555444455555335555555555555555555555555555554445554444445554445550000000000000000000000000000000000000000
