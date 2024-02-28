
debug,debug_time="",0
poke(0x5f2e,1) -- keeps the colours on quit


function debug_hitboxes()
	
	-- player col , pul col , enem col , bul col
	local plcol,pulcol,encol,bulcol=10,8,10,8

	if(t\4%2==0)draw_hitbox(player_x, player_y, player.hb, plcol)

	for enem in all(enems) do
		draw_hitbox(enem.x,enem.y,enem.hb,encol)
	end

	for bul in all(buls) do
		draw_hitbox(bul.x,bul.y,bul.hb,bulcol)
	end

	for pul in all(puls) do
		draw_hitbox(pul.x,pul.y,pul.hb,pulcol)
	end

	for opul in all(opuls) do
		draw_hitbox(opul.x,opul.y,opul.hb,pulcol)
	end
end

function draw_hitbox(_x,_y,hb,_c)
	local x,y=_x+hb.ox,_y+hb.oy
	rect(x,y,x+hb.w-1,y+hb.h-1,_c)
end


--[[
function start_at(_num)
	map_timeline=_num

    local current_target=1
	for spawn in all(enemy_spawns) do
		if(_num>spawn[1])current_target+=1
	end

	map_spawnstep=current_target
	map_nextspawn=enemy_spawns[map_spawnstep]

end
]]--