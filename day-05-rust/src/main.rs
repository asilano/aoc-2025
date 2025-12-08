use input_curler::input_for;
use std::ops::Range;

const SAMPLE: &str = "3-5
10-14
16-20
12-18

1
5
8
11
17
32";

fn main() {
    let data = input_for(5).unwrap();

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
    let (range_part, ingred_part) = data.split_once("\n\n").unwrap();
    let fresh_ranges = range_part.lines().map(|line| {
        let (start, stop) = line.split_once("-").unwrap();
        start.parse::<u64>().unwrap()..stop.parse::<u64>().unwrap() + 1
    });
    let ingredients = ingred_part.lines().map(|line| line.parse::<u64>().unwrap());

    ingredients
        .filter(|ingred| fresh_ranges.clone().any(|range| range.contains(ingred)))
        .count()
}

fn part_two(data: &str) -> u64 {
    let (range_part, _) = data.split_once("\n\n").unwrap();
    let mut fresh_ranges = range_part
        .lines()
        .map(|line| {
            let (start, stop) = line.split_once("-").unwrap();
            start.parse::<u64>().unwrap()..stop.parse::<u64>().unwrap() + 1
        })
        .collect::<Vec<Range<u64>>>();

    let mut keep_going = true;
    while keep_going {
        let size_before = fresh_ranges.len();
        fresh_ranges = combine_ranges(&fresh_ranges);

        if fresh_ranges.len() == size_before {
            keep_going = false;
        }
    }

    fresh_ranges
        .iter()
        .map(|range| range.end - range.start)
        .sum()
}

fn combine_ranges(ranges: &Vec<Range<u64>>) -> Vec<Range<u64>> {
    let mut new_ranges = Vec::<Range<u64>>::new();
    for range in ranges {
        let overlap = new_ranges
            .iter_mut()
            .find(|candidate| candidate.contains(&range.start) || range.contains(&candidate.start));

        if let Some(overlap_range) = overlap {
            overlap_range.start = overlap_range.start.min(range.start);
            overlap_range.end = overlap_range.end.max(range.end);
        } else {
            new_ranges.push(range.clone());
        }
    }

    new_ranges
}
