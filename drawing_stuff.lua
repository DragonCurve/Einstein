local statusbar_strs = {
    roll_die = "Please roll the die.",
    select_stone = "Please select the stone you want to move.",
    place_selected_stone = "Please select the field where you want to move the stone.",
    won_play_again = ""
  }
local dot_coords = { -- set up for non-6-sided-dies
  {x={2/4},                           y= {2/4}},                        -- 1
  {x={1/4, 3/4},                      y={3/4, 1/4}},                    -- 2
  {x={1/4, 2/4, 3/4},                 y={3/4, 2/4, 1/4}},               -- 3
  {x={1/4, 1/4, 3/4, 3/4},            y={1/4, 3/4, 1/4, 3/4}},          -- 4
  {x={1/4, 1/4, 2/4, 3/4, 3/4},       y={1/4, 3/4, 2/4, 1/4, 3/4}},     -- 5
  {x={1/4, 1/4, 1/4, 3/4, 3/4, 3/4},  y={1/4, 2/4, 3/4, 1/4, 2/4, 3/4}} -- 6
  }
--
function draw_board()
  love.graphics.setColor(board.shadow.col)
  love.graphics.rectangle("fill", board.pos_x+board.shadow.offset, board.pos_y+board.shadow.offset , board.size, board.size) -- shadow
  love.graphics.setColor(board.col)
  love.graphics.rectangle("fill", board.pos_x , board.pos_y , board.size, board.size)
  
  
  local function draw_field(pos_x1,pos_y1,draw_mode)
    love.graphics.rectangle(draw_mode, pos_x1 , pos_y1, board.field.size-board.field.margin, board.field.size-board.field.margin)
  end
  
  for j=1,board.ntimesnfields do
    for i=1,board.ntimesnfields do
      local k = ij2k(i,j);
      
      local pos_x = (j-1)*board.field.size+board.field.margin/2+total_margin;
      local pos_y = (i-1)*board.field.size+board.field.margin/2+total_margin;
      
      -- board squares
      love.graphics.setColor(board.field.col)
      draw_field(pos_x,pos_y,"fill")
      
      -- coloured home squares
      if is_home_field(k)==1 then-- area for player 1's stones
        love.graphics.setColor(player.col[1][1],player.col[1][2],player.col[1][3],player.col.homealpha)
        draw_field(pos_x,pos_y,"fill")
        
      elseif is_home_field(k)==2 then-- area for player 2's stones
        love.graphics.setColor(player.col[2][1],player.col[2][2],player.col[2][3],player.col.homealpha)
        draw_field(pos_x,pos_y,"fill")
      end
      
      -- stones
      local this_player = get_player(k);
      if this_player~=0 then
        local center_x = round((j-0.5)*board.field.size+board.field.margin/2+total_margin);
        local center_y = round((i-0.5)*board.field.size+board.field.margin/2+total_margin);
        -- fill
        love.graphics.setColor(player.col[this_player])
        love.graphics.circle("fill",center_x,center_y,stone.radius)
        -- edge
        love.graphics.setLineWidth( stone.edge.linewidth )
        love.graphics.setColor(stone.col.edge.pl[this_player])
        love.graphics.circle("line",(j-0.5)*board.field.size+board.field.margin/2+total_margin,(i-0.5)*board.field.size+board.field.margin/2+total_margin,stone.radius)
        -- stone id label
        love.graphics.setColor(stone.label.col)
        if is_einstein(this_player) then
          --love.graphics.printf("!", stone.label.font, pos_x, center_y-stone.label.font:getHeight()/2, board.field.size, 'center')
          love.graphics.draw( einstein_star.img, center_x-einstein_star.scaledwidth/2, center_y-einstein_star.scaledheight/2, 0, einstein_star.scalingf, einstein_star.scalingf)
        else
          love.graphics.printf(get_stone_id(k), stone.label.font, pos_x, center_y-stone.label.font:getHeight()/2, board.field.size, 'center')
        end
        --love.graphics.printf(    text     ,       font      ,   x  ,                  y                     ,       limit     ,  align  ) -- https://love2d.org/wiki/love.graphics.printf
      end
      
      -- highlighting
      if field_is_highlighted(k) then
        love.graphics.setLineWidth(board.field.highlight.linewidth)
        love.graphics.setColor(board.field.highlight.col)
        draw_field(pos_x,pos_y,"line")
      elseif field_is_faintly_highlighted(k) then -- to deselect a selected stone
        love.graphics.setLineWidth(board.field.highlight.linewidth)
        love.graphics.setColor(board.field.fainthighlight.col)
        draw_field(pos_x,pos_y,"line")
        --love.graphics.setColor(board.field.col[1],board.field.col[2],board.field.col[3],board.field.fadedalpha)
        --draw_field(pos_x,pos_y,"fill")
      elseif field_is_faded(k) then -- this field should be faded
        love.graphics.setColor(board.field.col[1],board.field.col[2],board.field.col[3],board.field.fadedalpha)
        draw_field(pos_x,pos_y,"fill")
        
      end
      
    end
  end
  
end

function draw_die_face(f)

  local fade_dots = false;
  if f==0 then
    f=die.sides;
    love.graphics.setColor(die.dot.col[1],die.dot.col[2],die.dot.col[3],die.dot.fadedalpha)
  else
    love.graphics.setColor(die.dot.col)
  end
  
  
  local dot_coords1 = dot_coords[f];
  for i = 1,f do
    love.graphics.circle("fill",die.pos_x+die.size*dot_coords1.x[i],
                                die.pos_y+die.size*dot_coords1.y[i],
                                die.dot.radius)
  end
  
  
end
function draw_die()
  
  love.graphics.setColor(die.shadow.col) -- shadow
  love.graphics.rectangle("fill", die.pos_x+die.shadow.offset, die.pos_y+die.shadow.offset, die.size, die.size, die.corner_r, die.corner_r)
  love.graphics.setColor(die.col)
  love.graphics.rectangle("fill", die.pos_x, die.pos_y, die.size, die.size, die.corner_r, die.corner_r)
  
  draw_die_face(get_die_state())
  
  if die_is_highlighted() then
    highlight_rad = die.size/3
    love.graphics.setColor(die.highlight.col)
    love.graphics.setLineWidth(die.highlight.linewidth)
    love.graphics.rectangle("line", die.pos_x-die.highlight.distance,
                                    die.pos_y-die.highlight.distance,
                                    die.size+die.highlight.distance*2+die.shadow.offset,
                                    die.size+die.highlight.distance*2+die.shadow.offset,
                                    die.corner_r, die.corner_r)
  end
  
end
  
function update_statusbar()
  
  love.graphics.setColor(statusbar.shadow.col)
  love.graphics.setLineWidth(statusbar.edge.linewidth)
  love.graphics.rectangle("fill", statusbar.pos_x+statusbar.shadow.offset, statusbar.pos_y+statusbar.shadow.offset , statusbar.width, statusbar.height) -- shadow
  love.graphics.rectangle("line", statusbar.pos_x, statusbar.pos_y , statusbar.width, statusbar.height) -- edge
  love.graphics.setColor(statusbar.col)
  love.graphics.rectangle("fill", statusbar.pos_x, statusbar.pos_y , statusbar.width, statusbar.height)
  
  if not get_waiting_for_player() or not statusbar_strs[get_waiting_for_action()] then
    error("Invalid get_waiting_for_player, get_waiting_for_action or statusbar_strs.")
  end
  
  local statusbar_colstring = {};
  if get_waiting_for_action()=="won_play_again" then
    statusbar_colstring = {
      player.col[get_waiting_for_player()], string.format("Player %d won!\n",get_waiting_for_player()),
      --statusbar.fontcol                  , string.format("%s",statusbar_strs[get_waiting_for_action()])
      };
  else
    statusbar_colstring = {
      player.col[get_waiting_for_player()], string.format("Player %d's",get_waiting_for_player()),
      statusbar.fontcol                  , string.format(" turn.\n%s",statusbar_strs[get_waiting_for_action()])
      };
  end
  love.graphics.setColor(1,1,1)
  love.graphics.printf(statusbar_colstring, statusbar.font, statusbar.pos_x, statusbar.pos_y, statusbar.width, 'left')
  --love.graphics.printf(   coloredtext   ,      font     ,   x  ,   y  ,      limit     ,  align  ) -- https://love2d.org/wiki/love.graphics.printf
  
end
function draw_play_again_button()
  if get_play_again_status() then
    
    love.graphics.setColor(play_again_button.shadow.col) -- shadow
    love.graphics.rectangle("fill", play_again_button.pos_x+play_again_button.shadow.offset, play_again_button.pos_y+play_again_button.shadow.offset,
      play_again_button.width, play_again_button.height, play_again_button.corner_r, play_again_button.corner_r)
    love.graphics.setColor(play_again_button.col)
    love.graphics.rectangle("fill", play_again_button.pos_x, play_again_button.pos_y, play_again_button.width, play_again_button.height, play_again_button.corner_r, play_again_button.corner_r)
    
    love.graphics.setColor(play_again_button.fontcol)
    love.graphics.printf("Do you want\nto play again?", play_again_button.font, play_again_button.pos_x, play_again_button.pos_y, play_again_button.width, 'center')
    
  end
  
end
function draw_sound_onoff()
  love.graphics.setColor(1,1,1)
  sound_onoff_colstr = {statusbar.fontcol , "Sound effects:\n"}
  love.graphics.printf(sound_onoff_colstr, sound_onoff.font, sound_onoff.label.pos_x, sound_onoff.label.pos_y, sound_onoff.label.width, 'center')
  love.graphics.setColor(statusbar.fontcol)
  love.graphics.setLineWidth( sound_onoff.edge.linewidth )
  love.graphics.rectangle("line", sound_onoff.box.pos_x , sound_onoff.box.pos_y, sound_onoff.box.size, sound_onoff.box.size)
  if get_sounds_onoff() then
    love.graphics.setColor(1,1,1)
    love.graphics.draw( sound_onoff.checkmark.img, sound_onoff.checkmark.pos_x, sound_onoff.checkmark.pos_y, 0, sound_onoff.checkmark.scalingf, sound_onoff.checkmark.scalingf)
  end
end
function plot_winning_stats()
  
  love.graphics.setColor(1,1,1)
  local winning_stats = get_winning_stats();
  local tmp_color = statusbar.fontcol
  local winningstats_colstring = {
        tmp_color           , "Games won:\n",
        player.col[1]       , string.format("%d",winning_stats[1]),
        tmp_color           , "/",
        player.col[2]       , string.format("%d",winning_stats[2])
        }
  love.graphics.printf(winningstats_colstring, winning_stats_disp.font, winning_stats_disp.pos_x, winning_stats_disp.pos_y, winning_stats_disp.width, 'center')
  
end