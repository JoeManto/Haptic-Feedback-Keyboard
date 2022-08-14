//
//  KeyboardViewController.swift
//  Haptic
//
//  Created by Joe Manto on 10/19/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import UIKit
import CoreHaptics

class KeyboardViewController: UIInputViewController,KeyButtonEvents,SuggestionsScheduler{

    private var keyboard:KeyBoard?
    private let sharedUserDefaults = UserDefaults(suiteName: "group.hapticfeedbackkeyboard")
   
    /*Values Held for user defualts settings*/
    
    //default dark mode setting is on or off
    lazy var hasDarkMode:Bool = true
    //default autocorrect setting is on or off
    lazy var needsSuggestionView:Bool = true
    //defualt autocorrect tune
    lazy var suggestionEngTune:Int = 1
    
    //defualt Theme selected by user
    private var theme:String = "Defualt"
    
    //Keyboard is in portrait mode
    private var keyboardIsPort = true
    //Determines if the keyboard has all the data to load
    private var shouldLoadKeyboard = false
    
    //emjois for emjoi replacements.
    var emojis = ["happy":"😀","thinking":"🙇🏽‍♂️","party":"🥳","cowboy":"🤠","crying":"😢",
                  "lmao":"😂","love":"❤️","kiss":"😗","ugh":"😒","meh":"😒","mad":"👿",
                  "poop":"💩","ok":"👌","perfect":"👌","okay":"👌","clap":"👏","family":"👨‍👩‍👦‍👦",
                  "sun":"☀️","santa":"🎅","snow":"❄️","winter":"❄️","cold":"🥶","ghost":"👻",
                  "pizza":"🍕","beer":"🍺","fire":"🔥","hi":"👋","snowboarding":"🏂","swimming":"🏊‍♂️",
                  "sad":"😔"
    ]
    
    /*Prepare for haptic feedback view config*/
    var feedbackGenerator : UIImpactFeedbackGenerator = UIImpactFeedbackGenerator();
    
    let stats:TypingStats = TypingStats()
    var suggestionButtons:[UIButton] = []
    let genWordSuggestions = WordSuggestions()
    let autoCorrectHandler = AutoCorrect()
 
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print(self.view.backgroundColor!)
        
        
        var expandedHeight:CGFloat = 218
        
        /*Set gathered data from user defualts and set to the local vars*/
        let data1 = sharedUserDefaults?.value(forKey: "hasAutoCorrect")
        if(data1 != nil){//checks if the value has ever been set
            needsSuggestionView = data1 as! Bool
            if(needsSuggestionView){expandedHeight = 260}
            
        }else{
            needsSuggestionView = true
            expandedHeight = 260
        }
        
        let data2 = sharedUserDefaults?.value(forKey: "hasDarkMode")
        if(data2 != nil){
            hasDarkMode = data2 as! Bool
        }else{
            hasDarkMode = true
        }
        
        let data3 = sharedUserDefaults?.value(forKey: "suggestionEngTune")
        if(data3 != nil){
            suggestionEngTune = data3 as! Int
        }else{
            suggestionEngTune = 1
        }
        
        /*Change the contrains on the inputview to create a taller view*/
        weak var _heightConstraint:NSLayoutConstraint?
        super.viewWillAppear(animated)
        self.becomeFirstResponder()
        //let expandedHeight:CGFloat = 218//260//270//218
        guard nil == _heightConstraint else {return}
        let emptyView = UILabel(frame: .zero)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        
        let hightConstraint:NSLayoutConstraint = NSLayoutConstraint(
            item: self.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0.0,
            constant: expandedHeight)
        
        hightConstraint.priority = .required-1
        view.addConstraint(hightConstraint)
        _heightConstraint = hightConstraint
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldLoadKeyboard = checkIfDataIsLoaded()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //Set background color for the inputview so touches on the buttons frame after insets are applied.
        self.inputView?.backgroundColor = UIColor.init(red: 209/255, green: 211/255, blue: 217/255, alpha: 1)
        self.stats.delegate = self
        if(shouldLoadKeyboard){self.stats.trackInputs()}
        


        feedbackGenerator.prepare()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //checks if the keyboard should load
        if !shouldLoadKeyboard{
            //show that the keyboard needs the input data
            showDataNeedsToLoad()
            return
        }
        self.findStartUpTheme()
        
        //config keyboard and keyboard view
        keyboard = KeyBoard(controller:self,prox:self.textDocumentProxy,hasExtendedFunctionalMenu: self.needsSuggestionView)
        _ = keyboard?.configBasicLayout(view:self.inputView!)
        keyboard?.configSpecialLayout(view: self.inputView!)
        
        //config the the return key for the type of keyboard
        self.configKeyboardForType();
        
        //config suggestion buttons
        if(needsSuggestionView == true){
            configSuggestionButtons()
            clearSuggestionForNewSentence()
        }
        
        let curserMove = UILongPressGestureRecognizer(target: self, action: #selector(moveCurser(gesture:)))
        curserMove.allowableMovement = view.frame.width
        curserMove.minimumPressDuration = 1
        keyboard?.specialKeys[4].addGestureRecognizer(curserMove)
    }
    /**
      Updates the keyboard and suggestions views when the device rotates
      - Note:
    */
    func updateKeyboardView(){
        keyboard?.updateButtonFrames(view: self.view!, width: self.view.frame.width, deviceFlip: true)
        if self.needsSuggestionView {adjustSuggestionFrameForRotate()}
    }
    
    /**
     looks for rotations of the device.
     If the device is rotated all keyboard views are updated
     and the correct boolean value for the orination of the keyboard is set
     - Note:
     */
    override func viewDidLayoutSubviews() {
        //notificationFeedbackGenerator.prepare()
        if(UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height){
            if keyboardIsPort == false{
                print("updating keyboard to port")
                updateKeyboardView()
                keyboardIsPort = true
            }
        }
        else{
            if keyboardIsPort == true{
                print("updating keyboard to hori")
                updateKeyboardView()
                keyboardIsPort = false
            }
        }
    }
    
    /**
     Sender function for the space bar for tracking long presses
     This function creates a pan gesture and adds it to the space bar.
     - Note:
        This function is only used to insure that the pan guesture is not triggered before the long press
     */
    @objc func moveCurser(gesture:UILongPressGestureRecognizer){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(curserFindLocation(gesture:)))
        keyboard?.specialKeys[4].addGestureRecognizer(pan)
        
    }
    
    /**
     This function uses the a pan gesture to track the location
     of the paning to simulate the movement of the curser.
     - Note:
     */
    @objc func curserFindLocation(gesture:UIPanGestureRecognizer){
       let translation = gesture.translation(in: self.view)
        gesture.view!.center = CGPoint(x: gesture.view!.center.x+translation.x, y: gesture.view!.center.y+translation.y)
        
        print(gesture.view!.center.x)
    }

    /**
     This function configs the look and text in the return button
     and special key colors depending on the current keyboard type.
     - Note:
     */
    func configKeyboardForType(){
        let keyboardType = self.textDocumentProxy.keyboardType
        if(keyboardType != UIKeyboardType.default){
            keyboard?.specialKeys[6].backgroundColor = UIColor.init(red: 21/255, green: 126/255, blue: 251/255, alpha: 1)
            keyboard?.specialKeys[6].turnImageButtonIntoText(value: "Go")
            keyboard?.specialKeys[6].setTitleColor(UIColor.white, for: UIControl.State.normal)
            keyboard?.specialKeys[6].keyValue = "RT"
        }else{
            keyboard?.specialKeys[6].backgroundColor = GlobalColors.specialButtonsColor
        }
    }

    /**
     This function is a sender function of the key class and operates
     all the necessary that adjust the view of the keyboard
     - Note:
     */
    func keyPress(sender: KeyButton) {
        stats.addKeyPressRecord()
        if(needsSuggestionView && suggestionButtons[1].tag == 10){
            suggestionButtons[1].tag = 0
            suggestionButtons[1].titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            clearSuggestionForNewSentence()
        }
        switch(sender.keyValue){
        case "globe":
            advanceToNextInputMode()
            break
        case "123":
            if (keyboard?.toggleNumber(sender:sender))!{keyboard?.swapKeyboardLayout(view: self.view, layoutType: .numbers)}
            break
        case "#=+":
            if (keyboard?.toggleAlt(sender:sender))!{keyboard?.swapKeyboardLayout(view: self.view, layoutType: .alt)}
            break
        case "abc":
            if (keyboard?.toggleEnLetter(sender:sender, view: self.view))!{
                keyboard?.swapKeyboardLayout(view: self.view, layoutType: .enLetters)
                keyboard?.adjustKeyCaseForKeyboardSwap()
            }
        default:
            if(sender.keyValue == "caps"){
                for g:UIGestureRecognizer in (self.view.window?.gestureRecognizers)!{
                    g.delaysTouchesBegan = false
                }
            }else if (sender.keyValue == "space"){
                if((keyboard?.layoutIsAlt())! == true){
                    if (keyboard?.toggleEnLetter(sender:(keyboard?.specialKeys[2])!, view: self.view))!{
                        keyboard?.swapKeyboardLayout(view: self.view, layoutType: .enLetters)
                        keyboard?.adjustKeyCaseForKeyboardSwap()
                    }
                }else if(needsSuggestionView){
                    let currentRec = genWordSuggestions.currentRecord
                
                    if let quickReplacement:replacement = autoCorrectHandler.findReplacement(word: currentRec.currentWord){
                        if(quickReplacement.isAbsolute!){
                            _ = removeCurrentWord(record: currentRec)
                            textDocumentProxy.insertText(quickReplacement.replacement!)
                        }else{
                            suggestionButtons[1].setTitle(quickReplacement.replacement!, for: UIControl.State.normal)
                            suggestionButtons[1].tag = 10
                            suggestionButtons[1].titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
                        }
                    }
                }
            }
            keyboard?.handleKeyInputs(prox:textDocumentProxy,sender:sender)
            _ = genWordSuggestions.updateCurrentWord(prox: textDocumentProxy)
        
            if(needsSuggestionView == true && suggestionEngTune != 2){
                if((suggestionEngTune == 0 && stats.getKeyAvgTime() < 3) || (suggestionEngTune == 1 && stats.getKeyAvgTime() < 4)){
                    DispatchQueue.main.asyncAfter(deadline:.now(), execute: {
                        self.updateSuggestions()
                    })
                }
            }
            break
        }
        genImpact()
    }
    
    /**
     This function requests an update of the suggestions words
     - Note:
        If conditions then this function will call the autocorrect and update all the suggestions
     */
    func updateSuggestions(){
        if !needsSuggestionView {return}
        var curWord = genWordSuggestions.currentRecord.currentWord.lowercased()
        if(curWord.count<2){
            //clearSuggestionForNewSentence()
            return
        }
        if(curWord.count >= 3 && curWord.count <= 12){
            curWord = curWord.components(separatedBy: CharacterSet.symbols).joined()
            let guess = genWordSuggestions.correct(word1:curWord)
            if curWord == guess{
                self.clearSuggestions()
                searchForEmojiReplacement(correct: curWord)
            }else{
                updateSuggestionForCorrectWord(correct: guess)
            }
        }else{
            //clearSuggestionForNewSentence()
        }
    }
    
    func suggestionUpdateRequested() {
        print("update suggested request by SuggestionsScheduler")
        DispatchQueue.main.asyncAfter(deadline:.now(), execute: {
            self.updateSuggestions()
        })
    }
    
    /**
     This function is a sender function of any of the suggestion labels
     And will insert the text from the label fields into text proxy
     - Note:
        Capitalizing is checked along with spaces.
     */
    @objc func insertWord(_ sender: UIButton){
        _ = genWordSuggestions.updateCurrentWord(prox: textDocumentProxy);
      
        if(sender.tag == 10){
            insertAutoCorrectSuggestion(sender)
            return
        }
        
        var wordToInsert = sender.titleLabel?.text
        //if title is emtpy just return
        if (wordToInsert!.count) <= 0{return}
        
        _ = removeCurrentWord(record: genWordSuggestions.currentRecord)
        let before = textDocumentProxy.documentContextBeforeInput
        
        if(before == nil ){
            wordToInsert?.capitalizeFirstLetter()
            textDocumentProxy.insertText(wordToInsert!)
        }else{
            smartInsert(word: wordToInsert!, content: before!)
        }
        if(keyboard?.capsToggle == true){
            keyboard?.toggleCaps(sender: (keyboard?.specialKeys[0])!)
        }
        textDocumentProxy.insertText(" ")
        genImpact()
    }
    
    func insertAutoCorrectSuggestion(_ sender:UIButton){
        let wordToInsert = sender.titleLabel?.text!
        var wordCount = wordToInsert!.count-1
        if(wordToInsert?.last == " "){print("HITTTTTT")
            wordCount = wordCount + 1}
        
        if(textDocumentProxy.documentContextBeforeInput != nil){
            while(textDocumentProxy.documentContextBeforeInput != nil){
                textDocumentProxy.deleteBackward()
                if(textDocumentProxy.documentContextBeforeInput?.last == " "){
                    break
                }
            }
        }
   
        textDocumentProxy.insertText(wordToInsert!)
        textDocumentProxy.insertText(" ")
        sender.tag = 0
        sender.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        clearSuggestionForNewSentence()
    }
    
    /**
     This function uses the current word range to remove the current word from the text proxy
     - Note:
        The curser postition is adjusted to the beging of the current word
     */
    func removeCurrentWord(record:WordSuggestions.WordRecord) -> Int{
        guard record.range > 0 else{return 0}
        if let len = textDocumentProxy.documentContextAfterInput{
            for c in len{
                if c == " "{break}
                textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
            }
        }
        for _ in (1...record.range){
            textDocumentProxy.deleteBackward()
        }
        
        if textDocumentProxy.documentContextBeforeInput == nil{
            return 0
        }
        return (textDocumentProxy.documentContextBeforeInput?.count)!
    }
    
    /**
     This function is another insert function that also takes into account of special keys ".!?"
     - Note:
     */
    func smartInsert(word:String,content:String){
        var newWord = word
        let charset = CharacterSet(charactersIn: ".!?")
        
        if content.count == 0 || String(content[content.count-2]).rangeOfCharacter(from: charset) != nil{
            newWord = word.capitalizingFirstLetter()
        }else if(newWord != "I"){
            newWord = word.lowercased()
        }
        textDocumentProxy.insertText(newWord)
    }
    
    /**
     This function peforms a dic lookup for the current word to
     see if a possible emoji replacement is aviavble
     - Note:
     */
    func searchForEmojiReplacement(correct:String){
        if(emojis[correct] != nil){
            suggestionButtons[0].setTitle(emojis[correct], for: UIControl.State.normal)
        }
    }
    
    
    override func textWillChange(_ textInput: UITextInput?) {
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        
    }
    
    /********Suggestions functions*******/
    
    func configSuggestionButtons(){
        let width = self.view.frame.width
        
        let button1:UIButton = UIButton(type: .custom)
        button1.frame = CGRect(x: 0, y: 12, width: width/3, height: 20)
        button1.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        button1.setTitleColor(GlobalColors.suggestionTextColor, for: UIControl.State.normal)
        button1.titleLabel?.textAlignment = NSTextAlignment.center
        button1.addTarget(self, action: #selector(self.insertWord(_:)), for: UIControl.Event.touchDown)
        button1.addTarget(self, action: #selector(anim), for: UIControl.Event.touchDown)
        button1.addRightBorder(borderColor: UIColor.lightGray, borderWidth: 0.5);
        button1.layer.zPosition = -50;
        
        let button2:UIButton = UIButton(type: .custom)
        button2.frame = CGRect(x: button1.frame.width, y: 12, width: width/3, height: 20)
        button2.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        button2.setTitleColor(GlobalColors.suggestionTextColor, for: UIControl.State.normal)
        button2.titleLabel?.textAlignment = NSTextAlignment.center
        button2.addTarget(self, action: #selector(self.insertWord(_:)), for: UIControl.Event.touchDown)
        button2.addTarget(self, action: #selector(anim), for: UIControl.Event.touchDown)
        button2.layer.zPosition = -50;
        
        
        let button3:UIButton = UIButton(type: .custom)
        button3.frame = CGRect(x: button1.frame.width+button2.frame.width, y: 12, width: width/3, height: 20)
        button3.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        button3.setTitleColor(GlobalColors.suggestionTextColor, for: UIControl.State.normal)
        button3.titleLabel?.textAlignment = NSTextAlignment.center
        button3.addTarget(self, action: #selector(self.insertWord(_:)), for: UIControl.Event.touchDown)
        button3.addTarget(self, action: #selector(anim), for: UIControl.Event.touchDown)
        button3.addLeftBorder(color: UIColor.lightGray, width: 0.5);
        button3.layer.zPosition = -50;
        
        suggestionButtons.append(button1)
        suggestionButtons.append(button2)
        suggestionButtons.append(button3)
        view.addSubview(button1)
        view.addSubview(button2)
        view.addSubview(button3)
    }
    
    //Animation for the wordsuggestions when they are clicked.
    @objc func anim(_ sender:UIButton){
        if(sender.titleLabel?.text?.count==0){return}
        sender.setTitleColor(.white, for: UIControl.State.normal)
        UIView.animate(withDuration: 0.3,
                       animations: {
                        sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                        
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.6) {
                            sender.setTitleColor(GlobalColors.suggestionTextColor, for: UIControl.State.normal)
                            sender.transform = CGAffineTransform.identity
                            self.clearSuggestions()
                        }
        })
    }
    //clears the suggestions
    func clearSuggestionForNewSentence(){
        suggestionButtons[0].setTitle("It", for: UIControl.State.normal)
        suggestionButtons[0].tag = 0
        suggestionButtons[1].setTitle("The", for: UIControl.State.normal)
        suggestionButtons[1].tag = 0
        suggestionButtons[2].setTitle("I", for: UIControl.State.normal)
        suggestionButtons[2].tag = 0
    }
    
    func clearSuggestions(){
        suggestionButtons[0].setTitle("", for: UIControl.State.normal)
        suggestionButtons[0].tag = 0
        suggestionButtons[1].setTitle("", for: UIControl.State.normal)
        suggestionButtons[1].tag = 0
        suggestionButtons[2].setTitle("", for: UIControl.State.normal)
        suggestionButtons[2].tag = 0
    }
    
    //updates the suggestions for a corrected word
    func updateSuggestionForCorrectWord(correct:String){
        suggestionButtons[0].tag = 1
        suggestionButtons[1].tag = 1
        suggestionButtons[2].tag = 1
        if(correct.contains(",")){
             suggestionButtons[0].setTitle(correct.removeCharacters(from: ","), for: UIControl.State.normal)
        }
        suggestionButtons[0].setTitle("", for: UIControl.State.normal)
        suggestionButtons[1].setTitle(correct, for: UIControl.State.normal)
        suggestionButtons[2].setTitle("", for: UIControl.State.normal)
        searchForEmojiReplacement(correct: correct)
    }
    
    func adjustSuggestionFrameForRotate(){
        let width = self.view.frame.width
        suggestionButtons[0].frame = CGRect(x: 0, y: 18, width: width/3, height: 20)
        suggestionButtons[1].frame = CGRect(x: suggestionButtons[0].frame.width, y: 18, width: width/3, height: 20)
        suggestionButtons[2].frame = CGRect(x: suggestionButtons[0].frame.width+suggestionButtons[1].frame.width, y: 18, width: width/3, height: 20)
    }
    
    /****************Theme functions******************/
    
    func findStartUpTheme(){
        let data = sharedUserDefaults?.string(forKey: "theme")
        if(data != nil){
            self.theme = data!
            changeColorsForTheme(theme: theme)
        }
        if self.textDocumentProxy.keyboardAppearance != UIKeyboardAppearance.light && self.theme == "Default" {
            self.switchToDarkMode()
        }
    }
    
    //switches the the background color to darkmode
    func switchToDarkMode(){
        if(hasDarkMode == true){
            self.inputView?.backgroundColor = UIColor.init(red: 48/255, green: 50/255, blue: 52/255, alpha: 1)
            GlobalColors.switchColorMode(mode: GlobalColors.colorMode.dark)
        }
    }
    
    func changeColorsForTheme(theme:String){
        switch(theme){
            case "Ocean":
                self.inputView?.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 162/255, alpha: 1)
                GlobalColors.switchColorMode(mode: GlobalColors.colorMode.Tocean)
            break
            case "Red":
                self.inputView?.backgroundColor = .white
                GlobalColors.switchColorMode(mode: GlobalColors.colorMode.Tred)
            break
            case "Dark":
                self.inputView?.backgroundColor = UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)
                GlobalColors.switchColorMode(mode: GlobalColors.colorMode.Tdark)
            break
            case "Light Grey":
                self.inputView?.backgroundColor = UIColor.init(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)
                GlobalColors.switchColorMode(mode: GlobalColors.colorMode.Tlightgrey)
            break
            default:
                GlobalColors.switchColorMode(mode: GlobalColors.colorMode.light)
                self.inputView?.backgroundColor = UIColor.init(red: 209/255, green: 211/255, blue: 217/255, alpha: 1)
            
        }
    }

    /***********other functions***********/
    
    //checks if the big data is loaded into saved data
    func checkIfDataIsLoaded() -> Bool{
        hasDarkMode = false
        needsSuggestionView = false
        let data = sharedUserDefaults?.value(forKey: "words")
        if(data == nil){
            return false
        }
        return true
    }
    
    /*If the word data isnt loaded this message is displayed on the screen*/
    func showDataNeedsToLoad(){
        let label = UILabel(frame: CGRect(x: self.view.frame.width/2-200, y: self.view.frame.height/2-150, width: 400, height: 300))
        label.text = "We made changes to our app that requires data\n to be installed in the actual app, not the keyboard.\n\nPlease OPEN and CLOSE the app to install the necessary data.\n\nYou will only have to do this\n on the first use of the app or on an update\nthat effects autocorrect."
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        self.view.addSubview(label)
    }
    
    
    //generates haptic feedback for a given saved type of haptic feedback
    func genImpact(){
        let type = sharedUserDefaults?.integer(forKey: "Impact")
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
        
        switch type {
            case 0:
                break;
                //notificationFeedbackGenerator.notificationOccurred(.warning)
                //notificationFeedbackGenerator.impactOccurred();
            case 1:
                break;
                //notificationFeedbackGenerator.impactOccurred();
            
            case 2:
                break;
                //notificationFeedbackGenerator.impactOccurred();
              
            default:
                sharedUserDefaults?.set(0, forKey: "Impact")
                //notificationFeedbackGenerator.impactOccurred();
                
        }
        
        //notificationFeedbackGenerator.prepare()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        exit(1)
    }
    
    func keyPressedAgain(sender: KeyButton) {
        keyboard?.handleKeyInputs(prox:textDocumentProxy,sender:sender)
    }
    func keyReleased(sender: KeyButton) {
        
    }
}

//****************extensions****************

extension UIButton {
    
    func addRightBorder(borderColor: UIColor, borderWidth: CGFloat) {
        let border = CALayer()
        border.backgroundColor = borderColor.cgColor
        border.frame = CGRect(x: self.frame.size.width - borderWidth,y: 0, width:borderWidth, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorder(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0, y:0, width:width, height:self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    
    subscript(_ range: CountableRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: CountableClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}
extension Substring {
    var string: String { return String(self) }
}
