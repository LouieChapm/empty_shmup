--lint: func::_init
function init_sprfuncs(_sprite_data, _anim_data)
	spr_library,anim_library,cur_transparent=parse_data(_sprite_data),parse_data(_anim_data),1
end

-- special stuff
function sspr_anim(_index, posx, posy, _offset, _speed)
    local frames,offset,speed = anim_library[_index],_offset or 0, _speed or 8
    sspr_obj(frames[(t+offset)\speed%#frames+1], posx, posy)
end

function sspr_obj(_data, posx, posy)
    local lib=spr_library[_data]
    if(not lib or #lib<=1)return

    local sx,sy,sw,sh,ox,oy,transparent,mirror_mode,flip_h,stack=unpack(lib)

    if stack!=0 then
        for i=1,3 do pal(i,7) end
        palt(stack==1 and 3 or 2,true)
    end
    if transparent!=cur_transparent then
        palt(cur_transparent,false)
        cur_transparent=transparent
        palt(transparent,true)
    end

    -- bit 1: repeat h-mirrored
    -- bit 2: repeat v-mirrored
    -- bit 4: odd mirroring (don't repeat center) (currently only works for h-mirroring)
    for qy=0,mirror_mode>>1&1 do
        for qx=0,mirror_mode&1 do
            sspr(sx,sy,sw,sh,
                 posx+ox+qx*(sw-mirror_mode\4%2),posy+oy+qy*sh,sw,sh,
                 qx!=flip_h,qy==1)
        end
    end

    if stack!=0 then
        -- for i=1,3 do pal(i,i) palt(i,false) end
        poke(0x5f01,1,2,3) --reset pal and palt for i=1..3
    end
end