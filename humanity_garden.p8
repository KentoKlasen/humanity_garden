pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--humanitygarden by kentoklasen

-- [ main / utils ] --

function _init()
 t=0
	init_intro()
	debug=true
end

function _draw()
 draw()
end

function _update()
 t+=1
	-- we want to update the
	-- "afters" queue no matter what
	upd_afters()
	update()
end

function init_game()
	init_world()
	init_crafting()
 	init_plr()
 	init_plants()
 	init_ui()
 	init_controls()
 	draw=draw_game
	update=update_game
	music(0)
end

function update_game()
	update_plr()
 	update_plants()
 	update_ui()
	update_crafting()
end

function draw_game()
 	cls(3)
	map()
 	draw_plants()
 	draw_plr()
 	draw_ui()
 	if debug then
		draw_debug()
	end
end

function draw_debug()
	cursor()
	color(0)
	color()
	?plr.x
	?plr.y
	?fget(mget(plr.front_x/8,plr.front_y/8),0)
	?mget(plr.front_x/8,plr.front_y/8)
	?recipies[1]["hemp"]
	?resources[1]
	for resource in all(resources) do
		?resource
	end
end

--these two functions work
--like timers. they go through
--each item in the queue and
--decrement their time one
--by one, and once the time
--reaches 0 it does calls the
--function then deletes itself.
q={}
function upd_afters()
	foreach(q,function(a)
		a.t-=1
		if (a.t<=0) a.f() del(q,a)
	end)
end

function do_after(_t,_f)
	add(q,{f=_f,t=_t})
end
-->8
-- [ player ] --

function init_plr()
	plr=
	{dir=4,
	x=32,y=32,
	front_x=8,
	front_y=16,
	spd=1,
	anim="idle",
	t=0,
	working=false,
	actionable=true,
	can_move_forward=true
	}
	
	-- ⬅️➡️⬆️⬇️
	anim_repo=	
	{ idle={1,1,3,2}
	, run ={6,6,8,4}
	, water={35,35,37,36}
	, dance={33,33,33,33}
	, work={35,35,37,36}
	}
	
	inventory={
		hemp=0,
		shirt=0,
	}
end

function draw_plr()
	palt(0,false)
	palt(1,true)
	draw_player()
	palt()
end

function update_plr()
	plr.t+=1
	--get the cell in front
	set_cell_infront()
	-- ⬅️➡️⬆️⬇️
	handle_menu_input()
	local on_cell = is_on_cell()
	if on_cell and
				plr.working==false and
				plr.actionable then
		check_infront()
 	handle_input()
 elseif plr.anim=="run" and
			not on_cell then
	 --go to next cell 
 	--add to plr x or y
 	if plr.dir==1 then
	 	plr.x-=plr.spd 
 	elseif	plr.dir==2 then
 	 plr.x+=plr.spd 
 	elseif plr.dir==3 then
 	 plr.y-=plr.spd
 	elseif plr.dir==4 then
 	 plr.y+=plr.spd
 	end
	elseif not plr.actionable and
		plr.working==false then
		plr.anim="idle"
	end
end

--returns: boolean
function is_on_cell()
 return plr.x%8==0 and plr.y%8==0
end

function set_cell_infront()
	local x_offset=0
	local y_offset=0
	
	if plr.dir==1 then
		x_offset=-8
	elseif plr.dir==2 then
		x_offset=8
	elseif plr.dir==3 then
		y_offset=-8
	elseif plr.dir==4 then
		y_offset=8
	end
	
	plr.front_x=plr.x+x_offset
	plr.front_y=plr.y+y_offset
end

function check_infront()
	local entity = 
		get_entity(plr.front_x
			,plr.front_y)
	-- don't do anything if there
	-- is nothing of interest
	-- in front of the player
	if entity==nil then
	set_btnx()
	elseif entity.kind=="plant"
		and entity.state==2 then
		set_btnx(pick,"pick")
	elseif entity.kind=="plant" then
		set_btnx(water,"water")
	end
	
	--check if we can move forward
	--0 is the index for collison flag
	plr.can_move_forward=
		not fget(mget(
			plr.front_x/8,plr.front_y/8),0)
end

function end_work()
		plr.anim="idle"
		plr.t=0
		plr.working=false
end

-- player work functions

function water()
	plr.anim="water"
	plr.working=true
	do_after(45,end_work)
	water_plant(plr.front_x
		,plr.front_y)
	sfx(10)
end

function pick()
	plr.anim="work"
	plr.working=true
	pick_plant(plr.front_x
		,plr.front_y)
	do_after(10,end_work)
	sfx(8)
end

function dance()
	plr.anim="dance"
	plr.working=true
	do_after(18,end_work)
	sfx(8)
	do_after(9,function() sfx(8) end)
end

-- drwaing the player

function draw_player()
	local frame=anim_repo[plr.anim][plr.dir]
	-- handle the animation by
	-- getting the frame we're
	-- supposed to show on the
	-- screen
	frame=get_anim_frame(frame)
	if plr.anim=="water" then
 	local xoffset=0
	 local yoffset=0
	 if plr.dir==3 then
	 yoffset=-4
	  spr(39
	  ,plr.x+xoffset,plr.y+yoffset,1,1,plr.dir==1)
   spr(frame
	  ,plr.x,plr.y,1,1,plr.dir==1)
	 else
   spr(frame
	  ,plr.x,plr.y,1,1,plr.dir==1)
	 local can_spr=38
	  if plr.dir==1 then
		  xoffset=-6
		 elseif plr.dir==2 then
		  xoffset=6
		 elseif plr.dir==4 then
		  can_spr=52
		  yoffset=6
	  end
		 spr(can_spr
		 ,plr.x+xoffset,plr.y+yoffset,1,1,plr.dir==1)
	 end
	else
	 spr(frame
	 ,plr.x,plr.y,1,1,plr.dir==1)
	end
end

-- function to get the sprite
-- number to use in the spr
-- function by handling the
-- animatoin logic
--
-- _frame: the first frame in
-- 								the animation sequence
function get_anim_frame(_frame)
	if plr.anim=="run" then
	 local plr_anim_speed=12
		return _frame+(plr.t+plr_anim_speed)/plr_anim_speed%2
	elseif plr.anim=="dance" then
		local plr_anim_speed=5
		return _frame+(plr.t+plr_anim_speed)/plr_anim_speed%2
	else
		return _frame
	end
end
-->8
--plants

function init_plants()
 plants={}
 add_plant(96,8)
 add_plant(104,8)
 
 add_plant(88,16)
 add_plant(96,16)
 add_plant(104,16)
 add_plant(112,16)
 
 add_plant(88,24)
 add_plant(96,24)
 add_plant(104,24)
 add_plant(112,24)
 
 add_plant(96,32)
 add_plant(104,32)
 
 --sparkle animation
 sparkles={}
end

function add_plant(_x,_y)
 local plant={
 	kind="plant",
  x=_x,
  y=_y,
  state=0,
  picked=false,
  watered=false,
  t=0,
  collision=false}
 set_entity(_x,_y,plant)
 add(plants,plant)
end

function draw_plants()
 for plant in all(plants) do
  spr(10+plant.state,plant.x,plant.y)
 end
 
 for spark in all(sparkles) do
 	spr(64+spark.t
 		,spark.x
 		,spark.y)
 	spark.t+=1
 	if spark.t>2 then
 		del(sparkles,spark)
 	end
 end
end

function update_plants()
	for plant in all(plants) do
		if plant.picked then
			plant.t=0
			plant.state=0
			plant.picked=false
			plant.watered=false
		end
		
	 if plant.watered then	
	 	if (t+flr(rnd(4)))%30==0 then
  		local spark={
  			x=plant.x+flr(rnd(4)),
  			y=plant.y+flr(rnd(4)),
  			t=0,
  		}
  		add(sparkles,spark)
  	end
	 	plant.t+=flr(rnd(20))
	 	--todo change later 
	 	if plant.t>450 then 
 	 	plant.t=0
 	 	plant.watered=false
 	 
	 	 if plant.state<2 then
	  		plant.state+=1
	  		plant.collision=true
 	 	end
 	 end
  end 
	end
end

function water_plant(_x,_y)
	plant=get_entity(_x,_y)
	plant.watered=true
end

function pick_plant(_x,_y)
	plant=get_entity(_x,_y)
	plant.picked=true
	plant.collision=false
	inventory.hemp+=1
end
-->8
-- [ ui/menu ] --

function init_ui()
	-- if true, then display
	-- the menu
	disp_menu=false
	-- labels for the
	-- buttons in the ui
	olbl,xlbl="menu","dance"
	box_offset=1
	menu_actionable=false
	indicator_off=0
	item_off=0
end

function update_ui()
	indicator_off=max(0
		,indicator_off-0.1)
	item_off=max(0
		,item_off-0.1)
end

function draw_ui()
 draw_menu()
 draw_hud()
end

function draw_hud()
	brd_rect(0,109,128,19,15,2)
	-- draw the border on the bottom
	-- of the screen
 -- draw the buttons 	local lbl_off=-sin(indicator_off)
 lbl_off=-sin(indicator_off)
	printol("🅾️"..olbl,3
		,112+lbl_off,10,3)
	printol("❎"..xlbl,3
		,120+lbl_off,10,3)
	spr(67,48,112)
	?inventory.hemp,56,112,3
end

function toggle_disp_menu()	
	disp_menu=not disp_menu
		
	if disp_menu then
		plr.actionable=false
		box_offset=1
		--set_btndir(move_ui_sel,true)
		--set_btnx(do_ui_sel,"select")
		olbl="close"
		set_btnx(function() end
			,"select")
		sfx(9)
	else
		--set_btndir(move_plr,false)
		set_btnx()
		olbl="menu"
		do_after(15,function()
			plr.actionable=true end)
		sfx(9)
	end
end

function draw_menu()
	if not disp_menu and box_offset==1 then
		return
	end
	
	local w,h=104,88
	local x,y,tx,ty=draw_ctr_box(
		w,h,-30,true)
	?"craft",x,y-10,15
	
	for recipe in all(recipies) do
		local recipe_y=recipe.y+y
		if recipe.craftable then
			?recipe.label,x+10,recipe_y,11
			spr(67,x+40,recipe_y)
		else
			?recipe.label,x+10,recipe_y,6
			spr(67,x+40,recipe_y)
		end
	end
	--draw cursor
	spr(80,x,recipies[selected_recipe_i].y+y)
end

function draw_ctr_box(
		w,h,v_off,head)
	local pw,ph=max(w+15,60),h+5
	local dx,dy=6,(50+(v_off or 0))/2
	dx+=128*box_offset

	box_offset=disp_menu 
		and max(box_offset-0.03-box_offset/3,0)
		or  min(box_offset+0.03+box_offset/3,1)
	draw_box(dx,dy,pw,ph,head)

	return dx+5,dy+4,dx+pw,dy+ph
end

function draw_box(x,y,w,h,head)
	brd_rect(x+2,y+2,w,h,5)
	if head then
	 brd_rect(x+2,y-5,w,7,5)
	 brd_rect(x+2,y-6,w,1,5)
 end
	
	brd_rect(x,y,w,h,15,4)
	if head then
		brd_rect(x,y-7,w,7,4)
		brd_rect(x,y-8,w,1,4)
		spr(2,x+w-9,y-8)
	end
end

-- a function to create
-- outlined text
--
-- txt: text to print
-- x: x pixel to print at
-- y: y prixel to print at
-- fc: foreground color of text
-- bc: background color of text
function printol(txt,x,y,fc,bc)
	-- horizontal offset of pixels
	for hor=-1,1 do
		-- vertical offset of pixels
		for ver=-1,1 do
			print(txt,x+hor,y+ver,bc)
		end
	end
	
	print(txt,x,y,fc)
end

-- draws a rect with border
-- fc = fillcolor
-- bc = bordercolor
function brd_rect(x,y,w,h,fc,bc)
	rectfill(x,y,x+w-1,y+h-1,bc or fc)
	rectfill(x+1,y+1,x+w-2,y+h-2,fc)
end
-->8
-- [ controls ] --

function init_controls()
	-- variables to hold the
	-- functions when the buttons
	-- are pressed
	set_btno()
	set_btnx()
	
end

-- temp function so that when
-- the user presses the button
-- nothing happens
function do_nothing()
end

function handle_menu_input()
		-- this is in a separate if
	-- statement since we want
	-- to be able to open
	-- the menu at all times
	if btnp(🅾️) then
	 btnpo()
		indicator_off=1
	end
end

-- function to handle the input
-- by the user. this is called
-- in the player code
function handle_input()
	if disp_menu then
		if btnp(❎) then
			btnpx()
		end
	else
		if btnp(❎) then 
			btnpx()
			indicator_off=1
		elseif btn(⬆️) and plr.y>=8 then
			plr.anim="run"
			plr.dir=3 
			if not fget(mget(plr.x/8,
					(plr.y-8)/8),0) and
				not get_entity_collision(
					plr.x,plr.y-8) then
				plr.y-=plr.spd
			end
		elseif btn(➡️) and plr.x<=112 then
			plr.anim="run"
			plr.dir=2
			if not fget(mget((plr.x+8)/8,
					plr.y/8),0) and
				not get_entity_collision(
					plr.x+8,plr.y)	then
				plr.x+=plr.spd
			end
		elseif btn(⬇️) and plr.y<=92 then
			plr.anim="run"
			plr.dir=4
			if not fget(mget(plr.x/8,
					(plr.y+8)/8),0) and
				not get_entity_collision(
					plr.x, plr.y+8) then
				plr.y+=plr.spd
			end
		elseif btn(⬅️) and plr.x>=8 then
			plr.anim="run"
			plr.dir=1
			if not fget(mget((plr.x-8)/8,
					plr.y/8),0) and
				not get_entity_collision(
					plr.x-8,plr.y) then
			plr.x-=plr.spd
			end
		else
			plr.anim="idle"
			plr.t=0
		end
	end
end

-- set the 🅾️ button
--
-- f: the function to call
-- 			when the button is
-- 			pressed
-- lbl: what to label the
-- 					button in the ui
function set_btno(f,lbl)
	-- if a function is not in
	-- the argument then set
	-- it to open/close menu
	if not f then
		btnpo,olbl=toggle_disp_menu,"menu"
	else
		btnpo,olbl=f,lbl
	end
end

-- set the ❎ button
--
-- f: the function to call
-- 			when the button is
-- 			pressed
-- lbl: what to label the
-- 					button in the ui
function set_btnx(f,lbl)
	-- if a function is not in
	-- the argument then set
	-- a default action
	if not f then
		btnpx,xlbl=dance,"dance"
	else
		btnpx,xlbl=f,lbl
	end
end
-->8
-- [ particles ] --

function init_particles()
	emitters={}
	particles={}
end

function update_particles()
	foreach(emitters,function(e)
		e.ctr+=e.rate+rnd(e.rand*2)-e.rand
		
		while e.ctr>1 do	
			add(particles,
			{ x=e.x+rnd(e.w),y=e.y+rnd(e.h)
			, vel=e.vel,dc=e.pdc,t=0
			, c=rnd(e.clrs)
			, event=e.event
			, emitter=e
			})
			
			e.ctr-=1
		end
		
		if (e.burst) del(emitters,e)
	end)
	
	foreach(particles,function(p)
		if (p.event) p:event()
		
		p.t+=1
		local dx,dy=p:vel()
		p.x+=dx
		p.y+=dy
		if p:dc() then
			del(particles,p)
		end
	end)
end

function draw_particles()
	foreach(particles,function(p)
		pset(p.x,p.y,p.c)
	end)
end
-->8
-- [ intro screens ] --

function init_intro()
	draw=draw_intro
	update=update_intro
	btn_pressed=false
	
	intro_done=false

	screen_off=300
	
	intro_wobble=0
	fade_percentage=0
	sfx(2)
end

function update_intro()
	if (intro_done) return
	
	if fade_percentage>0 then
		fade_percentage+=2
	end
	
	if btnp(❎) then 
	 if btn_pressed==false then
	  btn_pressed=true
	  sfx(9)
	  sfx(16)
			fade_percentage+=2
			do_after(50,function()	
				init_game()
				intro_done=true
				--reset the afters queue
				q={}
				pal()
			end)
		end
	else
		intro_wobble=t/40%2
		screen_off=max(0,screen_off/1.2)\1
	end
end

function draw_intro()
	if (intro_done) return

	cls(12)
	palt(14,true)
	palt(0,false)
	
	rectfill(0,120,128,128,4)

	
	-- drawing the logo
	sspr(64,16,64,16,
		0,20-screen_off,128,32)
	printol("ss21: the game",36,
		60-screen_off,
		5,6)
		
	printol("❎ to start",42,
		100+intro_wobble+screen_off,
		7,0)

	palt()
	fadepal(fade_percentage/100)
end

-- fading
function fadepal(_perc)
 -- 0 means normal
 -- 1 is completely black
 
 local p=flr(mid(0,_perc,1)*100)
 
 -- these are helper variables
 local kmax,col,dpal,j,k
 dpal={0,1,1, 2,1,13,6,
          4,4,9,3, 13,1,13,14}
 
 -- now we go trough all colors
 for j=1,15 do
  --grab the current color
  col = j
  
  --now calculate how many
  --times we want to fade the
  --color.
  kmax=(p+(j*1.46))/22  
  for k=1,kmax do
   col=dpal[col]
  end
  
  --finally, we change the
  --palette
  pal(j,col,1)
 end
end
-->8
-- [ world ] --

function init_world()
	entities={}
end

--sets an entity in the table
function set_entity(_x,_y,e)
	local y_table=entities[_x]
	if y_table~=nil then
		y_table[_y]=e
	else
		--if there are no tables
		--for the x coordinate
		--yet, then create one
		entities[_x]={}
		entities[_x][_y]=e
	end
end

function get_entity(_x,_y)
	local y_table=entities[_x]
	if y_table~=nil then
		return y_table[_y]
	else
		return nil
	end
end

function get_entity_collision(_x,_y)
 local entity=get_entity(_x,_y)
 return entity~=nil and entity.collision
end
-->8
-- [ crafting ] --

function init_crafting()
	resources={"hemp"}
	recipies={
		{label="shirt",
			hemp=1,
			craftable=false,
			y=5
		},
		{label="sweat shirt",
			hemp=3,
			craftable=false,
			y=15
		}
	}
	selected_recipe_i=1
end

function update_crafting()
	if disp_menu then
		for recipe in all(recipies) do
			-- check for each resource
			local craftable=true
			for resource in all(resources) do
				if recipe[resource]>inventory[resource] then
					craftable=false
				end
			end
			recipe.craftable=craftable
		end
	end
end

function craft_in_menu()
	sfx(10)
end

__gfx__
000000001119911111199111111991111119911111199111111991111119911111199111111991110000000000000000000b0000000000000000000000000000
0000000011999911119999111199991111999911119999111199991111999911119999111199991100000000000000000033b000000000000000000000000000
00700700177777111777777117777771177777711777777117777711177777111777777117777771003000000000000003333b00000000000000000000000000
0007700017770711170770711777777117077071170770711777071117770711177777711777777100000300000b000000333000000000000000000000000000
00077000177e77111e7777e1177777711e7777e11e7777e1177e7711177e771117777771177777710000000000bb0000000b0000000000000000000000000000
0070070011b7b1111bbbb4b11bbbbbb17bbbb4b77bbbb4b711b7b11111b7b1117bbbbbb77bbbbbb700030000003b300000030000000000000000000000000000
0000000011bbb11117bbbb7117bbbb7111bbbb1111bbbb1111bbb11111bbb111116bbb1111bbb611000000000000000000030000000000000000000000000000
00000000111611111161161111611611111116111161111111711111111171111111161111611111000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000770bb000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300077b00b00000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030300000b0770000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0000000770770000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000003000000770000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000f000000ff0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011999911111991111119911111199111111991111111111111111111ee000ee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeee
0000000017777771119999111199991111999911119999111111111111111111e0070e0070eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0770eee0000eeeeeeeeeeee
0000000017077071177777711777771117777771177777711111111111111111e0770e0770000000000000000e00000000000000000000000770000000e0000e
000000007e7777e717077071177707111707707117777771188861111111ccc1e077000770077007700770770e077777007707770e0770077777700770e0770e
000000001bbbb4b11e7777e1177e77111e7777e11777777181881c1111116661e07777777077000770777777700000077077700770007700770000077000770e
000000001bbbbbb11bbbb4b111bbb6111bbbb4b11bbbbbb1118811c111111811e07700077077000770770707700777777077000770e07700770000007777770e
000000001161161117bbbb7111bbb11116bbbb7117bbbb11111111c111118881e077000770770077707700077077707770770e0770007700770077000000770e
0000000011111111116116111116111111611611116116111111111111111811e070007700077770707700770007777070770e0700077000077770007777700e
0000000000000000000000000000000011111111000000000000000000000000e000e00000000000000000000e000000000000000e0000ee000000e0000000ee
0000000000000000000000000000000088811111000000000000000000000000eeeeeeee0077770ee000000000000000e00000770000000000000000eeeeeeee
0000000000000000000000000000000018111111000000000000000000000000eeeeeeee07700000e0777770070777700077707700777770077077700eeeeeee
0000000000000000000000000000000066611111000000000000000000000000eeeeeeee0770777000000077007700770770077707700077077700770eeeeeee
00000000000000000000000000000000ccc11111000000000000000000000000eeeeeeee0770007700777777007700000770007707777770077000770eeeeeee
0000000000000000000000000000000011111111000000000000000000000000eeeeeeee077700770777077700770eee07700777077700000770e0770eeeeeee
0000000000000000000000000000000011111111000000000000000000000000eeeeeeee007777700077770707700eee00777707007777700770e0700eeeeeee
0000000000000000000000000000000011111111000000000000000000000000eeeeeeeee0000000e00000000000eeeee0000000000000000000e000eeeeeeee
000000000000000000000000b00b00b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000700000000000003b0b0b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c0000007c700000060000003bbb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000070000000000000bbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000444400000000000000000004444444444444444444444400000000000000000000000000000000000000000000000000000000000000000000
00000000000444499444400000000000000444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000
00000000044499499499444000000000004444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000
00000004449499499499494440000000044444444444444444444444444444400000000000000000000000000000000000000000000000000000000000000000
00000444949499499499494944400000044444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
00044494949499499499494949444000444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
00449494949499499499494949494400444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
0294949494949949a49a494949494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
02949494949499499499494949494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
029494949494994994994a4949494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
029494949494a949a499494949494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
029494a4949499499499494a49494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
02949494a49499499499494949494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
02949494949499444499494949494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
029494949494444224444949494a4920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
02949494944422211222444949494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
0294a49444221111111122444a494920444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
02949444221114444441112244494920544444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
02a44422111444444444411122444920444444444444444444444444444444450000000000000000000000000000000000000000000000000000000000000000
02442211144444ffff44444111224420444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000
02121114444ffffffffff44441112120544444444444444444444444444444450000000000000000000000000000000000000000000000000000000000000000
01111444fffffffffffffff444411110544444444444444444444444444444450000000000000000000000000000000000000000000000000000000000000000
014444ff4444444fffffffffff444410544444444444444444444444444444450000000000000000000000000000000000000000000000000000000000000000
014fffff4141414fff4444fffffff410544444444444444444444444444444450000000000000000000000000000000000000000000000000000000000000000
014fffff4444444ff499994ffffff410544444444444444444444444444444450000000000000000000000000000000000000000000000000000000000000000
014fffff4141414ff499994ffffff410544444444444444444444444444444550000000000000000000000000000000000000000000000000000000000000000
014fffff4141414ff499994ffffff410554444444444444444444444444444500000000000000000000000000000000000000000000000000000000000000000
014fffff4444444ff4999a4ffffff410054444444444444444444444444444500000000000000000000000000000000000000000000000000000000000000000
014ffffffffffffff499994ffffff410055444444444444444444444444445500000000000000000000000000000000000000000000000000000000000000000
0144fffffffffffff499994fffff4410005544444444444444444444444455000000000000000000000000000000000000000000000000000000000000000000
04111111111111111111111111111140000555444444444444444444445550000000000000000000000000000000000000000000000000000000000000000000
00444444444444444444444444444400000000555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000010100000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010100000000000000000000000001010101000000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0080818283000000000000848586870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090919293000000000000949596970000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a0a1a2a3000000000000a4a5a6a70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b0b1b2b3000000000000b4b5b6b70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000076400760007600076000760007500075000750007400074000740007300073000720007200072500715007150a7000a7000a7000a70031700317003270016700117000f7000c7000c7000a70005700
0101000027750297502e750307503075033750337503575037750397503a7502e7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9102000024335283352b3352f2252b3051110022003230032400323003220031f0031d0031c0031c0031c0031e0042000322003240032600326003270032700324003220031e0031d0031c0031c0031e0031e003
910700001d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7061a706187061d7061c7061a70618706
010100003b6343f6123d6353c6003a600376000c6000c6000c6000c6000c6000c6001f6050c6000c6000c6000c6000c6000c6000c6001f6050c6000c6000c6000c6000c6000c6000c6001f6050c6000c6000c600
050100003c6443f6443c64435640306202b61027610246101f6101b6150c615166150761507615056150361503600036000360003600036000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000191101d120221302414627156291562b1520f4031340216401184001b4001d4001f40022400224002440022300223002c4002f4003040031400314003240016300113000f3000c3000c3000a30005300
0001000027750297502e750307503075033750337503575037750397503a7502e7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7361a736187361d7361c7061a706187061d7061c7061a70618706
012400000cc200cc000cc100000015d40000000cc10000000cc20000000cc100000015d40000000cc100cc000cc20000000cc100000015d40000000cc10000000cc20000000cc100000015d40000000cc1000000
012400001d8501880000000000001c80000000000001d8501f8501380000000000001f80000000000001f85018850000000000000000188000000000000000001885000000000000000000000000000000000000
0124000018755187001a700157001a755007001f700007001c7551f7001c7001a7001f755137051c7001c7001f7341f7401f7401f7401f7521f7521f7521a7501c7511c7421c7321c7221c7151c7001c7001c700
0124000018a000c20011a50139001fa00000000000000000000000000013a5000000000000000000000000000000018a000ca500000018a000000000000000000000000000000000000000000000000000000000
012400001f1241f12511a50139001fa00342003420034200231342313513a50000000000000000000000000028134281350ca500000018a000000000000000002a1342b131281322813528100000000000000000
010600000f6340a6351760006400004000040000400004000c6240a6250c60000400004000040000400004000a6140a6150040000400004000040000400006000a6140a615004000040000000000000000000000
011000002423026230282402b2522b2422824028240282300e2001020010200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
__music__
01 0b0c4344
00 0b0c0e44
00 0b0c0d44
00 0b0c0e44
00 0b0c4344
00 0b0c0f44
00 0b0c0e44
00 0b0c0e44
00 0b0c0d0f
00 0b0c0f44
00 0b0c4344
02 0b4c4344
02 0b0c4344

