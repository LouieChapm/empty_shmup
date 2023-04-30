
debug=""


function drw_debug()
	print(debug,1,1,7)
end


function debug_hitboxes()
	-- player col , pul col , enem col , bul col
	local plcol,pulcol,encol,bulcol=11,10,9,10

	if(t\4%2==0)draw_hitbox(player_x, player_y, player.hb, plcol)

	for enem in all(enems) do
		draw_hitbox(enem.x,enem.y,enem.hb,encol)
	end

	for pul in all(puls) do
		draw_hitbox(pul.x,pul.y,pul.hb,pulcol)
	end
end

function draw_hitbox(_x,_y,hb,_c)
	local x,y=_x+hb.ox,_y+hb.oy
	rect(x,y,x+hb.w-1,y+hb.h-1,_c)
end