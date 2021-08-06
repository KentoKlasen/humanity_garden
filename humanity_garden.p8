pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--humanitygarden by kentoklasen

-- [ main / utils ] --

function _init()
	debug=false
 t=0
	init_intro()
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
 init_plr()
 init_plants()
 init_ui()
 init_controls()
 draw=draw_game
 update=update_game
end

function update_game()
	update_plr()
 update_plants()
end

function draw_game()
 cls(8)
 draw_plants()
 draw_plr()
 draw_ui()
 if debug then
 	print(get_entity(plr.x,plr.y))
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
-- [ player / controls ] --

function init_plr()
	plr=
	{dir=4,
	x=8,y=8,
	spd=1,
	anim="idle",
	t=0,
	working=false,
	}
	
	timer=
	{start_time=0,
	length=0,
	action=false
	}
	
	-- ⬅️➡️⬆️⬇️
	anim_repo=	
	{ idle={1,1,3,2}
	, run ={6,6,8,4}
	, water={18,18,18,18}
	, dance={33,33,33,33}
	}
end

function draw_plr()
 map()
	palt(0,false)
	palt(1,true)
	draw_player()
	palt()
end

function update_plr()
	plr.t+=1
	-- ⬅️➡️⬆️⬇️
	if is_on_cell() and
				plr.working==false then
		check_infront()
 	handle_input()
 elseif plr.anim=="run" then
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
	end
end

--returns: boolean
function is_on_cell()
 return plr.x%8==0 and plr.y%8==0
end

function check_infront()
	local entity = 
		get_entity(plr.x,plr.y)
	-- don't do anything if there
	-- is nothing of interest
	-- in front of the player
	if entity == nil then
		xlbl="dance"
	else
		xlbl="water"
	end
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
end

function dance()
	plr.anim="dance"
	plr.working=true
	do_after(18,end_work)
end

-- drwaing the player

function draw_player()
	local frame=anim_repo[plr.anim][plr.dir]
	-- handle the animation by
	-- getting the frame we're
	-- supposed to show on the
	-- screen
	frame=get_anim_frame(frame)
	spr(frame
	,plr.x,plr.y,1,1,plr.dir==1)
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
 add_plant(16,16)
 add_plant(16,24)
 add_plant(16,32)
end

function add_plant(_x,_y)
 local plant={
  x=_x,
  y=_y,
  state=0,
  picked=0,
  t=0}
 set_entity(_x,_y,"plant")
 add(plants,plant)
end

function draw_plants()
 for plant in all(plants) do
   spr(10+plant.state,plant.x,plant.y)
 end
end

function update_plants()
	for plant in all(plants) do
	 plant.t+=flr(rnd(8))
	 	--todo change later 
	 if plant.t>450 then 
 	 plant.t=0
 	 
	  if plant.state<2 then
	  	plant.state+=1
 	 end
  end 
	end
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
end

function draw_ui()
	brd_rect(0,120,128,8,15,2)
	-- draw the border on the bottom
	-- of the screen
 -- draw the buttons
	printol("🅾️"..olbl,3,104,10,3)
	printol("❎"..xlbl,3,112,10,3)
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

function toggle_disp_menu()
	-- if disp_menu is true,
	-- then set it to false.
	-- if disp_menu is false,
	-- then set it to true.
	disp_menu=not disp_menu
	
	if disp_menu then
		--box_offset=1
		--set_btndir(move_ui_sel,true)
		--set_btnx(do_ui_sel,"SELECT")
		olbl="close"
		--sfx(9)
	else
		--set_btndir(move_plr,false)
		--set_btnx()
		olbl="menu"
		--sfx(10)
	end
end

function draw_hud()
	brd_rect(cx-1,cy+120,130,9,4,5)
	print_res(cx+1,cy+122,wood,stone,food,nil,true)
	print_pnum(cx+86,cy+122)
end
-->8
-- [ controls ] --

function init_controls()
	-- variables to hold the
	-- functions when the buttons
	-- are pressed
	btnpo=do_nothing
	btnpx=dance
end

-- temp function so that when
-- the user presses the button
-- nothing happens
function do_nothing()
end

-- function to handle the input
-- by the user. this is called
-- in the player code
function handle_input()
	-- this is in a separate if
	-- statement since we want
	-- to be able to open
	-- the menu at all times
	if (btn(🅾️)) btnpo()
	
	if btn(❎) then 
		btnpx()
	elseif btn(⬆️) and plr.y>=8 then
	 plr.anim="run"
	 plr.dir=3 
	 plr.y-=plr.spd 
	elseif btn(➡️) and plr.x<=112 then
	 plr.anim="run"
  plr.dir=2
	 plr.x+=plr.spd
 elseif btn(⬇️) and plr.y<=112 then
	 plr.anim="run"
	 plr.dir=4
	 plr.y+=plr.spd
	elseif btn(⬅️) and plr.x>=8 then
	 plr.anim="run"
	 plr.dir=1
	 plr.x-=plr.spd
	else
		plr.anim="idle"
		plr.t=0
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
	
	intro_done=false

	screen_off=300
	
	intro_wobble=0
	fade_percentage=0
end

function update_intro()
	if (intro_done) return
	
	if fade_percentage>0 then
		fade_percentage+=2
	end
	
	if btnp(❎) then
		fade_percentage+=2
		do_after(50,function()	
			init_game()
			intro_done=true
			--reset the afters queue
			q={}
			pal()
		end)
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

	print("by kento klasen",
		2,122,15)
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

__gfx__
000000001114411111144111111441111114411111144111111441111114411111144111111441110000000000000000000b0000000000000000000000000000
0000000011444411114444111144441111444411114444111144441111444411114444111144441100000000000000000033b000000000000000000000000000
00700700177777111777777117777771177777711777777117777711177777111777777117777771000000000000000003333b00000000000000000000000000
0007700017770711170770711777777117077071170770711777071117770711177777711777777100300000000b000000333000000000000000000000000000
00077000177e77111e7777e1177777711e7777e11e7777e1177e7711177e771117777771177777710000000000bb0000000b0000000000000000000000000000
0070070011373111133334311333333173333437733334371137311111373111733333377333333700000300003b300000030000000000000000000000000000
00000000113331111733337117333371113333111133331111333111113337111163331111333611000300000000000000000000000000000000000000000000
00000000111611111161161111611611111116111161111111711111111111111111161111611111000000000000000000000000000000000000000000000000
000000000000000077000007000000000000000000000000000000000000000000000000000000000000000000000000770bb000000000000000000000000000
00000000000000000070077700000000000000000000000000000000000000000000000000000000000000000000300077b00b00000000000000000000000000
000000000000000000077700000000000000000000000000000000000000000000000000000000000000000000030300000b0770000000000000000000000000
000000000000000000077770000000000000000000000000000000000000000000000000000000000000000000b0000000770770000000000000000000000000
0000000000000000077000070000000000000000000000000000000000000000000000000000000000f000000003000000770000000000000000000000000000
0000000000000000770000000000000000000000000000000000000000000000000000000000000000000f00000f000000ff0000000000000000000000000000
00000000000000007000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011444411111441110000000000000000000000000000000000000000ee000ee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeee
0000000017777771114444110000000000000000000000000000000000000000e0070e0070eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0770eee0000eeeeeeeeeeee
0000000017077071177777710000000000000000000000000000000000000000e0770e0770000000000000000e00000000000000000000000770000000e0000e
000000007e7777e7170770710000000000000000000000000000000000000000e077000770077007700770770e077777007707770e0770077777700770e0770e
00000000133334311e7777e10000000000000000000000000000000000000000e07777777077000770777777700000077077700770007700770000077000770e
0000000013333331133334310000000000000000000000000000000000000000e07700077077000770770707700777777077000770e07700770000007777770e
0000000011611611173333710000000000000000000000000000000000000000e077000770770077707700077077707770770e0770007700770077000000770e
0000000011111111116116110000000000000000000000000000000000000000e070007700077770707700770007777070770e0700077000077770007777700e
0000000000000000000000000000000000000000000000000000000000000000e000e00000000000000000000e000000000000000e0000ee000000e0000000ee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeee0077770ee000000000000000e00000770000000000000000eeeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeee07700000e0777770070777700077707700777770077077700eeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeee0770777000000077007700770770077707700077077700770eeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeee0770007700777777007700000770007707777770077000770eeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeee077700770777077700770eee07700777077700000770e0770eeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeee007777700077770707700eee00777707007777700770e0700eeeeeee
0000000000000000000000000000000000000000000000000000000000000000eeeeeeeee0000000e00000000000eeeee0000000000000000000e000eeeeeeee
__map__
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
