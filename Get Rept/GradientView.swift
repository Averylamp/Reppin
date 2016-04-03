//
//  GradientView.swift
//  Get Rept
//
//  Created by Sebastian Cain on 4/2/16.
//  Copyright © 2016 Avery Lamp. All rights reserved.
//
import UIKit

class GradientView: UIView {
    override func drawRect(rect: CGRect) {
        super.drawRect(frame)
        
        let startColor = UIColor(red: 115/255.0, green: 200/255.0, blue: 169/255.0, alpha: 1.0)
        let endColor = UIColor(red: 55/255.0, green: 59/255.0, blue: 68/255.0, alpha: 1.0)
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.CGColor, endColor.CGColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace,
                                                  colors,
                                                  colorLocations)
        
        //6 - draw the gradient
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:self.frame.width, y:self.frame.height)
        CGContextDrawLinearGradient(context,
                                    gradient,
                                    startPoint,
                                    endPoint,
                                    [])
    }
}
