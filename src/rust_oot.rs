//! Sample Rust Linux Out-of-tree kernel module
use kernel::prelude::*;

module! {
    type: RustOot,
    name: "rust_oot",
    author: "0xor0ne",
    description: "Rust out-of-tree sample",
    license: "GPL",
}

struct RustOot {
    numbers: Vec<i32>,
}

impl kernel::Module for RustOot {
    fn init(_module: &'static ThisModule) -> Result<Self> {
        pr_info!("Rust OOT sample (init)\n");

        let mut numbers = Vec::new();
        numbers.try_push(72)?;
        numbers.try_push(108)?;
        numbers.try_push(200)?;

        Ok(RustOot { numbers })
    }
}

impl Drop for RustOot {
    fn drop(&mut self) {
        pr_info!("Rust OOT: numbers {:?}\n", self.numbers);
        pr_info!("Rust OOT sample (exit)\n");
    }
}
