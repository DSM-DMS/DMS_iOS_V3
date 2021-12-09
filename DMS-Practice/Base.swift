//
//  Base.swift
//  DMS-Practice
//
//  Created by leedonggi on 24/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit
import CryptoSwift

public let ud = UserDefaults.standard

extension UIViewController {
    
    public func loginCheck() -> Bool{
        let isLogin = Token.instance.get() != nil
        return isLogin
    }
    
    func goNextVC(_ id: String){
        let vc = storyboard?.instantiateViewController(withIdentifier: id)
        if id == "weekendMealApplyVC" {
            vc!.modalPresentationStyle = .fullScreen
        }
        present(vc!, animated: true, completion: nil)
    }
    
    func goNextVCwithUIid(UIid: String, VCid: String) {
        let contentStoryboard = UIStoryboard.init(name: UIid, bundle: nil)
        let vc = contentStoryboard.instantiateViewController(withIdentifier: VCid)
        present(vc, animated: true, completion: nil)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func showError(_ code: Int){
        showToast(msg: "오류 : \(code)")
    }
    
    func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func showLabelAnimation(label: UILabel, duration: Float, _ to: Float, _ go: Float) {
        label.alpha = CGFloat(to)
        UIView.animate(withDuration: TimeInterval(duration)) {
            label.alpha = CGFloat(go)
        }
    }
    
    func showViewAnimation(view: UIView, duration: Float, _ to: Float, _ go: Float) {
        view.alpha = CGFloat(to)
        UIView.animate(withDuration: TimeInterval(duration)) {
            view.alpha = CGFloat(go)
        }
    }
    
    func showGoBack(button: UIButton) {
        UIView.animate(withDuration: 1) {
            button.alpha = 1
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
    
    func dropShadow(view: UIView, color: UIColor, opacity: Float = 0.5, offSet: CGSize, scale: Bool = true) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = 5
        
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadowButton(button: UIButton, color: UIColor, opacity: Float = 0.5, offSet: CGSize, scale: Bool = true) {
        button.layer.masksToBounds = false
        button.layer.shadowColor = color.cgColor
        button.layer.shadowOpacity = opacity
        button.layer.shadowOffset = offSet
        button.layer.shadowRadius = 5
        
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    private func showUpdateAlert(){
        let alert = UIAlertController(title: "업데이트가 필요합니다.", message: "DMS의 새로운 업데이트가 준비되었습니다.\n지금 업데이트 하세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showToast(msg: String, fun: (() -> Void)? = nil){
        let toast = UILabel(frame: CGRect(x: 32, y: 128, width: view.frame.size.width - 64, height: 42))
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        toast.textColor = UIColor.white
        toast.text = msg
        toast.textAlignment = .center
        toast.layer.cornerRadius = 8
        toast.clipsToBounds = true
        toast.autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleWidth]
        view.addSubview(toast)
        UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseOut, animations: {
            toast.alpha = 0.0
        }, completion: { _ in
            toast.removeFromSuperview()
            fun?()
        })
    }
    
    func setUserDefault(toSet: String, key: String) {
        ud.set("\(toSet)", forKey: "\(key)")
    }
    
    func textFieldAnimate(txt: UITextField, titleMsg: String, isEditting: Bool) {
        let title = UILabel(frame: CGRect(x: txt.frame.origin.x + 10, y: txt.frame.origin.y + 5, width: 30, height: 50))
        title.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 0)
        title.textColor = color.mint.getcolor()
        title.text = titleMsg
        if isEditting {
            view.addSubview(title)
            UIView.animate(withDuration: 0.3) {
                title.alpha = 1
                txt.borderStyle = .roundedRect
                txt.layer.cornerRadius = 6
                txt.layer.borderColor = color.mint.getcolor().cgColor
                txt.layer.borderWidth = 1
            }
        } else {
            title.removeFromSuperview()
        }
    }
    
    func showAlert() {
        let alert = UIView(frame: CGRect(x: 32, y: 140, width: view.frame.size.width - 64, height: 30))
        alert.backgroundColor = UIColor.white
        alert.alpha = 0
        
    }
    
    func getDate() -> String {
        let now = Date()
        let weekDay = DateFormatter()
        weekDay.locale = Locale(identifier: "ko_kr")
        weekDay.timeZone = TimeZone(abbreviation: "KST")
        weekDay.dateFormat = "EEEE"
        let monthEng = DateFormatter()
        monthEng.locale = Locale(identifier: "ko_kr")
        monthEng.timeZone = TimeZone(abbreviation: "KST")
        monthEng.dateFormat = "LLLL"
        let date = DateFormatter()
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        date.dateFormat = "dd yyyy HH:mm:ss"
        
        let kr = date.string(from: now)
        let returnValue = getMonthEng(monthEng.string(from: now)) + " " + getWeekday(weekDay.string(from: now)) + " " + kr
        return returnValue
    }
    
    func getCrypto() -> String {
        let date = getDate()
        let base64 = "iOS" + date
        let data = Data(base64.utf8).base64EncodedString()
        let crypto = data.sha3(.sha512)
        
        return crypto
    }
    
    func getToken() -> String {
        if let token = Token.instance.get() {
            return token.accessToken
        }
        return ""
    }
    
    func getWeekday(_ wd: String) -> String {
        switch wd {
        case "일요일":
            return "Sun"
        case "월요일":
            return "Mon"
        case "화요일":
            return "Tue"
        case "수요일":
            return "Wed"
        case "목요일":
            return "Thu"
        case "금요일":
            return "Fri"
        case "토요일":
            return "Sat"
        default:
            return "Error"
        }
    }
    
    func getMonthEng(_ me: String) -> String {
        switch me {
        case "1월":
            return "Jan"
        case "2월":
            return "Feb"
        case "3월":
            return "Mar"
        case "4월":
            return "Apr"
        case "5월":
            return "May"
        case "6월":
            return "Jun"
        case "7월":
            return "Jul"
        case "8월":
            return "Aug"
        case "9월":
            return "Sep"
        case "10월":
            return "Oct"
        case "11월":
            return "Nov"
        case "12월":
            return "Dec"
        default:
            return "Error"
            
        }
    }
    
    func isRelogin() -> Bool {
        var returnValue = false
        if ud.object(forKey: "accountID") == nil || ud.object(forKey: "accountPW") == nil {
            DispatchQueue.main.async {
                print("로그인 해주세요")
            }
        }
        Token.instance.remove()
        let parameters = ["id": (ud.object(forKey: "accountID") as! String), "password": (ud.object(forKey: "accountPW") as! String)]
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
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                print("\(jsonSerialization)")
                Token.instance.save(AuthModel(accessToken: jsonSerialization["accessToken"] as! String, refreshToken: (jsonSerialization["refreshToken"] as! String)))
                returnValue = true
            case 204:
                print("로그인 실패")
                DispatchQueue.main.async {
                    self?.showToast(msg: "로그인 실패")
                }
            default:
                DispatchQueue.main.async {
                    self?.showError((res as! HTTPURLResponse).statusCode)
                }
            }
            }.resume()
        return returnValue
    }
}

extension UIFont {
    
    static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]
        
        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }
    
    static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }
}

extension UILabel {
    
    /// Will auto resize the contained text to a font size which fits the frames bounds.
    /// Uses the pre-set font to dynamically determine the proper sizing
    func fitTextToBounds() {
        guard let text = text, let currentFont = font else { return }
        
        let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
        font = bestFittingFont
    }
    
    private var basicStringAttributes: [NSAttributedString.Key: Any] {
        var attribs = [NSAttributedString.Key: Any]()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        attribs[.paragraphStyle] = paragraphStyle
        
        return attribs
    }
}

enum color {
    case mint, lightGray, M1, M2, M3, M4, M5, M6, M7, M8, B1, B2, B3, B4, B5, B6, B7, B8, B9
    
    func getcolor() -> UIColor {
        switch self {
        case .mint:
            return UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 1)
        case .lightGray:
            return UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
        case .M1:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .M2:
            return UIColor(red: 230/255, green: 245/255, blue: 246/255, alpha: 1)
        case .M3:
            return UIColor(red: 205/255, green: 236/255, blue: 236/255, alpha: 1)
        case .M4:
            return UIColor(red: 181/255, green: 226/255, blue: 227/255, alpha: 1)
        case .M5:
            return UIColor(red: 157/255, green: 217/255, blue: 218/255, alpha: 1)
        case .M6:
            return UIColor(red: 135/255, green: 207/255, blue: 208/255, alpha: 1)
        case .M7:
            return UIColor(red: 115/255, green: 198/255, blue: 199/255, alpha: 1)
        case .M8:
            return UIColor(red: 97/255, green: 188/255, blue: 190/255, alpha: 1)
        case .B1:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        case .B2:
            return UIColor(red: 223/255, green: 223/255, blue: 223/255, alpha: 1)
        case .B3:
            return UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        case .B4:
            return UIColor(red: 159/255, green: 159/255, blue: 159/255, alpha: 1)
        case .B5:
            return UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
        case .B6:
            
            return UIColor(named: "colorGray700") ?? UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1)
        case .B7:
            return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
        case .B8:
            return UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
        case .B9:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}
