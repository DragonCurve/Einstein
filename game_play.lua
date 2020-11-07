local state = { board = {}, einstein = {}, highlighted = {}, selected = {}, waiting_for = {pl = {}, action = {}}, die = 0 , winning_stats = {0,0}, play_again_button = false, play_sounds = true};

function initialise_game()
  -- initialises the state table
  
  -- state.board is a board.ntimesnfields^2 element array, representing the fields of the board starting on the top left, first going down, then right
  -- use get_player and get_stone_id to extract the respective information out of the board state.
  
  
  if n_stones*2>board.ntimesnfields^2 then
    error("Incompatible n_stones and board.ntimesnfields. The square of board.ntimesnfields has to be at least twice the size as n_stones.")
  end
  
  -- at the beginning, the stones are distributed randomly, but positioned equally for both players.
  local initial_stone_layout = random_permutation(n_stones)
  local stone_i = {1,n_stones};
  
  for j=1,board.ntimesnfields do
    for i=1,board.ntimesnfields do
      -- the order in which the fields are visited is relevant, since the stones in initial_stone_layout are used in the order that the fields are visited.
      -- to match the linear indexing going first down, then right, i (rows) has to be nested within j (columns)
      local k = ij2k(i,j); -- linear index
      
      state.highlighted[k] = 0; -- initially, nothing is highlighted
      
      if is_home_field(k)==1 then-- area for player 1's stones
        state.board[k] = initial_stone_layout[stone_i[1]];
        
        --if initial_stone_layout[stone_i[1]]==4 then
        --  state.highlighted[k]= 1;
        --end
        
        stone_i[1] = stone_i[1]+1;
        
      elseif is_home_field(k)==2 then-- area for player 2's stones
        if (not n_stones) or (not initial_stone_layout[stone_i[2]]) then
          print("until here")
        end
        state.board[k] = n_stones+initial_stone_layout[stone_i[2]];
        
        --if initial_stone_layout[stone_i[2]]==3 then
        --  state.highlighted[k]= 1;
        --end
        
        stone_i[2] = stone_i[2]-1;
      else
        state.board[k] = 0;
      end
      
      
    end
  end
  
  
  --state.die = 0;
  state.play_again_button = false;
  local finished_game_count = state.winning_stats[1]+state.winning_stats[2];
  state.waiting_for.pl = math.fmod(finished_game_count,2)+1; -- players start alternatingly
  state.waiting_for.action = "roll_die";
  state.einstein = {0, 0};
  
  --[[
  print_table(get_player(state.board))
  print_table(get_stone_id(state.board))
  --]]
  
end

--
-- finding and counting stones
local function get_active_stones_logical(which_pl) -- get logical array of active (true) inactive (false) stones for a specific player p, i.e. stones that are still in the game
  
  local active_stones = {};
  
  -- initialise as false
  for s = 1,n_stones do
    active_stones[s] = false;
  end
  -- set present stones to true
  --for i = 1, n do
  for k = 1,#state.board do
    local stone_id = get_stone_id(k);
    if stone_id>=1 and stone_id<=n_stones and get_player(k)==which_pl then
      active_stones[stone_id] = true;
    end
  end
  return active_stones
  
end
local function get_active_stones(which_pl) -- get logical array of active (true) inactive (false) stones for a specific player p, i.e. stones that are still in the game
  
  local active_stones = {};
  
  --for i = 1, n do
  for k = 1,#state.board do
    local stone_id = get_stone_id(k);
    if stone_id>=1 and stone_id<=n_stones and get_player(k)==which_pl then
      table.insert(active_stones, stone_id);
    end
  end
  return active_stones
  
end
local function count_remaining_stones()
  
  for p = 1,2 do
    local active_stones = get_active_stones(p);
    if (#active_stones)==1 then
      state.einstein[p] = active_stones[1];
    end
  end
  
end
local function get_movable_stones() -- depending on player and die roll
  
  local active_stones = get_active_stones_logical(get_waiting_for_player())
  local movable_stones = {};
  
  if active_stones[state.die] then-- the stone of the rolled number still exists
    table.insert(movable_stones, state.die);
  else
    -- next lower stone
    local not_found_yet = true;
    for s = (state.die-1), 1, -1 do -- reverse for loop: https://www.lua.org/pil/4.3.4.html
      if active_stones[s] and not_found_yet then
        table.insert(movable_stones, s);
        not_found_yet = false;
      end
    end
    
    -- next higher stone
    local not_found_yet = true;
    for s = (state.die+1), n_stones do
      if active_stones[s] and not_found_yet then
        table.insert(movable_stones, s);
        not_found_yet = false;
      end
    end
  end
  
  return movable_stones -- xxx test this for cases when the stone equivalent to the rolled value is no longer available
end
local function find_einstein(pl) -- returns the position of the einstein
  if not state.einstein[pl] then
    error("There is no einstein (single stone) for this player.")
  end
  for k = 1, #state.board do
    if get_player(k)==pl then
      return k
    end
  end
  error("There should be an einstein (single stone) for this player, but I couldn't find one.")
end
local function check_winning_conditions()

  local winning_player = {};
  if get_player(1)==2 then -- player 2 reached the opposite corner
    winning_player = 2;
    
  elseif get_player(board.ntimesnfields^2)==1 then -- player 1 reached the opposite corner
    winning_player = 1;
    
  else -- check whether one player ran out of stones
    
    found_stone = {false,false}; -- 0 will also be set, but is irrelevant
    for k = 1,#state.board do
      found_stone[get_player(k)] = true;
    end
    
    if not found_stone[1] then
      winning_player = 2;
    elseif not found_stone[2] then
      winning_player = 1;
    else
      winning_player = 0;
    end
    
  end
  
  if winning_player~=0 then
    state.winning_stats[winning_player] = state.winning_stats[winning_player]+1;
  end
  return winning_player
  
end
--
-- highlighting
local function any_highlighted_fields()
  for k = 1, #state.highlighted do
    if state.highlighted[k]==1 then
      return true
    end
  end
  return false
end
local function reset_highlighting()
  for k=1,#state.highlighted do
    state.highlighted[k] = 0;
  end
end
local function highlight_movable_stones()
  
  reset_highlighting();
  
  movable_stones = get_movable_stones();
  for m,mst in pairs(movable_stones) do
    for k = 1, #state.board do
      
      if get_stone_id(k)==mst and get_player(k)==get_waiting_for_player() then
        state.highlighted[k] = 1;
      end
      
    end
  end
  -- to do next: take these movable stones, find them on the board and set them highlighted
end
local function highlight_reachable_fields()
  
  reset_highlighting();
  
  -- determine step direction
  if get_player(state.selected)==1 then
    step = 1;
  elseif get_player(state.selected)==2 then
    step = -1;
  end
  
  local sel_i, sel_j = k2ij(state.selected)
  
  if valid_i_or_j(sel_i+step) and valid_i_or_j(sel_j     ) then
    state.highlighted[ ij2k(sel_i+step,sel_j     ) ] = 1
  end
  if valid_i_or_j(sel_i     ) and valid_i_or_j(sel_j+step) then
    state.highlighted[ ij2k(sel_i     ,sel_j+step) ] = 1
  end
  if valid_i_or_j(sel_i+step) and valid_i_or_j(sel_j+step) then
    state.highlighted[ ij2k(sel_i+step,sel_j+step) ] = 1
  end
  
  state.highlighted[state.selected] = -1; -- for potential deselecting
  
end
--
-- moving stones
local function select_stone(k)
  if state.play_sounds then
    sounds.select_stone:play()
  end
  state.selected = k;
  state.waiting_for.action = "place_selected_stone";
  highlight_reachable_fields();
end
local function deselect_stone(k)
  if state.play_sounds then
    sounds.deselect_stone:play()
  end
  state.selected = {}; -- the selected stone is no longer selected
  state.waiting_for.action = "select_stone";
  highlight_movable_stones();
end
local function place_selected_stone(k)
  
  local target_field_empty = false
  if state.board[k]==0 then
    target_field_empty = true
  end
  
  state.board[k] = state.board[state.selected] -- the moved stone takes the place of whatever was in that field
  state.board[state.selected] = 0 -- the field from which the stone moved becomes empty
  state.selected = {} -- the selected stone is no longer selected
  reset_highlighting()
  state.die = 0
  count_remaining_stones()
  
  won = check_winning_conditions()
  if won==0 then -- start next turn
    
    if state.play_sounds then
      if target_field_empty then
        sounds.place_stone_empty:play()
      else
        sounds.place_stone_kill:play()
      end
    end
  
    state.waiting_for.pl = other_player(state.waiting_for.pl)
    
    if is_einstein(state.waiting_for.pl) then
      local k = find_einstein(state.waiting_for.pl)
      highlight_movable_stones()
      state.waiting_for.action = "select_stone"
    
      --select_stone(k);
    else
      state.waiting_for.action = "roll_die"
    end
    
  else
    if state.play_sounds then
      sounds.game_won:play()
    end
    state.waiting_for.action = "won_play_again"
    state.play_again_button = true
    state.waiting_for.pl = won
  end
end
--
--
-- functions making the game state accessible (read-only) to drawing_stuff.lua and callbacks.lua
--
function get_player(k) -- returns which player the stone in k belongs to
  if not k then -- checking for errors
    error("invalid k")
  elseif not state.board[k] then
    error("invalid state board at k")
  elseif not n_stones then
    error("invalid n_stones")
  end
  
  return math.floor((state.board[k]-1)/n_stones)+1
end
function get_stone_id(k)
  if not k then -- checking for errors
    error("invalid k")
  elseif not state.board[k] then
    error("invalid state board at k")
  elseif not n_stones then
    error("invalid n_stones")
  end
  if state.board[k]==0 then
    return 0;
  else
    return math.fmod(state.board[k]-1,n_stones)+1;
  end
  
end
function get_waiting_for_player()
  return state.waiting_for.pl;
end
function get_waiting_for_action()
  return state.waiting_for.action;
end
function get_die_state()
  return state.die;
end
function is_einstein(pl)
  return state.einstein[pl]>0;
end
function get_play_again_status()
  return state.play_again_button;
end
function get_winning_stats()
  return state.winning_stats;
end
function get_sounds_onoff()
  return state.play_sounds
end
-- checking fields
function is_home_field(k)
  -- returns 1 or 2, if the field i,j is in a player's home area, 0 if not.
  local i, j = k2ij(k);
  if i+j-1<=board.hometrianglelength then
    return 1;
  elseif (board.ntimesnfields-i+1)+(board.ntimesnfields-j+1)-1<=board.hometrianglelength then
    return 2;
  else
    return 0;
  end
end
function field_is_faded(k)
  return any_highlighted_fields() and (state.highlighted[k]==0);
  --return any(state.highlighted) and not state.highlighted[k]; -- when state.highlighted was an array of booleans
end
function field_is_highlighted(k)
  return state.highlighted[k]==1;
end
function field_is_faintly_highlighted(k)
  return state.highlighted[k]==-1;
end
function die_is_highlighted()
  return state.waiting_for.action=="roll_die"
end
--
-- functions trying to change the game state
function try_rolling_die()
  
  if state.waiting_for.action=="roll_die" then
    if state.play_sounds then
      sounds.click:play()
    end
    state.die = math.random(die.sides);
    highlight_movable_stones();
    state.waiting_for.action = "select_stone";
  end
  
end
function try_selecting_field_or_stone(k)
  if not valid_k(k) then
    error("how could you select this!?")
  end
  
  if state.waiting_for.action=="select_stone" and (state.highlighted[k]==1) then
    --state.waiting_for.pl == get_player(k) and -- is already covered by checking for highlighted stone
    select_stone(k);
    
  elseif state.waiting_for.action=="place_selected_stone" and (state.highlighted[k]==1) then
    place_selected_stone(k)
    
  elseif state.waiting_for.action=="place_selected_stone" and (state.highlighted[k]==-1) then
    deselect_stone(k)
  end
  
end
function try_starting_new_game()
  if state.play_again_button then
    if state.play_sounds then
      sounds.click:play()
    end
    initialise_game()
  end
end

function turn_sounds_onoff()
  state.play_sounds = not state.play_sounds
end
--

  -- further ideas:
  -- add an option for putting the stones yourself (click in order 1 to 6)
  -- draw the board, fields and status bar background on a canvas once instead of every iteration --https://love2d.org/wiki/Canvas
  -- add a german version
  
  