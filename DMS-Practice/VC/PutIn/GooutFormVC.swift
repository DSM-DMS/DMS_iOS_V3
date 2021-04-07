// https://www.youtube.com/watch?v=BZchurCYyJM
//  GooutFormVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 07/01/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class GooutFormVC: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet var lblsTextField: [UILabel]!
    @IBOutlet var txtsTime: [UITextField]!
    @IBOutlet weak var btnApplyOutlet: UIButton!
    
    var reasonArray = [Int]()
    var writingText = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dropShadowButton(button: btnApplyOutlet, color: UIColor.gray, offSet: CGSize(width: 3, height: 3))
        btnApplyOutlet.layer.cornerRadius = 17
        
        for i in 0...2 {
            lblsTextField[i].alpha = 0
            txtsTime[i].delegate = self
            txtsTime[i].layer.borderWidth = 0
            txtsTime[i].layer.cornerRadius = 3
            txtsTime[i].layer.borderColor = color.mint.getcolor().cgColor
        }
    }
    
    @IBAction func textGooutDate(_ sender: Any) {
        setTextField(senderTag: (sender as AnyObject).tag, mode: 0)
    }
    
    @IBAction func textGooutTime(_ sender: Any) {
        setTextField(senderTag: (sender as AnyObject).tag, mode: 1)
    }
    
    @IBAction func textReason(_ sender: Any) {
        setTextField(senderTag: (sender as AnyObject).tag, mode: 0)
    }
    
    @IBAction func btnGoback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnApplyAction(_ sender: Any) {
        for i in 0...2 {
            if txtsTime[i].text != "" {
                
            } else {
                showToast(msg: "모든 값을 확인하세요")
                return
            }
            if i == 2 {
                getData()
            }
        }
    }
    
    func setTextField(senderTag: Int, mode: Int) {
        writingText = senderTag
        txtsTime[writingText].layer.borderWidth = 1
        UIView.animate(withDuration: 0.5) {
            self.lblsTextField![self.writingText].alpha = 1
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtsTime[0] {
            
            if (txtsTime[0].text?.count == 2) {
                if !(string == "") {
                    if Int(txtsTime[0].text!)! > 12 {
                        txtsTime[0].text = "12"
                    }
                    txtsTime[0].text = (txtsTime[0].text)! + "-"
                }
            }
            if (txtsTime[0].text?.count == 5) {
                var char = txtsTime[0].text?.map { String($0) }
                if !(string == "") {
                    if Int(char![3])! * 10 + Int(char![4])! > 31 {
                        char![3] = "3"
                        char![4] = "1"
                        txtsTime[0].text = char![0] + char![1] + char![2] + char![3] + char![4]
                    }
                }
            }
            return !(textField.text!.count > 4 && (string.count ) > range.length)
        } else if textField == txtsTime[1] {
            switch txtsTime[1].text?.count {
            case 2:
                if !(string == "") {
                    txtsTime[1].text = (txtsTime[1].text)! + ":"
                }
            case 5:
                if !(string == "") {
                    txtsTime[1].text = (txtsTime[1].text)! + " ~ "
                }
            case 6:
                if !(string == "") {
                    txtsTime[1].text = (txtsTime[1].text)! + "~ "
                }
            case 7:
                if !(string == "") {
                    txtsTime[1].text = (txtsTime[1].text)! + " "
                }
            case 10:
                if !(string == "") {
                    txtsTime[1].text = (txtsTime[1].text)! + ":"
                }
            default: break
            }
            return !(textField.text!.count > 12 && (string.count ) > range.length)
        }
        else {
            return true
        }
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        txtsTime[writingText].layer.borderWidth = 0
        UIView.animate(withDuration: 0.3) {
            self.lblsTextField[self.writingText].alpha = 0
        }
    }
    
    func getData() {
        let parameters = ["date": txtsTime[0].text! + " " + txtsTime[1].text!, "reason": txtsTime[2].text!] as [String : Any]
        
        let url = URL(string: "https://api.dsm-dms.com/apply/goingout")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        request.addValue(self.getDate(), forHTTPHeaderField: "X-Date")
        request.addValue(self.getCrypto(), forHTTPHeaderField: "User-Data")
        request.addValue(self.getToken(), forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                switch httpStatus.statusCode {
                case 201:
                    DispatchQueue.main.async {
                        self.showToast(msg: "신청 성공")
                        self.navigationController?.popViewController(animated: true)
                    }
                case 204:
                    DispatchQueue.main.async {
                        self.showToast(msg: "신청 가능한 시간이 아닙니다")
                    }
                case 403:
                    if self.isRelogin() {
                        self.getData()
                    }
                case 409:
                    DispatchQueue.main.async {
                        self.showToast(msg: "정확한 시간을 입력하세요")
                    }
                default:
                    print(httpStatus.statusCode)
                }
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString!))")
        }
        task.resume()
    }
}
