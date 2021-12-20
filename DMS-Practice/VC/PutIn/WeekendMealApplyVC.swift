//
//  RemainApplyVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 03/01/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class WeekendMealApplyVC: UIViewController {
    
    @IBOutlet var viewsBackground: [UIView]!
    @IBOutlet var lblsTitle: [UILabel]!
    @IBOutlet var lblsDescription: [UILabel]!
    @IBOutlet weak var btnApplyOutlet: UIButton!
    
    let ud = UserDefaults.standard
    var curCondition = 0
    var preCondition = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStayCondition()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        btnApplyOutlet.layer.cornerRadius = 17
        dropShadowButton(button: btnApplyOutlet, color: UIColor.gray, offSet: CGSize(width: 3, height: 3))
        for i in 0...2 {
            viewsBackground[i].layer.cornerRadius = 17
            dropShadow(view: viewsBackground[i], color: UIColor(named: "barColor")!, offSet: CGSize(width: 3, height: 3))
        }
        // Do any additional setup after loading the view.
        let firAction = UITapGestureRecognizer(target: self, action: #selector(self.firstAction))
        self.viewsBackground[0].addGestureRecognizer(firAction)
        let secAction = UITapGestureRecognizer(target: self, action: #selector(self.secondAction))
        self.viewsBackground[1].addGestureRecognizer(secAction)
        let thiAction = UITapGestureRecognizer(target: self, action: #selector(self.thirdAction))
        self.viewsBackground[2].addGestureRecognizer(thiAction)
        
        if let string = ud.string(forKey: "weekendMealCondition") {
            curCondition = Int(string)!
        }
        
        changeColor()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func btnGoback(_ sender: Any) {
        goBack()
    }
    
    @objc func firstAction() {
        preCondition = curCondition
        curCondition = 0
        changeColor()
    }
    
    @objc func secondAction() {
        preCondition = curCondition
        curCondition = 1
        changeColor()
    }
    
    @objc func thirdAction() {
        preCondition = curCondition
        curCondition = 2
        changeColor()
    }
    
    @IBAction func btnApply(_ sender: Any) {
        getData()
        setUserDefault(toSet: "\(String(curCondition))", key: "weekendMealCondition")
    }
    
    func changeColor() {
        if preCondition < 3 {
            viewsBackground[preCondition].backgroundColor = UIColor(named: "colorGray200")
            lblsTitle[preCondition].textColor = color.mint.getcolor()
            lblsDescription[preCondition].textColor = UIColor(named: "colorGray700")
        }
        viewsBackground[curCondition].backgroundColor = color.mint.getcolor()
        lblsTitle[curCondition].textColor = .white
        lblsDescription[curCondition].textColor = .white
    }
    
    func getData() {
        let parameters = ["value": curCondition + 1]
        
        let url = URL(string: "https://eaes03njn2.execute-api.ap-northeast-2.amazonaws.com/apply-weekend")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        request.addValue(getDate(), forHTTPHeaderField: "X-Date")
        request.addValue(getCrypto(), forHTTPHeaderField: "User-Data")
        request.addValue(getToken(), forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                switch httpStatus.statusCode {
                case 200:
                    DispatchQueue.main.async {
                        self.showToast(msg: "신청되었습니다")
                    }
                case 409:
                    DispatchQueue.main.async {
                        self.showToast(msg: "신청가능시간을 확인해주세요")
                    }
                case 403:
                    if self.isRelogin() {
                        self.getData()
                    }
                default:
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString!))")
                }
            }
            
            
        }
        task.resume()
    }
    
    func getStayCondition() {
        
        var request = URLRequest(url: URL(string: "https://eaes03njn2.execute-api.ap-northeast-2.amazonaws.com/apply-weekend")!)
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
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Int]
                
                let current = jsonSerialization["value"]! - 1
                
                print("condition: \(current)")
                
                switch current {
                case 0:
                    DispatchQueue.main.async {
                        self?.showToast(msg: "현재 '대기' 상태입니다.")
                    }
                case 1:
                    DispatchQueue.main.async {
                        self?.showToast(msg: "현재 '신청' 상태입니다.")
                    }
                case 2:
                    DispatchQueue.main.async {
                        self?.showToast(msg: "현재 '미신청' 상태입니다.")
                    }
                default:
                    DispatchQueue.main.async {
                        self?.showToast(msg: "Errrorr")
                    }
                }
            case 401:
                print("정보없음")
            case 403:
                self?.showToast(msg: "로그인 기한 만료")
            default:
                print((res as! HTTPURLResponse).statusCode)
                print("error")
            }
        }.resume()
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            goBack()
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
