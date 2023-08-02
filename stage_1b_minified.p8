pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
fmenu_cart_address="shmup_menu.p8"crumb_lib=[[20,0,0,39,0,59,0,60,0,57,0,55,0,52,0,50,0,48,0,51,-2,57,-9,62,-25,60,-47,48,-68,28,-83,3,-88,-21,-83,-45,-76|20,0,0,-40,0,-60,0,-61,0,-58,0,-56,0,-53,0,-51,0,-49,0,-52,-2,-58,-9,-63,-25,-61,-47,-49,-68,-29,-83,-5,-89,19,-84,40,-70|30,0,0,-5,37,-9,71,-11,81,-11,79,-10,78,-10,76,-10,75,-9,70,-6,43,-1,5|30,0,0,4,37,8,71,10,81,10,79,9,78,9,76,9,75,8,70,5,43,0,5|20,0,0,-21,28,-38,58,-26,88,-11,92,-9,92,-8,92,-7,92,-6,92,-5,92,-4,92,5,87,12,55,-8,20,-31,-12|20,0,0,0,21,0,34,0,40,0,39,0,37,0,28,0,8,0,-17,0,-42|140,0,0,0,43,0,87,0,131,0,175|140,0,0,0,52,0,105,0,157|30,0,0,35,4,62,7,78,9,93,11,111,14,140,17,177,22|30,0,0,-35,11,-60,19,-76,24,-90,29,-108,34,-136,43,-171,55|20,0,0,39,0,59,0,60,0,57,0,55,0,52,0,50,0,48,0,51,-2,57,-9,62,-25,60,-47,48,-68,28,-83,3,-88,-21,-83,-45,-76|30,0,0,0,37,0,61,0,72,0,83,0,95,0,106,0,117,0,128,0,140,0,151,0,162,0,173,0,185|120,0,0,-60,7,-120,15,-179,22|45,0,0,0,33,0,61,0,76,0,83,0,89,0,96,0,103,0,110,0,116,0,123,0,130,0,137,0,143,0,150,0,157,0,164,0,170,0,177,0,184,0,191|40,0,0,-1,47,-6,59,-15,63,-25,64,-38,67,-45,79,-45,94,-45,109,-45,124,-45,139,-45,154,-45,169,-45,184|40,0,0,-46,6,-63,27,-69,46,-68,66,-59,84,-47,100,-36,116,-24,132,-12,148|40,0,0,24,0,34,0,43,3,46,13,46,23,46,33,46,43,46,53,46,63,46,73,46,83,46,93,46,103,46,113,46,123,46,133,46,143,46,153,46,163,46,173|40,0,0,-25,0,-35,0,-44,3,-47,13,-47,23,-47,33,-47,43,-47,53,-47,63,-47,73,-47,83,-47,93,-47,103,-47,113,-47,123,-47,133,-47,143,-47,153,-47,163,-47,173|15,0,0,0,18,0,37,0,52,0,61,0,62,0,62,0,61,0,60,0,59,0,59,0,58,0,57,0,56,0,56,0,52,0,42,0,24,0,6,0,-13|30,0,0,22,0,45,0,65,3,82,11,94,20,105,27,122,36,144,40,167,40,189,40|40,0,0,0,47,0,61,0,71,0,81,0,91,0,101,0,111,0,121,0,131,0,141,0,151,0,161,0,171,0,181,0,191|15,0,0,0,26,0,45,0,57,0,62,0,62,0,61,0,60,0,60,0,59,0,58,0,57,0,57,0,56,0,55,0,54,0,54,0,53,0,52,0,51,0,51,0,50,0,47,0,34,0,11,0,-19]]shot_lib=[[80,1,13,0.75|80,1,13,0.75|70,1,22,-1,190,1,22,-1|70,1,22,-1,190,1,22,-1|80,0.5,1,-1,180,0.15,1,-1,187,0.15,1,-1|60,0.5,1,-1,130,0.25,1,-1|||60,0.35,29,-1,150,0.15,28,-1,155,0,28,-1,160,0,28,-1|60,0.35,29,-1,150,0.15,28,-1,155,0,28,-1,160,0,28,-1|80,1,31,0.75|70,1,21,0.75,150,1,21,0.75,210,1,21,0.75|80,0.1,34,-1,160,0.1,34,-1,240,0.1,34,-1||60,0.7,57,-1,220,0.25,57,-1,280,0,47,-1|30,0.25,58,-1,40,1,58,-1,70,0,58,-1,80,1,58,-1|80,0,49,-1,180,0,49,-1,280,0,49,-1|80,0,49,-1,180,0,49,-1,280,0,49,-1|85,1,46,-1,90,1,46,-1,130,0.25,46,-1,135,0.25,46,-1,200,0,46,-1,205,0,46,-1,210,0,46,-1,215,0,46,-1|80,0.25,56,-1,180,0.25,56,-1|60,1,57,-1,190,0,57,-1|60,0,21,0.75,150,1,21,0.75,300,0,21,-1]]enemy_spawns=[[50,5,6,80,-80,2:5:-20|76,5,6,110,-60,2:5:-20|120,5,6,60,-40,2:5:20|240,1,2,-50,40|270,6,6,40,-10,3:10:16|420,9,1,-20,40,2:25:-10:-5|540,5,6,50,-70,2:5:-15|550,5,6,80,-30,2:5:-15|600,5,6,110,-60,2:5:-15|627,6,6,90,-25,4:20:-15|824,11,2,-45,50,1:40:20:-30|865,10,1,140,15,2:30:5:15|960,5,6,110,-70,2:5:-15|1050,5,6,95,-55,2:5:-15|1100,5,6,90,-30,2:5:-15|1200,1,2,-30,40|1254,10,1,150,0,2:30:0:25|1344,7,13,65,-20|1450,4,6,10,-10,2:15:0:-15|1480,3,6,120,-20,2:15:0:-15|1520,7,5,45,-10,1:0:40|1680,12,2,108,-30,1:30:-90|1720,7,5,65,-20|1760,7,5,25,-20,1:50:80|1960,1,2,-40,40|2050,10,1,140,10,2:30|2127,6,6,90,-25,4:20:-15|2242,7,5,30,-20|2296,2,2,160,45|2380,11,2,-45,55,1:30:25:-30|2450,13,6,140,60,4:50|2470,13,6,140,20,5:50|2490,13,6,140,35,3:50|2636,8,5,88,-20,2:30:-25|2880,12,2,65,-40|2900,7,5,25,-20,2:0:40|3376,14,7,40,-50|3551,11,2,-45,20|3655,14,7,105,-50,1:90:-75|3918,16,6,155,30,1:8:0:15|3948,16,6,155,30,1:15:0:40|3998,19,1,40,-30,2:10:25|4034,11,2,-45,40|4142,14,7,30,-50,1:30:75|4164,16,6,155,30,1:30|4301,14,7,65,-50|4360,18,2,150,10,1:210|4464,17,2,-18,10|4639,15,14,90,-30|4701,19,1,40,-45,2:10:25|4909,7,5,25,-20,2:0:40|5089,17,2,-25,40,0:45|5141,18,2,155,40,0:45|5148,7,5,45,-20,1:0:40|5382,16,6,155,30,1:30|5430,16,6,155,30,1:15:0:30|5496,15,14,105,-40,1:30:-60|5553,20,1,-30,20,1:60:0:20|5577,20,1,-30,30,1:20:5:-20|5607,20,1,-30,20,1:10:0:40|5810,14,7,65,-50|5862,21,14,20,-30,1:45:90|6171,21,14,63,-30,0:30|6227,20,1,-30,20,1:10:0:40|6249,20,1,-30,30,1:20:5:-20|6317,16,6,155,30,1:15:0:30|6369,16,6,145,20,1:5:0:30|6417,21,14,30,-30,0:30|6462,20,1,-30,30,1:20:5:-20|6480,20,1,-30,20,1:30:0:30|6542,21,14,45,-30,1:15:40|6562,17,2,-25,40|6572,18,2,150,20|6833,7,7,63,-30|6848,21,14,25,-15,1:30:80|6867,17,2,-30,20|6930,18,2,155,10|7288,22,2,63,-20,0:30|7317,6,6,30,-20,3:15:20|7385,3,6,128,-10,4:15:-5:-15|7401,4,6,0,-10,4:15:5:-15|7433,7,7,90,-30]]bul_library=[[sprite,2.2,3,4,0|sprite,1,7,4,0|array,2,0,7,0,0.125,0|array,6,-1,1,0,0.1,0|array,4,0,5,5,0,0.3|sprite,2,3,4,7|fspeed,0,0,30,0.97|array,12,1,4,3,0.02,-0.1|array,12,1,4,3,-0.02,-0.1|array,12,0,4,3,0,-0.11|combo,8,9,10|sprite,2.4,7,4,0|array,3,0,4,15,0.0235,0.1|sprite,1.3,3,4,0|array,14,0,3,0,0.25,0|array,17,0,5,5,0,0.25|circ,18,2,3,0,10|sprite,1.8,7,4,0|array,18,-2,2,0,0.05,0|array,33,0,3,0,0.25,0|array,20,-1,0,10,0.125,0.5|array,23,0,2,9,0,-0.08|sprite,1.5,3,4,0|sprite,2,3,4,0|array,24,-10,-2,0,0.05,0|array,24,2,9,0,0.05,0|combo,25,26,0|sprite,2.2,3,8,0|array,28,-1,1,5,0.05,0.1|array,32,0,5,3,0,0.25|array,3,0,1,10,0.0625,-0.2|circ,24,2,2,0,10|sprite,1,7,8,0|sprite,4,16,8,0|sprite,0.5,16,8,0|burst,35,16,0.5,2|array,28,-1,1,0,0.05,0|array,37,0,1,0,0.5,0|array,38,0,7,30,0.0625,0|array,41,0,1,5,0,0.25|sprite,3,16,8,0|sprite,1,3,6,0|combo,54,55,0|array,53,-1,-1,0,0.05,0|array,53,1,1,0,0.05,0|combo,44,45,0|array,46,0,2,8,0,-0.05|circ,53,2,5,0,10|loop,52,0,6,7,0,0.2|sprite,2.5,17,4,0|sprite,2,17,4,0|circ,50,2,5,0,10|sprite,2.3,3,4,0|array,53,-2,-1,0,0.1,0|array,53,1,2,0,0.1,0|loop,53,0,3,5,0,0|loop,43,0,4,20,0,0|sprite,2,7,4,0|sprite,1,16,8,0|array,62,-2,2,0,0.1,0|sprite,0.8,16,4,0|burst,61,1,0.02,0|sprite,1.7,3,4,0|burst,63,2,0.05,0|array,2,-6,-3,0,0.05,0|array,2,3,6,0,0.05,0|combo,65,66,0|array,67,0,2,25,0,0|burst,74,1,0.02,0|array,69,-8,8,1,0.025,0|burst,76,1,0.25,0.1|loop,73,0,4,3,0,0.2|sprite,1.6,16,4,0|sprite,1.3,3,4,0|sprite,0.8,7,4,0|circ,75,8,10,10,10|burst,75,1,0.75,0.1|array,79,-5,5,1,0.0625,0|sprite,0.8,3,4,0|burst,78,1,0.25,0|burst,43,1,0.01,0|burst,73,3,0.02,0.1|loop,82,0,10,3,0,0.2|circ,85,3,56,3,1|sprite,0,3,4,86|ftarget,0,300,-1,2.5,200|array,84,0,7,14,0,0|burst,76,1,0.15,0|burst,75,5,0.6,0.1]]spr_library=[[0,112,13,16,-5,-6,11,0,0,0|13,112,15,16,-6,-6,11,0,0,0|27,112,8,16,-7,-6,11,1,0,0|13,112,15,16,-7,-6,11,0,1,0|0,112,13,16,-6,-6,11,0,1,0|61,112,4,16,-1,-14,11,0,0,0|55,112,6,16,-2,-14,11,0,0,0|47,112,8,16,-3,-14,11,0,0,0|104,32,8,8,-3,-3,4,0,0,0|112,32,8,8,-3,-3,4,0,1,0|104,32,8,8,-3,-3,4,0,1,0|120,32,8,8,-3,-3,4,0,0,0|68,114,6,14,-5,-13,4,1,0,1|68,114,6,14,-5,-13,4,1,0,2|74,114,8,14,-7,-13,4,1,1,1|74,114,8,14,-7,-13,4,1,1,2|82,116,6,12,-2,-5,11,0,0,0|88,116,6,12,-2,-5,11,0,0,0|82,116,6,12,-2,-5,11,0,1,0|94,116,6,12,-2,-5,11,0,0,0|35,118,6,10,-2,-9,11,0,0,0|41,118,6,10,-2,-9,11,0,0,0|65,120,3,8,-2,-7,4,1,0,1|65,120,3,8,-2,-7,4,1,0,2|14,52,8,15,-7,-10,11,1,0,0|0,52,14,23,-13,-13,11,1,0,0|0,101,11,11,-5,-5,11,0,0,0|11,101,11,11,-5,-5,11,0,0,0|22,101,11,11,-5,-5,11,0,0,0|33,106,6,6,-2,-3,11,0,0,0|22,52,8,18,-5,-6,11,0,0,0|22,52,8,18,-2,-6,11,0,1,0|30,52,9,22,-8,-10,11,5,0,0|32,74,8,11,-7,-4,11,1,0,0|100,120,9,8,-4,-3,9,0,0,0|40,52,18,34,-17,-12,11,5,0,0|0,75,16,16,-7,-8,11,0,0,0|16,75,16,16,-7,-7,11,0,0,0|0,58,9,17,-8,-7,11,5,0,0|16,75,16,16,-8,-7,11,0,1,0|0,75,16,16,-8,-8,11,0,1,0|109,120,8,8,-3,-3,11,0,0,0|116,120,6,8,-2,-3,11,0,0,0|122,120,4,8,-1,-3,11,0,0,0|116,120,6,8,-2,-3,11,0,0,0|100,111,7,8,-3,-4,11,0,0,0|105,111,9,9,-4,-4,11,0,0,0|113,111,11,9,-5,-4,11,0,0,0|104,40,8,8,-3,-3,4,0,0,0|112,40,8,8,-3,-3,4,0,0,0|104,40,8,8,-3,-3,4,0,1,0|120,40,8,8,-3,-3,4,0,0,0|58,52,20,34,-19,-17,11,1,0,0|78,65,26,45,-9,-23,11,0,0,0|78,65,26,45,-16,-23,11,0,1,0|41,86,37,26,-36,-19,11,1,0,0|0,91,10,7,-4,-3,11,0,0,0|0,44,8,8,-3,-3,11,0,0,0|8,44,8,8,-3,-3,11,0,0,0|16,46,8,6,-3,-2,11,0,0,0|24,48,8,4,-3,-1,11,0,0,0|22,73,8,2,-3,0,0,0,0,0|14,67,4,5,-1,-1,11,0,0,0|32,85,5,6,-1,-2,11,0,0,0|18,67,4,3,0,-1,11,0,0,0|19,70,3,4,0,-1,11,0,0,0|14,72,2,2,0,0,11,0,0,0|16,72,3,3,0,-1,11,0,0,0|22,70,3,2,0,0,11,0,0,0|25,70,3,2,0,0,11,0,0,0|28,70,2,3,0,-1,11,0,0,0|10,91,8,9,-3,-5,11,0,0,0|104,99,12,12,-5,-5,11,0,0,0|18,91,7,7,-3,-3,11,0,0,0|40,43,9,9,-4,-4,11,0,0,0|48,43,9,9,-4,-4,11,0,0,0|104,86,7,13,-6,-6,11,5,0,0|32,43,9,9,-4,-4,11,0,0,0|111,86,7,13,-6,-6,11,5,0,0|118,86,7,13,-6,-6,11,5,0,0|104,63,11,23,-10,-13,11,1,0,0|113,48,5,5,-2,-2,4,0,0,0|118,48,5,5,-2,-2,4,0,0,0|123,48,5,5,-2,-2,4,0,0,0|123,48,5,5,-2,-2,11,0,0,0|123,66,5,20,2,2,11,0,0,0|126,114,2,14,50,2,11,0,0,0|113,48,5,5,-2,-2,4,0,1,0|32,32,8,8,-3,-3,4,0,0,0|40,32,7,8,-3,-3,4,0,0,0|47,32,8,7,-3,-3,4,0,0,0|32,32,8,8,-3,-3,4,0,1,0||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||]]anim_library=[[1,1|6,7,8,8,7|9,10,11,12|17,18,19,20|21,22|42,43,44,45|49,50,51,52|27,28,29,30|46,47,48|58,59,60,61,62,60|63,64,65,66,67,68|69,70,71|73,73|78,75,76|77,79,80,79|82,83,88,84|89,90,92,91|||||||||||||||||||||||||||||||||||||||||||||||]]enemy_data=[[25,8,4,0,0,8,0,0
26,40,3,0,0,15,0,1
31,13,5,1,40,7,0,-1
32,13,5,1,40,7,0,-1
33,20,6,0,21,10,0,0
34,3,4,0,0,5,0,0
36,90,7,0,0,100,1,1
39,50,2,1,0,30,0,0
53,2700,8,3,0,0,1,4
54,800,9,2,0,0,1,2
55,800,9,2,0,0,1,2
56,800,10,4,0,0,1,3
-15,34,4,5,0,50,0,1
81,40,3,0,0,22,0,1]]coin_amounts=split"3,3,0,0,0,1,10,0,15,0,0,10,0,3"boss_a=[[9,64,-64,2|10,-29,17,2|11,29,17,2
-1,1,64,30|delete
-1,1,64,30|delete,12,23
100,1,53,30,73,30|delete,14,15
100,.7,64,50,40,40,88,40|delete,19
120,1,30,20,88,20|delete
-1,1,64,30|delete -- big scary circle spawner this
-1,1,64,30|delete,12,23,24
120,1,30,20,88,20|delete,9
-1,1,64,30|delete,27]]boss_b=[[12,64,-64,3|none
-1,1,64,35|delete,6,7,8
-1,1,64,50|keep,9
-1,1,64,35|delete,7,8,9,10]]function init_mapfuncs(n,e,o)crumb_lib=parse_data(e)shot_lib=parse_data(o)enemy_spawns=parse_data(n)map_timeline,pause_timeline,map_spawnstep,map_nextspawn,map_spawnpreps=0,false,1,enemy_spawns[1],{}end function upd_mapfuncs()if(not pause_timeline)map_timeline+=1
while map_nextspawn and map_timeline>tonum(map_nextspawn[1])do prepare_spawn(map_nextspawn)end foreach(map_spawnpreps,check_spawn)end function prepare_spawn(n)map_spawnstep+=1add(map_spawnpreps,{0,map_nextspawn})if#n>5then local e,o,r,l=unpack(split(n[6],":"))local f,i=r or 0,l or 0for n=1,e do add(map_spawnpreps,{n*o,map_nextspawn,f*n,i*n})end end map_nextspawn=map_spawnstep<=#enemy_spawns and enemy_spawns[map_spawnstep]or nil end function check_spawn(n)if n[1]<=0then local f,e,o,r,l=unpack(n[2])local f,i=n[3]or 0,n[4]or 0spawn_enem(e,o,r+f,l+i)del(map_spawnpreps,n)else n[1]-=1end end function init_sprfuncs(n,e)spr_library,anim_library,cur_transparent=parse_data(n),parse_data(e),1end function sspr_anim(e,o,r,l,f)local n,i,a=anim_library[e],l or 0,f or 8sspr_obj(n[(t+i)\a%#n+1],o,r)end function sspr_obj(e,i,a)local n=spr_library[e]if(not n or#n<=1)return
local d,t,e,o,c,u,r,l,s,f=unpack(n)if f~=0then for n=1,3do pal(n,7)end palt(f==1and 3or 2,true)end if r~=cur_transparent then palt(cur_transparent,false)cur_transparent=r palt(r,true)end for n=0,l>>1&1do for r=0,l&1do sspr(d,t,e,o,i+c+r*(e-l\4%2),a+u+n*o,e,o,r~=s,n==1)end end if f~=0then poke(24321,1,2,3)end end function init_bulfuncs(n)bul_library,spawners,buls,bul_hitboxes=parse_data(n),{},{},parse_data"-1,-1,4,4|-1,-1,3,3"end function upd_bulfuncs()foreach(buls,upd_bul)if(shot_pause>0)spawners={}
foreach(spawners,upd_spawner)end function drw_bulfunc(n)sspr_anim(n.anim,n.x,n.y,n.spawn,n.anim_speed)end function iterate_filters(n)for e in all(n.filters)do local r,o=e.f_start,e.f_end if n.life>r then local o=e.type if o=="fspeed"then n.spd=n.spd<.1and 0or n.spd*e.rate end end if(o~=-1and n.life>o)del(n.filters,e)
end end function do_filter(e,n)local o,r,l,f,i,a=unpack(bul_library[n])local n={f_start=l,f_end=-1}n.type=o if o=="fspeed"then n.rate,n.f_end=i,f if(r~=0)do_filter(e,r)
end add(e.filters,n)end function upd_bul(n)n.life+=1n.wx+=cos(n.dir)*.5*n.spd n.wy+=sin(n.dir)*.5*n.spd iterate_filters(n)if n.circ_data then local e=n.circ_data n.circ_data.pos+=e.rate*.001n.circ_data.scale=min(e.scale+e.dscale*.01,1)local o=e.radius*e.scale n.ox,n.oy=sin(e.pos)*o,cos(e.pos)*o+sin(e.pos)end n.x,n.y=n.wx+n.ox,n.wy+n.oy if(abs(n.y-64)>=80or abs(n.x-64)>=90)del(buls,n)
end function spawn_bul(n,e,o,r,i,a)local l=1if(o==16)l=2
local f={x=n,wx=n,ox=0,y=e,wy=e,oy=0,hb=gen_hitbox(l,bul_hitboxes),anim=o,anim_speed=a,dir=r==-1and get_player_dir(n,e)or r,spd=i,spawn=t,life=0,filters={}}add(buls,f)return f end function create_spawner(r,e,i,n,o,a)if(r<0)e,r={x=e.x,y=e.y},abs(r)
local l,f=o or 0,a or 0local o={ox=l,oy=f,enemy=e,dir=i,spd=1,time=0,index=r,parent_origin_time=n and n.parent_origin_time or t,instructions=bul_library[r]}if(i==-1)o.dir=get_player_dir(e.x+l,e.y+f)
if n then o.spd=n.spd o.dir=n.instructions[1]=="loop"and get_player_dir(e.x+l,e.y+f)or n.dir o.ox,o.oy=n.ox,n.oy if(n.circ_data)o.circ_data=n.circ_data
end add(spawners,o)return o end function upd_spawner(n)local d=n.instructions local f,i,o,r,l,a,c=unpack(d)n.time+=1local e,u=n.dir,n.time if f=="sprite"then local f=spawn_bul(n.enemy.x+n.ox,n.enemy.y+n.oy,o,e,i*n.spd,r)f.life-=n.parent_origin_time-t if(n.circ_data)f.circ_data=n.circ_data
if(l~=0)do_filter(f,l)
del(spawners,n)elseif f=="burst"then if(e==-1)e=get_player_dir(n.enemy.x+n.ox,n.enemy.y,n.oy)
for f=1,o do local o=create_spawner(i,n.enemy,e,n)o.dir+=rnd(r)-r*.5o.spd+=rnd(l)end del(spawners,n)elseif f=="circ"then for d=0,o-1do local f=create_spawner(i,n.enemy,e,n)local n=1/o*d-e if a~=0then f.circ_data={pos=n,radius=r,scale=0,dscale=a,rate=l}else f.wx+=cos(n-.25)*r f.wy+=sin(n-.25)*r end end del(spawners,n)elseif f=="array"or f=="loop"then if l==0then for l=o,r do local r=create_spawner(i,n.enemy,e,n)r.dir+=l*a r.spd+=(l-o)*c end del(spawners,n)elseif u%l==0then local d,f=u\l-1,create_spawner(i,n.enemy,e,n)f.parent_origin_time,f.dir=t,f.dir+(d+o)*a f.spd+=d*c if(d>=r-o)del(spawners,n)
end elseif f=="combo"then for o=1,3do if(d[1+o]~=0)create_spawner(d[1+o],n.enemy,e,n)
end del(spawners,n)end end function get_player_dir(n,e)return atan2(player.x-n,player.y-e)end function init_expfuncs()parts,exp_fadeout,exp_default,text_effect_pause,exp_queue={},parse_data"222,224|221,222|221",parse_data"115|50,55|35,50|18,35|1,18|213",0,{}end function add_expqueue(n,e,o,r)for l in all(parse_data(r))do local r,f,i=unpack(l)add(exp_queue,{r,f+n,i+e,o})end end function upd_expqueue(n)local e,o,r,l=unpack(n)n[1]-=1if(e>0)return
new_explosion(o,r,l,false,5)del(exp_queue,n)end function drw_part(n)n=setmetatable(n,{__index=_ENV})local _ENV=n if(slow_motion and t%3~=0)func(_ENV)return
if(life==0)ox,oy=x,y
life+=1if(life<0)return
local n=tospd or.1if(toy)x,y=lerp(x,tox,n),lerp(y,toy,n)
if(torad)rad=lerp(rad,torad,toradspd or.5)
local e=vdrift or.15y-=e if(toy)toy-=e
if(hdrift)x-=hdrift
func(_ENV)if(rad and rad<0)del(parts,_ENV)
if(not step_points)goto skip
for n in all(step_points)do if(life==n)colstep+=1
end::skip::if life>maxlife then if onend=="return"then onend=nil maxlife+=life torad=-1toy,n,colstep,colour_lut,step_points,toradspd=y-3,.05,1,exp_fadeout,{5+life,12+life},.02else del(parts,_ENV)end end end function p_debris(n)local e,o=n.x,n.y n.hdrift*=.96n.vdrift=max(n.vdrift*.95-.02,-1)if(n.maxlife-n.life<15and n.life%8<4)return
local r=n.type if(r<0)pset(e,o,abs(r))return
sspr_anim(n.type,e,o)end function p_wave(n)local f,i,e,o=n.x,n.y+5,n.rad,n.life local n,r=e,e*.5local e,l=f-n*.5,i-r*.5oval(e,l,e+n,l+r,o>18and 2or o>7and 3or 7)end function p_grape(n)local i,a,e,f,o,l=n.x,n.y,n.rad,n.colour_lut or parse_data"50,55",split"1,.95,.85,.7",split"0b1111111111110111,0b1010101010101010,0b1010101000000000,0b1000001000000000"local r=f[n.colstep or 1]if(e<6)o=split"1,.9,.7"deli(l,3)
for n=1,#o do local f=e*o[n]fillp(l[n])circfill(i,a+f-e,f,r[n]or r[#r])end fillp""end function pnew_circ(o,r,i,a,n)local e,l=3+n,rnd"1"local f=1/e for d=1,e do local e=d*f+l local l,f=sin(e),cos(e)local e=new_basepart(o+l*2,r+f*2,0,.1+rnd".05",p_grape,a+eqrnd(10)\1)e=setmetatable(e,{__index=_ENV})local _ENV=e tox,toy,rad,torad,toradspd,colstep,step_points,colour_lut,onend,life=o+l*6+eqrnd(1+n*2),r+f*6+eqrnd(1),0,4+rnd"2"\1+rnd(n*.5)+n,1,1,split"3,5,7,16",exp_default,"return",-rnd"10"\1-i end end function p_text(n)local l,o,f,e=n.x,n.y,n.text,n.life if(n.maxlife-e<15and e%8<4)return
local n=5-min(e*.5,5)local i=e>10and e<20and 7or 6for e=o\1,o+8do clip(0,e,128,1)local r=l-n if(e%2==0)r+=n*2
?f,r,o,i
end clip()end function new_basepart(n,e,o,r,l,f)return add(parts,{x=n,y=e,hdrift=o,vdrift=r,func=l,life=0,maxlife=f})end function new_text(e,o,r,l,n)if(n and text_effect_pause>0)return
local f=new_basepart(e+5,o-3,0,.15,p_text,l)f.text=r if(n)text_effect_pause=3
end function new_debris(o,r,n,e,l)local e=rnd"1"local f=new_basepart(o,r,sin(e)*n,cos(e)*n,p_debris,rnd"60"\1)f.type=l end function new_explosion(e,r,f,i,a)local o,l,n=r+eqrnd(3),a or 20,f or 0sfx(rnd(split"56,57,58"),3)local r=new_basepart(e,o,0,0,p_grape,1)r.rad=15+n*6local r=new_basepart(e,o,0,0,p_wave,l)r.rad,r.torad,r.toradspd=1,40+n*8,.25for r=0,1+n do pnew_circ(e+eqrnd(1+r*6),o-r*6,r,l,n)end if(i==false)return
for r=1,rnd(2+n*5)\1do new_debris(e,o,.5+rnd"1.5",60+eqrnd"30",rnd(split"10,10,11,11,11,11,11,11,12,12,12,12,12,-5,-5,-5,-4,-4,-6"))end end function save(n,o)local e,r=split(n),split(o)for o=1,#e do local n=r[o]_ENV[e[o]]=n=="true"and true or n=="false"and false or n end end function init_baseshmup(n)save("score,lives,live_preview_offset,live_flash,bombs,bomb_preview_offset,bomb_flash,pmuz,pause_combo,combo_num,combo_counter,combo_freeze,disable_timer,player_immune,player_flash,ps_held_prev,screen_flash,bnk,bnkspd,plast,op_perc","0,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0.3,0,1")enems,puls,options,opuls,hitregs,pickups,turret_sprites,hitboxes={},{},{},{},{},{},split"37,38,39,40,41",parse_data"0,0,2,2|-3,-8,8,8|-9,-7,20,8|-3,-4,8,8|-4,-5,9,13|-5,-5,11,13|-13,-8,27,16|-15,-15,31,30|-9,-15,18,15|-32,-18,66,15"enemy_data=parse_data(n,"\n")pal({[0]=2,4,9,10,5,13,6,7,136,8,3,139,138,130,133,14},1)end function player_bomb()if(bombs<=0or bomb_flash>0)return
bombs-=1save("bomb_flash,bomb_preview_offset,screen_flash,player_immune,player_flash,combo_freeze","30,1,3,150,90,30")new_bulcancel(5,75)for n in all(enems)do damage_enem(n,30,true)end new_explosion(63,63,2,false,20)add_expqueue(63,63,0,"0,0,-40|4,40,0|8,0,40|12,-40,0")end function new_bul(n,e,o,r,l)return add(n and opuls or puls,{x=e,y=o,aox=t,type=r,hb=gen_hitbox(2),dir=l,opt=n})end function drw_pul(n)sspr_anim(n.type,n.x,n.y,n.aox,8)end function upd_pul(n)if n.alt==1and target_stance==1then local e=n.ox or n.opt.x-player_x n.x=player_x+e else n.x+=sin(n.dir)*psp end n.y+=cos(n.dir)*psp local e if abs(n.y-64)>=80or abs(n.x-64)>=90then e=true end local o=rnd(enem_col(n))if o then spawn_oneshot(8,3,n.x+eqrnd"3",n.y-rnd"3"-3)damage_enem(o,o.elite and 1.3or 1.8)add_ccounter(3)e=true end if e then if(n.opt)n.opt.shot_count-=1
del(puls,n)del(opuls,n)end end function spawn_oneshot(n,e,r,l)local o=#anim_library[n]add(hitregs,{index=n,x=r,y=l,o=t%o,life=o*e,speed=e})end function drw_hitreg(n)n.life-=1sspr_anim(n.index,n.x,n.y,n.o,n.speed)if(n.life<0)del(hitregs,n)
end function enem_col(o)local e={}for n in all(enems)do if(n.active==false)goto continue
if(col(o,n))add(e,n)
::continue::end return e end function check_bulcol(n)if(player_col(n))player_hurt(n)
end function player_col(n)if(player_immune>0)return false
return col(n,player)end function drw_enem(n)if(n.disabled and global_flash)return
local e=n.flash>0or n.anchor and n.anchor.flash>0if(e and t%4<2)allpal(9)
local e=pack(abs(n.s),n.sx+n.ox,n.sy+n.oy,15,6)if n.s>0then sspr_obj(unpack(e))else sspr_anim(unpack(e))end if(n.flash>-1)allpal()n.flash-=1
if(n.anchor and n.anchor.flash>0)allpal()
end function allpal(e)for n=0,15do pal(n,e or n)end end function col(o,r)local n,e=o.hb,r.hb local l,f=o.x+n.ox,o.y+n.oy local o,i=r.x+e.ox,r.y+e.oy return f<=i+e.h-1and i<=f+n.h-1and l<=o+e.w-1and o<=l+n.w-1end function gen_hitbox(e,o)local n,r={},o or hitboxes n.ox,n.oy,n.w,n.h=unpack(r[e])return n end function eqrnd(n)return rnd(n*2)-n end function parse_data(e,o)local n,r={},o or"|"for o in all(split(e,r))do add(n,split(o))end return n end function lerp(n,e,o)return n+(e-n)*o end function avg(n)local e=0for o in all(n)do e+=o end return e/#n end function spawn_anchor(e,r,l,f,i,a,o)local n=spawn_enem(nil,r,0,0,l,f)n.active,n.brain,n.anchor=i,a or nil,e if(o)add_turret(n,o)
add(e.anchors,n)return n end function spawn_enem(e,n,o,r,l,f)local i=setmetatable({},{__index=_ENV})local _ENV=i s,health,hb,deathmode,sui_shot,value,elite,exp=unpack(enemy_data[n])hb,elite,active,type,sx,sy,ox,oy,x,y,t,shot_index,perc,flash,path_index,pathx,pathy,anchors,patterns,turrets,lerpperc,intropause=gen_hitbox(hb),elite==1,true,n,o,r,l or 0,f or 0,63,-18,0,1,0,0,e,{},{},{},{},{},-1,0if(e)depth,path=gen_path(crumb_lib[e])
if(n==5)active=false spawn_anchor(_ENV,3,-3,-2)spawn_anchor(_ENV,4,3,-2)
if(n==7)spawn_anchor(_ENV,8,0,-1,false,4,1)
return add(enems,_ENV)end function gen_path(n)local o,e=tonum(n[1]),{}for o=2,#n,2do add(e,{x=n[o],y=n[o+1]})end return o,e end function kill_enem(n)if(n.exp>=0)new_explosion(n.x,n.y,n.exp)
spawn_pickup(n.x,n.y,coin_amounts[n.type],1.5)give_score(n.value*(max_rank<0and 1or.8))local e=n.elite combo_num+=e and 3or 1add_ccounter(e and 100or 30,100)delete_enem(n)end function upd_enem(n)if n.health<=0then local e,r,l,o=n.deathmode,n.x,n.y,n.anchor if e==1then del(o.anchors,n)if(#o.anchors<=0)o.active=true
elseif e==2then new_bulcancel(30,30)new_lerpbrain(o,o.x-sgn(n.ox)*15,30+eqrnd"10",2,"overshootout")del(o.anchors,n)del(enems,n)elseif e==3or e==4then if(t%4==0)spawn_pickup(n.x,n.y,1,3.5)
if not n.death_delay then new_bulcancel(30,75,true)n.disabled,n.death_delay=true,120save("combo_freeze,combo_counter,boss_active","160,100,false")give_score(10000,1)for e in all(n.anchors)do e.disabled,e.turrets=true,{}end if e==4then spawn_pickup(90,-20,1,0,2)add_expqueue(r,l,0,"0,-40,10|10,-25,4|20,-12,-5|30,12,13|40,25,0|50,30,-10|60,-40,10|70,-25,4|80,-12,-5|90,12,13|100,25,0|110,30,-10")poke(12621,peek(12621)&127)end if(e==3)save("spiral_lerpperc,spiral_exit,spiral_pause","0,true,240")
end elseif e==5then spawn_pickup(r,l,1,1,3)end if n.death_delay then n.death_delay-=1if n.death_delay<0then kill_enem(n)boss_active,pause_timeline=false,false end else kill_enem(n)end return end n.t+=1if(n.lerpperc>=0)upd_lerp(n)
if(n.brain)upd_brain(n,n.brain)
if n.intropause<=0then foreach(n.turrets,upd_turret)else n.intropause-=1end if(n.path)follow_path(n)
n.x,n.y=n.ox+n.sx,n.oy+n.sy for e in all(n.anchors)do add(anchors,e)e.sx,e.sy=n.x,n.y end n.flash-=1if(n.path and player_lerp_delay<=0)enem_path_shoot(n)
end function new_lerpbrain(n,e,o,r,l)n.originx,n.originy,n.tx,n.ty,n.lerpspeed,n.lerpperc,n.lerptype=n.sx,n.sy,e,o,r,0,l or"easeOutIn"end function enem_path_shoot(n)if n.shot_index*4<=#shot_lib[n.path_index]then if n.t==shot_lib[n.path_index][n.shot_index*4-3]then local e=shot_lib[n.path_index]local o=n.shot_index*4-3if(max_rank<0or rnd"1"<tonum(e[o+1]))add(n.patterns,create_spawner(e[o+2],n,e[o+3]))
n.shot_index+=1end end end function follow_path(n)local e,o=n.path,1/n.depth n.perc+=o local o,r=n.perc\1%(#e-1)+1,n.perc%1local l,f=lerp(e[o].x,e[o+1].x,r),lerp(e[o].y,e[o+1].y,r)add(n.pathx,l)if(#n.pathx>2)deli(n.pathx,1)
add(n.pathy,f)if(#n.pathy>2)deli(n.pathy,1)
n.ox=avg(n.pathx)n.oy=avg(n.pathy)if n.perc>#e-1then delete_enem(n)end end function delete_enem(n)for e in all(n.anchors)do e.dead=true del(enems,e)end foreach(n.patterns,del_spawners)del(enems,n)end function del_spawners(n)del(spawners,n)end function add_turret(n,o)local e={n}for n in all(turret_data[o])do add(e,n)end add(n.turrets,e)end function upd_turret(o)local n,r,l,e,f,i,a=unpack(o)if(boss_active)goto skip
if(n.y>64or n.y<5)return
::skip::if(n.t+a)%l==0then local o=e if(e=="?")o=n.dir
if(e=="-?")o=-n.dir
add(n.patterns,create_spawner(r,n,o,nil,f,i))end end function init_player()save("speeda,speedb,psp,pr8,plm,ps_laser_dur,ps_laser_length,ps_laser_dlength,ps_laser_maxlength,olm,ps_maxvol,ps_minimum_volley_trigger,ps_volley_count","1.8,0.8,5,3,30,0,0,1.05,10,3,6,3,0")formation_a=parse_data"-14,7|14,7"psoff,psdir=unpack(parse_data"-4,-2,4,-2|.49,.51")player,player_laser_data={x=63,y=140,hb=gen_hitbox(1)},{hb=gen_hitbox(1)}for n=1,2do add(options,{x=10,y=10,shot_count=0,muz=0,dir=n==1and.475or.525})end end function update_player()player_movement()upd_options()end function draw_player()foreach(opuls,drw_pul)foreach(puls,drw_pul)player_visible=player_flash<=0or global_flash if player_visible and not slow_motion then opt_draw_above=false foreach(options,drw_option)drw_player_laser()if pmuz>0then pmuz-=.5for n=-5,5,10do local e=player_x-n if(bnk_offset>0and n<0)e-=3
if(bnk_offset<0and n>0)e+=3
sspr_obj(split"13,14,15,16"[4-pmuz\1],e,player_y+2)end end sspr_obj(flr(bnk+3),player_x,player_y)opt_draw_above=true foreach(options,drw_option)end player_flash=max(0,player_flash-1)end function player_hurt(n)new_explosion(player_x,player_y,1)player_lerpx_1,player_lerpx_2,delx,dely=player_x,player_x,player_lerpx_1,player_lerpy_1 player.x,player.y=player_lerpx_1,player_lerpy_1 save("player_lerp_perc,player_lerp_delay,player_immune,player_flash,combo_num,combo_counter,ps_laser_length,live_preview_offset,live_flash,bombs,max_rank","0,30,180,180,0,0,0,1,30,1,600")lives-=1new_bulcancel(30,75)for n in all(pickups)do n.seek=false end if(lives<0)save("slow_motion,disable_timer,spiral_lerpperc,spiral_exit,spiral_pause","true,99999,0,true,90")return
sfx(55,2)end function damage_enem(n,e,o)if n.t>30then combo_num+=target_stance==1and.2or.1if(n.intropause<=0)n.health-=e
elseif o then n.health-=e end n.flash=n.flash<-1and 4or n.flash if not n.dead then n.dead=true local e=n.sui_shot if(e>0)create_spawner(e\1,{x=n.x,y=n.y},e%1==0and-1or e%1)
end end function player_shoot()if(btnp"4")player_bomb()
if(ps_volley_count<=0)return
if(plast>0or#puls>plm)plast-=1return
if target_stance==1then player_laser()return end if(ps_laser_length~=0)ps_volley_count,ps_laser_length=0,0return
ps_volley_count-=1foreach(options,opt_shoot)pmuz=4bnk_offset=tonum(bnk<-1)*-1+tonum(bnk>1)for n=1,#psoff,2do local e=ceil(n*.5)local o=new_bul(false,player_x+psoff[n]+bnk_offset,player_y+psoff[n+1],2,psdir[e])end plast=pr8 sfx(62,2)end function drw_option(n)if n.above==opt_draw_above then if(n.muz>0)sspr_obj(split"23,24"[2-n.muz\1],n.x,n.y-5)n.muz-=.5
sspr_anim(4,n.x,n.y)end end function upd_options()op_perc=lerp(op_perc,target_stance,.1)for e,n in inext,options do local o,r=unpack(formation_a[e])local l,f=rot_opt(n,1/#options*e,8,4,-8,.01)n.x,n.y=lerp(o,l-delx+player_x,op_perc)+delx,lerp(r,f-dely+player_y,op_perc)+dely end end function opt_shoot(n)if(n.shot_count>olm)return
local e=new_bul(n,n.x,n.y-5,5,n.dir)n.shot_count+=1n.muz=2end function rot_opt(e,o,r,l,f,i)local n=(o+t*i)%1e.above=n<=.5return cos(n)*r,sin(n)*l+f end function drw_player_laser()if(ps_laser_length<=0)return
local e=player_laser_data.y for o in all(parse_data"5,1|4,2|3,3|1,7")do local n,r=unpack(o)if(n<=2and t%6<3)n+=1
rectfill(player_x-n,e-1,player_x+n+1,ps_laser_hit_height,r)end sspr_obj(57,player_x,player_y-11)circfill(player_x+t%2,player_y-9,3+t\6%3,7)end function player_movement()input_disabled=disable_timer~=0inbtn=btn()&15if(player_lerp_perc>=0)lerp_player()
player_x,player_y=player.x,player.y delx,dely=delx or player_x,dely or player_y if btn"5"then ps_held_prev+=1if(ps_volley_count<=ps_minimum_volley_trigger)ps_volley_count+=ps_maxvol
else ps_held_prev=0end target_stance=ps_held_prev>15and 1or 0if(ps_held_prev==15)sfx(59,3)
if(disable_timer~=0)target_stance=0
local e,n,o=target_stance==1and speedb or speeda,tonum(btn"1")-tonum(btn"0"),tonum(btn"3")-tonum(btn"2")if(inbtn~=last_btn)player_x,player_y=player_x\1,player_y\1
last_btn=inbtn if input_disabled or player_lerp_perc>=0then if(disable_timer>0)disable_timer-=1
bnk=0else local r=n~=0and o~=0and.717or 1player_x,player_y,bnk=mid(-16,player_x+n*r*e,142),mid(2,player_y+o*r*e,124),mid(-2,mid(bnk-bnkspd,.5,bnk+bnkspd)+n*bnkspd*2.5,2.95)player.x,player.y=player_x,player_y end delx,dely=lerp(delx,player_x,.2),lerp(dely,player_y,.2)for n in all(enems)do if(not n.disabled and n.t>60and player_col(n))player_hurt()
end end function player_laser()ps_laser_length=min(5+ps_laser_length*ps_laser_dlength,128)player_laser_data.hb,player_laser_data.x,player_laser_data.y={ox=-10,oy=-ps_laser_length,w=22,h=ps_laser_length},player_x,player_y-10local o,n=-50,nil for e in all(enem_col(player_laser_data))do if(e.y>o)o,n=e.y,e
end if n then ps_laser_length=player_y-n.y player_laser_data.hb.oy,player_laser_data.hb.h=-ps_laser_length,ps_laser_length end ps_laser_hit_height=n and n.y+n.hb.oy+n.hb.h or player_y-ps_laser_length for n in all(enem_col(player_laser_data))do damage_enem(n,n.elite and 1or 1.6)add_ccounter(2,25)end if(t%4==0)new_debris(player_x,player_y-10,.5,5,-7)sfx(60,2)
if(ps_laser_hit_height>-5)spawn_oneshot(8,3,player_x+eqrnd"5",ps_laser_hit_height+eqrnd"2")
end function _init()cartdata"kalika_v1_01"dset(63,0)highscore=tostr(dget"0",2).."0"save("t,player_lerpx_1,player_lerpy_1,player_lerpx_2,player_lerpy_2,player_lerp_perc,player_lerp_speed,player_lerp_delay,player_lerp_type,combo_on_frame,map_progress,map_speed,moon_y,score_in_combo,bullet_cancel_origin,bullet_cancel,shot_pause,max_rank,speed_target,final_boss_phase,draw_particles_above,spiral_lerpperc,spiral_pause,coin_chain_timer,coin_chain_amount","0,64,150,63,95,0,2,0,easeout,0,128,2,-64,0,0,0,0,1100,2,1,-1,0,0,0,0")init_baseshmup(enemy_data)init_player()init_sprfuncs(spr_library,anim_library)init_mapfuncs(enemy_spawns,crumb_lib,shot_lib)init_bulfuncs(bul_library)init_expfuncs()music(0,5000)memcpy(49152,0,8192)memset(0,0,8192)srand"0xffb3"memset(32768,0,16384)for l=-4,7,.7do for e=3,9,.7do if rnd"1"-l/14+e/4<1.4then local n,o,r=rnd(10+e/16),64+l*12,64+e*10for e=mid(o-n,0,127),mid(o+n,0,127)do for l=mid(r-n,0,127),mid(r+n,0,127)do local f,i=e-o,l-r if(f*f+i*i<n*n)poke(32768+e*128+l,1)
end end end end end for r=0,128do for l=0,128do local a,n,e=(l+r)%2==0,l/128,r/128local f,o=(n-.5)*2,(e-.5)*2local i=sqrt(f*f+o*o)if i<1then local i,d=n-.6+sin(n*10+e*10)/80+sin(n*.5+.4+e*.8)/30,e-.4+sin(n*7+e*14)/80+sin(n*.5+.4+e*.8)/30local n=sqrt(i*i+d*d-i/9)+rnd(.04)local e=n<.57and a and 1or n<.55and 1or n<.48and a and 8or 13if n<.45then e=8local l=f/cos(atan2(sqrt(1-o*o),-o))local n,r=mid(flr(63+l*64),0,127),mid(flr(63+o*64),0,127)if peek(32768+n*128+r)==1then e=1if(peek(32768+min(n+1,127)*128+min(r-1,127))~=1)e=13
end end sset(l,r,e)end end end memcpy(32768,0,8192)memcpy(0,49152,8192)palt(0,false)turret_data,combo_big_letters,pickup_colours,moon_active,speed_changes,spiral_exit,slow_motion=parse_data"11,120,?,0,0,0|16,90,-1,0,0,0|15,15,?,-10,4,0|15,15,-?,10,4,0|19,120,.75,0,0,45|27,50,.75,0,-2,0|16,160,-1,-10,-10,0|16,160,-1,10,-10,90|27,50,.25,0,-2,25|36,120,.75,0,0,30|60,45,.75,0,0,0|64,25,-1,0,0,0|68,76,.75,0,0,0|70,45,.75,0,0,0|71,120,-1,0,0,23|72,120,-1,0,0,0|76,200,-1,0,0,100|77,3,.75,0,0,0|80,30,.75,0,0,0|41,8,.75,0,0,0|83,90,-1,0,0,0|83,90,-1,0,0,45|67,75,.75,0,0,0|88,75,-1,0,0,23|72,120,-1,0,0,60|74,30,.75,0,0,0|89,5,.75,0,0,0",parse_data"89,39|78,52|86,52|94,52|102,50|115,73|57,39|65,39|73,39|81,39",parse_data"0,8,9|10,11,12|1,2,3",false,parse_data"1000,3.5|2000,6|3250,0|3252,-.5|7650,.001|7950,0|15000,6969",false,false meter_colours,combo_colours,map_segments=unpack(parse_data"8,8,9,9,2,2,2,3,3,12,12|0,8,9,1,2,3,10,11,12,10,12,10,7,7,7|1, 1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1,1,9,1, 12,1,9,1,0,1,9,1,12,1,9,1,0,1,9,1,12,1,9,1,0,1,9,1,1,1,9,1,1,1,9,1, 13,1,1,1,12,1,1,1,13,1,1,1,12,1,1,1,13,1,1,1,12,1,1,1,13,1,1,1,12,1,1,1,13,1,1,1,13,1,1,1,13,1,1,1,13,1,1,1, 13,1,1,13,1,1,13,1,1,13,1,1,13,1,1,13,1,1, 13,1,13,1,13,1,13,1,13,1,13,1,13,1,13,1,13,1, 2,3,3,3,3,3,3,3,3,3,3, 3,3,4,5,6,7,6,5,6,7,6,6,7,6,6,10, 3,3,3,3,3, 14,15,15,15,15,16,15,15,16,15,15,16,17,18,19,18")end function _update60()t+=1if(slow_motion and t%3~=0)return
combo_on_frame-=1if coin_chain_timer>1then coin_chain_timer-=1else if(coin_chain_amount>10)new_text(player_x+10,player_y-7,"X"..coin_chain_amount.." combo!",120)
coin_chain_amount=1end if(text_effect_pause>0)text_effect_pause-=1
map_progress+=map_speed shot_pause,global_flash,anchors=max(shot_pause-1,0),t%8<=4,{}local e,n=unpack(speed_changes[1])if map_timeline>=e then if(n<=0)map_speed=abs(n)
speed_target=abs(n)deli(speed_changes,1)end map_speed=lerp(map_speed,speed_target,map_timeline>7500and.01or.001)if max_rank>=0then max_rank-=1if(combo_num>50)max_rank=-1
end spawn_boss(3250,boss_b)spawn_boss(7850,boss_a)upd_mapfuncs()upd_bulfuncs()foreach(enems,upd_enem)update_player()if(not input_disabled and player_lerp_perc<0)player_shoot()
moon_y+=.02cam_x=mid(-16,flr((player_x-64)*.25),16)camera(cam_x,0)if(player_immune>0)player_immune-=1
foreach(buls,check_bulcol)foreach(puls,upd_pul)foreach(opuls,upd_pul)if(bullet_cancel_origin>0)upd_bulcancel()
upd_combo()foreach(exp_queue,upd_expqueue)end function _draw()cls(13)if(screen_flash>0)rectfill(0+cam_x,0,128+cam_x,128,7)screen_flash-=1return
for n in all(split"700,2400,3000,3750,4800,6550")do if(map_timeline==n)moon_active=not moon_active
end if moon_active then palt(0,true)pal(1,0)memcpy(0,32768,8192)sspr(0,0,128,128,cam_x*.85,moon_y)memcpy(0,49152,8192)pal(1,1)palt(0,false)end palt(cur_transparent,false)palt(15,true)if map_timeline>3680and map_timeline<7900then local e,o,r,l,n,f,i=unpack(map_timeline>5000and split"120,10,30,8,9,.25,.5"or split"123,0,44,5,10,.25,.25")for i=-8*n,128,n*8do map(e,o,r+cam_x*f,i+t*.25%(n*8),l,n)end end for e,n in inext,map_segments do map(n\4*20,(3-n%4)*8,-16,map_progress-e*64,20,8)end palt(cur_transparent,true)palt(15,false)if(draw_particles_above<0)foreach(parts,drw_part)
foreach(pickups,drw_pickup)foreach(enems,drw_enem)foreach(anchors,drw_enem)if(draw_particles_above>=0)draw_particles_above-=1foreach(parts,drw_part)
draw_player()foreach(hitregs,drw_hitreg)foreach(buls,drw_bulfunc)if boss_active and boss.health>0then local n=cam_x+3rectfill(n,3,n+121*(boss.health/boss_maxhealth),4,7)end local n,e,o=3+cam_x,3,tostr(combo_num\1)if(boss_active)e+=6
if(combo_num==0)score_in_combo=0
highest_combo=tostr(max(highest_combo,o))local l=t%720>480and not boss_active local r=l and"HIGH "..highscore or tostr(score,2).."0"?r,n+125-#r*4,e-1,global_flash and 13or 0
?r,n+125-#r*4,e-2,l and 6or 7
if combo_num>50and t%5<4then local r,l=n,e+17if(boss_active)r,l=40+cam_x,7
palt(3,true)for n=0,2do pal(n,combo_colours[n+1+min(combo_num\250,4)*3])end if(combo_on_frame>0)pal(13,5)
for n=1,#o do local e,f=unpack(combo_big_letters[tonum(o[n])+1])sspr(e,f,8,13,r+n*9-3,l)end sspr(110,53,16,10,#o*9+r+6,l)pal(13,13)palt(3,false)allpal()end local l,r,f=min(combo_counter,100),"ᶜ2"..o.."HIT","+"..tostr(score_in_combo,2).."0"if(boss_active)goto skip_ui
e+=15n-=1rectfill(n,e-l/5.9,3+n,e,meter_colours[1+l\10])sspr_obj(86,cam_x-1,-1)?"⁶x3_____________\n_____________\n_____________ᶜ4⁴5\r_____________\n_____________\n_____________",cam_x+7,-3,5
sspr_obj(87,cam_x-5,-1)rect(n+4,14,n+15,17,4)rect(n+4,14,n+15,16,5)if t%500<150then?"MAX",n+6,2,7
r=highest_combo.."ᶜ7HIT"end?r,n+51-#r*4,2,3
?f,n+43-#f*4,8,7
?"|\n⁴f|\n⁴f|",n+3,1,5
::skip_ui::local e=bombs+bomb_preview_offset for o=1,e do if bomb_flash>0and o==e then bomb_flash-=1if(bomb_flash==0)bomb_preview_offset=0
if(global_flash)goto fuck_tokens
end sspr_obj(74,n+9*o-6,122)end::fuck_tokens::n+=128local e=lives+live_preview_offset for o=1,e do if live_flash>0and o==e then live_flash-=1if(live_flash==0)live_preview_offset=0
if(global_flash)goto skip_this_bullshit
end sspr_obj(72,n-9*o,122)end::skip_this_bullshit::if(spiral_pause>0)spiral_pause-=1
spiral_anim(lerp(tonum(spiral_exit),tonum(not spiral_exit),spiral_lerpperc))end function lerp_player()if(t<45)return
if(player_lerp_delay>0)player_lerp_delay-=1return
if(not input_disabled and inbtn>0and player_lerp_perc>50)player_lerp_perc=100
if(player_lerp_perc>=100)player_lerp_perc=-1return
player_lerp_perc+=player_lerp_speed local n=easeoutquad(player_lerp_perc*.01)player.x,player.y=lerp(player_lerpx_1,player_lerpx_2,n),lerp(player_lerpy_1,player_lerpy_2,n)end function easeoutquad(n)n-=1return 1-n*n end function easeinoutquad(n)if(n<.5)return n*n*2
n-=1return 1-n*n*2end function easeoutovershoot(n)return 6.6*n*(1-n)^2end function add_ccounter(e,o)if(combo_counter>100or player_lerp_delay>0)return
local n=combo_counter+e combo_counter,combo_on_frame=combo_num<=0and 0or min(n,max(o or n,combo_counter)),2end function upd_combo()if pause_combo~=0then if(pause_combo>0)pause_combo-=1
return end if combo_freeze>0then combo_freeze-=1else if combo_counter>0then combo_counter-=1else combo_num=0end end end function new_bulcancel(n,e,o)bullet_cancel_origin,bullet_cancel,cancel_start_y,spawn_pickups,player_immune=n,0,0,o,max(n,player_immune)for n in all(buls)do if(n.y>cancel_start_y)cancel_start_y=n.y
end if(e)shot_pause,spawners=e,{}
end function upd_bulcancel()local e=cancel_start_y-bullet_cancel/bullet_cancel_origin*200for n in all(buls)do if n.y>e then if(spawn_pickups)spawn_pickup(n.x,n.y)
spawn_oneshot(9,5,n.x,n.y)del(buls,n)end end bullet_cancel+=1if(bullet_cancel>=bullet_cancel_origin)bullet_cancel_origin=0
end function spawn_pickup(n,e,o,r,l)for f=1,o or 1do add(pickups,{x=n,y=e,ox=0,oy=0,dir=rnd(),spd=rnd(r)or.5,t=t,life=0,type=l or 1})end end function drw_pickup(n)local e,o=n.x+n.ox,n.y+n.oy local d=sqrt(abs(e-player_x)^2+abs(o-player_y)^2)n.life+=1local l,f,r,i,t,a=n.type,n.life,-1,6,50,.35is_bonus=l==2if l==2or l==3then t=20a=.15if not n.dont_wave then local e=f*.001n.ox,n.oy=sin(e)*25,cos(e*2)*10end if(l==2)i,r=13,(n.t+f\90)%3
if(l==3)i,r,a=14,4,.1
end if player_lerp_delay<=0and d<t then n.seek,n.dont_wave,n.ox,n.oy=true,true,0,0end if d<10then spawn_oneshot(9,3,e,o)del(pickups,n)local n="+bomb"if r==0or r==4then if bombs>=3then give_score(5000,1)new_text(e,o-7,"bombs full",60)new_text(e+4,o,"50000",90)return else bombs+=1end elseif r==1then lives+=1live_flash,n=60,"extend"elseif r==2then give_score(1000,1)combo_num+=30combo_counter,n=160,"10000"else coin_chain_timer=20coin_chain_amount+=1local n=50*min(coin_chain_amount,10)give_score(n,1)new_text(e,o,n.."0",45,true)sfx(61,2)return end new_text(e,o,n,90)return end n.x+=sin(n.dir)*n.spd n.y+=cos(n.dir)*n.spd+a n.spd*=.95if(n.seek)n.x,n.y=lerp(e,player_x,.2),lerp(o,player_y,.2)
if is_bonus then local n,e=f%90<5,1for o in all(n and split"1,2,3,4,5,6,7"or split"1,2,3")do pal(o,n and 7or pickup_colours[r+1][e])e+=1end end sspr_anim(i,e,o,n.t)if(is_bonus)allpal()
end function give_score(e,n)local o=n or max(.25*combo_num^1.25,1)local n=e*o if score<152.58788then score+=n>>>16score_in_combo+=n>>>16if score>=152.58788then score,score_in_combo=152.58788,152.58788end end end function spawn_boss(n,o)if(map_timeline~=n)return
map_timeline+=1local e=split(o,"\n")local n=parse_data(e[1])local o,r,l,f=unpack(n[1])boss=spawn_enem(nil,o,r,l)boss_maxhealth,boss_active,boss.brain,boss.intropause,boss.boss_data,boss.stage,pause_timeline=boss.health,true,f,120,e,0,true if n[2][1]~="none"then for e=2,#n do local o,r,l,f=unpack(n[e])local n=spawn_anchor(boss,o,r,l,true,nil,f)n.intropause=120end end boss_incriment_stage(boss,1)end function upd_lerp(n)n.lerpperc+=n.lerprate or 1local e=n.lerpperc*.01local o=n.lerptype=="overshootout"and easeoutovershoot(e)or easeinoutquad(e)n.sx,n.sy=lerp(n.originx,n.tx,o),lerp(n.originy,n.ty,o)if n.lerpperc>=100then local e,o=n.tx,n.ty if(n.lerptype=="overshootout")e,o=n.sx,n.sy
n.lerpperc,n.sx,n.sy=-1,e,o end end function boss_incriment_stage(n,e,o)if(o and e<=n.stage)return
n.stage=e local r=n.stage local e,o=unpack(parse_data(n.boss_data[r+1]))n.lerpcounter=0if#e>0then n.lerpchangerate,n.lerprate,n.lerpindex=e[1],e[2],1local o={}for n=3,#e,2do add(o,{e[n],e[n+1]})end local e,r=unpack(o[1])new_lerpbrain(n,e,r,n.lerprate)boss.lerp_positions=o end if(o[1]=="delete")n.turrets={}
for e=2,#o do add_turret(n,o[e])end end function upd_brain(n,e)local o=sin(n.t*.003)*5if e==2then n.oy=o local o,e=n.health,"2100|1,1|80,1,11|250,2,11|600,1|700,3|1100,1|1150,4,20|1600,1|1750,5,21,22"if o<500then if(t%30==0)draw_particles_above=30new_explosion(n.x,n.y)
e="60|1,9"elseif o<1250or#n.anchors<2then e="2100|1,1|80,1,11|250,7,11|600,1|700,3,16,25|1100,1|1150,4,20|1600,1|1750,8,21,22"if final_boss_phase==1then final_boss_phase,draw_particles_above=2,60new_bulcancel(30,30)new_lerpbrain(n,n.x-10,n.y-15,2,"overshootout")add_expqueue(n.x,n.y,0,"0,-20,10|2,-10,0|7,0,-15|8,15,5|14,-20,10")end end local o=parse_data(e)local r=n.t%o[1][1]for l=2,#o do local f,i,e,a=unpack(o[l])if r==f then boss_incriment_stage(n,i)for o=1,#n.anchors do local r=n.anchors[o]r.turrets={}if(e)add_turret(r,o==2and a or e)
end end end n.lerpcounter+=1if#n.lerp_positions>1and n.lerpcounter%n.lerpchangerate==0then n.lerpindex=n.lerpindex%#n.lerp_positions+1local e,o=unpack(n.lerp_positions[n.lerpindex])new_lerpbrain(n,e,o,n.lerprate)end elseif e==3then n.ox,n.oy,n.dir=sin(n.t*.005)*5,o,.25+sin(t*.01)*.07if(boss.health<400)boss_incriment_stage(n,3,true)
if(boss.health<600)boss_incriment_stage(n,2,true)
elseif e==4then local e=(get_player_dir(n.x,n.y)+0x.08)\0x.1n.dir=mid(.625,e*0x.1,.875)local e=n.dir\0x.1-9if(e<0)e=abs(e+2)
if(n.y<player_y)n.s=turret_sprites[mid(1,e,5)]
end end function spiral_anim(r)if(spiral_exit and spiral_lerpperc==1)load("kalikan_menu.p8",nil,"died|1|"..score.."|"..highest_combo.."|2")
if(spiral_lerpperc==1and not spiral_exit or spiral_pause>0)return
spiral_lerpperc=mid(0,spiral_lerpperc+.015,1)for n=0,63do local e,o,l=n%8*16+cam_x,n\8*16,mid(1,-64+split"1,2,3,4,5,6,7,8,28,29,30,31,32,33,34,9,27,48,49,50,51,52,35,10,26,47,60,61,62,53,36,11,25,46,59,64,63,54,37,12,24,45,58,57,56,55,38,13,23,44,43,42,41,40,39,14,22,21,20,19,18,17,16,15"[n+1]+r*70,5)\1fillp(split"0x0.8,0xa5a5.8,0x7d7d.8,0x7fff.8,0xffff.8"[l])rectfill(e-1,o,e+15,o+17,13)end fillp""end
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
3337777333bbbddbbbbd000dbeeeeeeeeeeeeeeeed9ddbbbbbbbbbbbbbbbbbbbbdd88897799997bbbd088888889900ddbbbbbbbbd056789d056789d856789eee
3733773373bbd33dbbd87778deeeeeeeeeeeeeeeed78dbbbbbbbbbbbbbbbbbbbd9988897799997bbbd0888888000ddbbbbbbbbbbbd40897ed08897ed88997eee
3773773773bb0220bb0878780eeeeeeeeeeeeeeeed78ddbbbbbbbbbbbbbbbbbd89988997799997bbbbd566666500dbbbbbbbbbbbd056789d056789d856789eee
3333773333bd3113db0877880eeeeeeeeeeeeeeeed988dbbbbbbbbbbbbbbbbd889988997799997bbbbd566666550dbbbbddddddbd056678d856678d956679eee
b22333322bb027720b0878780eeeeeeeeeeeeeeeed988dddbbbbbbbbbbbbbd8889988997799906bbbbbd08888055dddddd8888dbd845660d945668d945668eee
bb123321bbd317713dd87778deeeeeeeeeeeeeeeed08889dddddbbbbbbbbd88889989997799045bbbbbd088880056888888888dbbd94554bd94550bd94558eee
bbb1221bbb02700720bd000dbeeeeeeeeeeeeeeeed088999999ddddbbbdd888809899977790456bbbbbbd08880006888888888dbbbd800dbbd980dbbd998deee
eeeeeeeeeed164461deeeeeeeeeeeeeeeeeeeeeeed0899999999779ddd99880088999777990557bbbbbbd00000006688888800dbbbbdddbbbbdddbbbbdddbeee
eeeeeeeeeeb04dd40beeeeeeeeeeeeeeeeeeeeeeed069999999777999999008888997779980567bbbbbbbd08800066888800ddbbbbbddddddbbbeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed858888899779999999888888997799980567bbbbbbbd088000668800ddbbbbbbd622225dbbeeeeeeeeeeee
bbb77777bbbbbb77777bbbbbb33333bbbbbbbbbeedd5ddddd88679999999888888997799950567bbbbbbbbd080006000ddbbbbbbbd72332226dbeeeeeeeeeeee
bb7777777bbbb7777777bbbb3777773bbbbbbbbeebdddbbbdddd68999999888888997799958679bbbbbbbbd08000ddddbbbbbbbbd7137332216deeeeeeeeeeee
b777777777bb777333777bb377bbb773bbbbbbbeebbbbbbbbbbddd888899888888997799985697bbbbbbbbbd0000dbbbbbbbbbbbd6133332216deeeeeeeeeeee
7777777777777733333777377bbbbb773bbbbbbeebbbbbbbbbbbbddddd88088888997799985862bbbbbbbbbd0000dbbbbbbbbbbbd6123322215deeeeeeeeeeee
7777737777777333b3337737bbbbbbb73bbbbbbeebbbbbbbbbbbbbbbbdddd00088997799985063bbbbbbbbbbd000dbbbbbbbbbbbd6412222145deeeeeeeeeeee
777733377777733bbb337737bbbbbbb73b7777beebbbbbbbbbbbbbbbbbbbdd5500897799980706bbbbbbbbbbd000dbbbbbbbbbbbd6741111465deeeeeeeeeeee
7777737777777333b3337737bbbbbbb73777777eebbbbbbbbbbbbbbbbbbbbd6765d86699900560bbbbbbbbbbbd00dbbbbbbbbbbbd5674444654deeeeeeeeeeee
7777777777777733333777377bbbbb773773377eebbbbbbbbbbbbbbbbbbbbd6556dddd89908055bbbbbbbbbbbd00dbbbbbbbbbbbbd56667754dbeeeeeeeeeeee
b777777777bb777333777bb377bbb773b773377eebbbbbbbbbbbbbbbbbbbbdd44ddbbdd8908dddbbbbbbbbbbbbdddbbbbbbbbbbbbbd555544dbbeeeeeeeeeeee
bb7777777bbbb7777777bbbb3777773bb777777eebbbbbbbbbbbbbbbbbbbbbddddbbbbdd80ddddeeeeeeeeeeeeeeeeeeeeeeeeeebbbddddddbbbeeeeeeeeeeee
bbb77777bbbbbb77777bbbbbb33333bbbb7777beebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddddbbeeeeeeeeeeeeeeeeeeeeeebbbbbbbbb7bbbbbbbb7bbbbbeeee
bbbbbddbbbbbbbbbbbbddbbbbbbbbbbbbbdbbbbbbbbbbbbbbb11bbbbb11bbb11beeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbb7bbbbb7bbbbbbbbbbbbbbeeee
bbbbd33dbbbbbbbbbbd33dbbbbbbbbbbbd3bbbbbbbbbbbbbb1771bbb1771b1771eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebbb7bbbbb7bbbbbbbbbbbbbbeeee
bbbbd22dbbbbbbbbbbd220bbbbbbbbbbb02bbbbbbbbbbbbbb1771bbb1771b1771eee44444344434444eeeeeeeeeeeeeeeeeebb777bbbbbbbbbbbbbbbbbbbee55
bbbd3222dbbbbbbbbd3222dbbbbbbbbbd32bbbbbbbbbbbbbb1771bbb2772b1771eee44444344424444eeeeeeeeeeeeeeeeee77777777bbb777bbbbbbbbb7ee55
bbbd21120bbbbbbbb021120bbbbbbbbb021bbbbbbbbbbbbbb2772bbb2772b2772eee44444344424444bbddbbbbddbbbbddbbbb777bbbbbbbbbbbbbbbbbbbee55
bbbd20021dbbbbbbd3200220bbbbbbbd320bbbbbbbbbbbbb127721bb2772b2772eee44344344444444bd77dbbd77dbbd77dbbbb7bbbbb7bbbbbbbbbbbbbbee55
bbd3177123bbbbbb02177125dbbbbbb0217b1111bb1111bb127721b1777712772eee43343124444444dd66dddd66dddd66ddbbb7bbbbb7bbbbbbbbbbbbbbee55
bbd21771d2dbbbbd52177116dbbbbbd5217b1771bb1771b127777211777712772eee43321124444443d3333dd2333dd3333dbbbbbbbbb7bbbbbbbb7bbbbbee55
bbd12ddd723dbbb0612dd2dd3dbbbb0612db1771bb1771b22777722277772277244244111124444424d2222dd1222dd2222deeeeeeeeebbddddbbbddbbbddb55
bd3dd0076223dbd3dd2002d720dbbd3dd20127721b2772b22277222277772277242234111122444244d215ddd1222dd1551deeeeeeeeebd6777dbd67dbd67d55
bd2741146123dd0277411476230bd02774117777112772127277272277772222242131111122244444d266ddd1222dd1661deeeeeeeeed665567d6667dd67d55
d3164444201ddd316644446d123d032664427777217777127277272277772222222141111112244434d2222dd1222dd2222deeeeeeeeed656676d6576dd67d55
d21d3dd310ddbd21d63dd31d01dd321d63d27777227777227777772227722222221142111112244244d1111dd1111dd1111deeeeeeeeed656676d6576dd67d55
d10d12223ddbbd10d122223d0dddd10d12227777227777222777722227722222221144111111244444dd55dddd55dddd55ddeeeeeeeeed567766d5666dd67d55
dd0d301d4dbbbdd0d3d11d4ddbbbdd0d3d1227722277772b277772bb2222b222221144411111444444bd44dbbd44dbbd44dbeeeeeeeeebd5556dbd56dbd67d54
bbdd44d4dbbbbbbdd44dd4ddbbbbbbdd44db2772bb2772bbb2222bbbb22bbb22b42144441114444444bbddbbbbddbbbbddbbeeeeeeeeebbddddbbbddbbbddb4b
__map__
00000000000000000000000000000000000000001301011830311801010101010118303118010103000000000000000000000000000000000000000001010101011a28000000000000291a0101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411809383838380a18404118010103000000000000000000000000000000000000000001010101011a28000000000000291a0101010101080808080d190701010101010107191d0808080800000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301191840411828273636272918404118190103000000000000000000000000000000000000000001010101021a28000000000000291a17010101010938380a1801010101010101010101180938380a00000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301191840411828000000002918404118190103000000000000000000000000000000000000000001010101191a28000000000000291a1901010101281c362918190101010101010101191828361c2900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301191840411828000000002918404118190103000000000000000000000000000000000000000001010101011a28000000000000291a0101010101280405291801010101010101010101182824252900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411828000000002918404118010103000000000000000000000000000000000000000001011b01011a28000000000000291a01011b0101281415291819010101010101010119182834352900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411828000000002918404118010103000000000000000000000000000000000000000001010101031a28000000000000291a1301010101280405291801010101010101010101182824252900000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411802262626261718404118010803000000000000000000000000000000000000000001010101011a28000000000000291a0101010101281415291819010101010101010119182834352902000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011830311801010101010118303118010103002a2b00002a26262626262626262b00000000000101010101262800000000000029260101010101022626171801070101010101010701180226261700000000000000000000000000000000000000000000003e3f413e3f
00000000000000000000000000000000000000001301011840411801010101010118404118010103003739002a170101180101180101022b00000000010808080808072b000000002a07080808080801010101011819010101010101010119180101010100000000000000000000000000000000000000000000003e3f413e3f
000000000000000000000000000000000000000013010118404118190101010119184041180101033230313229382a2626262626262b38283232323238383838380a182800000000291809383838383838380a0102080d0101010101011d08170109383800000000000000000000000000000000000000003e3f414243403e3f
212121212100000000000000000000212121212113011918404118010101010101184041181901031317020938380a1901010101190938380a0102033b30313a2c291828000000002918282d3b3a3b3b363637383838180101010101011838383839363600000000000000000000000000000000000000003e3f414243403e3f
170333242520210000000000002122040533130113010218404118010101010101184041181701031301011830311807010101010718303118010103002a2b002f291b2800000000291b282e000000000405361c363618011b01011b011836361c36242500000000000000000000000000000000000000003e3f414243303e3f
010333343513012021212121220103141533130113010118404118010101010101184041180101031301011840411816080808081618404118010103003739002f373839000000003738392e0000000014152a26262601010101010101012626262b343500000000000000000000000000000000000000003e3f414243403e3f
010323242513010101010101010103040533130113010118404118010101010101184041180101031301011840411807010101010718404118010103003636003c3b3b3a000000003a3b3b3d000000002626170101011a0701010101071a01010102262600000000000000000000000000000000000000003e3f414243403e3f
01033334351301010101010101010314153313011301011840411801010101010118404118010103130101184041180101010101011840411801080300000000000000000000000000000000000000000101010101011a0708080808071a01010101010102000000000000000000000000000000000000003e3f414243403e3f
01033324251301010103130101010304052313011301010930310a0101010101010930310a010103010333242513180101031301011803040523130101033324251301010103130101010304052313010101010101011a0701010101071a01010101010100000000000000000000000000000000000000003e3f314243403e3f
0103333435130101010313010101031415331301130101262626260101010101012626262601010301033334351318010103130101180314153313010103333435130101010101010101031415331301010101010101010101010101010101010101010100000000000000000000000000000000000000003e3f414243403e3f
0103332425130101010313010101030405231301130101180217180101010101011802171801010301033324251318010103130101180304052313010103332425130707070707070707030405231301011901011901010808080808080101190101190100000000000000000000000000000000000000003e3f414243403e3f
010333343513010101031301010103141533130113010118010118011601010701180101180101030103333435131801010313010118031415331301010333343513010101010101010103141533130138383838383838380a010109383838383838383800000000000000000000000000000000000000000000000000000000
010323242513010101031301010103040533130113010118010118010101010101180101180101030103232425131801010313010118030405331301010323242513010c010101010c010304053313011c404136361c36363738383936361c363640411c00000000000000000000000000000000000000000000000000000000
010333343513010101031301010103141533130113010118010118010101010101180101180101030103333435131801010313010118031415331301010333343513010101010101010103141533130119404119011a0938273a3a27380a1a011940411900000000000000000000000000000000000000000000000000000000
010333242513010101031301010103040523130113010118170218010701011601181702180101030103332425130101010313010101030405231301010333242513070707070707070703040523130101303101011a282d3b3a3a3b2c291a010130310100000000000000000000000000000000000000000000000000000000
01033334351301010103130101010314153313011301010938380a0101010101010938380a0101030103333435130101010313010101031415331301010333343513010101010101010103141533130101262601011a283d000000003c291a010126260107000000000000000000000000000000000000000000000000000000
010323242513010101010101010103040533130138383838380a0101010101010101093838383838010333242513070808080808080703040523130101033324251301010103130101010304052313010938380a0126283232323232322926010938380a00000000000000000000000000000000000000000000000000000000
01033334351301010808080801010314153313013b30313a2c373838383838383838392d3b30313b0103333435131d1d1d1d1d1d11120314153313010103333435130101010313010101031415331301282727290118020101010101011718012827272900000000000000000000000000000000000000000000000000000000
0103332425130107101111120701030405231301004041002f363618030101131836362e0040410001033324251d1d1d00001d1d1d1d1104052313010103332425130707080808080707030405231301283031291918010801080108070118192830312900000000000000000000000000000000000000000000000000000000
0103333435130103000000001301031415331301002a2b002f250a18030101131809042e0040410001033334351d1d0000000000001d1d1415331301010333343513010110111112010103141533130128404129011b01010101010101011b012840412900000000000000000000000000000000000000000000000000000000
0103232425130103000000001301030405331301003739002f352918010101011828142e0030310001032324251d00000000000000001d04053313010103232425130603000000001306030405331301284041290118010708010801080118012840412900000000000000000000000000000000000000000000000000000000
0103333435130107202121220701031415331301003636003c2c37383838383838392d3d002a2b0001033334351d1d212121212121221d14153313010103333435130101202121220101031415331301284041291918093838383838380a18192840412900000000000000000000000000000000000000000000000000000000
010333242513010108080808010103040523130100000000002f36303136363031362e00003739000103332425131d1d01011d1d1d1d1d04052313010103332425130707080808080707030405231301284041290138282736363636272938012840412900000000000000000000000000000000000000000000000000000000
010333343513010101010101010103141533130100000000003c3a3b3b3b3b3b3b3a3d0000363600010333343513011d1d1d1d1d0101031415331301010333343513010101031301010103141533130102262617011a28000000000000291a010226261700000000000000000000000000000000000000000000000000000000
__gff__
0001010101000001000000000000000000010101010000010000010000000000000101010100010100000800000000000808090909080808000000000000010108080808080808080000000000000000080808080808080800000000000000000808080808080808000000000000000008080808080808080000000000000000
0808080808080808000000000000000008080808080808080000000000000000080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a51018000404304014040350405504015040350962504015040350405504015040350404304014040350405504015040350262504015040350405504015060341000510005100051000512005100050000500000
9c1018000704307014070350705507015070350762507015070350705507015070350604306014060350605506015060350662506015060330605306015020341300510005100051000510005000000000000000
c01000181723513235102351723513235102351723513235102351723513235102351723513235102351723513235102351823513235102351823513235102350020000200002000020000200002000020000200
c11018001c23517235102351c23517235102351c23517235102351c23517235102351a235122350e2351a235122350e2351a235122350e2351a23512235132350020000200002000020000200002000020000200
01101800230351f0351c035230351f0351c035230351f0351c035230351f0351c035230351f0351c035230351f0351c035240351f0351c035240351f0351c0350c0000c0000c0000c0000c0000c0000c0000c000
0110180028035230351c03528035230351c03528035230351c03528035230351c035260351e0351a035260351e0351a035260351e0351a035260351e0351f0350c0000c0000c0000c0000c0000c0000c0000c000
c110180004235072350b235102350b2351023504235072350b235102350b2351023504235072350b2351023513235102351323517235182351723513235102350020500205002050020500205002050020500000
c1101800072350a2350e235132350e23513235072350a2350e235132350e2351323506235092350d235122350d2351223506235092350d235122350d235122350020500205002050020500205002050020500205
d51000000424004240042400424004240042400424004240032410324500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011018001003513035170351c035170351c0351003513035170351c035170351c0351003513035170351c0351f0351c0351f0352303524035230351f0351c0350c0050c0050c0050c0050c0050c0050c0050c000
0110180013035160351a0351f0351a0351f03513035160351a0351f0351a0351f0351203515035190351e035190351e0351203515035190351e035190351e0350c0050c0050c0050c0050c0050c0050c0050c005
011000000404304014040350405509625040350401504015040430401404043040550962504035040150401503043030140303503055086250303503015030150304303014030350305508625030350304303015
491000001c1351013517135101351c1351013517135101351c1351713513135171351c1351013517135101351b1350f135171350f1351b1350f135171350f1351b1351713512135171351b1350f135171350f135
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c0351303513035130351c0351303513035130351c0351303517035130351c0351303513035130351b0351203512035120351b0351203512035120351b0351203516035120351b035120351203512035
0110000017035100351003510035170351003518035100351703510035100351003517035100351803510035160350f0350f0350f035160350f035170350f03517035160350f0350f03516035120351703518035
951000000443504435044350443500435004350543505435044350443504435044350043500435054350543504435044350443504435004350043500435004350443504435044350443504435044350443504435
951000000343503435034350343500435004350443504435034350343503435034350043500435044350443503435034350343503435004350043500435004350343503435034350343503435034350343503435
011000000404304014040350405509625040350401504015040430401404043040550962504035040150401504043040140403504055096250403504015040150404304014040430405509625040350401504015
011000000304303014030350305508625030350301503015030430301403035030550862503035030430301503043030140303503055086250303503015030150304303014030350305508625030350304303015
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910c1800102350c23509235102350c23509235102350c23509235102350c23509235102350c23509235102350c23509235102350c23509235112350c235092351120000200002000020000200002000020000000
910c1800102350c23509235102350c23509235102350c23509235112350c23509235102350c23509235102350c23509235102350c23509235112350c235092351120000200002000020000200002000020000200
900c18000f2350b235082350f2350b235082350f2350b235082350f2350b235082350f2350b235082350f2350b235082350f2350b23508235102350b235082351020000200002000020000200002000020000200
910c18000f2350b235082350f2350b235082350f2350b23508235102350b235082350f2350b235082350f2350b235082350f2350b235082351023508200102000020000200002000020000200002000020000200
010c00000421504215042150421504215042150421504215042150421504215042150421504215042150421504215042150421504215042150421505215052150420004200042000420004200042000420004200
010c00000321503215032150321503215032150321503215032150321503215032150321503215032150321503215032150321503215032150321504215042150320003200032000320003200032000320003200
010c00000321503215032150321503215032150321503215032150321503215032150321503215032150321503215032150321503215032001a62503200032000320003200032000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b8040000240741c655220710e22110621160710861102611026110161101611016010161100611006110000102601000010000100001000010000100001000010000100001000010000100001000010000100001
580400000e0042a6251a0510e22110621084310863106611056110461101621046110461103611026010160100601006010060101601006010060100601006010060100001006010060100001000010000100001
580400000c6313e611106210841108611026110261101001000010200102001000010000100001026010000100001000010000100001000010000100001000010000100001000010000100001000010000000000
500400000c0541e6252e6010e22110621084110861105611046110361101611026110160100001016010000102601006010000100601000010060100601006010000100001000010000100001000010000100001
a00400000e715056100d7201d63000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
96040000124141e714067151f00000001106010d601006010a6010a6010a601006010960100601096010060109601006010960109601096010060100601006010060100601006010060100601006010060100601
d60100001d5201d5201d5240050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
910100002011500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
a1030000042240a020040030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
__music__
01 08424344
00 08424344
00 09424344
00 08424344
00 09424344
00 080a4344
00 090b4344
00 080c4344
00 090d4344
00 080e4344
00 090f4344
00 08114344
00 09124344
00 08104344
00 08104344
00 08104344
00 08104344
00 480e4344
01 080a4344
02 090b4644
00 13544747
00 13544747
00 13144747
00 13164344
00 13144747
00 13164747
00 13164747
00 13174747
00 13164747
00 13174747
00 13144747
00 13164344
00 1a184344
00 1b194344
00 13144747
00 08104344
00 08104344
00 08104344
00 08104344
00 1d504344
00 1e504344
00 1f504344
00 20504344
01 1d214344
00 1e214344
00 1f224344
02 20234344
__label__
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
i5dll55llll55l5555l5llllllllllllllllllllllllllll977779llll55lllllllllllllllll477774lllllllllllllll5l5555l55llll55lld5l5ll5d5llli
i5ddddddddddddddddddddddddddddddddddddddddddddddl9999l5l5l55l5l5lllllllllllll977779lllllllllll5l5l5l5555l5577ll77ll777l777d777li
i5dddqdd55555555555555555599959995555555555555ddllllllllll55lllllllllllllllll977779lllllllllllllll5l5555ddd27dd2755722l227d727li
i5ddqqdd555lldl555l5llllllll9lll9l9l9l999l999lddllllllllll55lllllllllllllllll977779lllllllllllllll5l555ldll575557ll7775l77d7l7li
i5dqqqdd555lldl555l5llllll999l999l9l9ll9lll9llddllllllllll55llllllllllllllllll9779llllllllllllllll5l555ldll575557ll2275l27d7l7li
i5dqqqddddddddl555l5llllll9lll9lll999ll9lll9llddllllllllll55llllllllllllllllllllllllllllllllllllll5l555lddd777d77757775777d777li
i5dqqqddlllllll555l5llllll999l999l9l9l999ll9llddllllllllll544llllllllllllll44lllllllllllllllllllll5l555llll222l222l2225222d222li
i5dqqqddddddddddddddddddddddddddddddddddddddddddllllllllll4774llllllllllll4774llllllllllllllllllll5l555lllllllllllld5l5ll5d5llli
i5dqqqdd55555555555555555555557755775577757775ddllllllllll4774llllllllllll4774llllllllllllllllllll5l5555l5555lll5lld5l5ll5d5llli
i5dqqqddl5555l5555l5l5l5lll7lll7lll7ll7lllll7lddllllll5l5l4774l5llllllllll4774llllllllllllllll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dqqqddl555ll5555l5llllll777ll7lll7ll777ll77lddllllllllll9779llllllllllll9779llllllllllllllllllll5l5555ll555ll55lld555ll5d5llli
i5dqqqddl5555l5ll5l5lllllll7lll7lll7llll7lll7lddlllllllll497794llllllllll497794lllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dqqqddl5555l5ll5l5llllllllll777l777l777l777lddlllllllll497794llllllllll497794lllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dqqqddddddddddddddddddddddddddddddddddddddddd5llllllll49777794llllllll49777794llllllllllllllllll5l5ll5ll555lll5lldl55ll5d5llli
i5dqqqdd5555555555d5555555555555555555555555555lllllllll99777799llllllll99777799llllllllllllllllll5l5ll5l5555ll5dlldl55ll5d5llli
i5dqqqddddddddddddd5llllllllllllll4444llllllllllllllllll99977999llllllll99977999llllllllllllllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dqqdd5555555555555llllllllllllll4774llllllllllllllllll97977979alllllll97977979llllllllllllllllll5l5555l55llll55lld5l5ll5d5llli
i5dqdddllll55l5555l5l5l5llllllllll4774llllllllllllllll5a97977979aallllll97977979llllllllllllll5l5l5l5555l55lllllllld55lll5d5l5li
i5dddddddddddd5555l5llllllllllllll9779llllllllllll9a9lla97777779aallllll97777779llllllllllllllllll5l5555ddddddddd55d55lll5d5llli
i5dddd555522222255l222222ll22l22l2222222222lllll4aaa9a4a99777799aallllll99777799llllllllllllllllll5l555ldll55555llld555ll5d5llli
i5555555522iiii22522iiii22loolooliooiiiooiillii29a9aaa9aa9777797aa7llllll977779lllllllllllllllllll5l555ldll55555llld555ll5d5llli
i5d55dddd2i22iii252i22iii2l88l88l98877988ll2i67i9aaaaa9aa79999a7aaa77lllll9999llllllllllllllllllll5l555lddddddddd55d5l5ll5d5llli
i5dlllllloooollio5oooolliol88l88l98877988ll2i67i9aaaaa949aa7a7aa9aaaa77lllllllllllllllllllllllllll5l555lllllllllllld5l5ll5d5llli
i5dllllllii88ll585ii88lll8l88888l98877988ll2i67i4aaa9a444aaa5aaa7aaa7a7llllllllliilllliillllllllll5l555lllllllllllld5l5ll5d5llli
i5dll5llli88il5885i88ill88l88i88ll8879l88ll2i67i449a9444aaaaaaaaaa7777777lllllli88iiii88illlllllll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll88iil88i588iil88ilooloolloolllooll2i67i4444444aa77777777a77777777777iio88i77778oiilll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll8iil88ii58iil88iil22l22ll22lll22992i67il24494777a77777777777777779li62o84777777o26illllll5l5555ll555ll55lld555ll5d5llli
i5dll55lloi55oooo5oillooool22l22l2222l922ll2lii2l2ll779a9a77777777777777777lli2o4777aa77o2illlllll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll2555iii2525lliii2liiliiliiii9liillll2l2ll47449aa777777777777a777779llio4777aa77oillllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll22222222522222222lllllllll9lllllllllllll47aaa4a977777a77777aaa77779lli6977777776illllllll5l5ll5ll555lll5lld5l5ll5d5llli
i5dlld5lliiiiiiii5iiiiiiiillllllll9lllllllllllll9a7aaa4497777aaa77777a777779lli69777777d6illllllll5l5ll5l5555ll5dlld5l5ll5d5llli
i5dll55lliiiiiiii5iiiiiiiilllllll9lllllllllllll447aa9aaa477777a777777777777lllid9779id22dillllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllll9llllllllllllll49iiaaa9a9777777777777777779llll477774iddilllllllll5l5555l55llll55lld5l5ll5d5llli
iiiiillllll55l5555l5l5l5lllllll9lllllllllllllll4i67iaaaa94777777777777777llllll477774liillllll5l5l5l5555l55lllllllld555ll5d5l5li
i6777idddddddd5555l5lllllllllll9llllllllllllllli6667iaaa9457777777777777lllllll977779lllllllllllll5l5555ddddddddd55d555ll5d5llli
i6dd67i5555lldl555l5lllllllllll9llllllllllll44446d76ia9a445577777977779llllllll977779ll4444lllllll5l555ldll55555llld555ll5d5llli
id6676i5555lldl555l5lllllllllll9llllllllllll47746d76ia9a4l55lllll977779llllllll977779ll4774lllllll5l555ldll55555llld555ll5d5llli
id6676idddddddl555l5lllllllllll9llllllllllll4774d666ia44ll55lllll977779llllllll977779ll4774lllllll5l555lddddddddd55d5l5ll5d5llli
i67766illllllll555l5llllllllllll9llllllllll497794d6i774lll55lllll997799llllllll997799l497794llllll5l555lllllllllllld5l5ll5d5llli
iddd6illlllllll555l5lllllllllllll9lllllllll477774iilll777l55lllll997799llllll77997799l477774llllll5l555lllllllllllld5l5ll5d5llli
iiiii5lll5555l5555l5llllllllllllll9llllllll977779llllllll7777lllll9999lll7777lll9999ll977779llllll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5lllllllllll9lllllll977779lllll5l5l55l777777997777llllllll99lll977779ll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllll99lllll977779lllllllll55llll99llllllllllllllllllll977779llllll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllll99lll997799lllllllll55ll99llllllllllllllllllllll997799llllll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllll99999779lllllllll99999lllllllllllllllllllllllll9779lllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5lllllllllllllllllllllllll999999999999l55llllllllllllllllllllllllllllllllllllll5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllll44lllllllll44lllllllll5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll4774lllllll4774llllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll4774lllllll4774llllllll5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5lllllllllll9779lllllll9779llll5l5l5l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll9779lllllll9779llllllll5l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllll9779lllllll9779llllllll5l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllll477774lllll477774lllllll5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllll477774lllll477774lllllll5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55llllllllllllll977779lllll977779lllllll5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllll3333ll444455llllllllllllll977779lllll9777794444lll5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5lllllllllllllllllllllllllll3rqqr3l477455llllllllllllll977779lllll9777794774lll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5lllllllllllllllllllllll3r77r3l477455l5l5llllllllll977779lllll9777794774l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllll3rq77qr3977945llllllllllllll997799lllll99779997794ll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllll3rq77qr3777745llllllllllllll997799lllll99779977774ll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5lllllllllllllllllllllllllll3r77r39777795lllllllllllllll9999lllllll9999977779ll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5lllllllllllllllllllllllllll3rqqr39777795llllllllllllllll99lllllllll99l977779ll5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllll3333l9777795llllllllllllllllllllllllllllll977779ll5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l5ll5l5lllllllllllllllllllllllllllllllll9977995llllllllllllllllllllllllllllll997799ll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5lllllllrrrllllllllllllllllllllllll977955lllllllllllllllllllllllllllllll9779lll5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llrqqqrlllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5555l5lllllrqa7aqrllllllllllllllllllllllllll55llllllllllllllllll44lllllll44lllllllll5l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllrqa777qrllllllllllllllllllllllllll55lllllllllllllllll4774lllll4774llllllll5l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllrq777aqrllllllllllllllllllllllllll55lllllllllllllllll4774lllll4774llllllll5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllrqa7aqrlllllllllllllllllllllllllll55lllllllllllllllll4774lllll4774llllllll5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5lllllrqqqrllllllllllllllllllllllllllll55lllllllllllllllll9779lllll9779llllllll5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllrrrlllllllllllllllllllllllllllll55lllllllllllllllll9779lllll9779llllllll5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllllll9779lllll9779llllllll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5lllllllllllll9779lllll9779llll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllllllllllllllll55ll4444lllllllllll9779lllll9779llllllll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55ll4774lllllllllll9779lllll9779lll4444l5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55ll4774lllllllllll9999lllll9999lll4774l5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllllllllllllllllllllllllllllllll55ll9779lllllllllll9999lllll9999lll4774l5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5666l666l666llllllllllllllllllllllllllllllll55l497794llllllllll9999lllll9999lll9779l5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l56l5l6l6l6l6llllllllllllllllllllllllllllllll55l477774llllllllll9999lllll9999ll4977945l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5666l6l6l6l6llllllllllllllllllllllllllllllll55l977779llllllllll9999lllll9999ll4777745l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5556l6l6l6l6llllllllllllllllllllllllllll5l5l55l977779lllllllllll99lllllll99lll9777795l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5666l666l666llllllllllllllllllllllllllllllll55l977779lllllllllllllllllllllllll9777795l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55ll9779llllllllllllllllllllllllll9777795l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllllllllllllllllllllll9779l5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllllllllllllllllllllllllllllllllllll55lllllllllllllllll77lllll77llllllllllll5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55lllll77llllllll777777lii7777lllll77lll5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55llll7777llllll7777777iaai7777lll7777ll5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5llllllllllllllllllllllllllllllllllllll55llll7777llllll7777777299i7777lll7777ll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l777777llll7777777i999ai7777l777777l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllllllllllllllll55lll777777llll77777772944927777l777777l5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lll777777llll777777299229ai777l777777l5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lll777777lllll7777id947749277ll777777l5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllllllllllllllllllllllllllllllll55llll7ii7lllllll777i6447749dillll7ii7ll5l5ll5ll555lll5lld5l5ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lllli77illllllll7iaii9ii9462lllli77ill5l5ll5l5555ll5dlld5l5ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55lllii66iillllllli297i9229iiaillii66iil5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllllllllllllllllllllllllllllll55llliaaaailllllll2a96754457792iliaaaail5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5li9999illllllia94i65555664aili9999il5l5555l55lllllllld555ll5d5l5li
i5d55ddddddddd5555l5llllllllllllllllllllllllllllllllllllll55llli4dd4illllllii42i4aiia6i49ili4dd4il5l5555ddddddddd55d555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llli4664illlllliii2ia99994i24ili4664il5l555ldll55555llld555ll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llli9999illlllllllii5i44iai2iili9999il5l555ldll55555llld555ll5d5llli
i5d55dddddddddl555l5llllllllllllllllllllllllllllllllllllll55llli4444illllllllllii5ii55iillli4444il5l555lddddddddd55d5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55llliiddiilllllllllllllllllllllliiddiil5l555lllllllllllld5l5ll5d5llli
i5dllllllllllll555l5llllllllllllllllllllllllllllllllllllll55lllli55illlllllllllllllllllllllli55ill5l555lllllllllllld5l5ll5d5llli
i5dll5lll5555l5555l5llllllllllllllllllllllllllllllllllllll55llllliilllllllllllllllllllllllllliilll5l5555l5555lll5lld5l5ll5d5llli
i5dlld5ll5555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l5555ll5dlld555ll5d5l5li
i5dll55ll555ll5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555ll555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5ll555lll5lldl55ll5d5llli
i5dlld5ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll5dlldl55ll5d5llli
i5dll55ll5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l5555ll55lld5l5ll5d5llli
i5dll55llll55l5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555l55llll55lld5l5ll5d5llli
i5dllllllll55l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l55lllllllld55lll5d5l5li
i5d55ddddddddd5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555ddddddddd55d55lll5d5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555ldll5555iilld555liid5llli
i5dlll55555lldl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555ldll555iaaild555iaai5llli
i5d5i222idddddl555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555ldddddd29925d5l529925llli
i5dio777oilllll555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555llllllia44aid5lia44aillli
i5d2o7o7o2lllll555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l555llllll297792d5l297792llli
i5d2o77oo2555l5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555l555ia4774ai5ia4774ailli
i5d2o7o7o2555l5555l5l5l5llllllllllllllllllllllllllllll5l5l55l5l5llllllllllllllllllllllllllllll5l5l5l5555l555297227925297227925li
i5dio777oi55ll5555l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5555ll55i465564i5i465564illi
i5dli222i5555l5ll5l5llllllllllllllllllllllllllllllllllllll55llllllllllllllllllllllllllllllllllllll5l5ll5l555525ii52d5525ii52llli
i5dll55ll5555l5ll5l5llllllllll55llllllllllllllllllllllllll55llllllllllllllllllllllllll55llllllllll5l5ll5l5555ll55lld555ll5d5llli
i5dll5lll555ll5ll5l5llllllllll55llllllllllllllllllllllllll55llllllllllllllllllllllllll55llllllllll5l5ll5ll555lll5lldl55ll5d5llli
iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii