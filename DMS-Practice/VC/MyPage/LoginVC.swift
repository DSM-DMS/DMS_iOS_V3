//
//  LoginVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 24/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit
import Security

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var txtID: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var viewUnderlineID: UIView!
    @IBOutlet weak var viewUnderlinePassword: UIView!
    @IBOutlet weak var btnLoginOutlet: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet var lblInfo: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ud.object(forKey: "accountID") != nil {
            txtID.text = (ud.object(forKey: "accountID") as! String)
            txtPassword.text = (ud.object(forKey: "accountPW") as! String)
        }
        
        viewUnderlineID.alpha = 0.1
        viewUnderlinePassword.alpha = 0.1
        imgLogo.alpha = 0
        for i in 0...2 {
            lblInfo[i].alpha = 0
        }
        
        txtID.delegate = self
        txtPassword.delegate = self
        
        viewBackground.layer.cornerRadius = 10
        btnLoginOutlet.layer.cornerRadius = 13
        dropShadowButton(button: btnLoginOutlet, color: UIColor.gray, offSet: CGSize(width: 3, height: 3))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2) {
            self.imgLogo.alpha = 1
        }
        for i in 0...2 {
            showLabelAnimation(label: lblInfo[i], duration: 2, Float(lblInfo[i].alpha), 1)
        }
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        if isFull() {
            getData()
        } else {
            showToast(msg: "모든 값을 확인하세요")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editStart()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason:
        UITextField.DidEndEditingReason) {
        UIView.animate(withDuration: 0.3) {
            self.viewUnderlineID.alpha = 0.1
            self.viewUnderlinePassword.alpha = 0.1
        }
    }

    func editStart() {
        if txtID.isEditing {
            UIView.animate(withDuration: 0.5) {
                self.viewUnderlineID.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.viewUnderlinePassword.alpha = 1
            }
        }
    }
    
    func isFull() -> Bool {
        if txtPassword.text == "" || txtPassword.text == ""{
            return false
        } else {
            return true
        }
    }
    
    func getData() {
        let parameters = ["id": txtID.text!, "password": txtPassword.text!]
        let url = URL(string: "https://api.dsm-dms.com/account/auth")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        request.addValue(getDate(), forHTTPHeaderField: "X-Date")
        request.addValue(getCrypto(), forHTTPHeaderField: "User-Data")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { [weak self] data, res, err in
            guard self != nil else { return }
            if let err = err { print(err.localizedDescription); return }
            print((res as! HTTPURLResponse).statusCode)
            switch (res as! HTTPURLResponse).statusCode{
            case 200:
                DispatchQueue.main.async {
                    ud.set(self!.txtID.text, forKey: "accountID")
                    ud.set(self!.txtPassword.text, forKey: "accountPW")
                }
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                print("\(jsonSerialization)")
                Token.instance.save(AuthModel(accessToken: jsonSerialization["accessToken"] as! String, refreshToken: (jsonSerialization["refreshToken"] as! String)))
                DispatchQueue.main.async { self!.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {})
                }
            case 204:
                print("로그인 실패")
                DispatchQueue.main.async {
                    self?.showToast(msg: "로그인 실패")
                }
            case 403:
                if self!.isRelogin() {
                    self!.getData()
                }
            default:
                DispatchQueue.main.async {
                    self?.showError((res as! HTTPURLResponse).statusCode)
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

struct AuthModel: Codable{
    let accessToken: String
    let refreshToken: String?
}


class Token{
    
    static let instance = Token()
    private let repo = UserDefaults.standard
    private let accessKey = "access"
    private let refreshKey = "refresh"
    
    private init(){}
    
    func save(_ token: AuthModel){
        repo.set(token.accessToken, forKey: accessKey)
        repo.set(token.refreshToken!, forKey: refreshKey)
    }
    
    func changeAccessToken(_ token: String){
        repo.set(token, forKey: accessKey)
    }
    
    func remove(){
        repo.removeObject(forKey: accessKey)
        repo.removeObject(forKey: refreshKey)
    }
    
    func get() -> AuthModel?{
        let accessToken = repo.string(forKey: accessKey)
        let refreshToken = repo.string(forKey: refreshKey)
        if let at = accessToken, refreshToken != nil{ return AuthModel(accessToken: "Bearer " + at, refreshToken: "Bearer " + refreshToken!) }
        else{ return nil }
    }
    
}
