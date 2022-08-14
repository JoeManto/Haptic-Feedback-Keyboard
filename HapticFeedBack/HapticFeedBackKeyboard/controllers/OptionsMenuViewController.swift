//
//  OptionsMenuViewController.swift
//  HapticFeedBackKeyboard
//
//  Created by Joe Manto on 2/10/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit

class OptionsMenuViewController: UIViewController {
    let defualtFeedback = UIImpactFeedbackGenerator()
    
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
        label.text = "Options"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        label.layer.zPosition = 90
        return label
    }()
    
    lazy var subTitle:UILabel = {
        let label = UILabel(frame:CGRect(x:  self.view.frame.width/2-175, y: 75, width: 350, height: 100))
        label.numberOfLines = 0
        label.text = "Here you can adjust the type of vibration,\nthe keyboard color theme, and the general operating settings"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        label.textColor = UIColor.lightGray
        label.layer.zPosition = 90
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            self.view.backgroundColor = UIColor.white
        }

        let hapticSettings:UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        hapticSettings.frame = CGRect(x: self.view.frame.width/2-95, y: self.view.frame.height/2-40, width: 190, height: 40)
        hapticSettings.setTitle("Change Vibration Type", for: UIControl.State.normal)
        hapticSettings.tintColor = UIColor.white
        hapticSettings.layer.cornerRadius = 10
        hapticSettings.layer.masksToBounds = true
        hapticSettings.backgroundColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
        hapticSettings.layer.zPosition = 90
        hapticSettings.addTarget(self, action: #selector(hapticSettings(_:)), for: UIControl.Event.touchDown)
        
        let OptionSettings:UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        OptionSettings.frame = CGRect(x: self.view.frame.width/2-95, y: self.view.frame.height/2+80, width: 190, height: 40)
        OptionSettings.setTitle("General Options", for: UIControl.State.normal)
        OptionSettings.tintColor = UIColor.white
        OptionSettings.layer.cornerRadius = 10
        OptionSettings.layer.masksToBounds = true
        OptionSettings.backgroundColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
        OptionSettings.layer.zPosition = 90
        OptionSettings.addTarget(self, action: #selector(hapticOptions(_:)), for: UIControl.Event.touchDown)
        
        let themeSettings:UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        themeSettings.frame = CGRect(x: self.view.frame.width/2-95, y: self.view.frame.height/2+20, width: 190, height: 40)
        themeSettings.setTitle("Change Theme Type", for: UIControl.State.normal)
        themeSettings.tintColor = UIColor.white
        themeSettings.layer.cornerRadius = 10
        themeSettings.layer.masksToBounds = true
        themeSettings.backgroundColor = UIColor.init(red: 0.0, green: 122/255, blue: 255/255, alpha: 1)
        themeSettings.layer.zPosition = 90
        themeSettings.addTarget(self, action: #selector(themeSettings(_:)), for: UIControl.Event.touchDown)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(subTitle)
        self.view.addSubview(hapticSettings)
        self.view.addSubview(OptionSettings)
        self.view.addSubview(themeSettings)
        self.view.addSubview(done)
        
        done.anchor(top: nil, leading: view.centerXAnchor,
                    bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil,
                    padding:UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                    size: CGSize(width: 120, height: 40))
    }
    
    @objc func hapticSettings(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        let vc = HapticSettingsViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func themeSettings(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        let vc = ThemesViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func hapticOptions(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        let vc = ControlCenterViewController()
        self.present(vc,animated:true,completion: nil)
    }
    
    @objc func returnBack(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        self.dismiss(animated: true, completion: nil)
        let vc = ViewController()
        self.present(vc, animated: true, completion: nil)
    }
}
