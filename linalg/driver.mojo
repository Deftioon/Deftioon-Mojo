import matrix

fn main():
    let m: matrix.Matrix = matrix.Matrix(10, 10)
    for i in range(m.rows):
        for j in range(m.cols):
            m[i,j] = i * j
    m.print()