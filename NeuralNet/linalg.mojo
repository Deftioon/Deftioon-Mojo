from memory.unsafe import Pointer
from algorithm import vectorize
from algorithm import parallelize
alias type = DType.float64
alias nelts = simdwidthof[DType.float64]()

struct MathU:
    var e: Float64
    var pi: Float64

    fn __init__(inout self):
        self.e = 2.71828182845904523536028747135266249775724709369995
        self. pi = 3.14159265358979323846264338327950288419716939937510

struct Array[T: AnyRegType]:
    var ArrPointer: Pointer[T]
    var len: Int
    var capacity: Int

    fn __init__(inout self, default_value: T, capacity: Int = 10) -> None:
        self.len = capacity if capacity > 0 else 1
        self.capacity = self.len * 2
        self.ArrPointer = Pointer[T].alloc(self.capacity)
        for i in range(self.len):
            self[i] = default_value

    fn __getitem__(borrowed self, i: Int) -> T:
        if i >= self.len:
            print("getitem: IndexError: Out of Bounds")
            return self.ArrPointer.load(0) 
        return self.ArrPointer.load(i)

    fn __setitem__(inout self, loc: Int, item: T) -> None:
        if loc > self.capacity:
            print("setitem: IndexError: Out of Bounds")
            return
        if loc > self.len:
            let old_len = self.len
            self.len = loc + 1
            for i in range(old_len, self.len):
                self.ArrPointer.store(i, item)
            return
        self.ArrPointer.store(loc, item)

    fn pop(inout self) -> T:
        if self.len == 0:
            print("pop: IndexError: Pop from empty array")
            return self.ArrPointer.load(0)  # or handle error differently
        self.len -= 1
        return self.ArrPointer.load(self.len)
    
    fn delete(inout self, index: Int) -> None:
        for i in range(index, self.len-1):
            self[i] = self[i + 1]
        self.len -= 1

    fn load(inout self, input: VariadicList) -> None:
        if len(input) > self.len:
            print("load: IndexError: VariadicList is larger than User-defined Array Length")
            return
        for i in range(len(input)):
            self[i] = input[i]
            self.len = len(input)
    
    fn __del__(owned self) -> None:
        self.ArrPointer.free()

struct StackArray[T: AnyRegType]:
    var stack: Array[T]
    var top: Int

    fn __init__(inout self, default_value: T, capacity: Int = 10) -> None:
        self.stack = Array[T](default_value, capacity)
        self.top = -1

    fn len(borrowed self) -> Int:
        return self.top + 1

    fn push(inout self, item: T) -> None:
        self.top += 1
        self.stack[self.top] = item

    fn pop(inout self) -> T:
        if self.top == -1:
            print("pop: IndexError: Pop from empty stack")
            return self.stack.ArrPointer.load(0)  # or handle error differently
        self.top -= 1
        return self.stack[self.top + 1]

    fn peek(borrowed self) -> T:
        if self.top == -1:
            print("peek: IndexError: Peek from empty stack")
            return self.stack.ArrPointer.load(0)  # or handle error differently
        return self.stack[self.top]
    
    fn load(inout self, input: VariadicList) -> None:
        if len(input) > self.stack.len:
            print("load: IndexError: VariadicList is larger than User-defined Stack Length")
            return
        for i in range(len(input)):
            self.push(input[i])

struct QueueArray[T: AnyRegType]:
    var queue: Array[T]
    var front: Int
    var rear: Int

    fn __init__(inout self, default_value: T, capacity: Int = 10) -> None:
        self.queue = Array[T](default_value, capacity)
        self.front = -1
        self.rear = -1
    
    fn len(borrowed self) -> Int:
        return self.rear - self.front

    fn enqueue(inout self, item: T) -> None:
        self.rear += 1
        self.queue[self.rear] = item

    fn dequeue(inout self) -> T:
        if self.front == self.rear:
            print("dequeue: IndexError: Dequeue from empty queue")
            return self.queue.ArrPointer.load(0)  # or handle error differently
        self.front += 1
        return self.queue[self.front]

    fn peek(borrowed self) -> T:
        if self.front == self.rear:
            print("peek: IndexError: Peek from empty queue")
            return self.queue.ArrPointer.load(0)  # or handle error differently
        return self.queue[self.front]
    
    fn load(inout self, input: VariadicList) -> None:
        if len(input) > self.queue.len:
            print("load: IndexError: VariadicList is larger than User-defined Queue Length")
            return
        for i in range(len(input)):
            self.enqueue(input[i])

struct Broadcasting:
    var MathUnit: MathU
    fn __init__(inout self):
        self.MathUnit = MathU()

    fn Sigmoid(inout self, x: Matrix):
        for i in range(x.rows):
            for j in range(x.cols):
                x[i,j] = 1 / (1 + self.MathUnit.e ** (-x[i,j]))

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
    fn __init__(inout self, rows: Int, cols: Int, data: DTypePointer[DType.float64]):
        self.data = data
        self.rows = rows
        self.cols = cols
        self.shape = (rows, cols)

    fn __getitem__(self, y: Int, x: Int) -> Float64:
        return self.load[1](y, x)

    fn __setitem__(self, y: Int, x: Int, val: Float64):
        return self.store[1](y, x, val)

    fn load[nelts: Int](self, y: Int, x: Int) -> SIMD[DType.float64, nelts]:
        return self.data.simd_load[nelts](y * self.cols + x)

    fn store[nelts: Int](self, y: Int, x: Int, val: SIMD[DType.float64, nelts]):
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