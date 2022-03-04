extension VM{
    //move
    mutating func movir(num: Int, r1: Int){
        registers[r1] = num
    }
    mutating func movrr(r1: Int, r2: Int){
        registers[r2] = registers[r1]
    }
    mutating func movrm(r1: Int, label: Int){
        memory[label] = registers[r1]
    }
    mutating func movmr(label: Int, r1: Int){
        registers[r1] = memory[label]
    }
    mutating func movxr(r1: Int, r2: Int){
        registers[r2] = memory[registers[r1]]
    }
    mutating func movar(label: Int, r1: Int){
        registers[r1] = label
    }
    mutating func movb(r1: Int, r2: Int, r3: Int){
        var block = [Int]()
        for i in r1...r1+r2{
            block.append(memory[i])
        }
        var count = 0
        for j in r3...r3+r2{
            memory[j] = block[count]
            count += 1
        }
    }
    mutating func movrx(r1: Int, r2: Int){
        memory[registers[r2]] = registers[r1]
    }
    mutating func movxx(r1: Int, r2: Int){
        memory[registers[r2]] = memory[registers[r1]]
    }
    //add
    mutating func addir(num: Int, r1: Int){
        registers[r1] += num
    }
    mutating func addrr(r1: Int, r2: Int){
        registers[r2] += registers[r1]
    }
    mutating func addmr(label: Int, r1: Int){
        registers[r1] += memory[label]
    }
    mutating func addxr(r1: Int, r2: Int){
        registers[r2] += memory[registers[r1]]
    }
    //subtract
    mutating func subir(num: Int, r1: Int){
        registers[r1] -= num
    }
    mutating func subrr(r1: Int, r2: Int){
        registers[r2] -= registers[r1]
    }
    mutating func submr(label: Int, r1: Int){
        registers[r1] -= memory[label]
    }
    mutating func subxr(r1: Int, r2: Int){
        registers[r2] -= memory[registers[r1]]
    }
    //multiply
    mutating func mulir(num: Int, r1: Int){
        registers[r1] = registers[r1] * num
    }
    mutating func mulrr(r1: Int, r2: Int){
        registers[r2] = registers[r2] * registers[r1]
    }
    mutating func mulmr(label: Int, r1: Int){
        registers[r1] = registers[r1] * memory[label]
    }
    mutating func mulxr(r1: Int, r2: Int){
        registers[r2] = registers[r2] * memory[registers[r1]]
    }
    //divide
    mutating func divir(num: Int, r1: Int){
        registers[r1] = registers[r1]/num
    }
    mutating func divrr(r1: Int, r2: Int){
        registers[r2] = registers[r2]/registers[r1]
    }
    mutating func divmr(label: Int, r1: Int){
        registers[r1] = registers[r1]/memory[label]
    }
    mutating func divxr(r1: Int, r2: Int){
        registers[r2] = registers[r2]/memory[registers[r1]]
    }
    //sojz/aojz
    mutating func sojz(r1: Int, label: Int){
        registers[r1] -= 1
        if registers[r1] == 0{
            jmp(label: label)
        }
    }
    mutating func sojnz(r1: Int, label: Int){
        registers[r1] -= 1
        if registers[r1] != 0{
            jmp(label: label)
        }
    }
    mutating func aojz(r1: Int, label: Int){
        registers[r1] += 1
        if registers[r1] == 0{
            jmp(label: label)
        }
    }
    mutating func aojnz(r1: Int, label: Int){
        registers[r1] += 1
        if registers[r1] == 0{
            jmp(label: label)
        }
    }
    //out
    func outci(num: Int){
        print(unicodeValueToCharacter(num), terminator: "")
    }
    func outcr(r1: Int){
        print(unicodeValueToCharacter(registers[r1]), terminator: "")
    }
    func outcx(r1: Int){
        print(unicodeValueToCharacter(memory[registers[r1]]), terminator: "")
    }
    func outcb(r1: Int, r2: Int){
        var output = ""
        for i in r1...r1+r2{
            output += String(unicodeValueToCharacter(memory[i]))
        }
        print(output, terminator: "")
    }
    func printi(r1: Int){
        print(registers[r1], terminator: "")
    }
    func outs(label: Int){
        var outs = ""
        for i in label+1...memory[label]+label{
            outs += String(unicodeValueToCharacter(memory[i]))
        }
        print(outs, terminator: "")
    }
    //clear
        mutating func clrr(r1: Int) {
            registers[r1] = 0
        }
        mutating func clrx(r1: Int) {
            memory[registers[r1]] = 0
        }
    mutating func clrm(label: Int) {
            memory[label] = 0
        }
        mutating func clrb(r1: Int, r2: Int){
            for i in r1...r1+r2{
                memory[i] = 0
            }
        }
    //compare
    mutating func cmpir(num: Int, r1: Int) {
        compare = num - registers[r1]
    }
    mutating func cmprr(r1: Int, r2: Int) {
        compare = registers[r1] - registers[r2]
        //print("compare: \(compare)")
    }
    mutating func cmpmr(label: Int, r1: Int) {
        compare = registers[r1] - memory[label]
    }
    //jump
    mutating func jmpn(label: Int) {
        if compare < 0 {
            jmp(label: label)
        }
    }
    mutating func jmp(label: Int) {
            pointer = label-1
        }
    mutating func jmpz(label: Int) {
            if compare == 0 {
                jmp(label: label)
            }
        }
    mutating func jmpp(label: Int) {
            if compare > 0 {
                jmp(label: label)
            }
        }
    mutating func jmpne(label: Int){
        if compare != 0{
            jmp(label: label)
        }
    }
    //stack
    mutating func jsr(label: Int){
        for i in 0...4{
            push(r1: 9-i)
        }
        stack.push(element: pointer)
        jmp(label: label)
        //print(stack.elements)
        //print(registers[9])
    }
    mutating func ret(){
        pointer = stack.pop()!
        //print("pointer: \(pointer)")
        for i in 5...9{
            pop(r1: i)
        }
        
        //print(registers[9])
    }
    mutating func push(r1: Int){
        stack.push(element: registers[r1])
    }
    mutating func pop(r1: Int){
        registers[r1] = stack.pop()!
        //print("register \(r1): \(registers[r1])")
    }
    mutating func stackc(r1: Int){
        if stack.isFull(){
            registers[r1] = 1
        } else if stack.isEmpty(){
            registers[r1] = 2
        } else {
            registers[r1] = 0
        }
    }
    //extra methods
    mutating func getNextLine() -> Int{
        pointer += 1
        return memory[pointer]
    }
    func unicodeValueToCharacter(_ n: Int) -> Character{
        return Character(UnicodeScalar(n)!)
    }
    func splitStringIntoParts(_ expression: String)->[String] {
        return expression.components(separatedBy: " ")
    }
    mutating func readi(r1: Int?, r2: Int?) {
        let read = Swift.readLine()
        if let line = read {
            let input = splitStringIntoParts(line)
            guard input.count == 2 else {
                return
            }
            guard let int = Int(input[0]) else {
                return
            }
            registers[r1!] = int
            memory[r2!] = 0
            return
        }
        return
    }
    func characterToUnicodeValue(_ c: String)-> Int {
        let s = String(c)
        return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
    }
    mutating func readc(r1: Int?) {
        guard let line = Swift.readLine() else {
            return
        }
        registers[r1!] = characterToUnicodeValue(line)
    }
    mutating func readln(label:Int, r1: Int) {
        guard let line = Swift.readLine() else {
            return
        }
        let a = label
        registers[r1] = line.count
        for n in 0..<line.count {
            memory[a + n] = characterToUnicodeValue(line)
        }
    }
    func reg(){
        print("compare register: \(compare)")
    }
}
