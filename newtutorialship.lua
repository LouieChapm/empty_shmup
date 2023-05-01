
pal({[0]=128,133,141,7,129,1,140,12,134,6,136,8,3,139,11,10},1)
--pal({[0]=128,133,141,7,129,1,140,12,134,6,3,139,136,8,137,10},1)
--pal({[0]=128,134,6,7,129,1,140,12,132,143,3,139,136,8,137,10},1)
--pal({[0]=0,128,133,7,129,1,140,12,130,2,11,138,136,8,137,10},1)
--pal({[0]=0,128,133,7,129,1,140,12,3,139,11,138,136,8,137,10},1)

function _init()
	cls(6)
	t=0
	debug=""
    
    
    
    --player stuff--
    p1x=64-8
    p1y=100
    spd=1.7                 --player movement speed
    focus=.65               --this is the speed you reduce to when holding shoot button
    shield = {
        hits = 3,           -- the current number of hits the shield can take
        max_hits = 3,       -- the maximum number of hits the shield can take
        recharge_delay = 60,-- the delay before the shield starts recharging
        cooldown = 0,       -- the remaining time until the shield starts recharging
        colors = {11, 15, 14},
        currcolor=0,        -- the colors for each hit count (green, yellow, red)
        hit_color = 7       -- the color the shield will flash when hit (white)
    }
    
    hit = false             -- becomes true if you collide with a damaging object and affects the shield or health
    eco=0                   -- this is the eco meter, it climbs when you collect oil, maxes out at ten ,mins out at zero. it is what to use as a score multiplier
    lastdir=0               -- allows you to know if your direction input has changed which helps cobblestoning
 	shotwait=0              -- the countdown timer that delays firing again
    jet_time=0              -- the ticker that counts through the players jet sprites
    


    --button restriction and diagonal normalizing--
    butarr={1,2,0,3,5,6,3,4,7,8,4,0,1,2}  --each button input is the index position and the indexed number is what we want that button to do. 
	butarr[0]=0 --accounts for nil
 
    dirx={-1,1, 0,0,  -.7,.7,-.7,.7}  --makes it so if you are moving diagonal you go slower. 
    diry={ 0,0,-1,1,  -.7,-.7, .7,.7}
	
    dirx[0]=0 --accounts for nil
    diry[0]=0
	
    --the ship sprite animation array
    shiparr={1,3,5,7,9}
	shipspr=3.5  --middle position between the two ends of the sprite selection
    
    
    
    parts={}   --explosions container
    muz={}  --muzzleflash container
    shots={} --player bullet container
    
    --wake trail
	left_waves={}
	right_waves={}

	oils={} --oil container

    
    

    -----------------------------------------------------------------
    --THESE CONTROL THE SEGMENTS OF MAP THAT WILL GET DRAWN----------
    -----------------------------------------------------------------
    mapsegs={0,1,1,2,3,3,3,4,5,5,5,5,5,6,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28}	
    	
    mapsegi=1           -- the index counter we adjust to move which seg we draw
    cursegs={}          -- contains the three current segments in the draw
    scroll=0            -- the counter that will determine when the map moves and when enemies will spawn
    xscroll=0           -- moves the map left and right TODO switch to moving a camera of figure out how to shift every enemy and oil
    boss=false          --when true it will repeat the current segment so you can fight the boss
  
end

---------------------------------------------

--------------update-------------------------

---------------------------------------------
function _update60()
    --generic timer per frame
    t+=1

    --scroll value that controls the y scroll speed
    scroll+=.5


    -- adds a blob of oil for testing reasons ....    todo remove
    if t%2==0 and t < 10000 then
    	add(oils,{x=4+rnd(114), y=-4, r=4,})
    end
   
   --updates the oils attributes
    for o in all(oils) do
    	o.y+=0.5
        
		
        local playerdist=(p1x+9-o.x)*(p1x+9-o.x)+(p1y+9-o.y)*(p1y+9-o.y)  --this judges the distance between you and the oil ....   todo wrap in a function 
    	
        
        if playerdist<spd*spd*50*35 then    --- uses speed to control the distance that can suck up the oil, so that you have to stop shooting to collect the screens oil
						
        -- move toward player + shrink
        o.r -= 0.07
        local angle = atan2(p1x+8-o.x,p1y-o.y)
        o.x += cos(angle) * 1
        o.y += sin(angle) * 1                  
    	end
    	

        --eco meter is a score multiplier. draw a rectangle from the top of the eco meter donwards and have a black bar behind it so when you lose eco the black climbs up the green bar
        
        
        -- deletes the oil if you suck it in and grants you some eco
        if  playerdist < 20 or o.r<=0 then  
            del(oils,o)	
            eco+=.5 --to the eco meter
        end
        -- deletes the oil if you fail to collect it, removes some eco
        if o.y > 132 then 
            del(oils,o)
            eco-=1 -- from the eco mete
        end 
    end


    -- limits the eco meter for use as a multiplier
    if eco <0 then
        eco=0  
    end
    if eco >10 then
        eco=10
    end
 
    --scroll-cursegs[#cursegs].offset>0 
    if #cursegs <1 or scroll-cursegs[#cursegs].offset>0 then
        
        if boss then
            scroll-=64
            for seg in all(cursegs) do
                seg.offset-=64
            end
        else
        mapsegi+=1
        end
        local segnum=mapsegs[mapsegi]
        add(cursegs,{
            x=(segnum-1)\4*18,
            y=(segnum-1)%4*8,
            offset=#cursegs<1 and -64 or cursegs[#cursegs].offset+64
        })
        
        if scroll-cursegs[1].offset>=128 then
            deli(cursegs,1)
        end
  
   end
   --animate the jets by moving jet time
    if t %4 == 0 then
        jet_time+=1
    end
    
    --stops the timer from getting too high
    if t > 1000 then
        t=1
    end
   
    --uses button values to set direction
	dir=butarr[btn()&0b1111]
	--sets the centerpoint for the sprite animation
	local dshipspr=3.5
    --moves the player in the direction pressed
	if dir>0 then
	    p1x+=dirx[dir]*spd
	    p1y+=diry[dir]*spd
        
    end
    --limits player to the screen
    p1x = mid(p1x,0,112)
				p1y = mid(p1y,0,112)
	--changes player sprite based on player movement direction
    if     dirx[dir] < 0 then
            dshipspr = 1.95
    elseif dirx[dir] > 0 then
            dshipspr = 5
    end
	--controls how quickly you go through the roll animation
	local bankspd=0.25
	
	--applies the banking speed to the sprite change
	if dshipspr<shipspr then
		shipspr-=bankspd
	elseif dshipspr>shipspr then
		shipspr+=bankspd
	end
    -- clamps the ship sprite value to the 5 sprites
    shipspr=mid(1.95,shipspr,5)
    --anti cobblestoning movement detection
    lastdir=dir

    --sideways scroll update
    xscroll=mid(0,p1x/100,1)*-16
    --sets player to the center of a pixel so as to avoid the rounding setting you off
	if lastdir!=dir and dir>=5 then
	    --anti cobble--
	    p1x=flr(p1x)+0.5
	    p1y=flr(p1y)+0.5
	
	end


     --------------------------
	 ----shooting--------------
     --------------------------


     if btn(05) then
        --slows the player down for focus fire
        --todo make this triger after so many frames and ramp up much quicker
        spd-=.05
        if spd < focus then
            spd=focus
        end
    else
        spd=1.4
    end
    
    --fires the gun
	if btn(05) then 
       
        shot_ddp()
    				
    end
    --secondary function to be determined, likely bomb button
    --boss=btn(04)
    if btnp(04) then 
        explode(12+rnd(20),64)
        hit=true
    				
    end
    --makes the explosions
    for p in all(parts) do
        dopart(p)
        
    end

   --makes the stuff happen
    doshots()
    domuzflash()
    dowake()
    doshields()
end

-------------------------------------------

-------draw--------------------------------

-------------------------------------------
function _draw()
    cls(6)--sets bg color to alt blue
    
    palt(0,false)--removes the transparency of pal zero

    draw_mapbg() --draws the water layer flag zero

	--draws the oil particles	
    for o in all(oils) do
		circfill(o.x, o.y, o.r, 0)
	end

    --sineyshift(time(),4,4,-25,10,121)
    --sine_xshift(time(),4,4,-15,0,111)
    
    palt(6,true)--makes alt blue transparent so map tiles are clean cutouts
    draw_mapfg()--draws flag 1
    
    --controls the players jetfire
    local jet={53,54,55,54}
    local jetframe = jet[t\4%4+1]
    --resets the animation
    if jet_time > #jet then
    jet_time=1
    end

    --draws shield uner most things
    draw_shield()
    
    
    --draws explosion
    for p in all(parts) do
		if p.wait == nil then
			p.draw(p)
		end		
	end
	
    --draws bullets
    for s in all(shots) do
        spr(s.shotanim[flr(s.sprite_index)],s.x,s.y,s.w/8,s.h/8)
        
    end
   
    --drws the players wake
    draw_waves()


    draw_sprite_with_outline(shiparr[flr(shipspr)],p1x,p1y,2,2)
    
    
    --draws the player muzzleflash
    for s in all(muz) do
        spr(s.shotanim[flr(s.sprite_index)],p1x+s.x,p1y+s.y,s.w/8,s.h/8)
    end
    
    --draws the player jetfire
    spr(jetframe,p1x+4,p1y+14,1,1)
    
    ---------------------------------

    -------print statements----------

    ---------------------------------

    print(debug,5,9,14)
    print("eco"..":"..flr(eco),5,15,14)
    --print(flr(shipspr),5,21,8)
    --print(boss and "boss" or "noboss",5,27,8)
    btnv=btn()&0b1111
	--print(#oils, 5, 21,8)
	print(#oils,5,21,14)



end

---------------------------------

----this is the map stuff--------

---------------------------------
--this draws the water map layer
function draw_mapbg()

    for seg in all(cursegs) do
       
        
        map(seg.x,seg.y,xscroll,scroll-seg.offset,18,8,1)
					
        -- local myseg=seglib[mapsegs[i]]
        -- local segy=scroll-(i-1)*64
        -- map(myseg.mx,myseg.my,xscroll,segy,18,8)
    end   
    

end
--this draws the map stuff on top of the water todo add blue as transparency
function draw_mapfg()

    for seg in all(cursegs) do
       
        
        map(seg.x,seg.y,xscroll,scroll-seg.offset,18,8,2)
					
        -- local myseg=seglib[mapsegs[i]]
        -- local segy=scroll-(i-1)*64
        -- map(myseg.mx,myseg.my,xscroll,segy,18,8)
    end   
    

end 

-------------------------------

---this is the shooting--------

-------------------------------

--please make sure to get the bullet bending code from here. 

function shot_ddp()
        
        
        
        if shotwait<=0 and #shots < 100 then
        local shotspeed=5
        aim=((p1x+9)/16)-4
        aim2=-((p1x+9)/16)+4
        aim3=-(flr(shipspr)*spd)+3*spd
            add(shots,{
                x=p1x,
                y=p1y-16,
                h=16,
                w=8,
                sx=aim3,
                sy=shotspeed,
                sprite_index=t\4%4+1,
                shotanim={34,35,36,35}
            })
            add(shots,{
                x=p1x,
                y=p1y-16,
                h=16,
                w=8,
                sx=1+(aim3),
                sy=shotspeed,
                sprite_index=t\4%4+1,
                shotanim={34,35,36,35}
            })
            add(shots,{
                x=p1x+9,
                y=p1y-16,
                h=16,
                w=8,
                sx=aim3,
                sy=shotspeed,
                sprite_index=t\4%4+1,
                shotanim={34,35,36,35}
            })
           
            add(shots,{
                x=p1x+9,
                y=p1y-16,
                h=16,
                w=8,
                sx=-1+(aim3),
                sy=shotspeed,
                sprite_index=t\4%4+1,
                shotanim={34,35,36,35}
            })
           
            add(muz,{
                x=-5,
                y=-17,
                h=16,
                w=16,
                decay=0,
                sprite_index=t%3+1,
                shotanim={40,42,44,42}
                })
                
                add(muz,{
                x=5,
                y=-17,
                h=16,
                w=16,
                decay=0,
                sprite_index=t%3+1,
                shotanim={40,42,44,42}
            })

            shotwait=5
            sfx(0)
            
            end

    

end

function doshots()
	if shotwait >0 then 
	shotwait -=1
	end
	
	for s in all(shots) do
		local currx=p1x
		local curry=p1y
        if t%3==0 then
            s.sprite_index+=1
        end

        if flr(s.sprite_index) > #s.shotanim then
            s.sprite_index=1
        end

		if s.y < -16 then
		del(shots,s)
		end

		if s.x > abs(currx+128) then
		del(shots,s)
        end
        
	end
	
    

    for s in all(shots) do
      s.x-=s.sx
      s.y-=s.sy  
    end

end

function domuzflash()
	
	
	for s in all(muz) do
        --  if t%2==0 then   
        --     s.decay+=1
        --  end
        
         if t%2==0 then
            s.sprite_index+=1
        end
        
        if flr(s.sprite_index) > #s.shotanim then 
            del(muz,s)
        end
        
        -- if s.decay > #s.shotanim then
        --     del(muz,s)
        -- end

	end

end

------------------------------------------

---------this is the shield controls------

------------------------------------------


    -- this function updates the shield, managing its cooldown and recharging process.
function doshields()
    shield.cooldown -=1     -- decrease the cooldown timer by 1
    if shield.cooldown == 0 and shield.hits < shield.max_hits then
    shield.hits +=1  
    shield.cooldown = shield.recharge_delay       -- recharge the shield by 1 hit if cooldown is 0 and not at max hits
    end
   
    shield.currcolor=shield.colors[shield.hits]
    
    if shield.hits<0 then
        shield.hits=0
    end
    -- this function handles taking damage to the shield, decreasing the number of hits, and starting the cooldown
    if hit==true then
        shield.hits = shield.hits - 1               -- decrease the shield hits by 1
        shield.cooldown = shield.recharge_delay     -- reset the cooldown to the recharge delay
        hit=false
    end
    -- this function returns the current color of the shield based on the remaining number of hits.

end
    -- this function returns the flash color of the shield when hit (white). todo actually make this work lol should flash white for like 5 frames 
function flash_shield()
    return shield.hit_color                         -- return the shield hit color (white)
end
    -- draws the shields todo add some sparkly shit here
function draw_shield()
    if shield.hits > 0 then
        -- get the color corresponding to the remaining hits
        circ(p1x+8, p1y+8,12,shield.currcolor)    -- draw the shield shape at position (x, y) with the given radius and color
    end
end

-------------------------------------------------------

------sprite outline code------------------------------

-------------------------------------------------------

function draw_sprite_with_outline(sprnum, x, y,w,h)
        -- set all colors to black
        for i = 1, 15 do
            pal(i, 5)
        end

        -- draw the black outline
        for dx = -1, 1 do
            for dy = -1,1 do
                if dx ~= 0 or dy ~= 0 then
                    spr(sprnum, x + dx, y + dy,w,h)
                end
            end
        end

        -- reset the palette
        pal()
        pal({[0]=128,133,141,7,129,1,140,12,134,6,136,8,3,139,11,10},1)
        palt(6,true)
        -- draw the original sprite on top
        spr(sprnum, x, y,w,h)
    
end

------------------------------------------------------

---------water wigglers-------------------------------

------------------------------------------------------
--destined to be removed, pursuing pal shifting for water animation
function sineyshift(t,a,l,s,y1,y2)
    local dy = y2-y1+1
 
    memcpy(0x4300,0x6000+64*y1,64*dy)
 
    for y=y1,y2 do
     local yy = (y + flr(a * sin((y + flr(t*s + 0.5) + 0.5) / l) + 0.5)) % dy
 
     memcpy(0x6000+64*y,0x4300+64*yy,64)
   end
end

 function sine_xshift(t,a,l,s,y1,y2,mode)
    for y=y1,y2 do
      local off = a * sin((y + flr(t*s + 0.5) + 0.5) / l)
  
      if mode and y%2 < 1 then off *= -1 end
  
      local x = flr(off/2 + 0.5) % 64
  
      local addr = 0x6000+64*y
  
      memcpy(0x4300,addr,64)
      memcpy(addr+x,0x4300,64-x)
      memcpy(addr,0x4340-x,x)
    end
end

--------------------------------------------------------------------

----this is the code for the wake effect----------------------------

--------------------------------------------------------------------

function dowake()
    --these timers control the wave bounce
    timer1 = 1 - abs(time()/.1 % 2 - 1)
    timer2 = 1.3 - abs(time()/(timer1*2) % 2 - 1)
    timer3 = time()/.2 % 1.5
    
    -- this adds the waves--
    if t%1==0 then
        add(left_waves,{
        x=p1x-1+timer2,
        y=p1y-5,
        sp=37,
        age=0,
        maxage=2+timer3*3,
        cen=false
        })
        add(right_waves,{
        x=p1x+9+timer3,
        y=p1y-5,
        sp=37,
        age=0,
        maxage=2+timer3*3,
        cen=false
        })
        add(left_waves,{
        x=p1x-2-timer3,
        y=p1y+8,
        sp=37,
        age=0,
        maxage=7,
        cen=true
        })
        add(right_waves,{
        x=p1x+10+timer3,
        y=p1y+8,
        sp=37,
        age=0,
        maxage=7,
        cen=true
        })

    end

    --moves the waves-----
    for w in all(right_waves) do
        if w.cen==false then
            w.age+=1
            w.x+=1.5+timer3-(w.age/2)
            w.y+=3
        end
        
        if w.cen==true then
            w.age+=1
            w.x+=-.5+timer2/2+(w.age/16)
            w.y+=3
        end
        if w.age>=w.maxage then
            del(right_waves,w)
        end
    end
    for w in all(left_waves) do
        
        if w.cen==false then
            w.age+=1
            w.x-=1.5+timer3-(w.age/2)
            w.y+=3
        end
        
        if w.cen==true then
            w.age+=1
            w.x+=-.5+timer2/2-(w.age/16)
            w.y+=3
        end
        
        if w.age>=w.maxage then
        del(left_waves,w)
        end
    end
end
   
function draw_waves()

    for w in all (left_waves) do
        if w.cen==false then
            spr(w.sp,w.x,w.y,1,.5)
        else
            spr(w.sp,w.x+2,w.y,1,.5)
        end
    end

    for w in all (right_waves) do
        if w.cen==false then
        spr(w.sp,w.x-1,w.y,1,.5,true)
        else
        spr(w.sp,w.x-1,w.y,1,.5,true)
        end
    end
                
            
end

-----------------------------------------------

------------functions for explosions-----------

-----------------------------------------------

function shwave(p)
	local col={
		18,
		38,
		118,
		135,
		137,
		172,
		206,
		222,
		239,
		239,
		239
		
		}
		
	oval( p.x-p.rad,p.y-(p.rad/3), p.x+p.rad, p.y+(p.rad/2),col[3+p.change] )
end

function spark(p)
	local col={
		
		172,
		206,
		222,
		239,
		239,
		239
		
		}
		
	
		line(p.x,p.y,p.x-p.sx,p.y-p.sy,col[p.change])
		--line(p.x+1,p.y+1,p.x-p.sx,p.y-p.sy,col[p.change])
		
	-- pset(p.x,p.y,col[10])
end

function blob(p)
	local myr=flr(p.r)
	local thk={
  		 0, 
 	myr* 0.05,
	myr* 0.17,
	myr* 0.35,
	myr* 0.60


	}
	
	local col={
	18,
	38,
	118,
	135,
	137,
	172,
	206,
	222,
	239,
	239,
	239
	
	}
	

	local c1=10
	local c2=9
	local cfill=c1+c2*16
	
	
	
	local fills={
	
	0b1101111101101101,
	0b111011011010001,
	0b1001101001101101,
	0b00000000010000,
	0b01000000100000,
	}
	
	
	
	
	for i=1,#thk do
	
	fillp(fills[i])
	circfill(flr(p.x),flr(p.y)-thk[i],p.r-thk[i],col[i+(p.change)])
	
	end
end

function dopart(p)

	if p.wait then
	
	--wait
		p.wait-=1
			if p.wait <=0 then 
			    p.wait = nil
			end
	
	else
	
		 --particle code
	--change
	

	p.change=p.change or 3
	--age	
		p.age=p.age or 0
		p.spd=p.spd or 1
			if p.age==0 then
				p.ox=p.x
				p.oy=p.y
				p.r =p.r or 1
				p.sy=p.sy or 0
				p.rad=p.rad or 0

				
				
			end
		p.age+=1
		
		if p.draw == spark then
		p.sy+=p.age/100
		end
		if p.draw == spark then
			p.sx*=p.drag
			p.sy*=p.drag
		end


		if p.age%1 == 0 then
			p.rad+=2
		end
		
		if p.age%5 == 0 then
			p.change-=1
			
		end
		
		--movement go to function based on breadcrumbs
		
		if p.tox then
			p.x+=(p.tox-p.x)/(4/p.spd)
			p.y+=(p.toy-p.y)/(4/p.spd)
		end

		if p.sx then
			p.x+=p.sx
			p.y+=p.sy
			if p.tox then 
				p.tox+=p.sx
				p.toy+=p.sy
			end
		end

	
	--^^value+=(target-value)/spd^^
	--size
	
	if p.tor then
			p.r+=(p.tor-p.r)/6
		end
	--max age
	
	if p.age >=p.maxage 
	or p.r < 1 then
		if p.onend=="return" then
			p.onend=nil
			p.maxage+=100
			p.tox=p.ox
			p.toy=p.oy
			p.tor=0
		else
		del(parts,p)
		end
	end
	

	
	end

	--tox,toy  go to function ala breadcrumb

end

--blasts
function grape(ex,ey,ewait,emaxage,to_r,d)

		local spokes=3+ceil(rnd(3))
		local ang=rnd() 
		local step=1/spokes
		
		for i=1,spokes do
			 
			local myang=ang+step*i 
			local dist=d/2+ceil(rnd(d)/2)
			local dist2=dist/2
			
			 add(parts,{
				draw=blob,
				x=ex+sin(myang)*dist2,
				y=ey+cos(myang)*dist2,  
				r=3,
				tor=to_r*.5+rnd(to_r*.5),
				tox=ex+sin(myang)*dist,
				toy=ey+cos(myang)*dist,
				wait=ewait,
				maxage=emaxage,
				onend="return",
				spd=0.1,
				change=6
			})
				 
		end
		add(parts,{
				draw=blob,
				x=ex,
				y=ey,  
				r=3,
				tor=to_r*.5+rnd(to_r*.6),
				wait=ewait,
				maxage=emaxage,
				onend="return"	,
				change=6	 
			})
		
	
end

function sparkblast(ex,ey,ewait,life)
    --spark
	for i = 1,10 do
		add(parts,{
			draw=spark,
			drag=.95,
			x=ex,
			y=ey,
			sx=(rnd(3)-1.5)*2,
			sy=(-1+rnd()-1)*1.2,
			wait=ewait,
			maxage=life+rnd(life),
			change=4
		
		})
	end
end
--grape(ex,ey,ewait,emaxage,to_r,d)

function explode(ex,ey)
	--shwave
	
	add(parts,{
		draw=shwave,
		x=ex,
		y=ey+8,
		wait=0,
		rad=1,
		maxage=18,
		change=6
	
	})
	--x,y,wait,maxwait
	local wait=15+rnd(10)

	sparkblast(ex,ey+8,2,10)

	grape(ex,ey,2,13,8,10)
	
	grape(ex+(rnd(8)-4),ey-(wait)/3,8,wait,6,8)
	
	grape(ex+(rnd(8)-4),ey-(wait*2)/3,16,wait*1.5,5,7)
	
	grape(ex+(rnd(8)-4),ey-(wait*2.5)/3,25,wait*1.6,8,12)
	--flash
	add(parts,{
		draw=blob,
		x=ex,
		y=ey,
		r=17,
		wait=0,
		maxage=3,
		change=6


	
	})
	
 
 
end
function smallexplode(ex,ey)
	--shwave
	
	add(parts,{
		draw=shwave,
		x=ex,
		y=ey+8,
		wait=0,
		rad=1,
		maxage=10,
		change=6
	})
	--x,y,wait,maxwait
	local wait=8+rnd(6)
	sparkblast(ex,ey+6,2,6)
	grape(ex,ey,2,13,5,6)
	grape(ex+(rnd(4)-2),ey-(wait)/2,10,wait,5,7)
	grape(ex+(rnd(8)-4),ey-(wait),15,wait*2,6,8)
	
	--flash
	add(parts,{
		draw=blob,
		x=ex,
		y=ey,
		r=10,
		wait=0,
		maxage=3,
		change=6


	
	})
	
 
 
end

function tinyexplode(ex,ey)
	--shwave
	
	add(parts,{
		draw=shwave,
		x=ex,
		y=ey+8,
		wait=0,
		rad=1,
		maxage=6,
		change=6
	
	})

	
	
	
	--x,y,wait,maxwait
	local wait=5+rnd(5)
	sparkblast(ex,ey+4,2,4)
	grape(ex,ey,2,13,5,5)
	
	grape(ex+(rnd(4)-2),ey-(wait)/2,8,wait*3,4,6)
	
	
	--flash
	add(parts,{
		draw=blob,
		x=ex,
		y=ey,
		r=8,
		wait=0,
		maxage=3,
		change=6


	
	})
	
 
 
end 





































































































































--paste the code below at the end of your cart
do
local old_draw=_draw
poke(0x5f2d,1)
poke(0x5f2e,1)

local old_pal=pal

local draw_func=function()
	old_draw()
	pal=function(...)
	 local t={...}
	 if #t==0 then
	  old_pal(split("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0"))
	  palt()
	  fillp()
	 elseif type(t[1])=="table"
	 and #t==2
	 or #t==3 then
	 
	 else
	  old_pal(t[1],t[2])
	 end
	end
end

local sel_pal=sel_pal or 0
local game_palette={}
local sel_clr=sel_clr or 0
local draw_state,press={}
local active
_draw=function()
 if band(stat"34",2)==2 then
  press=press and press+1 or 0
  if (press==0) active=not active
 else
  press=nil
 end
 
 local mousex,mousey=stat"32",stat"33"
 
 draw_func()
	local pal=old_pal
	for i=0,15 do
	 game_palette[i]=peek(0x5f10+i)
	end
 if active then
		pal()
	 for i=0x5f00,0x5f3f do
	  draw_state[i]=peek(i)
	 end
	 
	 if band(stat"34",1)==1 then
	  local x8=mousex\8
	  if mousey<=8 then
	   sel_clr=x8
	  elseif mousey<=16 then
	   game_palette[sel_clr]=x8+128*sel_pal
	   local s="pal(split(\""
	   for i=0,14 do
	    s..=game_palette[i+1]..","
	   end
	   s..=game_palette[0].."\"),1)"
	   printh(s,"@clip")
	  elseif mousey<=23 and mousey<=36 then
	   sel_pal=mousex\18
	  end
	 end
	 
	 clip()
	 camera()
	 fillp()
	 --current palette
	 rectfill(0,0,127,8,1)
	 for i=0,15 do
	  rectfill(i*8,0,i*8+7,7,i)
	 end
	 rect(sel_clr*8-1,-1,sel_clr*8+8,8,7)
	 rect(sel_clr*8,0,sel_clr*8+7,7,0)
	 pal()
	 
	 --swap palette
	 for i=0,15 do
	  rectfill(i*8,9,i*8+7,16,i)
	 end
	 
	 --
	 rectfill(0,17,36,23,1)
	 ?"pal1",1,18,sel_pal==0 and 7 or 5
	 ?"pal2",21,18,sel_pal==1 and 7 or 5
	 
	 pset(mousex,mousey,8)
	 
	 for i=0x5f00,0x5f3f do
	  poke(i,draw_state[i])
	 end
	 poke(0x5f5f,0x10)
	 
	 poke(0x5f71,0xfe)
	 poke(0x5f72,1)
	else
		pal()
  memset(0x5f71,0,2)
	end
 --screen palette 2
 for i=0,15 do
  pal(i,i+128*sel_pal,2)
  pal(i,game_palette[i],1)
 end
end
end