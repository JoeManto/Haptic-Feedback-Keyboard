//
//  ThemesViewController.swift
//  HapticFeedBackKeyboard
//
//  Created by Joe Manto on 2/10/19.
//  Copyright © 2019 joemanto. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    //Mark: - Views
    
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
    
    let sharedUserDefaults = UserDefaults(suiteName: "group.hapticfeedbackkeyboard")
    let defualtFeedback = UIImpactFeedbackGenerator()
    let themes:[String] = ["Default","Red","Light Grey","Dark","Ocean"]
    let backgroundColors:[UIColor] = [UIColor.init(red: 208/255, green: 212/255, blue: 217/255, alpha: 1),
                                      .white,
                                      UIColor.init(red: 117/255, green: 117/255, blue: 117/255, alpha: 1),
                                      UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 1),
                                      UIColor.init(red: 255/255, green: 244/255, blue: 162/255, alpha: 1)
                                    ]
    var currentThemeIndex:Int = 0
    var imageView:UIImageView?
    let themeTitle = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let data = sharedUserDefaults?.string(forKey: "theme")
         var index = 0
        if(data != nil){
            for (i,s) in themes.enumerated(){
                if(s == data){
                    index = i
                    break
                }
            }
        }
        view.backgroundColor = backgroundColors[index]
        currentThemeIndex = index
        themeTitle.text = "Default"
        themeTitle.font = UIFont(name: "Helvetica-Bold", size: 46)
        
        let themeImage:UIImage = UIImage(named: themes[currentThemeIndex])!
        imageView = UIImageView(image: themeImage)
        imageView!.layer.anchorPoint = CGPoint(x: 1, y: 1)
        imageView!.isUserInteractionEnabled = true
        
        view.addSubview(themeTitle)
        view.addSubview(done)
        view.addSubview(imageView!)
        
        themeTitle.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor,
                          bottom: nil, trailing: nil,
                          padding:UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 0),
                          size: CGSize(width: 400, height: 100))
        
        done.anchor(top: nil, leading: view.centerXAnchor,
                    bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil,
                    padding:UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0),
                    size: CGSize(width: 120, height: 40))
        
        imageView!.anchor(top: view.centerYAnchor, leading: view.centerXAnchor, bottom: nil, trailing: nil,size:CGSize(width: 200, height: 250))
        
        let rightGest = UISwipeGestureRecognizer()
        rightGest.direction = .right
        rightGest.addTarget(self, action: #selector(swipeRight(_:)))
        let leftGest = UISwipeGestureRecognizer()
        leftGest.direction = .left
        leftGest.addTarget(self, action: #selector(swipeLeft(_:)))
        
        self.view.addGestureRecognizer(leftGest)
        self.view.addGestureRecognizer(rightGest)
        
        changeTitleAndImage(index: currentThemeIndex)
    }
    
    func changeTitleAndImage(index:Int){
        themeTitle.text = themes[index]
        imageView?.image = UIImage(named: themes[index])
        self.view.backgroundColor = backgroundColors[index]
    }
    
    func animateAwayRight(view:UIImageView,label:UILabel) {
        defualtFeedback.impactOccurred()
        if(currentThemeIndex == themes.count-1){
            currentThemeIndex = 0
        }else{
            currentThemeIndex = currentThemeIndex+1
        }
        
        let temp = view.frame
        let temp2 = label.frame
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                        view.frame = CGRect(x: self.view.frame.width, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
                        label.frame = CGRect(x:self.view.frame.width, y: label.frame.origin.y, width: label.frame.width,height:label.frame.height)
        },
                       completion: { _ in
                        self.changeTitleAndImage(index: self.currentThemeIndex)
                        view.frame = CGRect(x: -view.frame.width, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
                        label.frame = CGRect(x: -label.frame.width, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height)
                        UIView.animate(withDuration: 0.6) {
                            view.frame = temp
                            label.frame = temp2
                        }
        })
        sharedUserDefaults?.set(themes[currentThemeIndex], forKey: "theme")
    }
    
    func animateAwayLeft(view:UIImageView,label:UILabel) {
        defualtFeedback.impactOccurred()
        if(currentThemeIndex == 0){
            currentThemeIndex = themes.count-1
        }else{
            currentThemeIndex = currentThemeIndex - 1
        }
        
        let temp = view.frame
        let temp2 = label.frame
        UIView.animate(withDuration: 0.3,
                       animations: {
                        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                        view.frame = CGRect(x: -view.frame.width, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
                        label.frame = CGRect(x: -label.frame.width, y: label.frame.origin.y, width: label.frame.width, height: label.frame.height)
        },
                       completion: { _ in
                        self.changeTitleAndImage(index: self.currentThemeIndex)
                        UIView.animate(withDuration: 0.6) {
                            view.frame = temp
                            label.frame = temp2
                        }
        })
        sharedUserDefaults?.set(themes[currentThemeIndex], forKey: "theme")
    }
    
    
    @objc func swipeLeft(_ gest:UISwipeGestureRecognizer) {
        animateAwayLeft(view: imageView!,label: themeTitle)
        print("swipe left")
    }
    @objc func swipeRight(_ gest:UISwipeGestureRecognizer){
        animateAwayRight(view: imageView!,label: themeTitle)
        print("swipe right")
    }
    
    @objc func returnBack(_ sender:UIButton){
        defualtFeedback.impactOccurred()
        self.dismiss(animated: true, completion: nil)
        let vc = ViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?,leading:NSLayoutXAxisAnchor?,
                bottom:NSLayoutYAxisAnchor?,trailing:NSLayoutXAxisAnchor?,
                padding:UIEdgeInsets = .zero, size:CGSize = .zero){
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading{
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing{
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        if(size.width != 0){
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if(size.height != 0){
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}

