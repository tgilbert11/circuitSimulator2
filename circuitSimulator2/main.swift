//
//  main.swift
//  circuitSimulator2
//
//  Created by Taylor Gilbert on 12/1/19.
//  Copyright © 2019 Taylor Gilbert. All rights reserved.
//

import Foundation 

extension Array where Element == Bool {
    var numericalValue: Int { return self.enumerated().map({ $1 ? 1 << $0 : 0 }).reduce(0, +) }
}
func ArrayWithValue(_ value: Int, width: Int) -> [Bool] {
    return Array(0..<width).map({ value >> $0 & 1 > 0 })
}

func resolve(initialConditions: [Bool]) -> [Bool] {
    //print("simulation started")
    var simulationSteps: [[Bool]] = [initialConditions]
    while simulationSteps.count < 2 || simulationSteps[simulationSteps.count-1] != simulationSteps[simulationSteps.count-2] {
        
        //print(simulationSteps.last!)
        simulationSteps.append( Node.nodes.map({ $0.valueForNextTimeStep(currentTimeStep: simulationSteps.last!) }) )
        
    }
    return simulationSteps.last!
}

func stringFromMonitors(monitors: [(name: String, node: Node)], busMonitors: [(name: String, nodes: [Node])], state: [Bool]) -> String {
    let singlesString = monitors.count > 0 ? "\(monitors[0].name): \(state[monitors[0].node.indexNumber])" + monitors.dropFirst().map({ ", \($0.name): \(state[$0.node.indexNumber])" }).reduce("", { $0 + $1 }) : ""
    let busString = busMonitors.count > 0 ? "\(busMonitors[0].name): \(busMonitors[0].nodes.map({ state[$0.indexNumber] }).numericalValue)" + busMonitors.dropFirst().map({ ", \($0.name): \($0.nodes.map({ state[$0.indexNumber] }).numericalValue)" }).reduce("", { $0 + $1 }) : ""
    return singlesString.count + busString.count == 0 ? "nothing being monitored" : singlesString + (singlesString.count>0 && busString.count>0 ? ", " : "") + busString
}

var monitors: [(name: String, node: Node)] = []
var busMonitors: [(name: String, nodes: [Node])] = []

let clock = Node(undrivenValue: false)

let setEnable = Node(undrivenValue: true)
let setEnable_ = Node(drivers: [Driver(logicType: .nor, nodes: setEnable)])

let reset = Node(undrivenValue: true)
let reset_ = Node(drivers: [Driver(logicType: .nor, nodes: reset)])

let outputEnable = Node(undrivenValue: false)
let outputEnable_ = Node(drivers: [Driver(logicType: .nor, nodes: outputEnable)])

let size = 16

let data = ArrayWithValue(35, width: 16).map({ Node(undrivenValue: $0) })
let data_ = data.map({ Node(drivers: [Driver(logicType: .nor, nodes: $0)]) })

let output = Array(0..<size).map({ _ in Node(drivers: []) })

let register = Register(clock: clock, setEnable_: setEnable_, reset_: reset_, outputEnable_: outputEnable_, data_: data_, output: output)


monitors.append((name: "reset", node: reset))
monitors.append((name: "clock", node: clock))
monitors.append((name: "setEnable", node: setEnable))
monitors.append((name: "outputEnable", node: outputEnable))

busMonitors.append((name: "data", nodes: data))
busMonitors.append((name: "output", nodes: output))

print("nodes: \(Node.nodes.count)")

let initialConditions = Array(repeating: false, count: Node.nodes.count)
//print(stringFromMonitors(monitors: monitors, state: initialConditions))

var state = resolve(initialConditions: initialConditions)
print(stringFromMonitors(monitors: monitors, busMonitors: busMonitors, state: state))

reset.undrivenValue = false
state = resolve(initialConditions: state)
print(stringFromMonitors(monitors: monitors, busMonitors: busMonitors, state: state))

clock.undrivenValue = true
state = resolve(initialConditions: state)
print(stringFromMonitors(monitors: monitors, busMonitors: busMonitors, state: state))

clock.undrivenValue = false
state = resolve(initialConditions: state)
print(stringFromMonitors(monitors: monitors, busMonitors: busMonitors, state: state))

outputEnable.undrivenValue = true
state = resolve(initialConditions: state)
print(stringFromMonitors(monitors: monitors, busMonitors: busMonitors, state: state))

outputEnable.undrivenValue = false
state = resolve(initialConditions: state)
print(stringFromMonitors(monitors: monitors, busMonitors: busMonitors, state: state))
