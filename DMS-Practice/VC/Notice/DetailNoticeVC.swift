//
//  DetailNoticeVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 02/01/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class DetailNoticeVC: UIViewController {
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var btnBackOutlet: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    var paramId = ""
    var paramUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
        viewBackground.layer.cornerRadius = 25
        dropShadow(view: viewBackground, color: UIColor(named: "barColor")!, offSet: CGSize(width: 0, height: 5))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showGoBack(button: btnBackOutlet)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        goBack()
    }
    
    func getData() {
           var request = URLRequest(url: URL(string: "https://api.dsm-dms.com/\(paramUrl)/\(paramId)")!)
           request.httpMethod = "GET"
           request.addValue("iOS", forHTTPHeaderField: "User-Agent")
           request.addValue(getDate(), forHTTPHeaderField: "X-Date")
           request.addValue(getCrypto(), forHTTPHeaderField: "User-Data")
           URLSession.shared.dataTask(with: request){
               [weak self] data, res, err in
               guard self != nil else { return }
               if let err = err { print(err.localizedDescription); return }
               print((res as! HTTPURLResponse).statusCode)
               switch (res as! HTTPURLResponse).statusCode{
               case 200:
                   let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                   print("\(jsonSerialization)")
                   DispatchQueue.main.async {
                       self!.lblTitle.text = (jsonSerialization["title"] as! String)
                       self!.lblSubtitle.text = (jsonSerialization["postDate"] as! String)
                       self!.lblDescription.text = (jsonSerialization["content"] as! String)
                   }
               case 403:
                   if self!.isRelogin() {
                       self!.getData()
                   }
               default:
                   DispatchQueue.main.async {
                       self!.showToast(msg: "살려주세요")
                   }
               }
               }.resume()
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
