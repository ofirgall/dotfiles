#[cfg(test)]
mod tests {
    use rust_macros::make_answer;
    make_answer!();

    #[test]
    fn it_works() {
        assert_eq!(answer(), 42);
    }
}
