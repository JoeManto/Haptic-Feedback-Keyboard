//
//  TypingStats.swift
//  Haptic
//
//  Created by Joe Manto on 3/2/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit

protocol SuggestionsScheduler {
    func suggestionUpdateRequested()
}

class TypingStats: NSObject {
    
    var delegate:SuggestionsScheduler?
    private var timer:Timer!
    
    private var keyPresses:Int = 0
    private let refreshInterval = 2
    private var activeKeyPress = false
    private var processedNewChanges = false
    
    
    private var pressesInInterval:[Double] = []
    private var curModifyingIndex = 0
    
    override init() {
        super.init()
    }
    /*Start tracking the number of key presses*/
    func trackInputs(){
        var totalTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (_) in
            if totalTime == self.refreshInterval {
                self.createNewAvg(totalPresses: self.keyPresses, totalTime: totalTime)
                totalTime = 0
            }else{totalTime+=1}
            if(self.activeKeyPress == false && !self.processedNewChanges){
                self.requestUpdates()
                self.processedNewChanges = true
            }
            self.activeKeyPress = false
        }
    }
    
    private func createNewAvg(totalPresses:Int,totalTime:Int){
        self.keyPresses = 0
        if self.pressesInInterval.count < 5 {
            self.pressesInInterval.append(Double(totalPresses))
        }else{
            self.pressesInInterval[self.curModifyingIndex] = Double(totalPresses)
            if self.curModifyingIndex == 4 {self.curModifyingIndex = 0}else{self.curModifyingIndex+=1}
        }
    }
    
    func addKeyPressRecord(){
        self.keyPresses+=1
        self.activeKeyPress = true
        self.processedNewChanges = false
    }
    
    func getKeyAvgTime()->Int{
        return self.keyPresses
    }
    
    func stopTracking(){
        timer.invalidate()
    }
    
    func requestUpdates(){
        delegate?.suggestionUpdateRequested()
    }

}
