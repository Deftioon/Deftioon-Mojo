from linalg import Matrix
from linalg import Broadcasting
import random

fn main() raises:
    var Broadcaster: Broadcasting = Broadcasting()
    var res: Matrix = Matrix(2, 2)
    for i in range(2):
        for j in range(2):
            res[i, j] = random.random_float64(0, 1)
    res.print()

    Broadcaster.Sigmoid(res)
    res.print()