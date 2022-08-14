//
//  AutoCorrect.swift
//  Haptic
//
//  Created by Joe Manto on 5/31/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit

class replacement:NSObject{
    var replacement:String?
    let isAbsolute:Bool?
    init(replacement:String = "",isAbsolute:Bool = false) {
        self.replacement = replacement
        self.isAbsolute = isAbsolute
    }
}

class AutoCorrect: NSObject {
    
    //set of Aspostrophe word replacements of length 3 and under
    let smallApostropheReplacement:Dictionary<String,replacement> = [
        "hes":replacement(replacement: "he's",isAbsolute: true),
        "its":replacement(replacement: "it's",isAbsolute: true),
        "ive":replacement(replacement: "I've",isAbsolute: true),
        "im":replacement(replacement: "i'm",isAbsolute: true),
        "i":replacement(replacement: "I",isAbsolute: true),
        "ill":replacement(replacement: "i'll",isAbsolute: false),
        "id":replacement(replacement: "i'd",isAbsolute: false),
        "itd":replacement(replacement: "it'd", isAbsolute: true)
    ]
    
    //set of Aspostrophe word replacements of length 4
    let middleApostropheReplacement:Dictionary<String,replacement> = [
        "dont":replacement(replacement: "don't",isAbsolute: true),
        "itll":replacement(replacement: "it'll",isAbsolute: true),
        "youd":replacement(replacement: "you'd",isAbsolute: true),
        "whos":replacement(replacement: "who's",isAbsolute: true),
        "lets":replacement(replacement: "let's",isAbsolute: false),
        "aint":replacement(replacement: "ain't",isAbsolute: true),
        "whod":replacement(replacement: "who'd",isAbsolute: true),
        "cant":replacement(replacement: "can't",isAbsolute: true)
    ]
    
    let dayNamesReplacement:Dictionary<String,replacement> = [
        "sunday":replacement(replacement:"Sunday",isAbsolute: false),
        "monday":replacement(replacement:"Monday",isAbsolute: false),
        "tuesday":replacement(replacement:"Tuesday",isAbsolute: false),
        "wednesday":replacement(replacement:"Wednesday",isAbsolute: false),
        "thursday":replacement(replacement:"Thursday",isAbsolute: false),
        "friday":replacement(replacement:"Friday",isAbsolute: false),
        "saturday":replacement(replacement:"Saturday",isAbsolute: false),
    ]
    
    func findReplacement(word:String) -> replacement?{
        let isFirstCap = word.first?.isUppercase
        let lowerCasedWord = word.lowercased()
        let wordLength = word.count
        let replacementDic:Dictionary<String, replacement>?
        
        if(wordLength <= 3){
            replacementDic = smallApostropheReplacement
        }else if (wordLength < 5){
            replacementDic = middleApostropheReplacement
        }else if (wordLength > 5 && wordLength <= 9){
            replacementDic = dayNamesReplacement
        }else{
            return nil
        }
        if let replacement = replacementDic![lowerCasedWord] {
            if(isFirstCap!){
                replacement.replacement?.capitalizeFirstLetter()
            }
           return replacement
        }
        return nil
    }

}
