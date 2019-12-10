import Cocoa

typealias Program = [Int]

enum Mode: CustomStringConvertible {
    var description: String {
        switch self {
        case .imm: return "imm"
        case .pos: return "pos"
        }
    }
    case imm
    case pos
}

func parse(mode: Int) -> Mode? {
    switch mode {
    case 0: return .pos
    case 1: return .imm
    case _: return nil
    }
}

enum Operand: CustomStringConvertible {
    case add(arg1: Mode, arg2: Mode, dest: Mode)
    case mul(arg1: Mode, arg2: Mode, dest: Mode)
    case read
    case print(Mode)
    case end

    var description: String {
        switch self {
        case .add(let m):
            return "addition with modes: \(m)"
        case .mul(let m):
            return "multiplication with modes: \(m)"
        case .read:
            return "read from input"
        case .print(_):
            return "print to output"
        case .end:
            return "end program"
        }
    }
}

func parse(op: Int) -> Operand? {

    print("parsing operand \(op)")
    let operand = op % 100
    guard let arg1 = parse(mode: (op / 100  ) % 10) else { return nil }
    guard let arg2 = parse(mode: (op / 1000 ) % 10) else { return nil }
    guard let arg3 = parse(mode: (op / 10000) % 10) else { return nil }

    print("operand \(operand)")
    print("firstargmode \(arg1)")
    print("secondargmode \(arg2)")
    print("thirdargmode \(arg3)")

    switch operand {
    case 99: return .end
    case 1: return .add(arg1: arg1, arg2: arg2, dest: arg3)
    case 2: return .mul(arg1: arg1, arg2: arg2, dest: arg3)
    case 3: return .read
    case 4: return .print(arg1)
    case _: return nil
    }
}

print(parse(op: 1002))

enum Operation {
    case add(arg1: (Mode, Int), arg2: (Mode, Int), dest: Int)
    // multiply two numbers and store ar
    case mul(arg1: (Mode, Int), arg2: (Mode, Int), dest: Int)
    // read from input and store at address
    case read(addr: Int)
    // print whatever is at address or IMM
    case print(addr: (Mode, Int))
    case end
}

func offset(operation: Operation) -> Int {
    switch operation {
    case .add: return 4
    case .mul: return 4
    case .read: return 2
    case .print: return 2
    default: return 0
    }
}

func parseOperation(tape: [Int], index: Int) -> Operation? {
    let op = tape[index]
    switch parse(op: op) {
    case .add(let arg1, let arg2, _)?:
        return .add(
            arg1: (arg1, tape[index + 1]),
            arg2: (arg2, tape[index + 2]),
            dest: tape[index + 3])
    case .mul(let arg1, let arg2, _)?:
        return .mul(
        arg1: (arg1, tape[index + 1]),
        arg2: (arg2, tape[index + 2]),
        dest: tape[index + 3])
    case .read?:
        return .read(addr: tape[index+1])
    case .print(let mode)?:
        return .print(addr: (mode, tape[index + 1]))
    case .end?:
        return .end
    case nil: return nil
    }
}

func getVal(program: [Int], argument: (Mode, Int)) -> Int {
    switch argument {
    case (.imm, let v): return v
    case (.pos, let v): return program[v]
    }
}

func operate(tape: inout [Int], output: inout [Int], operation: Operation) {
    switch operation {
    case .add(let arg1, let arg2, let dest):
        let fst = getVal(program: tape, argument: arg1)
        let snd = getVal(program: tape, argument: arg2)
        tape[dest] = fst + snd
    case .mul(let arg1, let arg2, let dest):
        print("arg1 \(arg1)")
        print("arg2 \(arg2)")

        let fst = getVal(program: tape, argument: arg1)
        let snd = getVal(program: tape, argument: arg2)
        print("multipliaction \(fst) * \(snd)")
        tape[dest] = fst * snd
    case .read(let arg):
        tape[arg] = 1 // input is always 1
    case .print(let arg):
        output.append(getVal(program: tape, argument: arg))
    case .end:
        print("reach end of program")
    }
}

func readTape(program : Program) -> (Program, [Int]) {
    var tape = program // the tape is a mutable program
    var i = 0
    var output: [Int] = []
    while (true) {
        if i > tape.count {
            print("ran out of tape")
            break
        }
        guard let operation = parseOperation(tape: tape, index: i) else {
            print("unrecognised operation at index \(i) with value \(tape[i])")
            break
        }
        if case .end = operation {
            print("reach end of program")
            break
        }
        operate(tape: &tape, output: &output, operation: operation)
        i += offset(operation: operation)
    }
    return (tape, output)
}

readTape(program: [1,0,0,0,99])
readTape(program: [2,3,0,3,99])
readTape(program: [2,4,4,5,99,0])
readTape(program: [1002,4,3,4,33])
let (tape, output) = readTape(program: [3,225,1,225,6,6,1100,1,238,225,104,0,1102,27,28,225,1,113,14,224,1001,224,-34,224,4,224,102,8,223,223,101,7,224,224,1,224,223,223,1102,52,34,224,101,-1768,224,224,4,224,1002,223,8,223,101,6,224,224,1,223,224,223,1002,187,14,224,1001,224,-126,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,1102,54,74,225,1101,75,66,225,101,20,161,224,101,-54,224,224,4,224,1002,223,8,223,1001,224,7,224,1,224,223,223,1101,6,30,225,2,88,84,224,101,-4884,224,224,4,224,1002,223,8,223,101,2,224,224,1,224,223,223,1001,214,55,224,1001,224,-89,224,4,224,102,8,223,223,1001,224,4,224,1,224,223,223,1101,34,69,225,1101,45,67,224,101,-112,224,224,4,224,102,8,223,223,1001,224,2,224,1,223,224,223,1102,9,81,225,102,81,218,224,101,-7290,224,224,4,224,1002,223,8,223,101,5,224,224,1,223,224,223,1101,84,34,225,1102,94,90,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1007,677,677,224,102,2,223,223,1005,224,329,101,1,223,223,1108,226,677,224,1002,223,2,223,1005,224,344,101,1,223,223,1008,677,677,224,102,2,223,223,1005,224,359,101,1,223,223,8,226,677,224,1002,223,2,223,1006,224,374,101,1,223,223,108,226,677,224,1002,223,2,223,1006,224,389,1001,223,1,223,1107,226,677,224,102,2,223,223,1005,224,404,1001,223,1,223,7,226,677,224,1002,223,2,223,1005,224,419,101,1,223,223,1107,677,226,224,102,2,223,223,1006,224,434,1001,223,1,223,1107,226,226,224,1002,223,2,223,1006,224,449,101,1,223,223,1108,226,226,224,1002,223,2,223,1005,224,464,101,1,223,223,8,677,226,224,102,2,223,223,1005,224,479,101,1,223,223,8,226,226,224,1002,223,2,223,1006,224,494,1001,223,1,223,1007,226,677,224,1002,223,2,223,1006,224,509,1001,223,1,223,108,226,226,224,1002,223,2,223,1006,224,524,1001,223,1,223,1108,677,226,224,102,2,223,223,1006,224,539,101,1,223,223,1008,677,226,224,102,2,223,223,1006,224,554,101,1,223,223,107,226,677,224,1002,223,2,223,1006,224,569,101,1,223,223,107,677,677,224,102,2,223,223,1006,224,584,101,1,223,223,7,677,226,224,102,2,223,223,1005,224,599,101,1,223,223,1008,226,226,224,1002,223,2,223,1005,224,614,1001,223,1,223,107,226,226,224,1002,223,2,223,1005,224,629,101,1,223,223,7,226,226,224,102,2,223,223,1006,224,644,1001,223,1,223,1007,226,226,224,102,2,223,223,1006,224,659,101,1,223,223,108,677,677,224,102,2,223,223,1005,224,674,1001,223,1,223,4,223,99,226])

print(output)
