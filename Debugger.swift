extension VM{
    mutating func runDebugger(){
        var input: [String]
        repeat {
            print("Pdb (\(pointer),\(memory[pointer]))> ", terminator: "")
            input = splitStringIntoParts(Swift.readLine()!)
            switch input[0]{
            case "setbk":
                if checkNumParameters(input, 1){
                    setbk(input[1])
                }
            case "rmbk":
                if checkNumParameters(input, 1){
                    rmbk(input[1])
                }
            case "clrbk":
                breakPoints.removeAll()
            case "disbk":
                useBks = false
            case "enbk":
                useBks = true
            case "preg":
                preg()
            case "wreg":
                if checkNumParameters(input, 2){
                    wreg(input)
                }
            case "wpc":
                if checkNumParameters(input, 1){
                    wpc(input[1])
                }
            case "pmem":
                if checkNumParameters(input, 2){
                    pmem(input)
                }
            case "wmem":
                if checkNumParameters(input, 2){
                    wmem(input)
                }
            case "pst":
                pst()
            case "g":
                runG()
            case "s":
                runS()
            case "pbk":
                pbk()
            case "help":
                help()
            case "deas":
                if checkNumParameters(input, 2){
                    deas(input)
                }
            case "exit":
                break
            default:
                print("\(input[0]) is not a valid command")
            }
        } while input[0] != "exit" && pointer < memory.count
    }
    
    func checkNumParameters(_ line: [String], _ amountArgs: Int) -> Bool{
        if line.count-1 != amountArgs{
            print("Incorrect number of parameters")
            return false
        }
        return true
    }
    
    mutating func setbk(_ location: String){
        if let loc = handleAddress(location){
            if loc < memory.count{
                breakPoints.insert(loc)
                print("breakpoints: \(breakPoints)")
            }
        }
    }
    
    mutating func rmbk(_ location: String){
        if let loc = handleAddress(location){
            breakPoints.remove(loc)
        }
    }
    
    func preg(){
        print("registers: ")
        for i in 0...9{
            print("  r\(i): \(registers[i])")
        }
        print("PC: \(pointer)")
    }
    
    mutating func wreg(_ line: [String]){
        if let regNum = Int(line[1]), let newValue = Int(line[2]){
            registers[regNum] = newValue
        } else {
            print("Incorrect type of parameters")
        }
    }
    
    mutating func wpc(_ input: String){
        if let newValue = Int(input){
            pointer = newValue
        }
    }
    
    mutating func pmem(_ line: [String]){
        if let startAddress = handleAddress(line[1]), let endAddress = handleAddress(line[2]){
            print("Memory dump:")
            for i in startAddress..<endAddress{
                print("  \(i):  \(memory[i])")
            }
        }
    }
    
    mutating func wmem(_ line: [String]){
        if let loc = handleAddress(line[1]), let newValue = Int(line[2]){
            memory[loc] = newValue
        }
    }
    
    func pst(){
        print("Symbol Table:")
        for (label, loc) in symbolTable{
            print("\(label): \(loc)")
        }
    }
    
    func pbk(){
        print("Breakpoints:")
        for loc in breakPoints{
            var output = "\(loc)"
            if let sym = reverseST[loc]{
                output += "  (\(sym))"
            }
            print(output)
        }
    }
    
    func deas(_ line: [String]){
        if let startAddress = handleAddress(line[1]), let endAddress = handleAddress(line[2]){
            var output = "Disassembly:\n"
            var deasPointer = startAddress
            while deasPointer < endAddress+1 && deasInstructions[memory[deasPointer]] != nil{
                if let label = reverseST[deasPointer]{
                    output += "\(label): "
                }
                let instruction = deasInstructions[memory[deasPointer]]!
                output += instruction.name
                deasPointer += 1
                for param in instruction.Param{
                    switch param{
                    case "i":
                        output += " #\(memory[deasPointer])"
                    case "r":
                        output += " r\(memory[deasPointer])"
                    case "l":
                        if let label = reverseST[memory[deasPointer]]{
                            output += " \(label)"
                        } else {
                            print("label not found at \(memory[deasPointer])")
                        }
                    default:
                        break
                    }
                    deasPointer += 1
                }
                output += "\n"
            }
            print(output)
        }
    }
    
    func help(){
        print("\nDebugger Commands:")
        print("Note: <address can be numeric or symbolic>")
        print("  setbk <address> - set breakpoints at <address>")
        print("  rmbk <address> - remove breakpoint at <address>")
        print("  clrbk - clear all breakpoints")
        print("  disbk - temporarily disable all breakpoints")
        print("  enbk - enable breakpoints")
        print("  pbk - print breakpoint table")
        print("  preg - print the registers")
        print("  wreg <number> <value> - write value of register <number> to <value>")
        print("  wpc <value> - change value of PC to <value>")
        print("  pmem <start address> <end address> - print memory locations\n      from <start address> ending just before <end address>")
        print("  deas <start address> <end address> - deassamble memory locations\n      from <start address> ending just before <end address>")
        print("  wmem <address> <value> - change value of memory at <address> to <value>")
        print("  pst - print symbol table")
        print("  g - continue program execution")
        print("  s - singleStep")
        print("  exit - terminate virtual machine")
        print("  help - print this help table")
    }
    
    func handleAddress(_ address: String) -> Int?{
        if let loc = Int(address){
            if loc < memory.count{
                return loc
            }
        } else if let loc = symbolTable[address]{
            return loc
        }
        print("\(address) is not a valid address")
        return nil
    }
}
