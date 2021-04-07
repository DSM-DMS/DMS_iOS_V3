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
    @IBOutlet var imgsDeveloper: [UIImageView]!
    @IBOutlet var viewsName: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewGoback.layer.cornerRadius = viewGoback.frame.height / 2
        
        for i in 0...12 {
            let rectShape1 = CAShapeLayer()
            rectShape1.bounds = self.imgsDeveloper[i].frame
            rectShape1.position = self.imgsDeveloper[i].center
            rectShape1.path = UIBezierPath(roundedRect: self.imgsDeveloper[i].bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 17, height: 17)).cgPath
            self.imgsDeveloper[i].layer.mask = rectShape1
            let rectShape2 = CAShapeLayer()
            rectShape2.bounds = self.viewsName[i].frame
            rectShape2.position = self.viewsName[i].center
            rectShape2.path = UIBezierPath(roundedRect: self.viewsName[i].bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 17, height: 17)).cgPath
            self.viewsName[i].layer.mask = rectShape2
            imgsDeveloper[i].layer.masksToBounds = false
            dropShadowImg(view: imgsDeveloper[i], color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
        }
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
