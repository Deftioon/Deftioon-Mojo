from linalg import Matrix

fn main() raises:
    let m: Matrix = Matrix(3, 3)
    for i in range(m.rows):
        for j in range(m.cols):
            m[i,j] = i + j 
    let n: Matrix = Matrix(3, 3)
    for i in range(n.rows):
        for j in range(n.cols):
            n[i,j] = i // j + i % j
    let res: Matrix = Matrix(3,3)

    Matrix.matmul_parallelized(res, m, n)
    m.print()
    n.print()
    res.print()