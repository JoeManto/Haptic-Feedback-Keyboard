//
//  FallIngObject.swift
//  Tactical Haptic Keyboard
//
//  Created by Joe Manto on 12/28/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import UIKit

class FallIngObject: UIView {
    
    var y:CGFloat = 0
    var x:CGFloat = 0
    var size:CGFloat = 0
    var pageHeight:CGFloat = 0
    var pageWidth:CGFloat = 0
    var color:CGFloat = 255.0;
    
    init(parentViewSize:CGRect){
        self.pageWidth = parentViewSize.width
        self.pageHeight = parentViewSize.height
        x = CGFloat(Int.random(in: 0..<Int(pageWidth)))
        size = CGFloat(Int.random(in: 5..<30))
        super.init(frame:CGRect(x:self.x, y: 0, width: size, height: size))
        
        self.layer.cornerRadius = frame.width/2
        self.layer.masksToBounds = true
        self.setZPos()
        self.setBackgroundColor()
        
        y = frame.origin.y
        x = frame.origin.x
        fall()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fall(){
        self.y = pageHeight
        let length:Double = Double.random(in: 4.5..<14.0)
        UIView.animate(withDuration: length, animations: {
            self.frame = CGRect(x:self.x, y: self.y,
                                width: self.frame.width,
                                height: self.frame.height)
            
            
        },completion:{_ in self.setConstantsThenFall()})
        UIView.animate(withDuration: length, animations: {
            self.backgroundColor = UIColor.white
        })
    }
    
    func setConstantsThenFall() {
        x = CGFloat(Int.random(in: 0..<Int(pageWidth)))
        size = CGFloat(Int.random(in: 5..<30))
        self.frame = CGRect(x: x, y: 0, width: size, height: size)
        self.layer.cornerRadius = frame.width/2
        self.layer.masksToBounds = true
        self.setZPos()
        self.setBackgroundColor()
        y = frame.origin.y
        x = frame.origin.x
        fall()
    }
    
    func setZPos(){
        self.layer.zPosition = CGFloat(Int.random(in: 2..<10))
    }
    
    func setBackgroundColor(){
        let colorValue:CGFloat = CGFloat(Int.random(in: 235..<250))
        self.backgroundColor = UIColor.init(red: colorValue/255,
                                            green: colorValue/255,
                                            blue: colorValue/255, alpha: 1)
    }
    
    
    
}
