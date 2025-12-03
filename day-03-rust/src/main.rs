use input_curler::input_for;

const SAMPLE: &str = "987654321111111
811111111111119
234234234234278
818181911112111";

fn main() {
    let data = input_for(3).unwrap();

    let sample_one = part_one(SAMPLE);
    println!("Sample one: {}", sample_one);
    let answer_one = part_one(data.as_str());
    println!("Answer one: {}", answer_one);

    let sample_two = part_two(SAMPLE, 12);
    println!("Sample two: {}", sample_two);
    let answer_two = part_two(data.as_str(), 12);
    println!("Answer two: {}", answer_two);
}

fn part_one(data: &str) -> u32 {
    data.lines()
        .map(|line| {
            let len = line.len();
            let (max_ix, max) = line[0..len - 1]
                .char_indices()
                .max_by_key(|(ix, v)| (*v, -(*ix as i32)))
                .unwrap();

            let later_max = line.chars().skip(max_ix + 1).max().unwrap();

            max.to_digit(10).unwrap() * 10 + later_max.to_digit(10).unwrap()
        })
        .sum()
}

fn part_two(data: &str, battery_count: usize) -> u64 {
    data.lines()
        .map(|mut line| {
            (0..battery_count)
                .map(|digit| {
                    let len = line.len();
                    let (max_ix, max) = line[0..len + digit + 1 - battery_count]
                        .char_indices()
                        .max_by_key(|(ix, v)| (*v, -(*ix as i32)))
                        .unwrap();

                    line = &line[max_ix + 1..];
                    max
                })
                .collect::<String>()
                .parse::<u64>()
                .unwrap()
        })
        .sum()
}
