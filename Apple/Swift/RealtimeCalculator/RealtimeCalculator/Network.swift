//
//  Network.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 5/3/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

class Network: NSObject {
    
    static let shared = Network()
    
    let client: PubNub
    
    override init() {
        let config = PNConfiguration(publishKey: "demo-36", subscribeKey: "demo-36")
        config.stripMobilePayload = false
        self.client = PubNub.clientWithConfiguration(config)
        super.init()
        client.addListener(self)
    }
    
    func publish(firstValue: Int, operation: CalculatorLockedOperation, secondValue: Int) {
        let messageBody: [String: Any] = [
            "firstValue": NSNumber(value: firstValue),
            "operation": operation.rawValue,
            "secondValue": NSNumber(value: secondValue),
        ]
        client.publish(messageBody, toChannel: "Calculator") { (status) in
            if (status.isError) {
                print("Publish went wrong: \(status.debugDescription)")
            }
        }
    }

}

extension Network: PNObjectEventListener {
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("message: \(message.debugDescription)")
    }
    
}
