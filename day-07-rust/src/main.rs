use std::collections::{HashMap, HashSet};

use input_curler::input_for;

const SAMPLE: &str = ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............";

fn main() {
    let data = input_for(7).unwrap();

    let sample_one = part_one(SAMPLE);
    println!("Sample one: {}", sample_one);
    let answer_one = part_one(data.as_str());
    println!("Answer one: {}", answer_one);

    let sample_two = part_two(SAMPLE);
    println!("Sample two: {}", sample_two);
    let answer_two = part_two(data.as_str());
    println!("Answer two: {}", answer_two);
}

fn part_one(data: &str) -> usize {
    let mut split_count = 0usize;
    let mut tachyon_columns: HashSet<usize> = HashSet::new();
    tachyon_columns.insert(
        data.lines()
            .next()
            .unwrap()
            .chars()
            .position(|c| c == 'S')
            .unwrap(),
    );

    for line in data.lines().skip(1) {
        for (ix, location) in line.char_indices() {
            if location == '^' && tachyon_columns.contains(&ix) {
                tachyon_columns.remove(&ix);
                tachyon_columns.insert(ix - 1);
                tachyon_columns.insert(ix + 1);
                split_count += 1;
            }
        }
    }

    split_count
}

fn part_two(data: &str) -> usize {
    let mut tachyons: Vec<HashMap<usize, usize>> = vec![];
    let start = data
        .lines()
        .next()
        .unwrap()
        .chars()
        .position(|c| c == 'S')
        .unwrap();

    let mut row_zero: HashMap<usize, usize> = HashMap::new();
    row_zero.insert(start, 1);
    tachyons.push(row_zero);

    for line in data.lines().skip(1) {
        let prev_row = tachyons.last().unwrap();
        let mut row: HashMap<usize, usize> = HashMap::new();
        for (ix, location) in line.char_indices() {
            if let Some(above) = prev_row.get(&ix) {
                if location == '^' {
                    let new_timelines = match row.get(&(ix - 1)) {
                        Some(existing) => existing + above,
                        None => *above,
                    };
                    row.insert(ix - 1, new_timelines);
                    let new_timelines = match row.get(&(ix + 1)) {
                        Some(existing) => existing + above,
                        None => *above,
                    };
                    row.insert(ix + 1, new_timelines);
                } else {
                    let new_timelines = match row.get(&ix) {
                        Some(existing) => existing + above,
                        None => *above,
                    };
                    row.insert(ix, new_timelines);
                }
            }
        }
        tachyons.push(row);
    }

    tachyons.last().unwrap().values().sum()
}
