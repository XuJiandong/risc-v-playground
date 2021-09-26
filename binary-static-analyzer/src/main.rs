use binary_static_analyzer::analyze;
use env_logger;
use std::io;

fn main() {
    env_logger::init();

    let stdin = io::stdin();
    analyze(stdin.lock());
}
