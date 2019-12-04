import Cocoa

typealias Program = [Int]


func readTape(program : Program) -> Program {
    var tape = program // the tape is a mutable program
    var i = 0
    var op: Bool? = nil
    while (true) {
        if i > tape.count {
            print("ran out of tape")
            break
        }
        let v = tape[i]
        switch v {
        case 1 : op = true
        case 2 : op = false
        case 99 : op = nil
        case _ : op = nil; print("error")
        }
        if let o = op {
            let fstIdx = i + 1
            let sndIdx = i + 2
            let dstIdx = i + 3
            let fstVal = tape[fstIdx]
            let sndVal = tape[sndIdx]
            let result: Int
            if o {
                result = tape[fstVal] + tape[sndVal]
            } else {
                result = tape[fstVal] * tape[sndVal]
            }
            tape[tape[dstIdx]] = result
            i += 4
        } else {
            break
        }
    }
    return tape
}

print(readTape(program: [1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,13,19,2,9,19,23,1,23,6,27,1,13,27,31,1,31,10,35,1,9,35,39,1,39,9,43,2,6,43,47,1,47,5,51,2,10,51,55,1,6,55,59,2,13,59,63,2,13,63,67,1,6,67,71,1,71,5,75,2,75,6,79,1,5,79,83,1,83,6,87,2,10,87,91,1,9,91,95,1,6,95,99,1,99,6,103,2,103,9,107,2,107,10,111,1,5,111,115,1,115,6,119,2,6,119,123,1,10,123,127,1,127,5,131,1,131,2,135,1,135,5,0,99,2,0,14,0]))

let memory = [1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,13,19,2,9,19,23,1,23,6,27,1,13,27,31,1,31,10,35,1,9,35,39,1,39,9,43,2,6,43,47,1,47,5,51,2,10,51,55,1,6,55,59,2,13,59,63,2,13,63,67,1,6,67,71,1,71,5,75,2,75,6,79,1,5,79,83,1,83,6,87,2,10,87,91,1,9,91,95,1,6,95,99,1,99,6,103,2,103,9,107,2,107,10,111,1,5,111,115,1,115,6,119,2,6,119,123,1,10,123,127,1,127,5,131,1,131,2,135,1,135,5,0,99,2,0,14,0]
func mysteryProgram(input1: Int, input2: Int) -> Int {
    var mutableMemory = memory
    mutableMemory[1] = input1
    mutableMemory[2] = input2
    return readTape(program: mutableMemory)[0]
}

for i in 0...99 {
    for j in 0...99 {
        print("trying \((i,j))")

        if (mysteryProgram(input1: i, input2: j) == 19690720) {
            print("found inputs \((i,j))")
            break
        }
    }
}
