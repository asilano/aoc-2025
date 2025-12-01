use curl::easy::Easy;
use std::env::{self, VarError};

pub fn input_for(day: u8) -> Result<String, VarError> {
    let mut curler = Easy::new();
    curler
       .url(format!("https://adventofcode.com/2025/day/{}/input", day).as_str())
        .unwrap();
    let mut session_str = "session=".to_string();
    session_str.push_str(env::var("AOC_SESSION")?.as_str());
    curler.cookie(session_str.as_str()).unwrap();

    let mut result = "".to_string();
    {
        let mut transfer = curler.transfer();
        transfer
            .write_function(|data| {
                let len = data.len();
                result.push_str(String::from_utf8(data.to_vec()).unwrap().as_str());
                Ok(len)
            })
            .unwrap();
        transfer.perform().unwrap();
    }

    Ok(result)
}
