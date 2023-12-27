import matrix

fn main():
    var m: matrix.Matrix = matrix.Matrix(3, 3)
    for i in range(3):
        for j in range(3):
            m[i,j] = i * j
    for i in range(3):
        for j in range(3):
            print(m[i,j])