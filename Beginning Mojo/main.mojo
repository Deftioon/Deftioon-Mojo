import benchmark
fn fib(n: Int) -> Int:
    if n <= 2:
        return 1
    else:
        return fib(n-1) + fib(n-2)


fn test():
    print(fib(20))

fn main():
    let report = benchmark.run[test]()
    report.print()
    