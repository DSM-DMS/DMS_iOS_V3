//
//  TableViewPointVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 28/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit

class TableViewPointVC: UITableViewController {
    
    @IBOutlet weak var btnBackOutlet: UIBarButtonItem!
    
    var cellData = [CellPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointListCell") as! PointListCell
        
        cell.lblTitle?.text = cellData[(indexPath as NSIndexPath).row].title
        cell.lblDate?.text = cellData[(indexPath as NSIndexPath).row].date
        
        if !cellData[indexPath.row].type {
            cell.lblPoint?.textColor = color.mint.getcolor()
            cell.lblPoint?.text = String(cellData[(indexPath as NSIndexPath).row].point)
        } else {
            cell.lblPoint?.textColor = UIColor(red: 237/255, green: 96/255, blue: 91/255, alpha: 1)
            cell.lblPoint?.text = String(cellData[(indexPath as NSIndexPath).row].point)
        }
        
        return cell
    }

    @IBAction func btnBack(_ sender: Any) {
        goBack()
    }

    func getData() {
        let url = URL(string: "https://api.dsm-dms.com/info/point")!
        
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
                print(jsonSerialization)
                let list = jsonSerialization["point_history"]
                if list!.count == 0 {
                    return
                }
                for i in 0...(list!.count) - 1 {
                    let date: String = String(format: "%@", list![i]["date"] as! CVarArg)
                    let point: String = String(format: "%@", list![i]["point"] as! CVarArg)
                    let pointType: String = String(format: "%@", list![i]["pointType"] as! CVarArg)
                    let reason: String = String(format: "%@", list![i]["reason"] as! CVarArg)
                    var type: Bool = true
                    if pointType == "0" { type = true }
                    else { type = false }
                    self!.cellData.append(CellPoint(title: reason, date: date, point: point, type: type))
                }
                DispatchQueue.main.async {
                    self!.tableView.reloadData()
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

class PointListCell: UITableViewCell {
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPoint: UILabel!
    
    override func awakeFromNib() {
        viewBackground.layer.cornerRadius = 17
        viewBackground.layer.masksToBounds = false
        viewBackground.layer.shadowColor = UIColor(red: 25/255, green: 182/255, blue: 182/255, alpha: 0.16).cgColor
        viewBackground.layer.shadowOpacity = 0.5
        viewBackground.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewBackground.layer.shadowRadius = 5
        
        viewBackground.layer.shouldRasterize = true
        viewBackground.layer.rasterizationScale = true ? UIScreen.main.scale : 1
    }
}

class CellPoint {
    var title: String
    var date: String
    var point: String
    var type: Bool
    
    init(title: String, date: String, point: String, type: Bool) {
        self.title = title
        self.date = date
        self.point = point
        self.type = type
    }
}
