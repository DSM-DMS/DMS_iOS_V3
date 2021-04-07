//
//  SubmitVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 04/01/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class SubmitVC: UITableViewController {

    var cellData = [CellSubmit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goNextVC("SubmitProcessVC")
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
        return 103;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitListCell") as! SubmitListCell
        
        cell.lblTitle?.text = cellData[(indexPath as NSIndexPath).row].title
        cell.lblDate?.text = cellData[(indexPath as NSIndexPath).row].startDate + " ~ " + cellData[(indexPath as NSIndexPath).row].endDate
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "SubmitProcessVC") as? SubmitProcessVC else {
            return
        }
        rvc.paramId = cellData[indexPath.row].id
        self.present(rvc, animated: true)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        goBack()
    }
    
//    func getData() {
//        let url = URL(string: "https://api.dsm-dms.com/survey")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
//        request.addValue(getDate(), forHTTPHeaderField: "X-Date")
//        request.addValue(getCrypto(), forHTTPHeaderField: "User-Data")
//        request.addValue(getToken(), forHTTPHeaderField: "Authorization")
//        URLSession.shared.dataTask(with: request){
//            [weak self] data, res, err in
//            guard self != nil else { return }
//            if let err = err { print(err.localizedDescription); return }
//            print((res as! HTTPURLResponse).statusCode)
//            switch (res as! HTTPURLResponse).statusCode{
//            case 200:
//                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
//                print(jsonSerialization)
//                DispatchQueue.main.async {
//                    self!.tableView.reloadData()
//                }
//            case 403:
//                if self!.isRelogin() {
//                    self!.getData()
//                }
//            default:
//                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
//
//                print("\(jsonSerialization)")
//                print("error")
//            }
//            }.resume()
//    }
    
}

class SubmitListCell: UITableViewCell {
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
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

class CellSubmit {
    var answered: Bool
    var endDate: String
    var id: String
    var startDate: String
    var title: String
    
    init(answered: Bool, endDate: String, id: String, startDate: String, title: String) {
        self.answered = answered
        self.endDate = endDate
        self.id = id
        self.startDate = startDate
        self.title = title
    }
}
