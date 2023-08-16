pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()
	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,129},1)
	poke(0x5f2e,1) -- keeps the colours on quit

	palt(0,false)

	t=0
end

function _draw()
	t+=1

	cls()
	
	local flash_colours=split"13,13,13,13,0,8,9,8,8,0,0"
--	local flash_colours=split"13,13,13,13,9,8,8,0,0"

	pal(15,flash_colours[1+((t\4)%#flash_colours)])
	
	for i=-1,1 do
		local t=t*.25
		map(0,0,0,i*128+t%128,16,16)
	end
	
	local size=3
	for i=-30+t%(size*8),128,size*8 do
		map(125,0,0,i,size,size)
		map(125,4,128-24,i,size,size)
	end
end
__gfx__
0000000000000000dddddddddedddded00000000dddddddd44444444000000000000000000000000d06666744766660d00000000000000000000000000000000
0000000000000000dddddddddefddfed0000000055eeee5544444444000000000000000000000000d56669744796665d00000000000000000000000000000000
0070070000000000ddddddddddfddfdd000000004455554444444444000000000000000000000000d56689744798665d00000000000000000000000000000000
0007700000000000dddddddddeeddeed0000000044dddd4444444444000000000000000000000000d56889744798865d00000000000000000000000000000000
00077000000000005555555544444444000000004deeeed444444444000000000000000000000000d58889744798885d00000000000000000000000000000000
0070070000000000444444444dddddd4000000004eeffee444444444000000000000000000000000d08886744768880d00000000000000000000000000000000
000000000000000044444444deeeeeed000000004eeddee444444444000000000000000000000000d08866744766880d00000000000000000000000000000000
000000000000000044444444eeeeeeee0000000044eeee4444444444000000000000000000000000d08666744766680d00000000000000000000000000000000
de444eded4de45566554ed4d00000000444444444444444400000000444444444444444400000000555555558888888888888888888888880000000000000000
de444edededde454454edded000000004444444444444444000000004444444444444444000000005ee44ee58888888888888888888888880000000000000000
ede444eddede445ee544eded00000000444444444444444e00000000e444444444444444000000005ee44ee58888888888888888888888880000000000000000
ede444eddedde456654edded000000005555555554dd44ee00000000ee44dd455555555500000000555555558888888888888888888888880000000000000000
de444eded4de45566554ed4d00000000eeeeeeeeeeffeeee00000000eeeeffeeeeeeeeee00000000eeeeeeee8888888888888888888888880000000000000000
de444edededde454454edded00000000ededededeeddeeee00000000eeeeddeeedededed00000000eee44eee8888888666666666688888880000000000000000
ede444eddede445ee544eded00000000ddddededeeeeeeee00000000eeeeeeeeededdddd0000000044e44e448888886777777777768888880000000000000000
ede444eddedde456654edded00000000ddddddededddddde00000000eddddddeeddddddd000000004ee44ee48888867dddddddddd76888880000000000000000
44444444e465564e0000000044444444444444440000000000000000dddeedddefddddfededeededeee44eee8888867d00000000d76888880000000000000000
44444d44464444640000000044444444444444440000000000000000dddeedddeffffffefedffdef44e44e448888867d00000000d76888880000000000000000
4444ded4e44ee44e00000000444444444dd44dd40000000000000000ddddddddeefeefeefeffffef4ee44ee48888867d00000000d76888880000000000000000
44d44e44e44ff44e00000000eeeeeeeeeffeeffe0000000000000000deeddeededdeeddedeffffed4e4444e48888867d00000000d76888880000000000000000
4ded44444644446400000000eeeeeeeeeeeeeeee0000000000000000dedeededefddddfedeeffeed4e4444e48888867d00000000d76888880000000000000000
44e44444e465564e00000000edededededededed0000000000000000dedeededeffffffefefeefef4e4444e48888867d00000000d76888880000000000000000
44444444ed4444de00000000dddddddddddddddd0000000000000000deddddededfeefdefeffffef4e4444e48888867d00000000d76888880000000000000000
e44ee44eedeeeede00000000dddddddddddddddd0000000000000000ddddddddeddeeddedddffddd4ee44ee48888867d00000000d76888880000000000000000
00000000555ede5665ede5550000000000000000000000000000000000000000ddddddddeeffffee4ee44ee48888867dddddddddd76888880000000000000000
00000000444eee4444eee4440000000000000000000000000000000000000000ddddddddefddddfe4ee44ee48888806777777777760888880000000000000000
000000004d44444ee44444d40000000000000000000000000000000000000000ddddddddefdffdfe4ee44ee48888800666666666600888880000000000000000
000000004d44444dd44444d40000000000000000000000000000000000000000ddddddddefdeedfe4ee44ee48888880000000000008888880000000000000000
000000004d445564465544d40000000000000000000000000000000000000000ddddddddefddddfe4ee44ee48888888000000000088888880000000000000000
000000004444efe44efe44440000000000000000000000000000000000000000ddddddddeefddfee4ee44ee48888888888888888888888880000000000000000
000000004556ddd66ddd65540000000000000000000000000000000000000000ddddddddeedffdee4ee44ee48888888888888888888888880000000000000000
000000004dddee4444eeddd40000000000000000000000000000000000000000ddddddddedddddde44e44e448888888888888888888888880000000000000000
__map__
38383838383810111210383838383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b1a0a
38383838383810111210383838383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b2a0a
38383838383810111210383838383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002b3a0a
3838383838381021211038383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
38383838273810111210382738383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2a2d
38383838273810111210382738383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3a2d
38383829293810111210382929383838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1a2d
0202020303020531320502030302020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060606062006061a1a0606200606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323232324141511121718242323232300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838383939381011121038393938383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838292828381011121029282829383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838382828381011121038282838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838383939381021211038393938383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838382727381011121038383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3838383838381011121038383838383800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
