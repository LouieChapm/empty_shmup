-- THINGS TO CHANGE AFTER THE CARAVAN --

Change Type B laser combo add on frame to add slightly less when facing bosses . A number might need to be found- but .2 is just way too high on bosses , but feels good on everything else

Combo number colours are wrong from 750 to 1k









-- SCORING --

laser and normal give roughly the save combo / score
laser shots drop meter but caps at 30% but normal shots can max out the combo meter
small enemies give 30% meter , elite enemies give 100%

using a bomb pauses the combo meter for 0.5 seconds


rank is a timer that when active makes less projectiles spawn and gives only 80% score on kill
dying increases that rank timer for 10 seconds
having over 50 combo instantly gives max rank

-- IMPORTANT --
*rank is much less important in this game than you're probably used to*
*its mainly just made to soften enemies for a duration immediately after dying*
*"max rank" is just normal gameplay


bosses give the same score regardless of combo

coins give 1000 points and an extra 500 points for each one collected in a short span
up to a maximum of 500


powerup :
	red - gives bomb
	green - gives extend
	yellow - gives 10k points , maxes combo meter and gives 30 chain

-======- turret info -======-
	-- index, rate, direction, ox, oy, rate offset
		--  ?	<-- enemy custom dir
		-- -?	<-- negative enemy custom dir


-=======- boss info -=======-
	--[[
		** boss data format **

		enem_index, x, y, brain | anchor_enem_index, ox, oy, turret_index | ...
		lerp change_rate, lerp speed, x1, y1, x2, y2, x3, y3... | turret indexes
	]]--