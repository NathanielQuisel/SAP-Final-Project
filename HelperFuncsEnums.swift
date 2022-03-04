enum SymbolTable: Int{
    case halt, clrr , clrx , clrm , clrb , movir , movrr , movrm , movmr , movxr , movar , movb , addir , addrr , addmr , addxr , subir , subrr , submr , subxr , mulir , mulrr , mulmr , mulxr , divir , divrr , divmr , divxr , jmp , sojz , sojnz , aojz , aojnz , cmpir , cmprr , cmpmr , jmpn , jmpz , jmpp , jsr , ret , push , pop , stackc , outci , outcr , outcx , outcb , readi , printi , readc , readln , brk , movrx , movxx , outs , nop , jmpne, reg
}
 
let instructions = [
    "halt" : (code: SymbolTable.halt, Param: ""),
    "clrr" : (code: SymbolTable.clrr, Param: "r"),
    "clrx" : (code: SymbolTable.clrx, Param: "r"),
    "clrm" : (code: SymbolTable.clrm, Param: "l"),
    "clrb" : (code: SymbolTable.clrb, Param: "rr"),
    "movir" : (code: SymbolTable.movir, Param: "ir"),
    "movrr" : (code: SymbolTable.movrr, Param: "rr"),
    "movrm" : (code: SymbolTable.movrm, Param: "rl"),
    "movmr" : (code: SymbolTable.movmr, Param: "lr"),
    "movxr" : (code: SymbolTable.movxr, Param: "rr"),
    "movar" : (code: SymbolTable.movar, Param: "lr"),
    "movb" : (code: SymbolTable.movb, Param: "rrr"),
    "addir" : (code: SymbolTable.addir, Param: "ir"),
    "addrr" : (code: SymbolTable.addrr, Param: "rr"),
    "addmr" : (code: SymbolTable.addmr, Param: "lr"),
    "addxr" : (code: SymbolTable.addxr, Param: "rr"),
    "subir" : (code: SymbolTable.subir, Param: "ir"),
    "subrr" : (code: SymbolTable.subrr, Param: "rr"),
    "submr" : (code: SymbolTable.submr, Param: "lr"),
    "subxr" : (code: SymbolTable.subxr, Param: "rr"),
    "mulir" : (code: SymbolTable.mulir, Param: "ir"),
    "mulrr" : (code: SymbolTable.mulrr, Param: "rr"),
    "mulmr" : (code: SymbolTable.mulmr, Param: "lr"),
    "mulxr" : (code: SymbolTable.mulxr, Param: "rr"),
    "divir" : (code: SymbolTable.divir, Param: "ir"),
    "divrr" : (code: SymbolTable.divrr, Param: "rr"),
    "divxr" : (code: SymbolTable.divxr, Param: "rr"),
    "jmp" : (code: SymbolTable.jmp, Param: "l"),
    "sojz" : (code: SymbolTable.sojz, Param: "rl"),
    "sojnz" : (code: SymbolTable.sojnz, Param: "rl"),
    "aojz" : (code: SymbolTable.aojz, Param: "rl"),
    "aojnz" : (code: SymbolTable.aojnz, Param: "rl"),
    "cmpir" : (code: SymbolTable.cmpir, Param: "ir"),
    "cmprr" : (code: SymbolTable.cmprr, Param: "rr"),
    "cmpmr" : (code: SymbolTable.cmpmr, Param: "lr"),
    "jmpn" : (code: SymbolTable.jmpn, Param: "l"),
    "jmpz" : (code: SymbolTable.jmpz, Param: "l"),
    "jmpp" : (code: SymbolTable.jmpp, Param: "l"),
    "jsr" : (code: SymbolTable.jsr, Param: "l"),
    "ret" : (code: SymbolTable.ret, Param: ""),
    "push" : (code: SymbolTable.push, Param: "r"),
    "pop" : (code: SymbolTable.pop, Param: "r"),
    "stackc" : (code: SymbolTable.stackc, Param: "r"),
    "outci" : (code: SymbolTable.outci, Param: "i"),
    "outcr" : (code: SymbolTable.outcr, Param: "r"),
    "outcx" : (code: SymbolTable.outcx, Param: "r"),
    "outcb" : (code: SymbolTable.outcb, Param: "rr"),
    "readi" : (code: SymbolTable.readi, Param: "rr"),
    "printi" : (code: SymbolTable.printi, Param: "r"),
    "readc" : (code: SymbolTable.readc, Param: "r"),
    "readln" : (code: SymbolTable.readln, Param: "lr"),
    "brk" : (code: SymbolTable.brk, Param: ""),
    "movrx" : (code: SymbolTable.movrx, Param: "rr"),
    "movxx" : (code: SymbolTable.movxx, Param: "rr"),
    "outs" : (code: SymbolTable.outs, Param: "l"),
    "nop" : (code: SymbolTable.nop, Param: ""),
    "jmpne" : (code: SymbolTable.jmpne, Param: "l"),
    "reg" : (code: SymbolTable.reg, Param: "")
]
 
let directives = [ // change to not have decimal point
    "start" : "l",
    "end" : "",
    "integer" : "i",
    "allocate" : "i",
    "string" : "s",
    "tuple" : "t"
]
 
enum TokenType {
    case Register
    case LabelDefinition
    case Label
    case ImmediateString
    case ImmediateInteger
    case ImmediateTuple
    case Instruction
    case Directive
    case BadToken
}
struct Token: CustomStringConvertible{
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
    var description: String{
        var desc = "\(type)"
        if let int = intValue{
            desc += "\(int)"
        }
        if let string = stringValue{
            desc += string
        }
        if let tuple = tupleValue{
            desc += "\(tuple)"
        }
        return desc
    }
    init(_ type: TokenType, int: Int? = nil, string: String? = nil, tuple: Tuple? = nil){
        self.type = type
        intValue = int
        stringValue = string
        tupleValue = tuple
    }
}
struct Tuple: CustomStringConvertible{
    let currentState: Int
    let inputCharacter: Int
    let newState: Int
    let outputCharacter: Int
    let direction: Int
    var description: String{
        return "tUpLe"
    }
    init(_ CS: Int, _ IC: Int, _ NS: Int, _ OC: Int, _ DI: Int){
        currentState = CS
        inputCharacter = IC
        newState = NS
        outputCharacter = OC
        direction = DI
    }
}
func charToAscii(c: Character)->Int{
    return Int(String(c).utf8.first!)
}
func AsciiToChar(n: Int)-> Character{
    return Character(UnicodeScalar(n)!)
}
func splitStringIntoParts(expression: String)->[String]{
    return expression.split{$0 == " "}.map{ String($0) }
}
func splitStringIntoLines(expression: String)->[String]{
    return expression.split{$0 == "\r" || $0 == "\n" || $0 == "\r\n"}.map{ String($0) }
}
func readTextFile(_ path: String)->(message: String?, fileText: String?){
    let text: String
    do {
        text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
    }
    catch {
        return ("\(error)", nil)
    }
    return (nil, text)
}
 
func writeTextFile(_ path: String, data: String)->String? {
    let url = NSURL.fileURL(withPath: path)
    do {
        try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
        return "Failed writing to URL: \(url), Error: " + error.localizedDescription
    }
    return nil
}
 
func fit(_ s: String, _ size: Int, right: Bool = true) -> String{
    var result = ""
    let sSize = s.count
    if sSize == size {return s}
    var count = 0
    if size < sSize{
        for c in s {
            if count < size {result.append(c)}
            count += 1
        }
        return result
    }
    result = s
    var addon = ""
    let num = size - sSize
    for _ in 0..<num {addon.append(" ")}
    if right {return result + addon}
    return addon + result
}
