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
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...3 {
            viewsBack[i].layer.cornerRadius = 17
            dropShadow(view: viewsBack[i], color: UIColor(named: "barColor")!, offSet: CGSize(width: 3, height: 3))
            lblsDetail[i].fitTextToBounds()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !loginCheck() { goNextVCwithUIid(UIid: "AccountUI", VCid: "EmptyVC") }
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
