fn calc(n: Int) -> Float64:
    return (1 + 1/n) ** n

fn main():
    let n = 10000
    for i in range(n):
        print(calc(i))