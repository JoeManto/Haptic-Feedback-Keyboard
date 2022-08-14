//
//  GlobalColors.swift
//  Haptic
//
//  Created by Joe Manto on 10/24/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import UIKit

class GlobalColors: NSObject {
    
    enum colorMode {
        case light
        case dark
        case Tocean
        case Tred
        case Tdark
        case Tlightgrey
    }
    static var currentMode:colorMode = .light
    static var buttonColor = UIColor.white
    static var textColor = UIColor.black
    static var suggestionTextColor = UIColor.black
    static var specialButtonsColor = UIColor.init(red: 170/255, green: 175/255, blue: 184/255, alpha: 1)
    
    static func switchColorMode(mode:colorMode){
        guard mode != currentMode else{return}
        switch(mode){
        case .light:
            currentMode = .light
            buttonColor = UIColor.white
            textColor = UIColor.black
            suggestionTextColor = textColor
            specialButtonsColor = UIColor.init(red: 170/255, green: 175/255, blue: 184/255, alpha: 1)
            break
        case .dark:
            currentMode = .dark
            textColor = UIColor.white
            suggestionTextColor = textColor
            buttonColor = UIColor.init(red: 170/255, green: 175/255, blue: 184/255, alpha: 0.1)
            specialButtonsColor = UIColor.init(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.1)
            break
        case .Tocean:
            currentMode = .Tocean
            textColor = UIColor.white
            suggestionTextColor = UIColor.black
            buttonColor = UIColor.init(red: 6/255, green: 169/255, blue: 244/255, alpha: 1)
            specialButtonsColor = UIColor.init(red: 3/255, green: 155/255, blue: 229/255, alpha: 1)
            break
        case .Tred:
            currentMode = .Tred
            textColor = UIColor.white
            suggestionTextColor = UIColor.black
            buttonColor = UIColor.init(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
            specialButtonsColor = buttonColor
            break
        case .Tdark:
            currentMode = .Tdark
            textColor = UIColor.white
            suggestionTextColor = textColor
            buttonColor = UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
            specialButtonsColor = buttonColor
            break
        case .Tlightgrey:
            currentMode = .Tlightgrey
            textColor = UIColor.white
            suggestionTextColor = .white
            buttonColor = UIColor.init(red: 189/255, green: 189/255, blue: 189/255, alpha: 1)
            specialButtonsColor = buttonColor
        }
        
    }
}
