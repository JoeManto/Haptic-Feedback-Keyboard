//
//  KeyButton.swift
//  Haptic
//
//  Created by Joe Manto on 10/19/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//


import UIKit

/*KeyButton
 This class is a subclass of the UIButton and is the building block for which all the keys are built off.
 This class handles all the UIControl inputs and triggers the given delegate method.
 Configs all buttons based off buttonStyle and buttonImage types
 
 [basic button] defaults to white with text
 init(value:String,buttonFrame:CGRect,orientation:popUpKeyView.popupOrientation)
 
 [basic button with styleType] basic button but with a given style
 init(value:String,buttonFrame:CGRect,orientation:popUpKeyView.popupOrientation,withStyle:buttonStyle)
 
 [basic button with imageType] basic button with no text but with a given image
 init(value:String,buttonFrame:CGRect,orientation:popUpKeyView.popupOrientation,withStyle:buttonStyle,with Image:buttonImage)
 */

/*Protocal Methods for the delegate class (ViewController)*/
protocol KeyButtonEvents {
    func keyPress(sender:KeyButton)
    func keyReleased(sender:KeyButton)
    func keyPressedAgain(sender:KeyButton)
}



extension UIButton {
    
}

class KeyButton: UIButton {
    
    /*determines the type of background
     [needed] - Change types to .basicButton .specialButton*/
    enum buttonStyle{
        case white
        case grey
    }
    
    /*determines the type of image
     [needed] - add type to capsOff*/
    enum buttonImage{
        case none
        case globe
        case capsOn
        case capsOff
        case hardCaps
        case ret
        case delete
    }
    
    var delegate:KeyButtonEvents? //delegate controller | gets set in the config of the keyboard in the Keyboard Class
    var keyValue:String //Value of the key determines the operation to be carried out in the keyboard class when the delegate methods are triggered
    let orientation:popUpKeyView.popupOrientation //The given orientation for which the popupview is presented
    let style:buttonStyle //determines color of the button
    let image:buttonImage //determines the image of the button
    var restoreColor:UIColor? //background color before a keypress
    var addedToParentView = true /*determines if the view has been added to its parent view. Used when switching keyboard layouts when adding keys to
     the KeyButton array new keys need to be added to the parent view [The key created and this value is set to false]*/
    var frameInset:UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    init(value:String,buttonFrame:CGRect,orientation:popUpKeyView.popupOrientation){
        self.keyValue = value
        self.orientation = orientation
        self.style = .white
        self.image = .none
        super.init(frame:buttonFrame)
        setUpButton(style: .white)
    }
    
    init(value:String,buttonFrame:CGRect,orientation:popUpKeyView.popupOrientation,withStyle:buttonStyle){
        self.keyValue = value
        self.orientation = orientation
        self.style = withStyle
        self.image = .none
        super.init(frame:buttonFrame)
        setUpButton(style: withStyle)
    }
    
    init(value:String,buttonFrame:CGRect,orientation:popUpKeyView.popupOrientation,withStyle:buttonStyle,with Image:buttonImage){
        self.keyValue = value
        self.orientation = orientation
        self.style = withStyle
        self.image = Image
        super.init(frame:buttonFrame)
        setUpButtonWithImage(image:Image)
    }
    
    /*Sets up the basic keyboard key button and sets up
     the background color given a button style
     @buttonStyle: style the given style type*/
    private func setUpButton(style:buttonStyle){
        switch style {
        case .grey:
            self.buttonSetUpGrey()
            break
        case .white:
            self.buttonSetUpWhite()
            break
        }
        buttonBasicSetup()
        self.setTitle(keyValue, for: UIControl.State.normal)
        self.titleLabel?.textAlignment = NSTextAlignment.center
        self.titleLabel?.font = UIFont.systemFont(ofSize: 22)
    }
    
    /*Basic Button setup for buttons of all types
     sets the layer values and adds the UIControl event targets*/
    private func buttonBasicSetup(){
        self.isUserInteractionEnabled = true
       // self.clipsToBounds = true
        self.layer.cornerRadius = 6
        
        self.layer.masksToBounds = false
       // self.layer.borderWidth = 1.0
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 1.2)
        self.layer.zPosition = 50
       
        self.addTarget(self, action: #selector(self.keyPress(_:)), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(self.keyRelease(_:)), for: UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(self.keyMovedOutSide(_:)), for: UIControl.Event.touchDragExit)

    }
    
    /*Sets up the image by a given image type and sets the background color
     based on the sytle type give on the init call.
     @buttonImage:image image-type*/
    public func setUpButtonWithImage(image:buttonImage){
        self.backgroundColor = GlobalColors.specialButtonsColor
        buttonBasicSetup()
        let imageName:String
        switch image {
        case .globe:
            imageName = "globe"
            break
        case .delete:
            imageName = "backspace"
            break
        case .capsOff:
            imageName = "capsOff"
        case .capsOn:
            imageName = "capsOn"
            break
        case .hardCaps:
            imageName = "hardCaps"
        case .ret:
            imageName = "return"
            break
        default:
            print("failed attach image name")
            return
        }
        switch style {
        case .grey:
            self.buttonSetUpGrey()
            break
        case .white:
            self.buttonSetUpWhite()
            break
        }
        self.setImage(UIImage(named: imageName), for: UIControl.State.normal)
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    /*Sets the button background color to the button color
     [needed] - Change the title to buttonColor*/
    private func buttonSetUpWhite(){
        self.backgroundColor = GlobalColors.buttonColor
        self.setTitleColor(GlobalColors.textColor, for: UIControl.State.normal)
    }
    
    /*Sets the button background color to the special button color
     [needed] - Change the title to specialColor*/
    private func buttonSetUpGrey(){
        self.backgroundColor = GlobalColors.specialButtonsColor
        self.setTitleColor(GlobalColors.textColor, for: UIControl.State.normal)
    }
    
    /*[UnUsed]:Reason:because of clipping at the top
     creates the popUPKeyView and adds it as a subview of the button*/
    private func createPopUp(orientation:popUpKeyView.popupOrientation) {
        if(orientation != .none){
            let blowupView:popUpKeyView = popUpKeyView(frame:CGRect(x: -6.5, y: -60, width: self.frame.width-7, height: self.frame.height-10),orientation: orientation)
            blowupView.addCharLabel(value: self.keyValue)
            self.addSubview(blowupView)
            
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*On Key Pressed sets all the values to reflect a key press
     Darkens background of key
     calls protocal methods inbed in the deleage class which is the viewcontroller
     @self:sender button*/
    @objc func keyPress(_ sender: KeyButton){
        if(self.keyValue.count == 1){
            createPopUp(orientation: self.orientation)
        }
        delegate?.keyPress(sender:sender)
        //changeButtonColorForTap()
    }
    
    
    /*On Key Released sets all values back to defualt from being changed on keypressed
     Calls the protocal methond inbeded in the controller class with the controller delegate which
     is set in the KeyBoard class on basic config
     @self:sender button*/
    @objc func keyRelease(_ sender: KeyButton){
        if(self.subviews.count >= 2){self.subviews.last?.removeFromSuperview()}
        //if(keyValue.count == 1){
          //  restoreButtonColor()
        //}
        delegate?.keyReleased(sender:sender)
    }
    
    @objc func keyMovedOutSide(_ sender:KeyButton){
        if(self.subviews.count >= 2){self.subviews.last?.removeFromSuperview()}
    }
    
    @objc func hold(_ sender: KeyButton){
        print("hold")
    }
    
    /*On KeyPress/Hold change the color
     -[Needed]
     Change the color to a global color that work with both light and dark modes*/
    func changeButtonColorForTap(){
        if(keyValue.count == 1){
            self.restoreColor = self.backgroundColor!
            self.backgroundColor = UIColor(red: 127/255, green: 131/255, blue: 133/255, alpha: 1)
        }
    }
    
    /*called on keyReleased and restores the background color
     back to the color before the keyPress*/
    func restoreButtonColor(){
        self.backgroundColor = restoreColor
    }
    
    /*Changes the current Key Value to a lower case version*/
    func switchToLowercase(){
        changeButtonText(newValue: keyValue.lowercased())
    }
    /*Changes the current Key Value to a upper case version*/
    func switchToUppercase(){
        changeButtonText(newValue: keyValue.uppercased())
    }
    /*Changes the current button title label and keyvalue to a new given string
     @String newValue: new value for title label and keyValue
     */
    func changeButtonText(newValue:String){
        self.setTitle(newValue, for: UIControl.State.normal)
        self.keyValue = newValue
    }
    
    /*Turn a UIButton that displays UIImageView and turns it into just a button with a title.
     removes the UIImageView and add a new title label and shift the text over
     @String value: new value argIn: @changeButtonText*/
    func turnImageButtonIntoText(value:String){
        changeButtonText(newValue: value)
        self.imageView?.removeFromSuperview()
        titleEdgeInsets.left = -100
        self.setTitleColor(GlobalColors.textColor, for: UIControl.State.normal)
        self.titleLabel?.textAlignment = NSTextAlignment.center
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = frameInset
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
}



