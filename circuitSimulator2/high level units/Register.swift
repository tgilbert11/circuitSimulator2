class Register {
    let pulseGenerator1, pulseGenerator2, pulseGenerator3, rawPulse, pulse, pulse_: Node
    let cells: [FlipFlopCell]
    
    init(clock: Node, setEnable_: Node, reset_: Node, outputEnable_: Node, data_: [Node], output: [Node]) {
        assert(data_.count == output.count, "data and output count don't match on register")
        
        self.pulseGenerator1 = Node(drivers: [Driver(logicType: .nor, nodes: clock)])
        self.pulseGenerator2 = Node(drivers: [Driver(logicType: .nor, nodes: self.pulseGenerator1)])
        self.pulseGenerator3 = Node(drivers: [Driver(logicType: .nor, nodes: self.pulseGenerator2)])
        self.rawPulse = Node(drivers: [Driver(logicType: .nand, nodes: clock, self.pulseGenerator3)])
        self.pulse = Node(drivers: [Driver(logicType: .nor, nodes: setEnable_, self.rawPulse)])
        self.pulse_ = Node(drivers: [Driver(logicType: .nor, nodes: self.pulse)])
        
        var workingCells: [FlipFlopCell] = []
        for i in 0..<data_.count {
            workingCells.append(FlipFlopCell(data_: data_[i], pulse: self.pulse, pulse_: self.pulse_, reset_: reset_, outputEnable_: outputEnable_, output: output[i]))
        }
        self.cells = workingCells
    }
}
