//
//  popUpKeyView.swift
//  Haptic
//
//  Created by Joe Manto on 10/19/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import UIKit

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class popUpKeyView: UIView {
    
    enum popupOrientation {
        case center
        case right
        case left
        case none
    }
    
    init(frame: CGRect,orientation:popupOrientation) {
        super.init(frame: frame)
        setup(orientation: orientation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*builds the popup
     @popupOrientation:orientation - determines the way the popup looks*/
    func setup(orientation:popupOrientation) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPopUpBezierPath(type:orientation).cgPath
        shapeLayer.strokeColor = GlobalColors.buttonColor.cgColor
        shapeLayer.fillColor = GlobalColors.buttonColor.cgColor
        shapeLayer.lineWidth = 1.0
        shapeLayer.position = CGPoint(x: 10, y: 23)
        self.layer.addSublayer(shapeLayer)
    }
    
    /*add a larger sized keyvalue to the view
     @String:value - current key value*/
    func addCharLabel(value:String){
        let char = UILabel(frame: CGRect(x: self.frame.width/2-5, y: self.frame.height/2, width: self.frame.width, height: self.frame.height))
        char.text = value
        char.textColor = GlobalColors.textColor
        char.font = UIFont.systemFont(ofSize: CGFloat(30.0))
        char.textAlignment = NSTextAlignment.center
        self.addSubview(char)
    }
    
    /*Create the Bezier path for a given orientation
     @popupOrientation:type
     <- UIBezierPath: path for CAShape*/
    func createPopUpBezierPath(type:popupOrientation) -> UIBezierPath {
        let path = UIBezierPath()
        let width = self.frame.width
        let height = self.frame.height
        let scaler:CGFloat = 18.0
        let tailHeight:CGFloat = 40
        let tailWidthScaler:CGFloat = 15
        let radius:CGFloat = 8
        path.move(to: CGPoint(x: -scaler+15, y: -10))
        if(type == popUpKeyView.popupOrientation.right){
            path.addLine(to: CGPoint(x: width+3, y: -10))
        }else{
            path.addArc(withCenter: CGPoint(x: width+scaler-radius-0.5, y: -10+radius), radius: radius,
                        startAngle: CGFloat(275).degreesToRadians,
                        endAngle: CGFloat(0).degreesToRadians,
                        clockwise: true)
            path.addLine(to: CGPoint(x: width+scaler, y: height-15))
            path.addCurve(to: CGPoint(x: width+scaler-tailWidthScaler, y: height+15),
                          controlPoint1: CGPoint(x: width+scaler+2, y: height+5),
                          controlPoint2: CGPoint(x: width+scaler-tailWidthScaler, y: height-5))
        }
        path.addLine(to: CGPoint(x: width+scaler-tailWidthScaler, y: height+tailHeight))
        path.addLine(to: CGPoint(x: -scaler+tailWidthScaler, y: height+tailHeight))
        if(type == popUpKeyView.popupOrientation.left){
            path.addLine(to: CGPoint(x: -scaler+tailWidthScaler, y: -10))
        }else{
            path.addLine(to: CGPoint(x: -scaler+tailWidthScaler, y: height+15))
            path.addCurve(to: CGPoint(x: -scaler, y: height-15),
                          controlPoint1: CGPoint(x: -scaler+tailWidthScaler, y: height-5),
                          controlPoint2: CGPoint(x: -scaler-2, y: height+5))
            path.addArc(withCenter: CGPoint(x: -scaler+radius, y: -10+radius), radius: radius,
                        startAngle: CGFloat(180).degreesToRadians,
                        endAngle: CGFloat(270).degreesToRadians,
                        clockwise: true)
        }
        path.close()
        return path
    }
    
}
