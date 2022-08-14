//
//  WordSuggestions.swift
//  Haptic
//
//  Created by Joe Manto on 1/17/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit


extension String{
    public func removingCharacters(in set:CharacterSet) -> String{
        let filtered = unicodeScalars.lazy.filter{
            !set.contains($0)
        }
        return String(String.UnicodeScalarView(filtered))
        }
    }

class WordSuggestions: NSObject {
    
    private var WORDCOUNT:[String:Int] = [:]
    private var alphabet = ",'abcdefghijklmnopqrstuvwxyz"
    
    struct WordRecord {
        var currentWord = ""
        var location = 0
        var range = 0
    }
    
    var currentRecord = WordRecord()
    
    override init() {
        super.init()
        let sharedUserDefaults = UserDefaults(suiteName: "group.hapticfeedbackkeyboard")
        let data = sharedUserDefaults?.value(forKey: "words")
        if(data != nil){
            WORDCOUNT = data as! [String : Int]
        }
    }
    
    func correct(word1:String) -> String{
        let word = word1.lowercased()
        if(WORDCOUNT[word] != nil){
            return word1
        }
       
        var maxCount = 0
        var correctWord = word
        let editDistance1Words = editDistance1(word: word)
        var editDistance2Words:[String] = []
        
        for edit1Word in editDistance1Words{
            editDistance2Words.append(contentsOf: editDistance1(word: edit1Word))
        }
        
        for edit1Word in editDistance1Words{
            if WORDCOUNT[edit1Word] != nil{
                if(WORDCOUNT[edit1Word]! > maxCount){
                    maxCount = WORDCOUNT[edit1Word]!
                    correctWord = edit1Word
                }
            }
        }
        
        var maxCount2 = 0
        var correctWord2 = correctWord
        
        for edit2Word in editDistance2Words{
            if WORDCOUNT[edit2Word] != nil{
                maxCount2 = WORDCOUNT[edit2Word]!
                correctWord2 = edit2Word
            }
        }
        
        if word.count < 6{
            if maxCount2 > 100*maxCount{
                return correctWord2
            }
            return correctWord
        }else{
            if maxCount2 > 4*maxCount{
                return correctWord2
            }
            return correctWord
        }
    }
    
   private func editDistance1(word:String) -> [String]{
        var results:[String] = [];
        
        for c in stride(from: 0, to: word.count+1, by: 1){
            for letter in alphabet{
                var newWord = word
                let insertIndex = word.index(word.startIndex, offsetBy: c)
                newWord.insert(letter, at: insertIndex)
                results.append(newWord)
            }
        }
        
        if(word.count > 1){
            for c in stride(from: 0, to: word.count-1, by: 1){
                var newWord = word
                let removeIndex = word.index(word.startIndex, offsetBy: c)
                newWord.remove(at: removeIndex)
                results.append(newWord)
            }
        }
        
        if(word.count > 1){
            for c in stride(from: 0, to: word.count-1, by: 1){
                var newWord = word
                let removeIndex = word.index(word.startIndex, offsetBy: c)
                let insertIndex = word.index(word.startIndex, offsetBy: c+1)
                let temp = newWord.remove(at: removeIndex)
                newWord.insert(temp, at: insertIndex)
                results.append(newWord)
            }
        }
        for c in stride(from: 0, to: word.count, by: 1){
            for letter in alphabet{
                var newWord = word
                let removeIndex = word.index(word.startIndex, offsetBy: c)
                let insertIndex = word.index(word.startIndex, offsetBy: c)
                newWord.remove(at: removeIndex)
                newWord.insert(letter, at: insertIndex)
                results.append(newWord)
            }
        }
        return results
    }

    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func loadBigData(name:String,type:String) -> String{
        var contents:String = ""
        if let filePath = Bundle.main.path(forResource: name, ofType: "txt") {
            do{
                contents = try String(contentsOfFile: filePath)
            } catch {
                print("Contents could not be loaded")
            }
        }else{
            print("File \(name) not file")
        }
        return contents
    }

    
    func updateCurrentWord(prox:UITextDocumentProxy) -> WordRecord {
        if(prox.documentContextBeforeInput == nil){
            if(prox.documentContextAfterInput == nil){
                currentRecord.currentWord = ""
                return currentRecord
            }else{
                currentRecord.currentWord = prox.documentContextAfterInput!//?.lowercased())!
                currentRecord.range = (prox.documentContextAfterInput?.count)!
                return currentRecord
            }
        }
        
        if let index = prox.documentContextBeforeInput?.lastIndex(of: " "){
            currentRecord.location = (prox.documentContextBeforeInput?.distance(from: (prox.documentContextBeforeInput?.startIndex)!, to: index))!+1
        }else{
            currentRecord.location = 0
        }
        
        var before = prox.documentContextBeforeInput?.components(separatedBy: " ").last!
        currentRecord.range = (before?.count)!
        
        let after = prox.documentContextAfterInput
        
        //add all chars after insertion point intill " " (change to character set so .?! get stoped too)
        if(after != nil){
            for char in after!{
                let charToCheck = CharacterSet(charactersIn:String(char))
                if(char == " " || charToCheck.isSubset(of: .symbols)){break}
                before!.append(char)
                currentRecord.range += 1
            }
        }
        //before = before?.lowercased()
        
        //remove symbols and update currentWord
        //let set = CharacterSet(charactersIn: alphabet)
        //before = before?.removingCharacters(in: set.inverted)
        currentRecord.currentWord = before!
        
        print("Current word is \(currentRecord.currentWord) with a range of {location:\(currentRecord.location),range:\(currentRecord.range)}")
       
        return currentRecord
    }
}

