#[test_only]
module commander::commander_tests;

// uncomment this line to import the module
// use commander::commander;

const ENotImplemented: u64 = 0;

#[test]
fun test_commander() {}

#[test, expected_failure(abort_code = ::commander::commander_tests::ENotImplemented)]
fun test_commander_fail() {
    abort ENotImplemented
}
