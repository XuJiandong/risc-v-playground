use log::debug;
use regex::Regex;
use std::io::BufRead;

pub fn analyze<R: BufRead>(reader: R) {
    // 000000000001140a <ckb_debug>:
    let func = Regex::new(r"^\s*(\w+)\s+<(.+)>").unwrap();
    //    1143a:	8082                	ret
    let inst = Regex::new(r"^\s*(\w+):\s+").unwrap();
    let mut results: Vec<(String, u64)> = Default::default();
    let mut last_addr: Option<u64> = None;
    let mut last_func_name: Option<String> = None;
    let mut last_func_addr: Option<u64> = None;

    for line in reader.lines() {
        let line = line.unwrap();
        if let Some(func_match) = func.captures(&line) {
            let addr = u64::from_str_radix(&func_match[1], 16).unwrap();
            let name = &func_match[2];
            if last_func_addr.is_some() && last_func_name.is_some() {
                let size = last_addr.unwrap() - last_func_addr.unwrap();
                results.push((last_func_name.unwrap(), size));
            }
            last_func_name = Some(String::from(name));
            last_func_addr = Some(addr);
            debug!("addr = {}, name = {}", addr, name);
        }
        if let Some(inst_match) = inst.captures(&line) {
            let addr = u64::from_str_radix(&inst_match[1], 16).unwrap();
            last_addr = Some(addr);
            debug!("addr = {}", addr);
        }
    }
    results.sort_by(|(_, size1), (_, size2)| size2.cmp(size1));
    let top = 10;
    let mut index = 0;
    let mut total_size = 0;
    for (name, size) in results {
        if index < top {
            println!("name = {}, size = {}", name, size);
        }
        total_size += size;
        index += 1;
    }
    println!("-------------");
    println!("total size is {}", total_size);
}
