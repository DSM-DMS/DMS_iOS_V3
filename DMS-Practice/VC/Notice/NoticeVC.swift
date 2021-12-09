//
//  NoticeVC_.swift
//  DMS-Practice
//
//  Created by leedonggi on 27/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit

public var paramInt = 0

class NoticeVC: UIViewController {
    @IBOutlet var lblBases: [UILabel]!
    @IBOutlet var lblTitles: [UILabel]!
    @IBOutlet var lblDetails: [UILabel]!
    @IBOutlet var viewsNotice: [UIView]!
    @IBOutlet var imgsArrow: [UIImageView]!
    
    var curInt = 0
    var condition = true
    var tempY: CGFloat = 0
    var isGoNext = true
    
    override func viewDidLoad() {
        for i in 0...8 {
            viewsNotice[i].layer.cornerRadius = 24
            dropShadow(view: viewsNotice[i], color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 0, height: 10))
        }
        
        for i in 0...2 {
            let viewAction = UITapGestureRecognizer(target: self, action: #selector(self.viewAction))
            viewsNotice[i].tag = i
            self.viewsNotice[i].addGestureRecognizer(viewAction)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isDismissed {
            changeBack()
            isDismissed = false
            isGoNext = false
        }
        if !loginCheck() { goNextVCwithUIid(UIid: "AccountUI", VCid: "EmptyVC") }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isGoNext {
            print("유지")
        } else {
            changeBack()
        }
    }

    @objc func viewAction(_ sender: UITapGestureRecognizer) {
        curInt = (sender.view?.tag)!
        paramInt = (sender.view?.tag)!
        check()
    }
    
    func check() {
        if condition {
            changeColor()
        } else {
            changeBack()
        }
    }
    
    func changeColor() {
        condition = false
        UIView.animate(withDuration: 0.5) {
            self.lblTitles[self.curInt].textColor = UIColor(named: "colorGray200")
            self.lblDetails[self.curInt].textColor = UIColor(named: "colorGray700")
            self.viewsNotice[self.curInt].backgroundColor = color.mint.getcolor()
            self.imgsArrow[self.curInt].transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        calculate(viewAlpha: 0)
        goUp()
    }
    
    func changeBack() {
        condition = true
        UIView.animate(withDuration: 0.5) {
            self.lblTitles[self.curInt].textColor = color.mint.getcolor()
            self.lblDetails[self.curInt].textColor = color.B6.getcolor()
            self.viewsNotice[self.curInt].backgroundColor = UIColor(named: "colorGray200")
            self.imgsArrow[self.curInt].transform = CGAffineTransform(rotationAngle: 0)
        }
        
        calculate(viewAlpha: 1)
        goDown()
    }
    
    func goUp() {
        tempY = viewsNotice[curInt].center.y
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.viewsNotice[self.curInt].center = CGPoint(x: (self.view.frame.size.width) / 2, y: 120)
        }, completion: {(finished:Bool) in
            self.isGoNext = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "scrollViewVC")
            self.present(vc!, animated: false, completion: nil)
        })
    }
    
    func goDown() {
        UIView.animate(withDuration: 0.5) {
            self.viewsNotice[self.curInt].center = CGPoint(x: (self.view.frame.size.width) / 2, y: self.tempY)
        }
    }
    
    func calculate(viewAlpha: Float) {
        var i = 0
        for i in 0...1 {
            showLabelAnimation(label: lblBases[i], duration: 0.3, Float(lblBases[i].alpha), viewAlpha)
        }
        while i < 9 {
            if i != curInt {
                showViewAnimation(view: viewsNotice[i], duration: 0.3, Float(viewsNotice[i].alpha), viewAlpha)
                i += 1
            } else {
                i += 1
            }
        }
    }
}

