struct TwoPassAssembler{
    var errorLst = ""
    var successLst = "0:\n"
    var symFile = ""
    var memory = [Int]()
    var pointer = 0
    var symbolTable = [String : Int]()
    var labelsUsed = [String]()
    var file: String
    var errorMessage: String? = nil
    var numErrors = 0
    init(file: String = ""){
        self.file = file
        memory = [Int]()
    }
    
    mutating func run() -> Bool{
        if runPass(){
            runPass(true)
            print("Assembler was successful.")
            return true
        } else {
            print("Assembly found \(numErrors) errors")
            print("No binary file written")
            print("See .lst file for errors")
            return false
        }
    }
    
    mutating func runPass(_ isSecondPass: Bool = false) -> Bool{
        if isSecondPass{
            memory = [Int]()
            makeSymFile()
        }
        var NoErrors = true
        let lines = splitStringIntoLines(expression: file)
        for line in lines{
            let MemoryCount = memory.count
            let chunks = Chunker.makeChunks(line: Array(line))
            let tokens = Tokenizer.makeTokens(chunks: chunks)
            if tokens.count > 0{
                switch tokens[0].type{
                case .Instruction:
                    NoErrors = handleInstruction(tokens, isSecondPass)
                case .Directive:
                    NoErrors = handleDirective(tokens, isSecondPass)
                case .LabelDefinition:
                    NoErrors = handleLabelDef(tokens, isSecondPass)
                default:
                    EMNotLegalLine()
                    NoErrors = false
                }
                if !(tokens[0].type == .Directive && tokens[0].stringValue! == "end") && isSecondPass{
                    var finalLoc: Int
                    if memory.count-MemoryCount > 3{
                        finalLoc = MemoryCount+3
                    } else{
                        finalLoc = memory.count-1
                    }
                    addSuccessLst(line, MemoryCount, finalLoc)
                }
            }
            addErrorLst(line, errorMessage)
        }
        if isSecondPass{
            successLst += symFile
        }
        if !checkLabels(){
            NoErrors = false
        }
        return NoErrors
    }
    mutating func addSuccessLst(_ line: String, _ startingLoc: Int, _ finalLoc: Int){
        var header = ""
        header += "\(startingLoc): "
        for i in startingLoc...finalLoc{
            header += "\(memory[i]) "
        }
        header = fit(header, 22)
        successLst += "\(header)\(line)\n"
    }
    mutating func handleInstruction(_ tokens: [Token], _ isSecondPass: Bool) -> Bool{
        memory.append(instructions[tokens[0].stringValue!]!.code.rawValue)
        if tokens.count-1 == instructions[tokens[0].stringValue!]!.Param.count{
            let parameters = Array(instructions[tokens[0].stringValue!]!.Param)
            for i in 1..<tokens.count{
                switch parameters[i-1]{
                case "i":
                    if tokens[i].type == .ImmediateInteger{
                        memory.append(tokens[i].intValue!)
                    } else {
                        EMWrongParameters(tokens[0].stringValue!)
                        return false
                    }
                case "r":
                    if tokens[i].type == .Register{
                        memory.append(tokens[i].intValue!)
                    } else {
                        EMWrongParameters(tokens[0].stringValue!)
                        return false
                    }
                case "l":
                    if tokens[i].type == .Label{
                        handleLabel(tokens[i].stringValue!, isSecondPass)
                    } else {
                        EMWrongParameters(tokens[0].stringValue!)
                        return false
                    }
                default:
                    print("something went very wrong")
                }
            }
        } else {
            setErrorMessage("Illegal parameters for instruction \(tokens[0].stringValue!)")
            return false
        }
        return true
    }
    mutating func handleDirective(_ tokens: [Token], _ isSecondPass: Bool) -> Bool{
        switch tokens[0].stringValue!{
        case "start":
            if correctParamCountD(tokens[0].stringValue!, tokens.count-1){
                if tokens[1].type == .Label{
                    handleLabel(tokens[1].stringValue!, isSecondPass)
                } else {
                    EMWrongParameters(tokens[0].stringValue!)
                    return false
                }
            }
        case "end":
            return true
        case "integer":
            if correctParamCountD(tokens[0].stringValue!, tokens.count-1){
                if tokens[1].type == .ImmediateInteger{
                    memory.append(tokens[1].intValue!)
                } else {
                    EMWrongParameters(tokens[0].stringValue!)
                    return false
                }
            }
        case "allocate":
            if correctParamCountD(tokens[0].stringValue!, tokens.count-1){
                if tokens[1].type == .ImmediateInteger{
                    for _ in 0..<tokens[1].intValue!{
                        memory.append(0)
                    }
                } else {
                    EMWrongParameters(tokens[0].stringValue!)
                    return false
                }
            }
        case "string":
            if correctParamCountD(tokens[0].stringValue!, tokens.count-1){
                if tokens[1].type == .ImmediateString{
                    memory.append(tokens[1].stringValue!.count)
                    let chars = Array(tokens[1].stringValue!)
                    for char in chars {
                        memory.append(charToAscii(c: char))
                    }
                } else {
                    EMWrongParameters(tokens[0].stringValue!)
                    return false
                }
            }
        case "tuple":
            if correctParamCountD(tokens[0].stringValue!, tokens.count-1){
                if tokens[1].type == .ImmediateTuple{
                    let tuple = tokens[1].tupleValue!
                    memory.append(tuple.currentState)
                    memory.append(tuple.inputCharacter)
                    memory.append(tuple.newState)
                    memory.append(tuple.outputCharacter)
                    memory.append(tuple.direction)
                } else {
                    EMWrongParameters(tokens[0].stringValue!)
                    return false
                }
            }
        default:
            setErrorMessage("\(tokens[0].stringValue!) is not a directive")
        }
        return true
    }
    
    mutating func handleLabelDef(_ tokens: [Token], _ isSecondPass: Bool) -> Bool{
        symbolTable[tokens[0].stringValue!] = memory.count
        if tokens.count > 1{
            if tokens[1].type == .Instruction || tokens[1].type == .Directive{
                var newTokens = [Token]()
                for i in 1..<tokens.count{
                    newTokens.append(tokens[i])
                }
                if tokens[1].type == .Instruction{
                    return(handleInstruction(newTokens, isSecondPass))
                } else {
                    return(handleDirective(newTokens, isSecondPass))
                }
            } else {
                EMNotLegalLine()
                return false
            }
        } else {
            EMNotLegalLine()
            return false
        }
    }
    
    mutating func handleLabel(_ label: String, _ isSecondPass: Bool){
        if !isSecondPass{
            memory.append(-1)
            labelsUsed.append(label)
        } else {
            memory.append(symbolTable[label]!)
        }
    }
    
    mutating func checkLabels() -> Bool{
        var NoError = true
        for label in labelsUsed{
            if symbolTable[label] == nil{
                EMUndeclaredLabel(label)
                NoError = false
            }
        }
        return NoError
    }
    
    mutating func addErrorLst(_ line: String, _ error: String?){
        errorLst += "\(line)\n"
        if let errorMessage = error{
            errorLst += errorMessage
            numErrors += 1
        }
        errorMessage = nil
    }
    
    mutating func correctParamCountD(_ directive: String, _ numParam: Int) -> Bool{
        let parameters = directives[directive]!
        if Array(parameters).count != numParam{
            setErrorMessage("Illegal parameters for directive \(directive)")
            return false
        }
        return true
    }
    
    mutating func EMWrongParameters(_ command: String){
        setErrorMessage("Wrong parameters for \(command)")
    }
    mutating func EMNotLegalLine(){
        setErrorMessage("Expected Instruction or Directive")
    }
    mutating func EMUndeclaredLabel(_ label: String){
        setErrorMessage("No definition for symbol \(label)")
        errorLst += errorMessage!
        numErrors += 1
        errorMessage = nil
    }
    mutating func setErrorMessage(_ message: String){
        errorMessage = "..........\(message)\n"
    }
    
    mutating func makeSymFile() -> String{
        symFile += "Symbol Table: \n"
        for (label, location) in symbolTable{
            symFile += "\(label) \(location)\n"
        }
        return symFile
    }
    mutating func makeBinFile() -> String{
        var binFile = ""
        binFile += "\(memory.count)\n"
        for mem in memory{
            binFile += "\(mem)\n"
        }
        return binFile
    }
}
