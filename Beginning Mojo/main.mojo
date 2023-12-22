from memory.unsafe import Pointer

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
            print("IndexError: Out of Bounds")
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

    fn __del__(owned self) -> None:
        self.ArrPointer.free()

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
            print("IndexError: VariadicList is larger than User-defined Array Length")
            return
        for i in range(len(input)):
            self[i] = input[i]
            self.len = len(input)

fn main():
    var loadList: VariadicList[Int] = VariadicList[Int](1,2,3,4,5)
    var myList: Array[Int] = Array[Int](0, 10)
    myList.load(loadList)
    myList.delete(2)
    for i in range(myList.len):
        print(myList[i])
