use std::collections::HashMap;

use input_curler::input_for;

const SAMPLE: &str = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out";

const SAMPLE_TWO: &str = "svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out";

fn main() {
    let data = input_for(11).unwrap();

    let sample_one = part_one(SAMPLE);
    println!("Sample one: {}", sample_one);
    let answer_one = part_one(data.as_str());
    println!("Answer one: {}", answer_one);

    let sample_two = part_two(SAMPLE_TWO);
    println!("Sample two: {}", sample_two);
    let answer_two = part_two(data.as_str());
    println!("Answer two: {}", answer_two);
}

type NetMap = HashMap<String, Vec<String>>;
fn part_one(data: &str) -> usize {
    let netmap = parse(data);
    let mut route_counts: HashMap<_, _> = HashMap::from([("you".to_string(), 1)]);

    ways_to_reach(&"out".to_string(), &netmap, &mut route_counts)
}

type RouteCountsVia = HashMap<(bool, bool), usize>;
fn zero_routes_via() -> RouteCountsVia {
    RouteCountsVia::from([
        ((false, false), 0),
        ((false, true), 0),
        ((true, false), 0),
        ((true, true), 0),
    ])
}
fn part_two(data: &str) -> usize {
    let netmap = parse(data);
    let start_route_count = HashMap::from([
        ((false, false), 1),
        ((false, true), 0),
        ((true, false), 0),
        ((true, true), 0),
    ]);
    let mut route_counts: HashMap<_, _> = HashMap::from([("svr".to_string(), start_route_count)]);

    *ways_to_reach_via_dac_fft(&"out".to_string(), &netmap, &mut route_counts)
        .get(&(true, true))
        .unwrap()
}

fn ways_to_reach(
    node: &String,
    netmap: &NetMap,
    route_counts: &mut HashMap<String, usize>,
) -> usize {
    if let Some(ways) = route_counts.get(node) {
        return *ways;
    }

    if netmap.get(node) == None {
        return 0;
    }

    let sources = netmap.get(node).unwrap();
    let ways = {
        sources.iter().fold(0, |acc, source| {
            let new_ways = ways_to_reach(source, netmap, route_counts);
            acc + new_ways
        })
    };
    route_counts.insert(node.to_string(), ways);
    ways
}

fn ways_to_reach_via_dac_fft(
    node: &String,
    netmap: &NetMap,
    route_counts: &mut HashMap<String, RouteCountsVia>,
) -> RouteCountsVia {
    if let Some(ways) = route_counts.get(node) {
        return ways.clone();
    }

    if !netmap.contains_key(node) {
        return zero_routes_via();
    }

    let sources = netmap.get(node).unwrap();
    let via_ways = {
        let zeroes = zero_routes_via();
        sources.iter().fold(zeroes, |mut acc, source| {
            let new_ways = ways_to_reach_via_dac_fft(source, netmap, route_counts);

            for (truths, ways) in acc.iter_mut() {
                *ways += new_ways.get(truths).unwrap();
            }

            if node == "dac" {
                let old = *acc.get(&(false, false)).unwrap();
                *acc.get_mut(&(true, false)).unwrap() += old;
                let old = *acc.get(&(false, true)).unwrap();
                *acc.get_mut(&(true, true)).unwrap() += old;
                *acc.get_mut(&(false, false)).unwrap() = 0;
                *acc.get_mut(&(false, true)).unwrap() = 0;
            } else if node == "fft" {
                let old = *acc.get(&(false, false)).unwrap();
                *acc.get_mut(&(false, true)).unwrap() += old;
                let old = *acc.get(&(true, false)).unwrap();
                *acc.get_mut(&(true, true)).unwrap() += old;
                *acc.get_mut(&(false, false)).unwrap() = 0;
                *acc.get_mut(&(true, false)).unwrap() = 0;
            }
            acc
        })
    };
    route_counts.insert(node.to_string(), via_ways.clone());
    via_ways
}

fn parse(data: &str) -> NetMap {
    data.lines().fold(HashMap::new(), |mut builder, line| {
        let (source, rest) = line.split_once(": ").unwrap();

        for dest in rest.split_ascii_whitespace() {
            builder
                .entry(dest.to_string())
                .and_modify(|s| s.push(source.to_string()))
                .or_insert(vec![source.to_string()]);
        }

        builder
    })
}
