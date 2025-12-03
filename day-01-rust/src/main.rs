use input_curler::input_for;
use std::ops::Div;

const SAMPLE: &str = "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82";

fn main() {
    let data = input_for(1).unwrap();

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
    let turns = parse_data(data);
    turns
        .iter()
        .fold((50, 0), |(old, zeroes), turn| {
            let new = (old + turn).rem_euclid(100);
            let zeroes = if new == 0 { zeroes + 1 } else { zeroes };
            (new, zeroes)
        })
        .1
}

fn part_two(data: &str) -> usize {
    let turns = parse_data(data);
    turns
        .iter()
        .fold((50, 0usize), |(old, zeroes), turn| {
            let full_turns = turn.div(100).unsigned_abs() as usize;
            let part_turn = turn % 100;

            let part_crosses_zero = match (old, part_turn.signum()) {
                (0, _) => 0,
                (o, 1) if 100 - o <= part_turn => 1,
                (o, -1) if o <= part_turn.abs() => 1,
                _ => 0,
            };

            let new = (old + part_turn).rem_euclid(100);
            (new, zeroes + full_turns + part_crosses_zero)
        })
        .1
}

fn parse_data(data: &str) -> Vec<i32> {
    data.lines()
        .map(|line| match line.chars().next() {
            Some('L') => -(line[1..].parse::<i32>().unwrap()),
            Some('R') => line[1..].parse::<i32>().unwrap(),
            _ => panic!(),
        })
        .collect()
}
