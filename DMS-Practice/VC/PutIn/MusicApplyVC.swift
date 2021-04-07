//
//  MusicApplyVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 03/01/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class MusicApplyVC: UIViewController {
    
    @IBOutlet var viewsBack: [UIView]!
    @IBOutlet var lblsDay: [UILabel]!
    @IBOutlet var lblsDescription: [UILabel]!
    @IBOutlet weak var btnApplyOutlet: UIButton!
    
    var num = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        btnApplyOutlet.layer.cornerRadius = 17
        dropShadowButton(button: btnApplyOutlet, color: UIColor.gray, offSet: CGSize(width: 3, height: 3))
        for i in 0...4{
            viewsBack[i].layer.cornerRadius = 17
            dropShadow(view: viewsBack[i], color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
        }
        
        for i in 0...4 {
            let mon = UITapGestureRecognizer(target: self, action: #selector(self.viewAction))
            viewsBack[i].tag = i
            self.viewsBack[i].addGestureRecognizer(mon)
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnGoback(_ sender: Any) {
        goBack()
    }
    
    @IBAction func btnApply(_ sender: Any) {
        if num == 5 {
            showToast(msg: "요일을 선택해주세요")
        } else {
            guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "MusicSendVC") as? MusicSendVC else {
                return
            }
            rvc.day = self.getDay()
            self.navigationController?.pushViewController(rvc, animated: true)
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            goBack()
        }
    }
    
    @objc func viewAction(_ sender: UITapGestureRecognizer) {
        num = (sender.view?.tag)!
        changeColor()
    }

    func changeColor() {
        for i in 0...4 {
            viewsBack[i].backgroundColor = UIColor.white
            lblsDay[i].textColor = color.mint.getcolor()
            lblsDescription[i].textColor = UIColor.darkGray
        }
        viewsBack[num].backgroundColor = color.mint.getcolor()
        lblsDay[num].textColor = UIColor.white
        lblsDescription[num].textColor = UIColor.white
    }
    
    func getDay() -> String{
        switch num {
        case 0:
            return "월요일"
        case 1:
            return "화요일"
        case 2:
            return "수요일"
        case 3:
            return "목요일"
        case 4:
            return "금요일"
        default:
            return ""
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
