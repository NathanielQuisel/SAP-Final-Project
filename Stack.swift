struct StackIterator<T>: IteratorProtocol {
    let values: [T]
    var index: Int?
    
    
    init(_ values: [T]) {
        self.values = values
    }
    
    mutating func next() -> T? {
        if index == nil{
            index = values.count-1
            return values[index!]
        }
        if index! > 0{
            self.index! -= 1
            return values[index!]
        } else {
            return nil
        }
    }
}
 
struct Stack<T: Comparable> : CustomStringConvertible, Sequence{
    var elements: [T]
    var pointer = 0
    var empty: T
    init(size: Int, initial: T){
        var holder = [T]()
        holder.reserveCapacity(size)
        for i in 0..<size{
            holder.insert(initial, at: i)
        }
        elements = holder
        self.empty = initial
    }
    func isEmpty()-> Bool{
        if pointer == 0{
            return true
        }
        return false
    }
    func isFull()-> Bool{
        if pointer == elements.count{
            return true
        }
        return false
    }
    mutating func push(element: T){
        if !isFull(){
            elements[pointer] = element
            pointer += 1
        }
    }
    mutating func pop()-> T?{
        if !isEmpty(){
            pointer -= 1
            let holder = elements[pointer]
            elements[pointer] = empty
            return holder
        }
        return nil
    }
    var description: String{
        var stringStack = ""
        for i in 0..<elements.count{
            if !(elements[i] == empty){
                stringStack += "\(elements[i]) "
            }
        }
        stringStack += "T"
        return (stringStack)
    }
    
    func makeIterator() -> StackIterator<T>{
        return StackIterator<T>(elements)
    }
}
