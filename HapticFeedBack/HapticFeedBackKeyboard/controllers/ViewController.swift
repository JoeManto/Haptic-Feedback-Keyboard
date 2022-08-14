//
//  ViewController.swift
//  HapticFeedbackKeyboard
//
//  Created by Joe Manto on 12/28/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    let numBackgroundObjects = 50;
    let defualtFeedback = UIImpactFeedbackGenerator()
    let sharedUserDefaults = UserDefaults(suiteName: "group.hapticfeedbackkeyboard")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.view.backgroundColor = UIColor.white
        }
        defualtFeedback.prepare()
        spawnBackground()
        configView()
        loadBigData()
    }
    
    @objc func openSettings(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
    @objc func OptionSettings(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        let vc = OptionsMenuViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func spawnBackground(){
        for _ in 0..<75{
            DispatchQueue.main.asyncAfter(deadline:.now()+Double.random(in: 0.0..<3.5), execute: {
                self.view.addSubview(FallIngObject(parentViewSize: self.view!.frame))
            })
        }
    }
    
    func loadBigData(){
        //let data = sharedUserDefaults!.value(forKey: "words")
        let data:NSObject? = nil
        if(data == nil){
            print("loading data")
            var fileContent = loadBigData(name: "bigData", type: "txt")
            fileContent = fileContent.lowercased()
            sharedUserDefaults?.setValue(getWordCounts(context: fileContent), forKey: "words")
        }else{
            print("data was already loaded")
        }
    }
    
    private func getWordCounts(context:String) -> [String:Int]{
        var result:[String:Int] = [:]
        let matched = matches(for: "[a-zA-Z,']+", in: context)
        for match in matched{
            if result[match] != nil{
                result[match] = result[match]! + 1
            }else{
                result[match] = 1
            }
        }
        return result
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
    
    private func configView(){
        let titleLabel:UILabel = UILabel(frame: CGRect(x: self.view.frame.width/2-125,
                                                       y: 50, width: 250, height: 100))
        titleLabel.text = "Getting Started"
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 30)
        titleLabel.layer.zPosition = 90
        
        let subTitle:UILabel = UILabel(frame:CGRect(x:  self.view.frame.width/2-125, y: 80, width: 270, height: 100))
        subTitle.text = "Follow the steps below on your device\n"
        subTitle.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        subTitle.textColor = UIColor.lightGray
        subTitle.layer.zPosition = 90
        
        /*setting view steps*/
        let stepsView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2))
        stepsView.layer.zPosition = 90
        let settings:UILabel = UILabel(frame: CGRect(x: self.view.frame.width/2-125,
                                                     y: 150, width: 250, height: 100))
        settings.text = "Steps"
        settings.textAlignment = NSTextAlignment.left
        settings.font = UIFont(name: "HelveticaNeue-Light", size: 30)
        settings.layer.zPosition = 90
        
        let subSetting:UILabel = UILabel(frame:CGRect(x:  self.view.frame.width/2-80, y: 190, width: 270, height: 350))
        subSetting.numberOfLines = 0
        subSetting.text = "\n\nOpen the settings app\n\n👉🏼 General\n\n👉🏼 Keyboard\n\n👉🏼 Keyboards\n\n👉🏼 Add New Keyboard\n\n👉🏼 Select Haptic\n\n"
        subSetting.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        subSetting.adjustsFontSizeToFitWidth = true
        subSetting.textColor = UIColor.black
        subSetting.layer.zPosition = 90
        
        stepsView.addSubview(settings)
        stepsView.addSubview(subSetting)
        
        
        let settingsButton:UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        settingsButton.frame = CGRect(x: self.view.frame.width/2-67.5, y: self.view.frame.height-150, width: 135, height: 40)
        settingsButton.setTitle("Open Settings", for: UIControl.State.normal)
        settingsButton.tintColor = UIColor.white
        settingsButton.layer.cornerRadius = 10
        settingsButton.layer.masksToBounds = true
        settingsButton.backgroundColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
        settingsButton.layer.zPosition = 90
        settingsButton.addTarget(self, action: #selector(openSettings(_:)), for: UIControl.Event.touchDown)
        
        let hapticSettings:UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        hapticSettings.frame = CGRect(x: self.view.frame.width/2-125, y: self.view.frame.height-100, width: 250, height: 40)
        hapticSettings.setTitle("Change App Settings", for: UIControl.State.normal)
        hapticSettings.tintColor = UIColor.white
        hapticSettings.layer.cornerRadius = 10
        hapticSettings.layer.masksToBounds = true
        hapticSettings.backgroundColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
        hapticSettings.layer.zPosition = 90
        hapticSettings.addTarget(self, action: #selector(OptionSettings(_:)), for: UIControl.Event.touchDown)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(subTitle)
        self.view.addSubview(stepsView)
        self.view.addSubview(settingsButton)
        self.view.addSubview(hapticSettings)
        
        
        shouldShowReview()
        
    }
    
    func shouldShowReview(){
        let data = sharedUserDefaults!.value(forKey: "numTimesOpened")
        if(data == nil){
            sharedUserDefaults!.set(1, forKey: "numTimesOpened")
        }else{
            var numTimes = data as! Int
            numTimes = numTimes + 1
            if(numTimes == 4){
               SKStoreReviewController.requestReview()
            }
            sharedUserDefaults?.set(numTimes, forKey: "numTimesOpened")
        }
    }
    
}

