class FlipFlopCell {
    let set, q, q_, reset, fullReset: Node
    
    init(data_: Node, pulse: Node, pulse_: Node, reset_: Node, outputEnable_: Node, output: Node) {
        self.set = Node(drivers: [Driver(logicType: .nor, nodes: data_, pulse_)])
        self.reset = Node(drivers: [Driver(logicType: .nand, nodes: pulse, data_)])
        self.fullReset = Node(drivers: [Driver(logicType: .nand, nodes: self.reset, reset_)])
        self.q = Node(drivers: [])
        self.q_ = Node(drivers: [Driver(logicType: .nor, nodes: self.q, self.fullReset)])
        self.q.drivers.append(Driver(logicType: .nor, nodes: self.set, self.q_))
        output.drivers.append(Driver(logicType: .nor, nodes: self.q, outputEnable_))
    }
}
