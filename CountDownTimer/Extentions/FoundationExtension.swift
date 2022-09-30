//
//  FoundationExtension.swift
//  CountDownTimer
//
//  Created by Nitin Bhatia on 24/09/22.
//

import Foundation
import UIKit

extension Int{
    func appendZeros() -> String {
        if (self < 10) {
            return "0\(self)"
        } else {
            return "\(self)"
        }
    }
    
    func degreeToRadians() -> CGFloat {
       return  (CGFloat(self) * .pi) / 180
    }
}
