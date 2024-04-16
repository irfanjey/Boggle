#![allow(non_snake_case,non_camel_case_types,dead_code)]

use std::collections::HashMap;

/*
    Fill in the boggle function below. Use as many helpers as you want.
    Test your code by running 'cargo test' from the tester_rs_simple directory.
    
    To demonstrate how the HashMap can be used to store word/coord associations,
    the function stub below contains two sample words added from the 2x2 board.
*/

fn boggle(board: & [&str], words: & Vec<String>) -> HashMap<String, Vec<(u8, u8)>>
{
    let mut found: HashMap<String, Vec<(u8, u8)>> = HashMap::new();

    let n = board.len();
    let mut found_word = false;
    let mut dfs_return: Vec<(u8,u8)> = Vec::new();

    let mut track_map: HashMap<char, Vec<(u8,u8)>>  = HashMap::new();
    for i in 'a'..='z'{
        track_map.insert(i, Vec::new());
    }

    for x in 0..n{
        for y in 0..n{
            if let Some(ch) = board[x].chars().nth(y) {
                track_map.entry(ch).and_modify(|vec| vec.push((x as u8, y as u8)));
            }
            else{
            }
            
        }
    }

    for word in words.iter(){
        if let Some(first_val) = word.chars().nth(0){
            if let Some(temp) = track_map.get(&first_val) {
                for each in temp{
                    dfs_return = dfs(board, each.0, each.1, word.as_str(), 0, Vec::new());
                    if !dfs_return.is_empty(){
                        found.insert(word.to_string(), dfs_return);
                        found_word = true;
                        break;
                    }
                }
            }
            else{
            }
        }
        else{
        }
    }
    found
}

fn dfs(board: & [&str], row: u8, column: u8, word: &str, index: usize, mut coordinates: Vec<(u8, u8)>) -> Vec<(u8,u8)>
{
    coordinates.push((row, column));
    if coordinates.len() == word.len(){
        return coordinates
    }
    else{
        let directions = [(-1, 0), (0, 1), (1, 0), (0, -1), (-1, -1), (-1, 1), (1, -1), (1, 1)];
        for cord in &directions{
            let new_row = (row as i8 + cord.0) as u8;
            let new_column = (column as i8 + cord.1) as u8;

            if new_row < board.len() as u8 && new_column < board.len() as u8{
                if board[new_row as usize].chars().nth(new_column as usize) == word.chars().nth(index+1) && !coordinates.contains(&(new_row, new_column)){
                    let result = dfs(board, new_row, new_column, word, index + 1, coordinates.clone());
                    if result.len() == word.len() {
                        return result;
                    }
                }
            }
        }
        coordinates.pop();
        return Vec::new();
    }

}


#[cfg(test)]
#[path = "tests.rs"]
mod tests;

