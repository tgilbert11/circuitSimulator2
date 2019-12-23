class Node {
    static var nodes: [Node] = []

    var drivers: [Driver]
    var undrivenValue: Bool
    let indexNumber: Int
    
    func valueForNextTimeStep(currentTimeStep: [Bool]) -> Bool {
        return drivers.count > 0 ? drivers.map({ $0.valueForNextTimeStep(currentTimeStep: currentTimeStep) }).reduce(false, { $0 || $1 }) : undrivenValue
    }
    
    init(drivers: [Driver]) {
        self.drivers = drivers
        self.undrivenValue = false
        self.indexNumber = Node.nodes.count
        Node.nodes.append(self)
        
    }

    init(undrivenValue: Bool) {
        self.drivers = []
        self.undrivenValue = undrivenValue
        self.indexNumber = Node.nodes.count
        Node.nodes.append(self)
    }
}

struct Driver {
    let nodeIndices: [Int]
    let logicType: LogicType
    
    func valueForNextTimeStep(currentTimeStep: [Bool]) -> Bool {
        let bools = nodeIndices.map({ currentTimeStep[$0] })
        switch logicType {
            case .and:
                return bools.reduce(true, { $0 && $1 })
            case .or:
                return bools.reduce(false, { $0 || $1 })
            case .nand:
                return !bools.reduce(true, { $0 && $1 })
            case .nor:
                return !bools.reduce(false, { $0 || $1 })
        }
    }
    
    init(logicType: LogicType, nodes: Node...) {
        self.logicType = logicType
        self.nodeIndices = nodes.map({ $0.indexNumber })
    }
}

enum LogicType {
    case and
    case or
    case nand
    case nor
}
