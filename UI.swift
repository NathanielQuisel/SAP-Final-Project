struct SAP_UI{
    var assembler: TwoPassAssembler
    var path: String = ""
    
    init(){
        assembler = TwoPassAssembler()
    }
    
    mutating func runUI(){
        print("Welcome to SAP!\n")
        help()
        print("\nEnter option...", terminator: "")
        var input = readLine()
        while input != nil && input! != "quit"{
            let line = splitStringIntoParts(expression: input!)
            switch line[0]{
            case "path":
                if checkNumParameters(1, line){
                    path = line[1]
                }
            case "asm":
                if checkNumParameters(1, line){
                    assembleFile(line[1])
                }
            case "run":
                if checkNumParameters(1, line){
                    runProgram(line[1])
                }
            case "printsym":
                if checkNumParameters(1, line){
                    printFile("\(line[1]).sym")
                }
            case "printlst":
                if checkNumParameters(1, line){
                    printFile("\(line[1]).lst")
                }
            case "printbin":
                if checkNumParameters(1, line){
                    printFile("\(line[1]).bin")
                }
            case "help":
                if checkNumParameters(0, line){
                    help()
                }
            default:
                print("\(line[0]) is not a legal command")
                print("try 'help' to see list of commands")
            }
            print("\nEnter option...", terminator: "")
            input = readLine()
        }
    }
    
    func printTemplate(_ fileName: String){
        print("Printing \(path)\(fileName)")
    }
    
    mutating func assembleFile(_ fileName: String) -> Bool{
        if let file = readTextFile("\(path)\(fileName).txt").fileText{
            assembler = TwoPassAssembler(file: file)
            let NoErrors = assembler.run()
            if NoErrors{
                writeTextFile("\(path)\(fileName).lst", data: assembler.successLst)
                writeTextFile("\(path)\(fileName).bin", data: assembler.makeBinFile())
                writeTextFile("\(path)\(fileName).sym", data: assembler.symFile)
                return true
            } else {
                writeTextFile("\(path)\(fileName).lst", data: assembler.errorLst)
                return false
            }
        } else {
            print("Unable to retrieve file \(path)\(fileName)")
            return false
        }
    }
    
    mutating func runProgram(_ fileName: String){
        if assembleFile(fileName){
            var VMachine = VM(memoryLength: assembler.memory.count, memory: assembler.memory, symbolTable: assembler.symbolTable)
            VMachine.runDebugger()
        }
    }
    
    mutating func printFile(_ fileName: String){
        if let file = readTextFile("\(path)\(fileName)").fileText{
            printTemplate(fileName)
            print(file)
        } else {
            print("Unable to retrieve file at \(path)\(fileName)")
        }
    }
    
    func checkNumParameters(_ correctNum: Int, _ line: [String]) -> Bool{
        if correctNum+1 == line.count{
            return true
        }
        print("Incorrect number of parameters")
        print("Try typing 'help' for list of commands")
        return false
    }
    
    func help(){
        print("SAP Help:")
        print("  asm <program name> - assembler the specified program")
        print("  run <program name> - run the specified program")
        print("  path <path specification> - set the path for the SAP program directory")
        print("    include final / but not name of file. SAP file must have an extension of .txt")
        print("  printlst <program name> - print listing file for the specified program")
        print("  printbin <program name> - print binary file for the specified program")
        print("  printsym <program name> - print symbol table for the specified program")
        print("  quit  - terminate SAP program")
        print("  help  - print help table")
    }
}
