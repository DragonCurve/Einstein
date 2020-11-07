-- genearlly useful and mathy stuff that is not directly related to the game
function random_permutation(n)
  -- https://stackoverflow.com/questions/16120281/randomize-numbers-in-lua-with-no-repeats
  
  local t = {}
  for i = 1, n do
    t[i] = i
  end
  
  for i = 1, n do
    local j = math.random(i, n)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

function decompose_triangle(n)
  
  local k=0;
  local n1=0;
  
  while n1<n do
    k  = k+1;
    n1 = n1+k;
  
  end
  if n1==n then
    return k
  else
    error("Invalid n_stones. It has to be a triangular number.")
  end
  
end

function round(k)
  return math.floor(k+.5)
end

function print_table(t)
  for key,value in pairs(t) do
    print(key,value);
  end
  print("")
end
function all(a)
  
  for i = 1, #a do
    if not a[i] then
      return false
    end
  end
  
  return true
  
end
function any(a)
  
  for i = 1, #a do
    if a[i] then
      return true
    end
  end
  
  return false
  
end

-- board indexing
function valid_i_or_j(ij)
  return not(ij<1 or ij>board.ntimesnfields)
end
function valid_k(k)
  return not(k<1 or k>(board.ntimesnfields^2))
end
function ij2k(i,j) --i: row, j: column. index k goes first down, then right
  if not valid_i_or_j(i) then
    error("invalid i")
  end
  if not valid_i_or_j(j) then
    error("invalid j")
  end
  return (j-1)*board.ntimesnfields+i
end
function k2ij(k)
  if k<1 or k>board.ntimesnfields^2 then
    error("invalid k")
  end
  local i = math.fmod(k-1,board.ntimesnfields)+1;
  local j = math.floor((k-1)/board.ntimesnfields)+1;
  return i,j
end
function other_player(p)
  return math.fmod(p,2)+1;
end