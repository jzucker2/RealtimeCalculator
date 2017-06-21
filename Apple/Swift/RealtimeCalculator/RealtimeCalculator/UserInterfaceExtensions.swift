//
//  UserInterfaceExtensions.swift
//  RealtimeCalculator
//
//  Created by Jordan Zucker on 6/21/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

extension UIView {
    
    static func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
}

extension UIView {
    
    func forceAutolayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}

extension UIView {
    
    func animateButtonPress(and completion: @escaping (Bool) -> (Void)) {
        let originalTransform = self.transform
        UIView.animate(withDuration: 0.01, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .layoutSubviews, .allowAnimatedContent, .curveEaseInOut], animations: {
            self.transform = originalTransform.scaledBy(x: 0.5, y: 0.5)
            self.layoutIfNeeded()
        }) { (finished) in
            UIView.animate(withDuration: 0.02, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .layoutSubviews, .allowAnimatedContent, .curveEaseInOut], animations: {
                self.transform = originalTransform.scaledBy(x: 1.1, y: 1.1)
                self.layoutIfNeeded()
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.01, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: [.allowUserInteraction, .layoutSubviews, .allowAnimatedContent, .curveEaseInOut], animations: {
                    self.transform = originalTransform
                    self.layoutIfNeeded()
                }, completion: { (finished) in
                    completion(finished)
                })
            })
        }
    }
    
}
