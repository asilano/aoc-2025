use std::{cmp::max, cmp::min};

use input_curler::input_for;
use itertools::{Itertools, MinMaxResult};

#[derive(Debug)]
struct Point {
    x: u64,
    y: u64,
}
impl From<&str> for Point {
    fn from(value: &str) -> Self {
        let (xs, ys) = value.split_once(",").unwrap();
        Point {
            x: xs.parse().unwrap(),
            y: ys.parse().unwrap(),
        }
    }
}

const SAMPLE: &str = "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3";

fn main() {
    let sample_points = parse_data(SAMPLE);

    let data = input_for(9).unwrap();
    let data_points = parse_data(data.as_str());

    let sample_one = part_one(&sample_points);
    println!("Sample one: {}", sample_one);
    let answer_one = part_one(&data_points);
    println!("Answer one: {}", answer_one);

    let sample_two = part_two(&sample_points);
    println!("Sample two: {}", sample_two);
    let answer_two = part_two(&data_points);
    println!("Answer two: {}", answer_two);
}

fn parse_data(data: &str) -> Vec<Point> {
    data.lines().map(Point::from).collect()
}

type Extent = (u64, u64);
type DirectionLines = Vec<(u64, Extent)>;
fn green_edges(points: &[Point]) -> (DirectionLines, DirectionLines) {
    let mut verts = DirectionLines::new();
    let mut horizs = DirectionLines::new();

    for (a, b) in points.iter().circular_tuple_windows() {
        if a.x == b.x {
            verts.push((a.x, (a.y, b.y)));
        } else {
            horizs.push((a.y, (a.x, b.x)));
        }
    }

    (verts, horizs)
}

fn part_one(points: &[Point]) -> u64 {
    points
        .iter()
        .cartesian_product(points.iter())
        .map(|(a, b)| (a.x.abs_diff(b.x) + 1) * (a.y.abs_diff(b.y) + 1))
        .max()
        .unwrap()
}

fn part_two(points: &[Point]) -> u64 {
    let edges = green_edges(points);
    let filtered_rects = points
        .iter()
        .cartesian_product(points.iter())
        // Filter by bottom-right point inside the big poly, plus no lines of big poly inside rectangle; unless there's another line right next to it for the same extent
        .filter(|(a, b)| {
            let bottom_right = Point {
                x: max(a.x, b.x),
                y: max(a.y, b.y),
            };
            bottom_right_inside(&bottom_right, &edges.0)
        })
        .filter(|(a, b)| !edges_in_rectangle((a, b), &edges))
        .collect::<Vec<(&Point, &Point)>>();
    filtered_rects
        .iter()
        .map(|(a, b)| (a.x.abs_diff(b.x) + 1) * (a.y.abs_diff(b.y) + 1))
        .max()
        .unwrap()
}

fn bottom_right_inside(bottom_right: &Point, verticals: &DirectionLines) -> bool {
    let crossings = verticals
        .iter()
        .filter(|&(x, _)| *x >= bottom_right.x)
        .filter(|(_, (start, end))| {
            (start < &bottom_right.y && &bottom_right.y <= end)
                || (end < &bottom_right.y && &bottom_right.y <= start)
        })
        .count();
    crossings % 2 == 1
}

fn edges_in_rectangle(corners: (&Point, &Point), edges: &(DirectionLines, DirectionLines)) -> bool {
    let (verticals, horizontals) = edges;
    let left = min(corners.0.x, corners.1.x);
    let right = max(corners.0.x, corners.1.x);
    let top = min(corners.0.y, corners.1.y);
    let bottom = max(corners.0.y, corners.1.y);

    let vert_crossings = verticals.iter().filter(|(x, (start_y, end_y))| {
        *x > left && *x < right && min(*start_y, *end_y) < bottom && max(*start_y, *end_y) > top
    });
    let horiz_crossings = horizontals.iter().filter(|(y, (start_x, end_x))| {
        *y > top && *y < bottom && min(*start_x, *end_x) < right && max(*start_x, *end_x) > left
    });

    vert_crossings.count() > 0 || horiz_crossings.count() > 0
}
