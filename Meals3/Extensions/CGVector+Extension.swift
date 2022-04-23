//
//  CGVector+Extension.swift
//  Meals3
//
//  Created by Uwe Petersen on 23.04.22.
//  Copyright © 2022 Uwe Petersen. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGVector {
    /// Magnitude of the vector.
    /// - Returns: the magnitude, i.e. sqrt(dx^2 + dy^2).
    var magnitude: CGFloat {
        return sqrt( (self.dx * self.dx) + (self.dy * self.dy) )
    }
    
    /// The Vector rotated by an angle.
    /// - Parameter angle: The angle in radians!
    /// - Returns: A new CGVector which is the old vector rotated by the angle.
    func rotated(by angle: Double) -> CGVector {
        let x = ( cos(CGFloat(angle)) * Double(self.dx) - sin(CGFloat(angle)) * Double(self.dy) )
        let y = ( sin(CGFloat(angle)) * Double(self.dx) + cos(CGFloat(angle)) * Double(self.dy) )
        return CGVector(dx: x, dy: y)
    }
    
    init(from start: CGPoint, to end: CGPoint) {
        self = CGVector(
            dx: end.x - start.x,
            dy: end.y - start.y
        )
    }
}
