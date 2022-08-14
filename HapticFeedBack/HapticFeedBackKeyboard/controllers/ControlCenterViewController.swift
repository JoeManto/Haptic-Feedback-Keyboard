//
//  ControlCenterViewController.swift
//  HapticFeedBackKeyboard
//
//  Created by Joe Manto on 3/4/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit

class ControlCenterViewController: UIViewController,UIScrollViewDelegate{
    
    private let sharedUserDefaults = UserDefaults(suiteName: "group.hapticfeedbackkeyboard")
    private let defualtFeedback = UIImpactFeedbackGenerator()
    
    private var switchOptions:[UISwitch] = []
    private let titles:[String] = ["Dark Mode Support","Suggestions","Full Suggestions","Middle Suggestions","Simple Suggestions"]
    private let subTexts:[String] = ["Darkens the keys and background of the keyboard to reflect the color of the current app.",
                                     "Computation of Word Suggestions. If turned off no suggestions are generated and the suggestion view is removed",
                                     "This tunes the suggestion engine so words are suggested mid typing and has close to no limit on the amount of suggestions generated.",
                                     "Same as Full Suggestion just at a slower limited rate. This is the recommended option.",
                                     "This will only suggest words for thought to be completed words. This feature is also in both full and middle suggestions."]
    private var autoTuneOption = 3
    lazy var contentSize:CGSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    
    // MARK: - Views
    
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView(frame:.zero)
       
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.white
        } else {
            self.view.backgroundColor = UIColor.white
        }
        
        view.frame = self.view.bounds
        view.frame.origin = CGPoint(x: 0, y: 150)
        view.contentSize = CGSize(width:self.contentSize.width, height: self.contentSize.height)
        return view
    }()
    
    lazy var contentView:UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.white
        } else {
            self.view.backgroundColor = UIColor.white
        }
        view.frame.size = self.contentSize
        return view
    }()
    
    lazy var done:UIButton = {
        let button = UIButton(type: UIButton.ButtonType.roundedRect)
        button.setTitle("Done", for: UIControl.State.normal)
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
        button.addTarget(self, action: #selector(returnBack(_:)), for: UIControl.Event.touchDown)
        button.layer.anchorPoint = CGPoint(x: 1, y: 1)
        return button
    }()
    
    lazy var titleLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: self.view.frame.width/2-140,
                                          y: 30, width: 280, height: 100))
        label.text = "General Options"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        label.layer.zPosition = 90
        return label
    }()
    
    lazy var subTitle:UILabel = {
        let label = UILabel(frame:CGRect(x:  self.view.frame.width/2-175, y: 75, width: 350, height: 100))
        label.numberOfLines = 0
        label.text = "Here you can disable the features you don't want"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        label.textColor = UIColor.lightGray
        label.layer.zPosition = 90
        return label
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.white
        } else {
            self.view.backgroundColor = UIColor.white
        }
        
        view.addSubview(titleLabel)
        view.addSubview(subTitle)
        view.addSubview(scrollView)
        contentView.addSubview(done)
        scrollView.addSubview(contentView)

        done.anchor(top: nil, leading: view.centerXAnchor,
                    bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil,
                    padding:UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                    size: CGSize(width: 120, height: 40))
        
        
        var optionsViews:[UIView] = []
        var height:CGFloat = 0.0
        
        for i in 0...4{
            optionsViews.append(createOption(optionText:self.titles[i],subText:self.subTexts[i],edge: UIEdgeInsets(top: height, left: 50, bottom: 0, right: 0), num: 1))
            contentView.addSubview(optionsViews.last!)
            height = height + optionsViews.last!.frame.height+10
        }
        
        for i in 0...4{
            if(i > 1){
                switchOptions[i].tag = i
            }else if(i == 0){
                switchOptions[i].tag = 1
            }else if(i == 1){
                switchOptions[i].tag = 0
            }
        }
        
        self.gatherSettings()
    }
    
    func setSwitchInvaild(sender:UISwitch){
        sender.tintColor = UIColor.gray
        sender.onTintColor = UIColor.gray
        sender.isUserInteractionEnabled = false
    }
    
    func setAllAutoCorrectOptionsInvaild(){
        for option in switchOptions{
            if(option.tag > 1){
                setSwitchInvaild(sender: option)
            }
        }
    }
    
    @objc func returnBack(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        self.dismiss(animated: true, completion: nil)
        let vc = ViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func createOption(optionText:String,subText:String?,edge:UIEdgeInsets,num:Int = 0) -> UIView{
        let optionView:UIView = {
            let view = UIView()
            view.frame = CGRect(x: 0, y: edge.top, width: self.view.frame.width, height: 75);
            view.backgroundColor = UIColor.white;
            return view
        }()
      
        let option:UISwitch = {
            let optswitch = UISwitch()
            optswitch.isOn = true
            optswitch.tag = num
            optswitch.tintColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
            optswitch.onTintColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
            optswitch.addTarget(self, action: #selector(changeSavedValue(_:)), for: UIControl.Event.valueChanged)
            switchOptions.append(optswitch)
            return optswitch
        }()

        let text:UILabel = {
            let label = UILabel()
            label.text = optionText
            label.textColor = UIColor.black
            label.numberOfLines = 0
            label.font = UIFont(name: "HelveticaNeue-bold", size: 16)
            label.textAlignment = .center
            return label
        }()
        
        let sub = UILabel()
        if(subText != nil){
            sub.text = subText
            sub.textColor = UIColor.lightGray
            sub.numberOfLines = 0
            sub.font = UIFont(name: "HelveticaNeue-Light", size: 12)
            sub.textAlignment = .center
            optionView.addSubview(sub)
        }

        optionView.addSubview(option)
        optionView.addSubview(text)
       
        option.frame = CGRect.init(x: 15, y: optionView.frame.height/2-15, width: option.frame.width, height: option.frame.height)
        text.frame = CGRect.init(x: optionView.frame.width/2-100, y: 0, width: 200, height: 30)
        sub.frame = CGRect.init(x:optionView.frame.width/2-100,y:5,width:200,height: 100)
        return optionView
    }
    
    
    func gatherSettings(){
        let data1 = sharedUserDefaults?.value(forKey: "hasAutoCorrect")
        if(data1 != nil){
            let on:Bool = data1 as! Bool
            if(on == false){
                switchOptions[1].isOn = false
                for option in switchOptions{
                    if(option.tag > 1){
                        setSwitchInvaild(sender: option)
                        option.setOn(false, animated: false)
                    }
                }
            }
        }
        let data2 = sharedUserDefaults?.value(forKey: "hasDarkMode")
        if(data2 != nil){
            let on:Bool = data2 as! Bool
            if(on == false){switchOptions[0].isOn = false}
        }
        let data3 = sharedUserDefaults?.value(forKey: "autoCorrectTune")
        if(data3 != nil){
            let on:Int = data3 as! Int
            autoTuneOption = on+2
            for option in switchOptions{
                if(option.tag > 1 ){
                    if (on+2 == option.tag){
                        option.setOn(true, animated: false)
                    }else{
                        option.setOn(false, animated: false)
                    }
                }
            }
        }else{
            switchOptions[2].setOn(false, animated: false)
            switchOptions[4].setOn(false, animated: false)
            switchOptions[3].setOn(true, animated: false)
            sharedUserDefaults?.set(1, forKey: "autoCorrectTune")
            print("auto tune set to \(1)")
        }
    }
    
    @objc func changeSavedValue(_ sender:UISwitch){
        print(sender.tag)
        
        //switchOptions[0].setOn(false, animated: true)
        let on:Bool = sender.isOn
        switch(sender.tag){
        case 0:
            if(!sender.isOn){
                setAllAutoCorrectOptionsInvaild()
            }else{
                var isOptionOn = false
                for option in switchOptions{
                    if(option.tag > 1){
                        option.tintColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
                        option.onTintColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
                        option.isUserInteractionEnabled = true
                        if(option.isOn){
                            isOptionOn = true
                        }
                    }
                }
                if(isOptionOn == false){
                    switchOptions[3].setOn(true, animated: true)
                    sharedUserDefaults?.set(1, forKey: "autoCorrectTune")
                }
            }
            sharedUserDefaults?.set(on, forKey: "hasAutoCorrect")
            break
        case 1:
            sharedUserDefaults?.set(on, forKey:"hasDarkMode")
        default:
            var on:Int?
            for option in switchOptions{
                if(option.tag > 1 && option.tag != sender.tag){
                    option.setOn(false, animated: true)
                }else if(option.tag == sender.tag){
                    if(sender.isOn){on = sender.tag-2}
                }
            }
            if(on != nil){
                sharedUserDefaults?.set(on, forKey: "autoCorrectTune")
                
            }else{
                switchOptions[1].setOn(false, animated: true)
                changeSavedValue(switchOptions[1])
            }
            break
        }
    }
}
