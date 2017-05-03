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
        let config = PNConfiguration(publishKey: Constants.pubKey, subscribeKey: Constants.subKey)
        config.stripMobilePayload = false
        self.client = PubNub.clientWithConfiguration(config)
        super.init()
        client.addListener(self)
        client.subscribeToChannels([Constants.calculatorChannel], withPresence: true)
    }
    
    func publish(firstValue: Int, operation: CalculatorLockedOperation, secondValue: Int) {
        let messageBody: [String: Any] = [
            "firstValue": NSNumber(value: firstValue),
            "operation": operation.rawValue,
            "secondValue": NSNumber(value: secondValue),
        ]
        client.publish(messageBody, toChannel: Constants.calculatorChannel) { (status) in
            if (status.isError) {
                print("Publish went wrong: \(status.debugDescription)")
            }
        }
    }
    
    func addListener(_ listener: PNObjectEventListener) {
        client.addListener(listener)
    }

}

extension Network: PNObjectEventListener {
    
//    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
//        print("message: \(message.debugDescription)")
//    }
    
}
