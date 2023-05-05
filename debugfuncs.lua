
debug=""
debug_time=0

poke(0x5f2e,1) -- keeps the colours on quit

function ndebug(_msg, _time) -- new debug_msg
	debug=_msg
	debug_time=_time or 60
end

function drw_debug()
	if debug_time>0 then
		debug_time-=1
		if(debug_time<=0)debug=""
	end

	print(debug,1,1,7)
end


function debug_hitboxes()
	-- player col , pul col , enem col , bul col
	local plcol,pulcol,encol,bulcol=10,11,10,11

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




