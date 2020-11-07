
require("utilities")
require("game_settings") -- requires utilities

require("game_play")     -- requires utilities, game settings
require("drawing_stuff") -- requires utilities, game settings, game_play
require("callbacks")     -- requires utilities, game settings, game play


function love.load()
  
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  math.randomseed(os.time())
  
  
  love.window.setTitle( "Einstein würfelt nicht" )
  love.graphics.setBackgroundColor(col.bkgr)
  
  initialise_game() -- initialises the table state.board
  
end

function love.draw()
  
  draw_board()
  draw_die()
  update_statusbar()
  plot_winning_stats()
  draw_play_again_button()
  draw_sound_onoff()
  
  
end
