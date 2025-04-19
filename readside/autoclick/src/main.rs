use core::time::Duration;
use std::thread;

use mouse_rs::{types::keys::Keys, Mouse};

fn main() {
    let mouse = Mouse::new();

    loop {
        thread::sleep(Duration::from_secs(1));
        mouse.click(&Keys::LEFT).unwrap();
    }
}
