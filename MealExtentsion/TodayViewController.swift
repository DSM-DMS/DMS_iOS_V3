//
//  TodayViewController.swift
//  MealExtentsion
//
//  Created by leedonggi on 07/02/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit
import NotificationCenter
import CryptoSwift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dataTextView: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let formatter = DateFormatter()
    
    private var date: Date!
    private let aDay = TimeInterval(86400)
    private var breakfastMenu = ""
    private var lunchMenu = ""
    private var dinnerMenu = ""
    
    private var data = [String]()
    
    private var currentTime = 0
    
    override func viewDidLoad() {
        date = Date()
        setInit()
    }
    
    @IBAction func before(_ sender: Any) {
        currentTime -= 1
        setData()
    }
    
    @IBAction func after(_ sender: Any) {
        currentTime += 1
        setData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController{
    
    private func setInit(){
        formatter.dateFormat = "H"
        guard let curIntTime = Int(formatter.string(from: date)) else{ return }
        switch curIntTime {
        case 0...8:
            currentTime = 0
        case 9...12:
            currentTime = 1
        case 13...17:
            currentTime = 2
        default:
            date! += aDay
            currentTime = 0
        }
        connect()
    }
    
    private func setData(){
        switch currentTime {
        case -1:
            date! -= aDay
            currentTime = 2
            connect()
        case 3:
            date! += aDay
            currentTime = 0
            connect()
        default:
            bind()
        }
    }
    
    private func connect(){
        var breakfastData = ""
        var lunchData = ""
        var dinnerData = ""
        
        formatter.dateFormat = "YYYY-MM-dd"
        let dateStr = formatter.string(from: date)
        let url = "https://api.dsm-dms.com/meal/" + dateStr
        var request  = URLRequest(url: URL(string: url)!)
        request.addValue("MealExtensioniOS", forHTTPHeaderField: "User-Agent")
        request.addValue(getDate(), forHTTPHeaderField: "X-Date")
        request.addValue(getCrypto(), forHTTPHeaderField: "User-Data")
        URLSession.shared.dataTask(with: request){
            [weak self] data, res, err in
            guard let strongSelf = self else { return }
            if let err = err { print(err.localizedDescription); return }
            print((res as! HTTPURLResponse).statusCode)
            switch (res as! HTTPURLResponse).statusCode{
            case 200:
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: [String: [String]]]
                let list = jsonSerialization["\(dateStr)"]
                if jsonSerialization["breakfast"]?.count != 0 {
                    self!.breakfastMenu = ""
                    var i = 0
                    while true {
                        if list == nil {
                            return
                        }
                        if list!["breakfast"] == nil {
                            breakfastData = "급식이 없습니다"
                            break
                        }
                        if i < (list!["breakfast"]?.count)! {
                            if self!.breakfastMenu == "" {  }
                            else { self!.breakfastMenu += ", " }
                            self!.breakfastMenu += list!["breakfast"]![i]
                        } else {
                            break
                        }
                        i += 1
                    }
                    if self!.breakfastMenu != "" {
                        breakfastData = self!.breakfastMenu
                    }
                }
                if jsonSerialization["lunch"]?.count != 0 {
                    self!.lunchMenu = ""
                    var i = 0
                    while true {
                        if list == nil {
                            return
                        }
                        if list!["lunch"] == nil {
                            breakfastData = "급식이 없습니다"
                            break
                        }
                        if i < (list!["lunch"]?.count)! {
                            if self!.lunchMenu == "" {  }
                            else { self!.lunchMenu += ", " }
                            self!.lunchMenu += list!["lunch"]![i]
                        } else {
                            break
                        }
                        i += 1
                    }
                    if self!.lunchMenu != "" {
                        lunchData = self!.lunchMenu
                    }
                }
                if jsonSerialization["dinner"]?.count != 0 {
                    self!.dinnerMenu = ""
                    var i = 0
                    while true {
                        if list == nil {
                            return
                        }
                        if list!["dinner"] == nil {
                            breakfastData = "급식이 없습니다"
                            break
                        }
                        if i < (list!["dinner"]?.count)! {
                            if self!.dinnerMenu == "" {  }
                            else { self!.dinnerMenu += ", " }
                            self!.dinnerMenu += list!["dinner"]![i]
                        } else {
                            break
                        }
                        i += 1
                    }
                    if self!.breakfastMenu != "" {
                        dinnerData = self!.dinnerMenu
                    }
                }
                
                print("\(jsonSerialization)")
                
                strongSelf.data = ["\(breakfastData)", "\(lunchData)", "\(dinnerData)"]
            case 204: strongSelf.data = ["급식이 없습니다", "급식이 없습니다", "급식이 없습니다"]
            case let code: strongSelf.data = ["오류 : \(code)", "오류 : \(code)", "오류 : \(code)"]
            }
            DispatchQueue.main.async { strongSelf.bind() }
            }.resume()
    }
    
    func bind(){
        formatter.dateFormat = "YYYY-MM-dd"
        let dateStr = formatter.string(from: date)
        dateLabel.text = dateStr
        timeLabel.text = ["아침", "점심", "저녁"][currentTime]
        dataTextView.text = data[currentTime]
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
        let base64 = "MealExtensioniOS" + date
        let data = Data(base64.utf8).base64EncodedString()
        let crypto = data.sha3(.sha512)
        
        return crypto
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
    
}

public typealias MealTuple = (breakfast: String, dinner: String, lunch: String)

public struct MealModel: Codable{
    
    let breakfast: [String]
    let dinner: [String]
    let lunch: [String]
    
    func getData() -> MealTuple{
        return (getStr(breakfast), getStr(dinner), getStr(lunch))
    }
    
    func getDataForExtension() -> [String]{
        return [getStr(breakfast), getStr(dinner), getStr(lunch)]
    }
    
    private func getStr(_ arr: [String]) -> String{
        var data = arr.map{ $0 + ", " }.reduce(""){ $0 + $1 }
        data.removeLast(2)
        return data
    }
    
}

