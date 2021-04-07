//
//  SubmitProcessVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 04/01/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class SubmitProcessVC: UIViewController {
    @IBOutlet weak var btnGobackOutlet: UIView!
    @IBOutlet weak var btnStartOutlet: UIButton!
    
    var paramId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(paramId)
        btnStartOutlet.isHidden = true
        btnGobackOutlet.layer.cornerRadius = 12
        btnStartOutlet.layer.cornerRadius = 17
        dropShadowButton(button: btnStartOutlet, color: UIColor.gray, offSet: CGSize(width: 3, height: 3))
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnGoback(_ sender: Any) {
        goBack()
    }
    
    @IBAction func btnStart(_ sender: Any) {
        
    }
    
    func getData() {
        let url = URL(string: "https://api.dsm-dms.com/survey/\(paramId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        request.addValue(getDate(), forHTTPHeaderField: "X-Date")
        request.addValue(getCrypto(), forHTTPHeaderField: "User-Data")
        request.addValue(getToken(), forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request){
            [weak self] data, res, err in
            guard self != nil else { return }
            if let err = err { print(err.localizedDescription); return }
            print((res as! HTTPURLResponse).statusCode)
            switch (res as! HTTPURLResponse).statusCode{
            case 200:
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:[[String: Any]]]
                let list = jsonSerialization["point_history"]
                DispatchQueue.main.async {
                    self?.showToast(msg: "권한 없음")
                }
            case 403:
                if self!.isRelogin() {
                    self!.getData()
                }
            default:
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                
                print("\(jsonSerialization)")
                print("error")
            }
            }.resume()
    }
    
}
