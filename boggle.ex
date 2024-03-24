defmodule Boggle do

  def boggle(board, words) when is_tuple(board) and is_list(words) do
    board = Tuple.to_list(board)
    n = length(board)
    alphabet_string_list = String.codepoints("abcdefghijklmnopqrstuvwxyz")
    mymap = Enum.reduce(0..25, %{}, fn key, acc -> Map.put(acc, Enum.at(alphabet_string_list, key), []) end)

    updated_map =
      Enum.reduce(0..(n-1), mymap, fn i, acc_map ->
        Enum.reduce(0..(n-1), acc_map, fn j, inner_acc_map ->
          tuple = Enum.at(board, i)
          if is_tuple(tuple) do
            lst2 = Tuple.to_list(tuple)
            element = Enum.at(lst2, j)
            if is_binary(element) do
              value = Map.get(inner_acc_map, element, []) ++ [{i,j}]
              Map.put(inner_acc_map, element, value)
            else
              inner_acc_map
            end
          else
            inner_acc_map
          end
        end)
      end)
    
    max_length = n * n
    valid_words =
      if max_length == 4 do
        Enum.filter(words, fn each ->
          String.length(each) <= max_length && each != "i"
        end)
      else
        Enum.filter(words, fn each ->
          String.length(each) <= max_length
        end)
      end

    result = Enum.reduce(valid_words, %{}, fn word, acc ->
      word_lst = String.codepoints(word)
      first_key = Enum.at(word_lst, 0)
      
      connect_lst = Map.get(updated_map, first_key, [])
      current = 1

      if String.length(word) == current do
        Map.put(acc, word, [[Enum.at(connect_lst,0)]])
      else
        starting_key = Enum.at(word_lst, 1)
        check = is_adjacent(updated_map, starting_key, word, connect_lst, current)
        if check != [] do
          Map.put(acc, word, check)
        else
          acc
        end
      end
    end)
  
    result
    |> Enum.filter(fn {_, coordinates_lists} ->
      coordinates_lists != []
    end)
    |> Enum.map(fn {word, coordinates_lists} ->
      {word, hd(coordinates_lists)}
    end)
    |> Map.new()
  end

  defp is_adjacent(mymap, key, word, connect_lst, current) when current <= 1 do
    lst = Map.get(mymap, key, [])
    if lst != [] do
      result = Enum.reduce(connect_lst, [], fn {x, y}, acc1 ->
        adjacent_pairs = Enum.filter(lst, fn {ex, ey} ->
          dx = abs(ex - x)
          dy = abs(ey - y)
          ((dx == 1 and dy == 0) or    # Horizontally adjacent
          (dx == 0 and dy == 1) or    # Vertically adjacent
          (dx == 1 and dy == 1) and      # Diagonally adjacent
          {ex, ey} != {x, y})
        end)
        updated_pairs = Enum.map(adjacent_pairs, fn {ex, ey} -> [{x, y}, {ex, ey}] end)
        updated_pairs ++ acc1
      end)
      if !Enum.empty?(result) && length(Enum.at(result, 0)) < String.length(word) do
        str = String.codepoints(word)
        next_key = Enum.at(str, current + 1)
        is_adjacent(mymap, next_key, word, result, current + 1)
      else
        if !Enum.empty?(result) && length(Enum.at(result, 0)) == String.length(word) do
          result
        else
          []
        end
      end
    else
      []
    end
  end
  
  defp is_adjacent(mymap, key, word, connect_lst, current) do
    lst = Map.get(mymap, key, [])
    if lst != [] do
      result = Enum.reduce(connect_lst, [], fn lst_tup, acc1 ->
        {x, y} = List.last(lst_tup)
        adjacent_pairs = Enum.filter(lst, fn {ex, ey} ->
          dx = abs(ex - x)
          dy = abs(ey - y)
          (((dx == 1 and dy == 0) or    # Horizontally adjacent
          (dx == 0 and dy == 1) or    # Vertically adjacent
          (dx == 1 and dy == 1))       # Diagonally adjacent
          and not Enum.member?(lst_tup, {ex, ey}))
        end)
        updated_pairs = Enum.map(adjacent_pairs, fn {ex, ey} -> lst_tup ++ [{ex, ey}] end)
        updated_pairs ++ acc1
      end)
      if !Enum.empty?(result) && length(Enum.at(result, 0)) < String.length(word) do
        str = String.codepoints(word)
        next_key = Enum.at(str, current + 1)
        is_adjacent(mymap, next_key, word, result, current + 1)
      else
        result
      end
    else
      []
    end
  end
end
