struct VM{
    var registers = [Int]()
    var memory = [Int]()
    var stack: Stack<Int>
    var pointer: Int
    var breakPoints = Set<Int>()
    var compare = 0
    var symbolTable = [String: Int]()
    var reverseST = [Int: String]()
    var useBks = true
    var deasInstructions = [Int: (name: String, Param: String)]()
    init(memoryLength: Int, memory: [Int], symbolTable: [String: Int]){
        registers.reserveCapacity(10)
        self.memory.reserveCapacity(memoryLength+1)
        registers = Array(repeating: 0, count: 10)
        self.memory = memory
        stack = Stack<Int>(size: 500, initial: -1)
        pointer = memory[0]
        self.symbolTable = symbolTable
        for (sym, loc) in symbolTable{
            reverseST[loc] = sym
        }
        for (key, value) in instructions{
            deasInstructions[value.code.rawValue] = (name: key, Param: value.Param)
        }
    }
    mutating func runG(){
        runS()
        while pointer < memory.count && (!breakPoints.contains(pointer) || !useBks){
            //print("PC: \(pointer)")
            runS()
        }
    }
    mutating func runS(){
        readLine(command: memory[pointer])
        pointer += 1
    }
    mutating func readLine(command: Int){
        var line = SymbolTable(rawValue: command)
        //print(line!)
        switch line{
        case .clrr:
            clrr(r1: getNextLine())
        case .clrx:
            clrx(r1: getNextLine())
        case .clrm:
            clrm(label: getNextLine())
        case .clrb:
            clrb(r1: getNextLine(), r2: getNextLine())
        case .movir:
            movir(num: getNextLine(), r1: getNextLine())
        case .movrr:
            movrr(r1: getNextLine(), r2: getNextLine())
        case .movrm:
            movrm(r1: getNextLine(), label: getNextLine())
        case .movmr:
            movmr(label: getNextLine(), r1: getNextLine())
        case .movxr:
            movxr(r1: getNextLine(), r2: getNextLine())
        case .movar:
            movar(label: getNextLine(), r1: getNextLine())
        case .movb:
            movb(r1: getNextLine(), r2: getNextLine(), r3: getNextLine())
        case .addir:
            addir(num: getNextLine(), r1: getNextLine())
        case .addrr:
            addrr(r1: getNextLine(), r2: getNextLine())
        case .addmr:
            addmr(label: getNextLine(), r1: getNextLine())
        case .addxr:
            addxr(r1: getNextLine(), r2: getNextLine())
        case .subir:
            subir(num: getNextLine(), r1: getNextLine())
        case .subrr:
            subrr(r1: getNextLine(), r2: getNextLine())
        case .submr:
            submr(label: getNextLine(), r1: getNextLine())
        case .subxr:
            subxr(r1: getNextLine(), r2: getNextLine())
        case .mulir:
            mulir(num: getNextLine(), r1: getNextLine())
        case .mulrr:
            mulrr(r1: getNextLine(), r2: getNextLine())
        case .mulmr:
            mulmr(label: getNextLine(), r1: getNextLine())
        case .mulxr:
            mulxr(r1: getNextLine(), r2: getNextLine())
        case .divir:
            divir(num: getNextLine(), r1: getNextLine())
        case .divrr:
            divrr(r1: getNextLine(), r2: getNextLine())
        case .divmr:
            divmr(label: getNextLine(), r1: getNextLine())
        case .divxr:
            divxr(r1: getNextLine(), r2: getNextLine())
        case .jmp:
            jmp(label: getNextLine())
        case .sojz:
            sojz(r1: getNextLine(), label: getNextLine())
        case .sojnz:
            sojnz(r1: getNextLine(), label: getNextLine())
        case .aojz:
            aojz(r1: getNextLine(), label: getNextLine())
        case .aojnz:
            aojnz(r1: getNextLine(), label: getNextLine())
        case .cmpir:
            cmpir(num: getNextLine(), r1: getNextLine())
        case .cmprr:
            cmprr(r1: getNextLine(), r2: getNextLine())
        case .cmpmr:
            cmpmr(label: getNextLine(), r1: getNextLine())
        case .jmpn:
            jmpn(label: getNextLine())
        case .jmpz:
            jmpz(label: getNextLine())
        case .jmpp:
            jmpp(label: getNextLine())
        case .jsr:
            jsr(label: getNextLine())
        case .ret:
            ret()
        case .push:
            push(r1: getNextLine())
        case .pop:
            pop(r1: getNextLine())
        case .stackc:
            stackc(r1: getNextLine())
        case .outci:
            outci(num: getNextLine())
        case .outcr:
            outcr(r1: getNextLine())
        case .outcx:
            outcx(r1: getNextLine())
        case .outcb:
            outcb(r1: getNextLine(), r2: getNextLine())
        case .readi:
            readi(r1: getNextLine(), r2: getNextLine())
        case .printi:
            printi(r1: getNextLine())
        case .readc:
            readc(r1: getNextLine())
        case .readln:
            readln(label: getNextLine(), r1: getNextLine())
        case .brk:
            break
        case .movrx:
            movrx(r1: getNextLine(), r2: getNextLine())
        case .movxx:
            movxx(r1: getNextLine(), r2: getNextLine())
        case .outs:
            outs(label: getNextLine())
        case .nop:
            break
        case .jmpne:
            jmpne(label: getNextLine())
        case .reg:
            reg()
        default:
            break
        }
    }
}
