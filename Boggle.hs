module Boggle (boggle) where
import qualified Data.Map.Strict as Map
import Data.List (nub)
{--
    Fill in the boggle function below. Use as many helpers as you want.
    Test your code by running 'cabal test' from the tester_hs_simple directory.
--}
empty_map :: Map.Map Char [(Int, Int)]
empty_map = Map.fromList [(c, []) | c <- ['a'..'z']] 
-- Map.fromList takes the list comprehension which is a list of tuples and converts it into a map. 

insert_map :: [String] -> [(Int, Int)] -> Map.Map Char [(Int, Int)] -> Map.Map Char [(Int,Int)]
insert_map board [] map = map
insert_map board ((x,y): xs) map = 
                let
                     letter = board !! x !! y
                     new_map = Map.insertWith (++) letter [(x,y)] map
                in insert_map board xs new_map
                                  

create_coordinates :: [String] -> Map.Map Char [(Int, Int)] -> Map.Map Char [(Int,Int)]
create_coordinates board map = 
                    let 
                        list = [(x, y) | y <- [0..(length board -1)], x <- [0..(length board -1)]]
                    in insert_map board list map

boggle :: [String] -> [String] -> [ (String, [ (Int, Int) ] ) ]
boggle board words = 
    let
        map = create_coordinates board empty_map
        result = nub (words_iterate board words map) 
    in
        result


words_iterate :: [String] -> [String] -> Map.Map Char [(Int, Int)] -> [ (String, [ (Int, Int) ] ) ]
words_iterate _ [] _ = []
words_iterate board (word : xs) map = 
    let 
        first_char = head word
        coordinates = Map.findWithDefault [] first_char map
        result = map_coordinates board word coordinates
    in result ++ (words_iterate board xs map) 

map_coordinates :: [String] -> String -> [(Int, Int)] -> [ (String, [ (Int, Int) ] ) ]
map_coordinates board word [] = []
map_coordinates board word ((x, y) : xs) 
    | length dfs_rtn == length word = [(word, dfs_rtn)]
    | otherwise = map_coordinates board word xs
    where
        dfs_rtn = dfs board x y word 0 [(x, y)]

dfs :: [String] -> Int -> Int -> String -> Int -> [(Int,Int)] -> [(Int,Int)]
dfs board row column word index coordinates
    | index == length word = coordinates
    | otherwise =
        let
            n = length board
            directions = [(-1, 0), (0, 1), (1, 0), (0, -1), (-1, -1), (-1, 1), (1, -1), (1, 1)]
            
            validMoves = filter (\(dx, dy) -> 
                let 
                    newRow = row + dx; 
                    newCol = column + dy 
                in
                    newRow >= 0 && newRow < n && newCol >= 0 && newCol < length (head board) &&
                    notElem (newRow, newCol) coordinates && (index + 1 < length word) && (board !! newRow !! newCol) == word !! (index + 1)) directions
        in
            if null validMoves
                then coordinates
                else 
                    let results = [dfs board (row + dx) (column + dy) word (index + 1) (coordinates ++ [(row + dx, column + dy)]) | (dx, dy) <- validMoves]
                        resulting_list = filter (\res -> length res == length word) results
                    in 
                        if length resulting_list == 0
                            then []
                            else
                                head resulting_list
