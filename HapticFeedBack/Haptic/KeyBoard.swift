//
//  KeyBoard.swift
//  Haptic
//
//  Created by Joe Manto on 10/20/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import UIKit


class KeyBoard: NSObject {
    
    // array of current keys in use
    var keysObj:[[KeyButton]] = [];
    /* array of current special keys in use
     [Notice] Special Keys are changed to act as different special keys.*/
    var specialKeys:[KeyButton] = [];
    
    //The different keyboard layouts
    enum keyboardLayoutType {
        case enLetters
        case numbers
        case alt
    }
    private var currentLayoutType:keyboardLayoutType = .enLetters
    var capsToggle = true
    private var numbersToggle = false
    private var altToggle = false
    private var numBackspaceRan = 0
    private var hardCapsToggle = false
    private let prox:UITextDocumentProxy!
    
    /*
     [needed] - keys name to enLetters
     | keyboard layouts
     */
    public let numberKeys =   [["1","2","3","4","5","6","7","8","9","0"],
                               ["-","/",":",";","(",")","$","&","@","\""],
                               [".",",","?","!","'"]]
    
    public let altKeys =     [["[","]","{","}","#","%","^","*","+","="],
                              ["_","\\","|","~","<",">","€","£","¥","∙"],
                              [".",",","?","!","'"]]
    
    public let keys =        [["Q","W","E","R","T","Y","U","I","O","P"],
                              ["A","S","D","F","G","H","J","K","L"],
                              ["Z","X","C","V","B","N","M"]]
    
    
    private var btnWidth:CGFloat?
    private var btnHeight:CGFloat = 45.0
    private let btnVertGap:CGFloat = 10.0
    private var btnstartingY:CGFloat = 5//6.0+42//52
    private let btnRowGap:CGFloat = 5.0
    private var oldWidth:CGFloat? //The width before a flip of the keyboard
    private var timer:Timer!
    private var lastKeyPressed:String!
    
    let controller:KeyButtonEvents?
    init(controller:KeyButtonEvents,prox:UITextDocumentProxy,hasExtendedFunctionalMenu:Bool){
        self.controller = controller
        self.prox = prox
        if(self.prox.documentContextBeforeInput != nil){
            capsToggle = false
        }
        if(hasExtendedFunctionalMenu){
            self.btnstartingY = (6.0+42)
        }
        
    }
    
    /*Gives rowDetails like starting x postion and buttonWidth for that row of buttons
     @CGFloat:viewWidth - used as a basis for buttonwidth and starting x pos
     @Int:rowcount - current amount of keys in the row
     @CGFloat:gap - gap inbetween Keys
     @CGFloat:IndentNumRows - the number of keys to indent the starting x pos
     <- CGFloat:starting x
     <- CGFloat:button width
     */
    func getRowDetails(viewWidth:CGFloat,for rowCount:Int,withgap:CGFloat,IndentNumRows:CGFloat) -> (x:CGFloat,buttonWidth:CGFloat){
        let buttonWidth = (viewWidth-(withgap*CGFloat(rowCount)))/CGFloat(rowCount)
        let halfBlock = buttonWidth*IndentNumRows+withgap*IndentNumRows
        let buttonWidthTemp = buttonWidth - (halfBlock*2)/CGFloat(rowCount)
        return (halfBlock+2.5,buttonWidthTemp)
    }
    
    /*Configs all the basic button
     Configs for the .enLetters keyboard layout by defualt
     @UIView:view given for the frame size of the custom view
     <- UIView: view with all the Keys added as subviews
     */
    func configBasicLayout(view:UIInputView) -> UIInputView{
        var y:CGFloat = btnstartingY
        oldWidth = view.frame.width
        let rowGap:CGFloat = btnRowGap
        for (i,keysArray) in keys.enumerated(){
            var row:[KeyButton] = []
            var rowDetails = getRowDetails(viewWidth: view.frame.width, for: (keys.first?.count)!, withgap: rowGap, IndentNumRows: 0.0)
            if i == 1{
                btnWidth = rowDetails.buttonWidth
                rowDetails.x += (rowDetails.buttonWidth+rowGap)/2
            }else if i == 2{
                rowDetails.x += ((rowDetails.buttonWidth+rowGap)/2)*3
            }
            for (x,key) in keysArray.enumerated(){
                let testKey:KeyButton = KeyButton(value: key, buttonFrame: CGRect(x: rowDetails.x, y: y, width: rowDetails.buttonWidth, height: btnHeight), orientation: popUpKeyView.popupOrientation.center, withStyle: KeyButton.buttonStyle.white)
                
                //set insets for different positions of keys
                if(x == keysArray.count-1){
                    testKey.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -rowGap/2, bottom: -btnVertGap/2, right: -(view.frame.width - (testKey.frame.origin.x+testKey.frame.width)))
                }else if (x == 0){
                    testKey.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -testKey.frame.origin.x, bottom: -btnVertGap/2, right: -rowGap/2)
                }else{
                    testKey.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -rowGap/2, bottom: -btnVertGap/2, right: -rowGap/2)
                }
                
                testKey.delegate = self.controller
                row.append(testKey)
                view.addSubview(testKey)
                rowDetails.x+=rowDetails.buttonWidth+rowGap
            }
            keysObj.append(row)
            y+=btnHeight+btnVertGap
        }

        if(capsToggle == false){
            keysToLower()
        }
        
        return view
    }
    
    /*Handles all key inputs and uses the text proxy to make changes to the textview
     Toggles setting based on keyboard intercationn
     @UITextDocumentProxy:prox - doc prox from the controller class
     @KeyButton:sender - The key that was pressed
     */
    func handleKeyInputs(prox:UITextDocumentProxy,sender:KeyButton){
        let keyCount = sender.keyValue.count
        print("button pressed %s",sender.keyValue)
        
        //if input is a single char then just print that to the proxy
        if(keyCount==1){
            lastKeyPressed = sender.keyValue
            prox.insertText(sender.keyValue)
            if(capsToggle && hardCapsToggle == false){
                toggleCaps(sender: specialKeys[0])
            }
        }else{
            switch(sender.keyValue){
            case "RT":
                prox.insertText("\n")
            case "<-":
                backSpace(DocumentProxy: prox)
                break
            case "space":
                if(prox.documentContextBeforeInput?.last == "."){
                    print("toggling caps")
                    toggleCaps(sender: specialKeys[0])
                }
                prox.insertText(" ")
                break
            case "caps":
                print("toogle")
                toggleCaps(sender: sender)
                break
            default:
                break
            }
        }
    }
    
    /*Removes text from the textDocument for a given tap or hold from the backspace key
     @UITextDocumentProxy:DocumentProxy - used for changing the text document*/
    func backSpace(DocumentProxy:UITextDocumentProxy){
       // guard DocumentProxy.documentContextBeforeInput != nil || DocumentProxy.selectedText?.count != 0 else{print("returned")
            //return}
        if(DocumentProxy.selectedText != nil){
            print("removing selected text")
            for _ in 1...(DocumentProxy.selectedText?.count)!{
                DocumentProxy.deleteBackward()
            }
        }else if(DocumentProxy.documentContextBeforeInput?.last != nil){
            DocumentProxy.deleteBackward()
        }
        if(DocumentProxy.documentContextBeforeInput?.last == nil){
            if !capsToggle{ toggleCaps(sender: specialKeys[0])}
        }
    }
    
    
    /*[need] - add the ability to only change caps when the layout is equal to .enLetters
     Changes all the keys in the keylayout .enLetters to lower case or upper case
     @KeyButton:sender - the caps lock button*/
    func toggleCaps(sender:KeyButton){
        
        hardCapsToggle = false
       
        if(currentLayoutType == .enLetters){
            DispatchQueue.main.async {
                if self.capsToggle{
                    self.specialKeys[0].setImage(UIImage(named: "capsOn"), for: UIControl.State.normal)
                    //self.specialKeys[0].backgroundColor = UIColor.white
                }else{
                    self.specialKeys[0].setImage(UIImage(named: "capsOff"), for: UIControl.State.normal)
                    //self.specialKeys[0].backgroundColor = UIColor.white
                }
            }
   
            if capsToggle{
                keysToLower()
            }else{
                keysToUpper()
            }
            
        
            capsToggle = !capsToggle
            print("toggled caps -> %b (true-upper | false-lower)",capsToggle)
        }
        
    }
    
    /*changes the caps icon to hardcaps and toggles caps if the layout is lower case
     @KeyButton:sender - the caps lock button*/
    @objc func toggleHardCaps(sender:KeyButton) -> Bool{
        //if(sender.titleLabel?.text == nil){return false}
        if(capsToggle == false){
            toggleCaps(sender: specialKeys[0])
        }
        
        hardCapsToggle = true
        specialKeys[0].setImage(UIImage(named: "hardCaps"), for: UIControl.State.normal)
        return true
    }
    
    @objc func repeatBackSpace(gesture: UILongPressGestureRecognizer){
        var charDeleted = 0
        if gesture.state == .began {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (_) in
                charDeleted+=1
                if charDeleted > 20 && self.prox.documentContextBeforeInput?.last != " "{
                    while(self.prox.documentContextBeforeInput?.last != " " && self.prox.documentContextBeforeInput?.last != nil){
                        self.controller?.keyPress(sender: self.specialKeys[1])
                        //self.backSpace(DocumentProxy: self.prox)
                    }
                }else{
                    self.controller?.keyPress(sender: self.specialKeys[1])
                    //self.backSpace(DocumentProxy: self.prox)
                }
            }
        }
        if gesture.state == .ended {
            timer?.invalidate()
        }
    }
    
    @objc func doubleSpace(gesture:UITapGestureRecognizer){
        if(lastKeyPressed != "." && lastKeyPressed != " " && lastKeyPressed != nil){
            prox.deleteBackward()
            prox.insertText(". ")
            lastKeyPressed = "."
        }else{
            prox.insertText("  ")
        }
    }
    
    
    func keysToLower(){
        for keys in keysObj{
            for key in keys{
                key.switchToLowercase()
            }
        }
    }
    
    func layoutIsAlt() -> Bool{
        if(currentLayoutType == .enLetters){return false}
        return true
    }
    
    func keysToUpper(){
        for keys in keysObj{
            for key in keys{
               key.switchToUppercase()
            }
        }
    }
    
    func adjustKeyCaseForKeyboardSwap(){
        if(getCapsToggle() == false){
            keysToLower()
        }
    }
    
    func getCapsToggle() -> Bool{
        return capsToggle
    }
    
    /*sets the class variables and specialKeys to reflect the change of keyboard layout to reflect the number layout
     @KeyButton:sender - the numbers special key*/
    func toggleNumber(sender:KeyButton) -> Bool{
        capsToggle = false
        altToggle = false
        sender.changeButtonText(newValue: "abc")
        specialKeys[0].turnImageButtonIntoText(value: "#=+")
        specialKeys[0].backgroundColor = GlobalColors.specialButtonsColor
        return true
    }
    
    /*set the class variables and specialKeys to reflect the change of keyboard layout to reflect the english letters layout
     @KeyButton:sender - the english letters special key
     <- bool: if you can switch to engLetters*/
    func toggleEnLetter(sender:KeyButton,view:UIView) -> Bool{
        specialKeys[0].backgroundColor = GlobalColors.buttonColor
        specialKeys[0].removeFromSuperview()
        
        //change back to the caps image
        if(capsToggle){
            specialKeys[0] = KeyButton(value: "caps", buttonFrame: specialKeys[0].frame, orientation: popUpKeyView.popupOrientation.center, withStyle: KeyButton.buttonStyle.white, with: KeyButton.buttonImage.capsOn)
        }else{
            specialKeys[0] = KeyButton(value: "caps", buttonFrame: specialKeys[0].frame, orientation: popUpKeyView.popupOrientation.center, withStyle: KeyButton.buttonStyle.white, with: KeyButton.buttonImage.capsOff)
        }
        specialKeys[0].delegate = self.controller
        
        //add the tapGesture back to the new caps button
        let tapTwice = UITapGestureRecognizer(target: self, action: #selector(toggleHardCaps))
        tapTwice.numberOfTapsRequired = 2
        specialKeys[0].addGestureRecognizer(tapTwice)
        
        sender.changeButtonText(newValue: "123")
        view.addSubview(specialKeys[0])
        
        return true
    }
    
    
    /*set the class variables and specialKeys to reflect the change of keyboard layout to reflect the alt letters layout
     @KeyButton:sender - the english letters special key
     <- bool: if you can switch to alt letters**/
    func toggleAlt(sender:KeyButton) -> Bool{
        sender.changeButtonText(newValue: "123")
        sender.backgroundColor = GlobalColors.specialButtonsColor
        return true
    }
    
    /* {UTIL}
     Gets the keyboard layout array based on the keyboardType given
     @KeyboardLayoutType:layoutType
     <-[[String]] keyboardLayout*/
    func getKeyLayoutArrayForType(layoutType:keyboardLayoutType)->[[String]]{
        switch layoutType {
        case .enLetters:
            return keys
        case .numbers:
            return numberKeys
        case .alt:
            return altKeys
        }
    }
    
    /*Swaps a current keyboard layout for a new one
     First changes the keysObj array of keys to reflect the new layout (add/remove)
     on removemal of a key the object is removed from the superview and remove from the array
     on add of a key the object is created and append and also flaged as not in the super view
     Finally calls and updates keyvalues and calls to update button frames based on the new layout
     @UIView:view - Should be removed
     @keyboardLayoutType:layoutType - keylayout to be added*/
    func swapKeyboardLayout(view:UIView,layoutType:keyboardLayoutType){
        currentLayoutType = layoutType
        let keyLayout = getKeyLayoutArrayForType(layoutType: layoutType)
        for (i,keys) in keysObj.enumerated(){
            if(keyLayout[i].count > keys.count){
                while(keyLayout[i].count > keysObj[i].count){
                    let key = KeyButton(value: keyLayout[i].last!, buttonFrame:CGRect(x: 0, y: 0, width: 0, height: 0),orientation:popUpKeyView.popupOrientation.center)
                    key.addedToParentView = false
                    keysObj[i].append(key)
                }
            }else if keyLayout[i].count < keys.count{
                while(keyLayout[i].count < keysObj[i].count){
                    keysObj[i].last?.removeFromSuperview()
                    keysObj[i].remove(at: keysObj[i].count-1)
                }
            }
        }
        updateKeyValuesForNewLayout(keyLayout:keyLayout)
        updateButtonFrames(view: view, width: view.frame.width, deviceFlip: false)
    }
    
    /*Updates all the keys keyvalues and button titles to reflect a change in keyvalues
     @[[String]]:keyLayout - new key layout*/
    func updateKeyValuesForNewLayout(keyLayout:[[String]]) {
        for (y,keys) in keysObj.enumerated(){
            for (x,key) in keys.enumerated(){
                key.changeButtonText(newValue:keyLayout[y][x])
            }
        }
    }
    
    /*Like the config function but updated all the basic letter keys with new button frames
     Call when device is fliped and change of keyboard layout
     @UIView:view - should remove
     @CGFloat:width - used for size of the button frame
     @Bool:deviceFlip - if false then a change in just the layout if true then special key frames are also effected*/
    func updateButtonFrames(view:UIView,width:CGFloat,deviceFlip:Bool){
        var y:CGFloat = btnstartingY
        let rowGap:CGFloat = btnRowGap
        for (i,keys) in keysObj.enumerated(){
            var rowDetails = getRowDetails(viewWidth: width, for: 10, withgap: rowGap, IndentNumRows: 0.0)
            if i == 1{
                btnWidth = rowDetails.buttonWidth
                if(currentLayoutType == .enLetters){rowDetails.x += (rowDetails.buttonWidth+rowGap)/2}
            }else if i == 2{
                if(currentLayoutType == .enLetters){
                    rowDetails.x += ((rowDetails.buttonWidth+rowGap)/2)*3
                }else{
                    rowDetails.x += ((rowDetails.buttonWidth+rowGap)/2)*4
                    rowDetails.buttonWidth = rowDetails.buttonWidth+8.0
                }
            }
            for (x,key) in keys.enumerated(){
                key.frame = CGRect(x: rowDetails.x, y: y, width: rowDetails.buttonWidth, height: btnHeight)
                //set insets for different positions of keys
                if(x == keys.count-1 && i != 2){
                    key.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -rowGap/2, bottom: -btnVertGap/2, right: -(view.frame.width - (key.frame.origin.x+key.frame.width)))
                }else if (x == 0){
                    key.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -key.frame.origin.x, bottom: -btnVertGap/2, right: -rowGap/2)
                }else{
                    key.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -rowGap/2, bottom: -btnVertGap/2, right: -rowGap/2)
                }
                
                rowDetails.x+=rowDetails.buttonWidth+rowGap
                if key.addedToParentView == false{
                    key.delegate = self.controller
                    print("Added new key to parentView %s",key.keyValue)
                    view.addSubview(key)
                }
            }
            y+=btnHeight+btnVertGap
        }
        if deviceFlip{
            updateSpecialKeys(width: width)
        }
    }
    
    /*apon a flip of the device this function is calls and changes the frames of all the special keys
     @CGFloat:width - The new width to be applied*/
    func updateSpecialKeys(width:CGFloat){
        /*var scaler:CGFloat = 0.0
        if(width > oldWidth!){
            scaler = 20.0
        }*/
        let keyHightWithGap = btnstartingY+(btnHeight+btnVertGap)
        let keyWidthWithGap = 2.5+(btnWidth!+btnRowGap)
        /*((keyWidthWithGap)*7)+2.5+scaler*/
        //specialKeys[0].frame = CGRect(x: 3, y: (keyHightWithGap*2-5.0)+(btnstartingY), width: btnWidth!+9.5, height: btnHeight)
        specialKeys[0].frame = CGRect(x: 3, y: (keyHightWithGap*2)+(btnstartingY-8), width: btnWidth!+9.5, height: btnHeight)
        specialKeys[1].frame = CGRect(x: width-(btnWidth!+9.5)-btnRowGap+2.5, y: keyHightWithGap*2+(btnstartingY-8), width: btnWidth!+9.5, height: btnHeight)
        specialKeys[2].frame = CGRect(x: 3, y: keyHightWithGap*3-10.0, width: btnWidth!+9.5, height: btnHeight)
        specialKeys[3].frame = CGRect(x: keyWidthWithGap+10, y: keyHightWithGap*3-10.0, width: btnWidth!+9.5, height: btnHeight)
        specialKeys[4].frame = CGRect(x: ((keyWidthWithGap)*2.5)-2.5, y: keyHightWithGap*3-7.5, width: ((keyWidthWithGap)*5 - (keyWidthWithGap/2)), height: btnHeight-5)
        specialKeys[5].frame = CGRect(x:(width-btnWidth!*2.5)-(5+btnRowGap), y: keyHightWithGap*3-10, width: btnWidth!, height: btnHeight)
        specialKeys[6].frame = CGRect(x:width-(btnWidth!+17.5)-btnRowGap+2.5, y: keyHightWithGap*3-10, width: btnWidth!+17.5, height: btnHeight)
        for key in specialKeys{
           
            if(key.keyValue == "space"){
                key.frameInset = UIEdgeInsets(top: -btnVertGap, left: -btnRowGap/2, bottom: -btnVertGap, right: -btnRowGap/2)
            }else{
                key.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -btnRowGap/2, bottom: -btnVertGap/2, right: -btnRowGap/2)
            }
            key.frame = CGRect(x: key.frame.origin.x, y: key.frame.origin.y-(btnstartingY*2)+8, width: key.frame.width, height: key.frame.height)
        }
        oldWidth = width
    }
    
    /*configs the special keys with values and frame
     @UIView:view - used to add views to parent view*/
    func configSpecialLayout(view:UIView){
        let keyHightWithGap = btnstartingY+(btnHeight+btnVertGap)
        let keyWidthWithGap = 2.5+(btnWidth!+btnRowGap)
        
        specialKeys.append(KeyButton(value: "caps", buttonFrame: CGRect(x: 3, y: keyHightWithGap*2-5.0, width: btnWidth!+9.5, height: btnHeight), orientation: popUpKeyView.popupOrientation.none, withStyle: KeyButton.buttonStyle.white, with: KeyButton.buttonImage.capsOn))
        let tapTwice = UITapGestureRecognizer(target: self, action: #selector(toggleHardCaps))
        tapTwice.numberOfTapsRequired = 2
        specialKeys.last?.addGestureRecognizer(tapTwice)
 
        specialKeys.append(KeyButton(value: "<-", buttonFrame: CGRect(x:(keyWidthWithGap*7.5+btnWidth!)-3, y: keyHightWithGap*2-6.0, width: btnWidth!+9.5, height: btnHeight), orientation: popUpKeyView.popupOrientation.none, withStyle: KeyButton.buttonStyle.grey, with: KeyButton.buttonImage.delete))
        specialKeys.last?.imageView?.tintColor = UIColor.black
        
        specialKeys.append(KeyButton(value: "123", buttonFrame: CGRect(x: 3, y: keyHightWithGap*3-10.0, width: btnWidth!+9.5, height: btnHeight), orientation: popUpKeyView.popupOrientation.none, withStyle: KeyButton.buttonStyle.grey))
        specialKeys.last?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        specialKeys.append(KeyButton(value: "globe", buttonFrame: CGRect(x: keyWidthWithGap+10, y: keyHightWithGap*3-10.0, width: btnWidth!+9.5, height: btnHeight), orientation: popUpKeyView.popupOrientation.none, withStyle: KeyButton.buttonStyle.grey,with:KeyButton.buttonImage.globe))
        
        specialKeys.append(KeyButton(value: "space", buttonFrame: CGRect(x: ((keyWidthWithGap)*2.5)-2.5, y: keyHightWithGap*3-7.5, width: ((keyWidthWithGap)*5 - (keyWidthWithGap/2)), height: btnHeight-5), orientation: popUpKeyView.popupOrientation.none, withStyle: KeyButton.buttonStyle.white))
        specialKeys.last?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        specialKeys.append(KeyButton(value: ".", buttonFrame: CGRect(x: ((keyWidthWithGap)*7)+2.5, y: keyHightWithGap*3-10, width: btnWidth!, height: btnHeight), orientation: popUpKeyView.popupOrientation.none, withStyle: KeyButton.buttonStyle.grey))
        
        specialKeys.append(KeyButton(value: "RT", buttonFrame: CGRect(x: keyWidthWithGap*8, y: keyHightWithGap*3-10, width: btnWidth!+17.5, height: btnHeight), orientation: popUpKeyView.popupOrientation.none, withStyle: KeyButton.buttonStyle.grey, with: KeyButton.buttonImage.ret))
        
        updateSpecialKeys(width: view.frame.width)
        for key in specialKeys{
            key.frameInset = UIEdgeInsets(top: -btnVertGap/2, left: -btnRowGap/2, bottom: -btnVertGap/2, right: -btnRowGap/2)
            key.delegate = controller.self
            view.addSubview(key)
        }
    
        let holdGesturer = UILongPressGestureRecognizer(target: self, action: #selector(repeatBackSpace(gesture:)))
        holdGesturer.minimumPressDuration = 0.3
        specialKeys[1].addGestureRecognizer(holdGesturer)
        
        let spaceDoubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleSpace(gesture:)))
        spaceDoubleTap.numberOfTapsRequired = 3
        specialKeys[4].addGestureRecognizer(spaceDoubleTap)
    
    }
    
    func updateKeysColors(){
        for key in specialKeys{
            key.backgroundColor = GlobalColors.specialButtonsColor
            key.setTitleColor(GlobalColors.textColor, for: UIControl.State.normal)
        }
        for keyArray in keysObj{
            print(GlobalColors.buttonColor)
            
            for key in keyArray{
                key.backgroundColor = GlobalColors.buttonColor
                key.setTitleColor(GlobalColors.textColor, for: UIControl.State.normal)
            }
        }
    }
    
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}
