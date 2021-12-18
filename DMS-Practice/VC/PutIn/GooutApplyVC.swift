//
//  GooutApplyVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 03/01/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class GooutApplyVC: UIViewController {
    
    @IBOutlet var viewsBack: [UIView]!
    @IBOutlet var viewsNum: [UIView]!
    @IBOutlet weak var btnApplyOutlet: UIButton!
    @IBOutlet var lblsDay: [UILabel]!
    @IBOutlet var lblsDescription: [UILabel]!
    @IBOutlet var lblsNum: [UILabel]!
    
    var num = 3
    var satCnt = 0
    var sunCnt = 0
    var dayCnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        btnApplyOutlet.layer.cornerRadius = 17
        dropShadowButton(button: btnApplyOutlet, color: UIColor.gray, offSet: CGSize(width: 3, height: 3))
        
        for i in 0...2{
            viewsBack[i].layer.cornerRadius = 17
            dropShadow(view: viewsBack[i], color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
        }
        
        for i in 0...2 {
            let mon = UITapGestureRecognizer(target: self, action: #selector(self.viewAction))
            viewsNum[i].layer.cornerRadius = 20
            dropShadow(view: viewsNum[i], color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
            viewsBack[i].tag = i
            viewsBack[i].layer.cornerRadius = 10
            dropShadow(view: viewsBack[i], color: UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16), offSet: CGSize(width: 3, height: 3))
            self.viewsBack[i].addGestureRecognizer(mon)
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("hello")
        getData()
    }
    
    @IBAction func btnApply(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GooutFormVC")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func btnGoback(_ sender: Any) {
        goBack()
    }
    
    @objc func viewAction(_ sender: UITapGestureRecognizer) {
        if (sender.view?.tag)! == num {
            guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "GooutListVC") as? GooutListVC else {
                return
            }
            rvc.keyValueInt = (sender.view?.tag)!
            self.navigationController?.pushViewController(rvc, animated: true)
        } else {
            num = (sender.view?.tag)!
            changeColor()
        }
    }
    
    func changeColor() {
        for i in 0...2 {
            viewsBack[i].backgroundColor = UIColor(named: "colorGray200")
            lblsDay[i].textColor = color.mint.getcolor()
            lblsDescription[i].textColor = UIColor(named: "colorGray700")
        }
        viewsBack[num].backgroundColor = color.mint.getcolor()
        lblsDay[num].textColor = UIColor.white
        lblsDescription[num].textColor = UIColor.white
    }
    
    func getData() {
        var request = URLRequest(url: URL(string: "https://api.dsm-dms.com/apply/goingout")!)
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
                print("\(jsonSerialization)")
                let keyValue = ["saturday", "sunday", "workday"]
                self!.satCnt = (jsonSerialization[keyValue[0]]?.count)!
                self!.sunCnt = (jsonSerialization[keyValue[1]]?.count)!
                self!.dayCnt = (jsonSerialization[keyValue[2]]?.count)!
                
                print("\(self!.satCnt) \(self!.sunCnt) \(self!.dayCnt)")
                
                DispatchQueue.main.async {
                    if self!.satCnt == 0 { self!.viewsNum[0].isHidden = true }
                    else { self!.lblsNum[0].text = String(self!.satCnt); self!.viewsNum[0].isHidden = false }
                    if self!.sunCnt == 0 { self!.viewsNum[1].isHidden = true }
                    else { self!.lblsNum[1].text = String(self!.sunCnt); self!.viewsNum[1].isHidden = false}
                    if self!.dayCnt == 0 { self!.viewsNum[2].isHidden = true }
                    else { self!.lblsNum[2].text = String(self!.dayCnt); self!.viewsNum[2].isHidden = false }
                }
                
            case 204:
                DispatchQueue.main.async {
                    self!.lblsNum[0].text = "0"
                    self!.viewsNum[0].isHidden = true
                    self!.lblsNum[1].text = "0"
                    self!.viewsNum[1].isHidden = true
                    self!.lblsNum[2].text = "0"
                    self!.viewsNum[2].isHidden = true
                }
                print("nothing")
            case 403:
                DispatchQueue.main.async {
                    self!.showToast(msg: "로그인 기한 만료")
                }
            default:
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
