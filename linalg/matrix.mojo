from algorithm import vectorize
from algorithm import parallelize
alias type = DType.float32

# adapted from https://docs.modular.com/mojo/notebooks/Matmul.html

struct Matrix:
    var data: DTypePointer[type]
    var rows: Int
    var cols: Int
    var shape: (Int,Int)

    # Initialize zeroeing all values
    fn __init__(inout self, rows: Int, cols: Int):
        self.data = DTypePointer[type].alloc(rows * cols)
        memset_zero(self.data, rows * cols)
        self.rows = rows
        self.cols = cols
        self.shape = (rows, cols)

    # Initialize taking a pointer, don't set any elements
    fn __init__(inout self, rows: Int, cols: Int, data: DTypePointer[DType.float32]):
        self.data = data
        self.rows = rows
        self.cols = cols
        self.shape = (rows, cols)

    fn __getitem__(self, y: Int, x: Int) -> Float32:
        return self.load[1](y, x)

    fn __setitem__(self, y: Int, x: Int, val: Float32):
        return self.store[1](y, x, val)

    fn load[nelts: Int](self, y: Int, x: Int) -> SIMD[DType.float32, nelts]:
        return self.data.simd_load[nelts](y * self.cols + x)

    fn store[nelts: Int](self, y: Int, x: Int, val: SIMD[DType.float32, nelts]):
        return self.data.simd_store[nelts](y * self.cols + x, val)
    
    fn print(self):
        print_no_newline("[")
        for y in range(self.rows):
            if y != 0:
                print_no_newline(" ")
            for x in range(self.cols):
                print_no_newline(String(self[y, x]))
                if x != self.cols - 1:
                    print_no_newline(", ")
            if y != self.rows - 1:
                print()
        print("]")
    # Parallelize the code by using the builtin parallelize function
    fn matmul_parallelized(C: Matrix, A: Matrix, B: Matrix) raises -> None:
        if A.cols != B.rows:
            raise ("Error: Shape Mismatch: " + String(A.cols) + " does not match" + String(B.rows))
        else:
            alias nelts = simdwidthof[DType.float32]()
            @parameter
            fn calc_row(m: Int):
                for k in range(A.cols):
                    @parameter
                    fn dot[nelts : Int](n : Int):
                        C.store[nelts](m,n, C.load[nelts](m,n) + A[m,k] * B.load[nelts](k,n))
                    vectorize[nelts, dot](C.cols)
            parallelize[calc_row](C.rows, C.rows)
        
    fn __del__(owned self):
        self.data.free()