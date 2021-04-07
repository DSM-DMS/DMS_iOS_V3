//
//  PutInVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 20/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit

class PutInVC: UIViewController {
    
    @IBOutlet var viewsBack: [UIView]!
    @IBOutlet var lblsDetail: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...3 {
            viewsBack[i].layer.cornerRadius = 17
            dropShadow(view: viewsBack[i], color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
            lblsDetail[i].fitTextToBounds()
        }
        
        let selfstudy = UITapGestureRecognizer(target: self, action:  #selector(self.selfstudyApply))
        let remain = UITapGestureRecognizer(target: self, action:  #selector(self.remainApply))
        let music = UITapGestureRecognizer(target: self, action:  #selector(self.musicApply))
        let goout = UITapGestureRecognizer(target: self, action:  #selector(self.gooutApply))
        self.viewsBack[0].addGestureRecognizer(selfstudy)
        self.viewsBack[1].addGestureRecognizer(remain)
        self.viewsBack[2].addGestureRecognizer(music)
        self.viewsBack[3].addGestureRecognizer(goout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !loginCheck() { goNextVCwithUIid(UIid: "AccountUI", VCid: "EmptyVC") }
    }

    @objc func selfstudyApply() {
        goNextVC("selfstudyApplyVC")
    }
    
    @objc func remainApply() {
        goNextVC("remainApplyVC")
    }
    
    @objc func musicApply() {
        goNextVC("musicApplyVC")
    }
    
    @objc func gooutApply() {
        goNextVC("gooutApplyVC")
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
