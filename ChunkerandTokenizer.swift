struct Chunker{
    static func makeChunks(line: [Character]) -> [String]{
        var chunks = [String]()
        var i = 0
        var target = " "
        while(i < line.count && line[i] != ";"){
            var currentChunk = ""
            if(line[i] == "\""){
                currentChunk += String(line[i])
                target = String(line[i])
                i += 1
            }
            if(line[i] == "\\"){
                currentChunk += String(line[i])
                currentChunk += " "
                target = String(line[i])
                i += 1
            }
            while(i < line.count && String(line[i]) != target && line[i] != "\r" && line[i] != "\n" && line[i] != "\r\n"){
                currentChunk += String(line[i])
                i += 1
            }
            i += 1
            if Array(currentChunk).count > 0{
                chunks.append(currentChunk)
            }
            target = " "
        }
        return chunks
    }
}
 
struct Tokenizer{
    static func makeTokens(chunks: [String]) -> [Token]{
        var results = [Token]()
        for i in 0..<chunks.count{
            let currentChunk = chunks[i]
            let firstChar = currentChunk[currentChunk.startIndex]
            if firstChar == "r" && currentChunk.count == 2, let value = Int(String(currentChunk.dropFirst())){
                if value > -1 && value < 10{
                    results.append(Token(.Register, int: value))
                }
                
            } else if let instruction = instructions[currentChunk.lowercased()]{
                results.append(Token(.Instruction, string: currentChunk.lowercased()))
                
            } else if currentChunk[currentChunk.index(before: currentChunk.endIndex)] == ":" && isGoodLabel(String(currentChunk.dropLast())){
                results.append(Token(.LabelDefinition, string: String(currentChunk.dropLast().lowercased())))
                
            } else if currentChunk[currentChunk.startIndex] == "."{
                results.append(Token(.Directive, string: currentChunk.dropFirst().lowercased()))
                
            } else if(firstChar == "#"){
                let indeces = currentChunk.index(after: currentChunk.startIndex)..<currentChunk.endIndex
                results.append(Token(.ImmediateInteger, int: Int(String(currentChunk[indeces]))))
                
            } else if(firstChar == "\""){
                results.append(Token(.ImmediateString, string: String(currentChunk.dropFirst())))
                
            } else if(firstChar == "\\"){
                let tupleString = splitStringIntoParts(expression: currentChunk)
                if tupleString.count < 7{
                    if let CS = Int(tupleString[1]), let NS = Int(tupleString[3]){
                        if tupleString[2].count < 2 && tupleString[4].count < 2{
                            if tupleString[5].lowercased() == "r" || tupleString[5].lowercased() == "l"{
                                let IC = charToAscii(c: Character(tupleString[2]))
                                let OC = charToAscii(c: Character(tupleString[4]))
                                var DI = 0
                                if tupleString[5].lowercased() == "r"{
                                    DI = 1
                                }
                                results.append(Token(.ImmediateTuple, tuple: Tuple(CS, IC, NS, OC, DI)))
                            }
                        }
                    }
                }
            } else if isGoodLabel(currentChunk){
                results.append(Token(.Label, string: currentChunk.lowercased()))
            } else {
                results.append(Token(.BadToken))
            }
        }
        return results
    }
    
    static func isGoodLabel(_ chunk: String) -> Bool{
        let characters = Array(chunk.lowercased())
        for character in characters{
            if !((character >= "a" && character <= "z") || (character >= "0" && character <= "9")){
                return false
            }
        }
        return true
    }
}
