//
//  HapticSettingsViewController.swift
//  HapticFeedBackKeyboard
//
//  Created by Joe Manto on 1/4/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit

class HapticSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    //MARK: - Views
    
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
        label.text = "Adjust The Vibration"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        label.layer.zPosition = 90
        return label
    }()
    
    lazy var subTitle:UILabel = {
        let label = UILabel(frame:CGRect(x:  self.view.frame.width/2-175, y: 75, width: 350, height: 100))
        label.numberOfLines = 0
        label.text = "Here you can adjust the type of vibration\nthat is just right for you"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        label.textColor = UIColor.lightGray
        label.layer.zPosition = 90
        return label
    }()
    
    var picker:UIPickerView!
    var pickerData = ["Default Type(Recommended)","Haptic Type 1","Haptic Type 2"]
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    let defualtFeedback = UIImpactFeedbackGenerator()
    let sharedUserDefaults = UserDefaults(suiteName: "group.hapticfeedbackkeyboard")
    var type = 0
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type = row
        switch row {
        case 0:
            notificationFeedbackGenerator.notificationOccurred(.warning)
            notificationFeedbackGenerator.prepare()
        case 1:
            notificationFeedbackGenerator.notificationOccurred(.error)
            notificationFeedbackGenerator.prepare()
        case 2:
            notificationFeedbackGenerator.notificationOccurred(.success)
            notificationFeedbackGenerator.prepare()
        default:
            return
        }
        sharedUserDefaults?.set(type, forKey: "Impact")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.view.backgroundColor = UIColor.white
        }
        notificationFeedbackGenerator.prepare()
        defualtFeedback.prepare()
        
        picker = UIPickerView(frame: CGRect(x: 0, y: self.view.frame.height/2-150, width: self.view.frame.width, height: 300))
        picker.delegate = self
        picker.dataSource = self
        
        let subTitle2:UILabel = UILabel(frame:CGRect(x:  self.view.frame.width/2-175, y: 695, width: 350, height: 100))
        subTitle2.numberOfLines = 0
        subTitle2.text = "To adjust the vibration in the future just revisit this location"
        subTitle2.textAlignment = NSTextAlignment.center
        subTitle2.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        subTitle2.textColor = UIColor.lightGray
        subTitle2.layer.zPosition = 90
        
        self.view.addSubview(picker)
        self.view.addSubview(done)
        self.view.addSubview(titleLabel)
        self.view.addSubview(subTitle)
        self.view.addSubview(subTitle2)
        
        done.anchor(top: nil, leading: view.centerXAnchor,
                    bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil,
                    padding:UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                    size: CGSize(width: 120, height: 40))
 
    }
    
    @objc func returnBack(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        self.dismiss(animated: true, completion: nil)
        let vc = ViewController()
        self.present(vc, animated: true, completion: nil)
        sharedUserDefaults?.set(type, forKey: "Impact")
    }
}
