
local function area_clicked (click_x,click_y,field_pos_x,field_pos_y,field_size_x,field_size_y)
  
  if click_x>field_pos_x and click_x<(field_pos_x+field_size_x) and
     click_y>field_pos_y and click_y<(field_pos_y+field_size_y) then
    return true
  else
    return false
  end
end

function love.mousereleased( click_x, click_y, button)
  
  if button==1 then-- main button
    
    if area_clicked(click_x, click_y, board.pos_x, board.pos_y, board.size, board.size) then -- clicked on the board
      -- find which field was clicked
      -- try_select_field()
      local j = math.ceil((click_x-board.pos_x)/board.field.size);
      local i = math.ceil((click_y-board.pos_y)/board.field.size);
      try_selecting_field_or_stone(ij2k(i,j))
    
    elseif area_clicked(click_x, click_y, die.pos_x,die.pos_y, die.size, die.size) then -- clicked on the die
      try_rolling_die()
    
    elseif area_clicked(click_x, click_y, play_again_button.pos_x,play_again_button.pos_y, play_again_button.width, play_again_button.height) then -- clicked on the play again button
    -- (or the area it takes when it's visible)
      try_starting_new_game()
      
    elseif area_clicked(click_x, click_y, sound_onoff.box.pos_x, sound_onoff.box.pos_y, sound_onoff.box.size, sound_onoff.box.size) then -- clicked on the sound checkbox
      turn_sounds_onoff()
    end
    
  end
end