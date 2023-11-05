pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,14},1)
	palt(0,false)
	poke(0x5f2e,1) -- keeps the colours on quit
end

__gfx__
fff111fffff11fffff11ffff122ffffff212fffff2332fffff2332fff121ff013fddddddddddddddddddddddddddddddddddddddddddddddddddbbbddddddbbb
ff12221fff1227fff1221ff12331ffff73237fff377773fff377773f1232137370ddddddddddddddddddddddddddddddddddddddddddddddddddbbd622225dbb
f1237321f13772fff2732ff237731ff2373732f37322373f273223722333213731ddddddddddddddddddddddddddddddddddddddddddddddddddbd72332226db
12377721f27731fff3773ff2377731f12373212732112372372112731232107373ddddddddddddddddddddddddddddddddddddddddddddddddddd7137332216d
12777321f7221ffff3773fff13777322373732372100127337211273f121ff310fddddddddddddddddddddddddddddddddddddddddddddddddddd6133332216d
1237321fff11fffff2372ffff137732f73237f372100127327322372f232ff311fddddddddddddddddddddddddddddddddddddddddddddddddddd6123322215d
f12221fffffffffff1221fffff13321ff212ff2732112372f377773f2373213233ddddddddddddddddddddddddddddddddddddddddddddddddddd6412222145d
ff111ffff12721ffff11fffffff221fff010fff37322373fff2332ff3777312221ddddddddddddddddddddddddddddddddddddddddddddddddddd6741111465d
fff00fff1237321ffffffffff01210ff02220fff377773ffff1221ff2373233231ddddddddddddddddddddddddddddddddddddddddddddddddddd5674444654d
f001100f1237321ffff110fff12321f1237321fff2332ffff277772ff232ff113fddddddddddddddddddddddddddddddddddddddddddddddddddbd56667754db
01122110f12721ffff2210ff02373203777773fff1221fff17211271f373ff231fddddddddddddddddddddddddddddddddddddddddddddddddddbbd555544dbb
02333320fffffffff2331fff02373201237321ff277772ff271001723727310302ddddddddddddddddddddddddddddddddddddddddddddddddddbbbddddddbbb
02333320ff11fffff1332fff0237320f02220ff27211272f271001727222733733dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
01122110f7221fff0122ffff0237320ff010ff1721001271172112713727320301dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f001100ff27731ff011ffffff12321fff012ff2710000172f277772ff373ff132fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
fff00ffff13772fffffffffff01210ff02237f2710000172ff1221fff323ff133fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff111fffff1227fffffffffffff221f02377321721001271ff0110ff3212337271dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f12221fffff11fffffffffffff133211277721f27211272ff133331f2111232723dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
1237321fff131fff123321fff1377320377320ff277772ff032112303212317273dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
12777321f12721f12377721f1377732f73220ffff1221fff13133131f323ff331fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
12377721f23732f127773212377731fff211fffff0110fff13133131dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f1237321f23732ff123321f237731ffff131ffff133331ff03211230dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff12221ff12721fffffffff12331ffff02720ff13200231ff133331fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
fff111ffff131fffffffffff122ffff02373200320110230ff0110ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff0000ffdddddddffffffffffffffff12777211301331031ff0110ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f012210fdddddddf122ffffff0000ff02373201301331031f122221fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f017710fdddddddf1233fff01122110f02720f032011023002733720dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
01277210dddddddff2773ff12277221ff131fff13200231f12322321dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
01277210dddddddff3772ff27777772dddddddff133331ff12322321dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f017710fdddddddfff3321f12277221dddddddfff0110fff02733720dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f012210fdddddddffff221f01122110dddddddfff0110ffff122221fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff0000ffdddddddffffffffff0000ffdddddddff122221ffff0110ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddbddbbbddbbbddddbb
ddddddddddddddddddddddddddddddddddddddf12333321fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd12dbd12dbd1222db
dddddddddddddddddddddddddddddddddddddd0230110320dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd12dd1112d110012d
dddddddddddddddddddddddddddddddddddddd1231111321dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd12dd1021d101121d
dddddddddddddddddddddddddddddddddddddd1231111321dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd12dd1021d101121d
dddddddddddddddddddddddddddddddddddddd0230110320dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd12dd0111d012211d
ddddddddddddddddddddddddddddddddddddddf12333321fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd12dbd01dbd0001db
ddddddddddddddddddddddddddddddddddddddff122221ffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbddbbbddbbbddddbb
ddddddddddddddddddddddddddddddddddddddfff0110fffddddddddddddddddbbbbbbd77dbbbbbbbbbbbbbbbbd77dbbbbbbbbbbbbd33dbbbbbbbbd33dbbbbbb
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbbbbbbd33dbbbbbbbbbbbbbbbb033dbbbbbbbbbbbb022dbbbbbbbbd22dbbbbbb
00b00b0000000000ddddddddddddddddddddddddddddddddddddddddddddddddbbbbd077770dbbbbbbbbbbbbb07770bbbbbbbbbbbd12220bbbbb0d2222d0bbbb
11b11bd11ddd11ddddddddddddddddddddddddddddddddddddddddddddddddddbbbd03377330dbbbbbbbbbbd077732dbbbbbbbbdd12112dbbbb0d221122d0bbb
22b22bb22bbb22bbddddddddddddddddddddddddddddddddddddddddddddddddbb071337733170bbbbbbbb0717773210bbbbbb0202211230bbd3d221122d3dbb
22b22bb22bbb22bbddddddddddddddddddddddddddddddddddddddddddddddddd02323377332320dbbbbb0232773321dbbbbd0221221123ddd220211112022dd
22222bb22bbb22bbddddddddddddddddddddddddddddddddddddddddddddddddd23323222232332dbbbbd2332773321dbbdd12221221127dd32102100120123d
22d22bb22bbb22bbddddddddddddddddddddddddddddddddddddddddddddddddd33211111111233dbbbd33337772210dbd1231122000d37dd32101000010123d
11b11bb11bbb11bbddddddddddddddddddddddddddddddddddddddddddddddddd1210dddddd0121dbdd2333321dddddbd132dbdddddd377dd3110dddddd0113d
00b00bb00bbb00bbddddddddddddddddddddddddddddddddddddddddddddddddd01ddbbbbbbdd10dd22210dddd000dbb01321bdddd2773dbd033dddddddd330d
00b00b0000bb00bbddddddddddddddddddddddddddddddddddddddddddddddddbdd0000000000ddbd1110ddddddddbbbbd03333377730dbbbddd33777733dddb
ddbddbddddbbddbbddddddddddddddddddddddddddddddddddddddddddddddddbbbddddddddddbbbbddddbbbbbbbbbbbbbbddddddd00bbbbbbbbddddddddbbbb
b000000b000000bbb000000bb000000b000000000000000bbb00000b00000000b000000bb000000bdddddddddddddddddddddddddddddddddddddddddddddddd
00dddd000dddd0bb00dddd0000dddd000d00ddd00ddddd0bb00ddd0b0dddddd000dddd0000dddd00dddddddddddddddddddddddddddddddddddddddddddddddd
0ddd00d000ddd0bb0d00ddd00d00ddd00d00ddd00ddd000b00dd000b0000ddd00ddd00d00d00ddd0dddddddddddddddddddddddddddddddddddddddddddddddd
1dbb11d1d1bbb1bb1111bbd11111bbd11b11bbb11bbb1ddb1ddb1ddbddd1bbb11dbb11d11d11bbd1dddddddddddddddddddddddddddddddddddddddddddddddd
2bbb2db2d2bbb2bbdd22bbb2d222bbb22b22bbb22bbb222b2dbb222bdd22bbb22bbb22b22b22bbb2bdddddddbdddddddbdddddddbddddddddddddddddddddddd
2bbbddb2b2bbb2bbd22dbb22d2ddbb222bddbbb22bbbdd222bbbdd22bb2dbb2222bbdd2222ddbbb2dd08880ddd00d88ddd8d888ddbddbbbddbbbddddbbdddddd
2bbbd2b2b2bbb2bb22ddb22db222bbd22222bbb22222ddd22bbb22d2b22dbb2d2dbb22d2d222bbb2d0977790d5668996d4089776dd67dbd67dbd6777dbdddddd
2bbb22b2b2bbb2bb2ddb22dd2222bbd2ddd2bbb22222bbd22bbb22d2b2dbb22d2dbb22d2ddd2bbb2d8979798d5068997d5089796dd67dd6667d665567ddddddd
1bbb11b111bbb1111dbb11111d11bbb1ddd1bbb11d11bbb11bbb11b1b1dbb1db1bbb11b1b111bbb1d8977998d5688997d5089779dd67dd6576d656676ddddddd
00bbdd000dbbbbd00bbbddd000ddbb00bbb0bbb000ddbb0000bbdd00b0bbb0db00bbdd00b0ddbb00d8979798d5068997d5089796dd67dd6576d656676ddddddd
d000000d0000000000000000d000000dbbb00000d000000dd000000db00000bbd000000db000000dd0977790d5668996d4089776dd67dd5666d567766ddddddd
ddddddddddddddddddddddddddddddddbbbdddddddddddddddddddddbdddddbbddddddddbddddddddd08880ddd00d88ddd8d888ddd67dbd56dbd5556dbdddddd
bddddddbddddddddddddddddbddddddbbbbdddddbddddddbbddddddbbdddddbbbddddddbbddddddbbdddddddbdddddddbdddddddbbddbbbddbbbddddbbdddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
