//
//  MyPageVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 20/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit

class MyPageVC: UIViewController{
    
    @IBOutlet weak var viewPrise: UIView!
    @IBOutlet weak var viewPenalty: UIView!
    @IBOutlet weak var viewCondition: UIView!
    @IBOutlet weak var lblPrise: UILabel!
    @IBOutlet weak var lblPenalty: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPrise.layer.cornerRadius = 16
        viewPenalty.layer.cornerRadius = 16
        
        dropShadow(view: viewPrise, color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
        dropShadow(view: viewPenalty, color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
        
        viewCondition.layer.cornerRadius = 17
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !loginCheck() { goNextVCwithUIid(UIid: "AccountUI", VCid: "EmptyVC") }
        else { getData() }
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        goNextVC("SubmitProcessVC")
    }
    
    @IBAction func btnBrokenReport(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let attributedString = NSAttributedString(string: "시설 고장 신고", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor : color.mint.getcolor()
            ])
        
        alert.view.tintColor = color.mint.getcolor()
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        alert.addTextField { (myTextField) in
            myTextField.placeholder = "제목을 입력하세요"
        }
        alert.addTextField { (myTextField) in
            myTextField.placeholder = "방 번호를 입력하세요"
        }
        
        let ok = UIAlertAction(title: "전송", style: .default) { (ok) in
            if alert.textFields?[0].text != nil && alert.textFields?[1].text != nil {
                if let _ = Int(((alert.textFields?[1].text)!)) {
                    let parameters = ["content": (alert.textFields?[0].text)!, "room": Int((alert.textFields?[1].text)!)!] as [String : Any]
                    let url = URL(string: "https://api.dsm-dms.com/report/facility")!
                    self.postData(parameters: parameters, url: url)
                } else {
                    self.showToast(msg: "숫자만 입력하세요")
                }
            } else {
                self.showToast(msg: "모든 값을 입력하세요")
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnBugReport(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let attributedString = NSAttributedString(string: "버그 신고", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor : color.mint.getcolor()
            ])
        
        alert.view.tintColor = color.mint.getcolor()
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        alert.addTextField { (myTextField) in
            myTextField.placeholder = "제목을 입력하세요"
        }
        alert.addTextField { (myTextField) in
            myTextField.placeholder = "내용을 입력하세요"
        }
        
        
        let ok = UIAlertAction(title: "전송", style: .default) { (ok) in
            if alert.textFields?[0].text != nil && ((alert.textFields?[1].text) != nil) {
                let parameters = ["content": "\((alert.textFields?[0].text)!) / " + (alert.textFields?[1].text)!]
                let url = URL(string: "https://api.dsm-dms.com/report/bug/3")!
                self.postData(parameters: parameters, url: url)
            } else {
                self.showToast(msg: "모든 값을 확인하세요")
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func postData(parameters: [String: Any], url: URL) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription) 
        }
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        request.addValue(self.getToken(), forHTTPHeaderField: "Authorization")
        request.addValue(self.getDate(), forHTTPHeaderField: "X-Date")
        request.addValue(self.getCrypto(), forHTTPHeaderField: "User-Data")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { [weak self] data, res, err in
            guard self != nil else { return }
            if let err = err { print(err.localizedDescription); return }
            print((res as! HTTPURLResponse).statusCode)
            switch (res as! HTTPURLResponse).statusCode{
            case 201:
                DispatchQueue.main.async {
                    self!.showToast(msg: "신청되었습니다")
                }
            case 403:
                if self!.isRelogin() {
                    self!.postData(parameters: parameters, url: url)
                }
            default:
                DispatchQueue.main.async {
                    self?.showError((res as! HTTPURLResponse).statusCode)
                }
            }
            }.resume()
    }
    
    func getData() {
        let url = URL(string: "https://api.dsm-dms.com/info/basic")!
        
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
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                
                print("\(jsonSerialization)")
                DispatchQueue.main.async {
                    self!.lblName.text = (jsonSerialization["name"] as! String)
                    self!.lblNumber.text = String(jsonSerialization["number"] as! Int)
                    self!.lblPrise.text = String(jsonSerialization["goodPoint"] as! Int)
                    self!.lblPenalty.text = String(jsonSerialization["badPoint"] as! Int)
                    self!.lblStatus.text = String(jsonSerialization["advice"] as! String)
                }
            case 403:
                if self!.isRelogin() {
                    print("시작")
                    self!.getData()
                }
            default:
                print("error")
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

