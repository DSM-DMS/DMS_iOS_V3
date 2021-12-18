//
//  DeveloperVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 06/03/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class DeveloperVC: UIViewController {
    
    @IBOutlet weak var viewGoback: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewGoback.layer.cornerRadius = viewGoback.frame.height / 2
    }
    
    
    @IBAction func btnGoback(_ sender: Any) {
        goBack()
    }
    
    func dropShadowImg(view: UIImageView, color: UIColor, opacity: Float = 0.5, offSet: CGSize, scale: Bool = true) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = 5
        
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
}
