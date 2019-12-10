import Cocoa

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
    case ifTrue(test: Mode, dest: Mode)
    case ifFalse(test: Mode, dest: Mode)
    case lessThan(fst: Mode, snd: Mode)
    case equals(fst: Mode, snd: Mode)
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
        case .ifTrue(test: let m):
            return "ifTrue(\(m))"
        case .ifFalse(test: let m):
            return "ifFalse(\(m))"
        case let .lessThan(fst: f, snd: s):
            return "\(f) < \(s)"
        case let .equals(fst: f, snd: s):
            return "\(f) == \(s)"
        case .end:
            return "end program"
        }
    }
}

func parse(op: Int) -> Operand? {

    let operand = op % 100
    guard let mode1 = parse(mode: (op / 100  ) % 10) else { return nil }
    guard let mode2 = parse(mode: (op / 1000 ) % 10) else { return nil }
    guard let mode3 = parse(mode: (op / 10000) % 10) else { return nil }

    switch operand {
    case 99: return .end
    case 1: return .add(arg1: mode1, arg2: mode2, dest: mode3)
    case 2: return .mul(arg1: mode1, arg2: mode2, dest: mode3)
    case 3: return .read
    case 4: return .print(mode1)
    case 5: return .ifTrue(test: mode1, dest: mode2)
    case 6: return .ifFalse(test: mode1, dest: mode2)
    case 7: return .lessThan(fst: mode1, snd: mode2)
    case 8: return .equals(fst: mode1, snd: mode2)
    case _: return nil
    }
}


enum Operation {
    case add(arg1: (Mode, Int), arg2: (Mode, Int), dest: Int)
    // multiply two numbers and store ar
    case mul(arg1: (Mode, Int), arg2: (Mode, Int), dest: Int)
    // read from input and store at address
    case read(addr: Int)
    // print whatever is at address or IMM
    case print(addr: (Mode, Int))
    case ifTrue(cond: (Mode, Int), dest: (Mode, Int))
    case ifFalse(cond: (Mode, Int), dest: (Mode, Int))
    case lessThan(arg1: (Mode, Int), arg2: (Mode, Int), dest: Int)
    case equals(arg1: (Mode, Int), arg2: (Mode, Int), dest: Int)
    case end
}

func parseOperation(tape: [Int], index: Int) -> Operation? {
    let op = tape[index]
    let fst = index + 1
    let snd = index + 2
    let trd = index + 3
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
    case .ifTrue(test: let m, dest: let m2)?:
        return .ifTrue(cond: (m, tape[fst]), dest: (m2, tape[snd]))
    case .ifFalse(test: let m, dest: let m2)?:
        return .ifFalse(cond: (m, tape[fst]), dest: (m2, tape[snd]))
    case .lessThan(fst: let m1, snd: let m2)?:
        return .lessThan(arg1: (m1, tape[fst]), arg2: (m2, tape[snd]), dest: tape[trd])
    case .equals(fst: let m1, snd: let m2)?:
        return .equals(arg1: (m1, tape[fst]), arg2: (m2, tape[snd]), dest: tape[trd])
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

struct Program {
    var tape: [Int]
    let input: Int
    var output: [Int]
    var functionPointer: Int
}

// also returns the new
func operate(program: inout Program, operation: Operation) {
    switch operation {
    case .add(let arg1, let arg2, let dest):
        let fst = getVal(program: program.tape, argument: arg1)
        let snd = getVal(program: program.tape, argument: arg2)
        program.tape[dest] = fst + snd
        program.functionPointer += 4

    case .mul(let arg1, let arg2, let dest):
        let fst = getVal(program: program.tape, argument: arg1)
        let snd = getVal(program: program.tape, argument: arg2)
        program.tape[dest] = fst * snd
        program.functionPointer += 4

    case .read(let arg):
        program.tape[arg] = program.input
        program.functionPointer += 2

    case .print(let arg):
        program.output.append(getVal(program: program.tape, argument: arg))
        program.functionPointer += 2

    case .ifTrue(cond: let arg, dest: let dest):
        let val = getVal(program: program.tape, argument: arg)
        if val != 0 {
            program.functionPointer = getVal(program: program.tape, argument: dest)
        } else {
            program.functionPointer += 3
        }
    case .ifFalse(cond: let arg, dest: let dest):
        let val = getVal(program: program.tape, argument: arg)
        if val == 0 {
            program.functionPointer = getVal(program: program.tape, argument: dest)
        } else {
            program.functionPointer += 3
        }
    case .lessThan(arg1: let l, arg2: let r, dest: let dest):
        let isLessThan = getVal(program: program.tape, argument: l) <
            getVal(program: program.tape, argument: r)
        program.tape[dest] = isLessThan ? 1 : 0
        program.functionPointer += 4

    case .equals(arg1: let l, arg2: let r, dest: let dest):
        let isEqual = getVal(program: program.tape, argument: l) ==
            getVal(program: program.tape, argument: r)
        program.tape[dest] = isEqual ? 1 : 0
        program.functionPointer += 4

    case .end:
        print("reach end of program")
    }
}

func interpret(tape : [Int], input: Int) -> [Int] {
    var program = Program(tape: tape, input: input, output: [], functionPointer: 0)
    while (true) {
        if program.functionPointer > program.tape.count {
            print("ran out of tape")
            break
        }
        guard let operation = parseOperation(tape: program.tape, index: program.functionPointer) else {
            print("unrecognised operation \(program.tape[program.functionPointer])")
            break
        }
        if case .end = operation {
            print("reach end of program")
            break
        }
        print("found operation \(operation)")
        operate(program: &program, operation: operation)
    }
    return (program.output)
}

// shoudl output 1 if the input equals 8 otherwise 0
//interpret(tape: [3,9,8,9,10,9,4,9,99,-1,8], input: 9)
// should output 1 if the input is less than 8 otherwise 0
//interpret(tape: [3,9,7,9,10,9,4,9,99,-1,8], input: 3)

//return 1 if input is 8 otherwise 0
//interpret(tape: [3,3,1108,-1,8,3,4,3,99], input: 8)

// x < 8 ? 1 : 0
//interpret(tape: [3,3,1107,-1,8,3,4,3,99], input: 7)

// should output 0 if the input equals 0 otherwise  1
interpret(tape: [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], input: 1)

// return 999 if less than 8
// retunr 1000 is equal to 8
// return 1001 if larger than 8
//interpret(tape: [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
//1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
//999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], input: 9)
interpret(tape: [3,225,1,225,6,6,1100,1,238,225,104,0,1102,27,28,225,1,113,14,224,1001,224,-34,224,4,224,102,8,223,223,101,7,224,224,1,224,223,223,1102,52,34,224,101,-1768,224,224,4,224,1002,223,8,223,101,6,224,224,1,223,224,223,1002,187,14,224,1001,224,-126,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,1102,54,74,225,1101,75,66,225,101,20,161,224,101,-54,224,224,4,224,1002,223,8,223,1001,224,7,224,1,224,223,223,1101,6,30,225,2,88,84,224,101,-4884,224,224,4,224,1002,223,8,223,101,2,224,224,1,224,223,223,1001,214,55,224,1001,224,-89,224,4,224,102,8,223,223,1001,224,4,224,1,224,223,223,1101,34,69,225,1101,45,67,224,101,-112,224,224,4,224,102,8,223,223,1001,224,2,224,1,223,224,223,1102,9,81,225,102,81,218,224,101,-7290,224,224,4,224,1002,223,8,223,101,5,224,224,1,223,224,223,1101,84,34,225,1102,94,90,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,1007,677,677,224,102,2,223,223,1005,224,329,101,1,223,223,1108,226,677,224,1002,223,2,223,1005,224,344,101,1,223,223,1008,677,677,224,102,2,223,223,1005,224,359,101,1,223,223,8,226,677,224,1002,223,2,223,1006,224,374,101,1,223,223,108,226,677,224,1002,223,2,223,1006,224,389,1001,223,1,223,1107,226,677,224,102,2,223,223,1005,224,404,1001,223,1,223,7,226,677,224,1002,223,2,223,1005,224,419,101,1,223,223,1107,677,226,224,102,2,223,223,1006,224,434,1001,223,1,223,1107,226,226,224,1002,223,2,223,1006,224,449,101,1,223,223,1108,226,226,224,1002,223,2,223,1005,224,464,101,1,223,223,8,677,226,224,102,2,223,223,1005,224,479,101,1,223,223,8,226,226,224,1002,223,2,223,1006,224,494,1001,223,1,223,1007,226,677,224,1002,223,2,223,1006,224,509,1001,223,1,223,108,226,226,224,1002,223,2,223,1006,224,524,1001,223,1,223,1108,677,226,224,102,2,223,223,1006,224,539,101,1,223,223,1008,677,226,224,102,2,223,223,1006,224,554,101,1,223,223,107,226,677,224,1002,223,2,223,1006,224,569,101,1,223,223,107,677,677,224,102,2,223,223,1006,224,584,101,1,223,223,7,677,226,224,102,2,223,223,1005,224,599,101,1,223,223,1008,226,226,224,1002,223,2,223,1005,224,614,1001,223,1,223,107,226,226,224,1002,223,2,223,1005,224,629,101,1,223,223,7,226,226,224,102,2,223,223,1006,224,644,1001,223,1,223,1007,226,226,224,102,2,223,223,1006,224,659,101,1,223,223,108,677,677,224,102,2,223,223,1005,224,674,1001,223,1,223,4,223,99,226], input: 5)
