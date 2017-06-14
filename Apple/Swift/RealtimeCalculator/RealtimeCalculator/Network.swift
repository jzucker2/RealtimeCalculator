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
    
    private let client: PubNub
    
    var uuid: String {
        return client.uuid()
    }
    
    func addListener(listener: PNObjectEventListener) {
        client.addListener(listener)
    }
    
    override init() {
        let config = PNConfiguration(publishKey: Constants.pubKey, subscribeKey: Constants.subKey)
        config.stripMobilePayload = false
        self.client = PubNub.clientWithConfiguration(config)
        super.init()
        client.addListener(self)
        client.subscribeToChannels([Constants.calculatorChannel], withPresence: true)
    }
    
    func publish(current total: Double, operation: CalculatorLockedOperation, input value: Double, with completion: PNPublishCompletionBlock? = nil) {
        let messageBody: [String: Any] = [
            Constants.currentTotal: NSNumber(value: total),
            Constants.operation: operation.rawValue,
            Constants.inputValue: NSNumber(value: value),
        ]
        client.publish(messageBody, toChannel: Constants.calculatorChannel) { (status) in
            completion?(status)
        }
    }
    
    func addListener(_ listener: PNObjectEventListener) {
        client.addListener(listener)
    }

}

extension Network: PNObjectEventListener {
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        print("\(status.debugDescription)")
    }
    
//    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
//        print("message: \(message.debugDescription)")
//    }
    
}
