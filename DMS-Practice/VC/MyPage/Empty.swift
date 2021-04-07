//
//  Empty.swift
//  DMS-Practice
//
//  Created by leedonggi on 26/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit

class Empty: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if loginCheck() {
            goBack()
        } else {
            goNextVC("LoginVC")
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
