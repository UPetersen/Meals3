//
//  IPodStyleRotationWheel.swift
//  Meals3
//
//  Created by Uwe Petersen on 23.04.22.
//  Copyright © 2022 Uwe Petersen. All rights reserved.
//

import Foundation
import SwiftUI

struct IPodStyleRotationWheel: View {
    
    @Binding var amount: NSNumber?
    let factor: CGFloat = 0.3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .foregroundColor(Color(.systemFill))
                
                Circle()
                    .frame(width: geometry.size.width * factor, height: geometry.size.width * factor)
                    .foregroundColor(Color(.systemBackground))
                
                Image(systemName: "arrow.2.circlepath")
                    .resizable()
                    .foregroundColor(Color(.systemBackground))
                    .aspectRatio(200/170, contentMode: .fit)
                    .padding()
            }
        }
        .foregroundColor(Color.brown)
        .gesture(rotationalDragGesture(amount: $amount))
    }
}



/// A rotational drag gesture for increasing or decreasing a numerical value, trying to mimic the rotational wheel interface, the first ipods had.
///
/// Attach this gesture to a shape of proper size (e.g. a circle).
///
/// Rotate your finger on the respective shape to increase or decrease a numerical value. Clockwhise rotation increases the value.
///
/// Be aware, that not the angle is used, but the distance the finger is moved. This is independent from the distance of the finger to the center or rotation and provides a more 'natural' feeling.
///
/// Binds to an `NSNumber?. Only positive values will be generated/allowed and instead of zero, nil is returned.
/// Please adapt accordingly if a Double? or anything smilar shall be returned.
///
/// Parameters:
///   - amount: `NSNumber`
///   The numerical value to be increased or decreased. Rounded to the next natural nummber.
struct rotationalDragGesture: Gesture {
    
    ///   The numerical value to be increased or decreased. Rounded to the next natural nummber.
    @Binding var amount: NSNumber?
    
    /// use this factor to scale the rotation to the desired range of values
    let scalingFactor: Double = 0.2
    
    /// Minimum translation of the drag to be used for updating the numerical value
    let minimumTranslationIncrement: CGFloat = 5.0
    
    /// State of the one finger rotation drag.
    ///
    /// To detect the angle of rotation with respect to the center of the circle (the amount the finger has moved circular), at least two different finger positions are needed.
    /// This enum is used to track in what state the drag is and especially if already two different values have been registered.
    enum DragState {
        /// The drag not yet started or already ended.
        case inactive
        /// The drag has begun, but there is was only one inital (current) value. So we can store this to be used as old value for when the next drag location is registered.
        case began
        /// There have been at least two drag values registerd, such that an old position could be set and the translation from the old to the new (current) position can be calculated.
        case isDragging
    }
    
    // State of the drag
    @GestureState var dragState: DragState = .inactive
    
    // Stores the location of the previous drag point
    @State var oldLocation = CGPoint()
    
    var body: some Gesture {
        
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .updating($dragState) { value, gestureState, transaction in
                // use .updating only to change and adapt the state of the gesture
                switch gestureState {
                case .inactive:
                    gestureState = .began
                case .began:
                    gestureState = .isDragging
                case .isDragging:
                    break
                }
            }
            .onEnded { value in
                self.oldLocation = CGPoint(x: 0.0, y: 0.0)
            }
            .onChanged { value in
                
                switch self.dragState {
                case .inactive:
                    break
                case .began:
                    self.oldLocation = value.location
                case .isDragging:
                    // Translation vector from the previous drag location point to the current drag location point
                    let translationIncrementVector = CGVector(from: oldLocation, to: value.location)
                    // The magnitude of the translation, i.e. the increment or distance between the last point and the current point of the drag motion
                    let translationIncrementMagnitude = translationIncrementVector.magnitude
                    if translationIncrementMagnitude >= minimumTranslationIncrement {
                        // Absolute angle of the old location with respect to the center of the roation
                        let absoluteAngle = -Angle(radians: Double(atan2(self.oldLocation.y - 150.0, self.oldLocation.x - 150.0)))
                        // TranslationVector transformed into the coordinate system of the vector from the center of the rotation to the old location
                        // If the dy-value (its y-coordinate) is positive, we have a positive incrementation (i.e. the numerical value will increase)
                        let rotatedTranslationVector = translationIncrementVector.rotated(by: absoluteAngle.radians)
                        
                        let amountDelta = scalingFactor * ( rotatedTranslationVector.dy >= 0 ? Double(translationIncrementMagnitude) : Double(-translationIncrementMagnitude) )
                        let nonNilAmount = max(0.0, (self.amount?.doubleValue ?? 0.0) +  amountDelta ).rounded()
                        self.amount = nonNilAmount <= 0.0000001 ? nil : NSNumber(value: nonNilAmount) // if amount is zero -> make it nil to show the placeholder (and do not allow to store the value)
                        
                        self.oldLocation = value.location
                    }
                }
            }
    }
}


