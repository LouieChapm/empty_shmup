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