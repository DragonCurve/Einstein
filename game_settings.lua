--------------------------------------------------------------
-- game options

  board = {ntimesnfields = 5} -- side length of the board in fields
  n_stones = 6
  die = {sides = 6}


  board.hometrianglelength = decompose_triangle(n_stones)

--------------------------------------------------------------

-- drawing related settings: size

  total_margin = 15 -- around the whole board in addition to half the field_margin
  panel_width = 300

  board.shadow = {offset = 3}
  board.field = {size = 100, margin = 3}
  board.field.highlight = {linewidth = 5}
  board.size = board.field.size*board.ntimesnfields
  board.totalsize = board.size+board.shadow.offset
  board.pos_x = total_margin
  board.pos_y = board.pos_x
  
  stone = {radius = board.field.size*0.5*.8, edge = {linewidth = 2}}
  stone.edge.colfactor = 0.5
  stone.label = {size = stone.radius, col = {.1, .1, .1}}
  --which_font = "orange juice 2.0.ttf"
  --stone.label.font = love.graphics.newFont(which_font,stone.label.size)
  stone.label.font = love.graphics.newFont(stone.label.size) -- default font
 
  
  statusbar = {fontsize = 20, margin = board.field.margin, n_lines = 3, y_offset = 0}
  statusbar.shadow = {offset = board.shadow.offset}
  statusbar.edge = {linewidth = board.field.margin/2}
  --statusbar.y_offset = statusbar.y_offset+statusbar.edge.linewidth
  statusbar.width = panel_width-statusbar.shadow.offset
  statusbar.font = love.graphics.newFont(statusbar.fontsize)
  statusbar.height = statusbar.n_lines*1.1*statusbar.font:getHeight()+2*statusbar.edge.linewidth
  statusbar.pos_x = board.totalsize+2*total_margin
  statusbar.pos_y = total_margin+statusbar.y_offset
  
  die.size = board.field.size*2/3
  die.corner_r = die.size/5
  die.dot = {radius = die.size/10}
  die.shadow = {offset = board.shadow.offset}
  die.pos_x = board.totalsize+2*total_margin + panel_width/2 - die.size/2
  die.pos_y = statusbar.pos_y+statusbar.height+die.size*1
  die.highlight = {linewidth = 4, distance = die.size/5}
  
  play_again_button = {n_lines = 2, width = panel_width*2/3}
  play_again_button.corner_r = die.size/5
  play_again_button.font = statusbar.font
  play_again_button.shadow = {offset = board.shadow.offset}
  play_again_button.height = play_again_button.n_lines*1.1*play_again_button.font:getHeight()
  play_again_button.pos_x = board.totalsize+2*total_margin + panel_width/2 - play_again_button.width/2
  play_again_button.pos_y = die.pos_y+die.size*3
  
  winning_stats_disp = {n_lines = 1}
  winning_stats_disp.font = statusbar.font
  winning_stats_disp.width = statusbar.width/2
  winning_stats_disp.height = winning_stats_disp.n_lines*1.1*winning_stats_disp.font:getHeight()
  winning_stats_disp.pos_x = statusbar.pos_x
  winning_stats_disp.pos_y = board.totalsize-total_margin-winning_stats_disp.height
  
  sound_onoff = {label = {}, box = {}}
  sound_onoff.font = winning_stats_disp.font
  sound_onoff.edge = {linewidth = statusbar.edge.linewidth*2}
  sound_onoff.label.height = sound_onoff.font:getHeight()
  sound_onoff.label.width = statusbar.width-winning_stats_disp.width
  sound_onoff.label.pos_x = winning_stats_disp.pos_x+winning_stats_disp.width
  sound_onoff.label.pos_y = winning_stats_disp.pos_y +(winning_stats_disp.n_lines-1)*1.1*winning_stats_disp.font:getHeight()
  sound_onoff.box.size = winning_stats_disp.font:getHeight()*.7;
  sound_onoff.box.pos_x = sound_onoff.label.pos_x+sound_onoff.label.width/2-sound_onoff.box.size/2;
  sound_onoff.box.pos_y = winning_stats_disp.pos_y+sound_onoff.label.height+sound_onoff.box.size*.2
  
  
  
  game_window = {}
  game_window.height  = board.totalsize+2*total_margin
  game_window.width   = board.totalsize+panel_width+3*total_margin
  game_window.flags   = {resizable=false, vsync=false, minwidth=400, minheight=300}
  love.window.setMode( game_window.width, game_window.height,game_window.flags)
  
  
-- drawing related settings: colour --------------------------

  col = {}
  col.bkgr    = {.8, .8, .8}
  
  board.col   = {.1, .1, .1}
  board.field.col  = {.9, .9, .9}
  board.field.fadedalpha = 0.6
  board.field.highlight.col = {.1, .9, .1}
  board.field.fainthighlight = {col = {.2, .5, .2}}
  board.shadow.col = board.col
  
  player = {col = {}}
  player.col[1]     = {.9, .1, .1}
  player.col[2]     = {.1, .1, .9}
  player.col.homealpha = .2 -- set to 0 if no home bases should be drawn
  
  stone.col = { edge = { pl={} } }
  stone.col.edge.pl[1] = {}
  stone.col.edge.pl[2] = {}
  for i=1,#player.col[1] do
    stone.col.edge.pl[1][i] = player.col[1][i]*stone.edge.colfactor
  end
  for i=1,#player.col[2] do
    stone.col.edge.pl[2][i] = player.col[2][i]*stone.edge.colfactor
  end
  
  statusbar.col = board.field.col
  statusbar.shadow.col = board.shadow.col
  statusbar.fontcol = stone.label.col
  
  die.col = {.2, .8, .2}
  die.dot.col = board.shadow.col
  die.dot.fadedalpha = 0.1
  die.shadow.col = board.shadow.col
  die.highlight.col = board.field.highlight.col
  
  play_again_button.col = die.col
  play_again_button.shadow.col = board.shadow.col
  play_again_button.fontcol = stone.label.col
  
  
  -- drawing related settings: other --------------------------
  
  einstein_star = {img = love.graphics.newImage("einstein_star.png")}
  einstein_star.height = einstein_star.img:getHeight()
  einstein_star.width = einstein_star.img:getWidth()
  einstein_star.scalingf = 1.1*stone.label.size/math.max(einstein_star.height,einstein_star.width)
  einstein_star.scaledwidth = einstein_star.width*einstein_star.scalingf
  einstein_star.scaledheight = einstein_star.height*einstein_star.scalingf
  
  sound_onoff.checkmark = {}
  sound_onoff.checkmark.img = love.graphics.newImage("checkmark.png")
  sound_onoff.checkmark.height = sound_onoff.checkmark.img:getHeight()
  sound_onoff.checkmark.width = sound_onoff.checkmark.img:getWidth()
  sound_onoff.checkmark.scalingf = 1.5*sound_onoff.box.size/math.max(sound_onoff.checkmark.height,sound_onoff.checkmark.width)
  sound_onoff.checkmark.scaledwidth = sound_onoff.checkmark.width*sound_onoff.checkmark.scalingf
  sound_onoff.checkmark.scaledheight = sound_onoff.checkmark.height*sound_onoff.checkmark.scalingf
  sound_onoff.checkmark.pos_x = sound_onoff.box.pos_x+sound_onoff.box.size/2-sound_onoff.checkmark.scaledwidth/2
  sound_onoff.checkmark.pos_y = sound_onoff.box.pos_y+sound_onoff.box.size/2-sound_onoff.checkmark.scaledheight/2
  
  -- sounds ---------------------------------------------------
  
  sounds = {}
  sounds.click              = love.audio.newSource("Eshed_click.wav", "static")
  sounds.select_stone       = love.audio.newSource("Eshed_select.ogg", "static")
  sounds.deselect_stone     = love.audio.newSource("Eshed_deselect.ogg", "static")
  sounds.place_stone_empty  = love.audio.newSource("Eshed_place.wav", "static")
  sounds.place_stone_kill   = love.audio.newSource("Eshed_eat.ogg", "static")
  sounds.game_won           = love.audio.newSource("Eshed_yay.ogg", "static")
  
  overall_volume = .5
  sounds.click:setVolume(overall_volume)
  sounds.select_stone:setVolume(overall_volume*0.9)
  sounds.deselect_stone:setVolume(overall_volume*0.9)
  sounds.place_stone_empty:setVolume(overall_volume)
  sounds.place_stone_kill:setVolume(overall_volume)
  sounds.game_won:setVolume(overall_volume*0.9)
  