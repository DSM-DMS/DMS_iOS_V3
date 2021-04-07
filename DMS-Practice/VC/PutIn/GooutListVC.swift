//
//  GooutListVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 12/02/2019.
//  Copyright © 2019 leedonggi. All rights reserved.
//

import UIKit

class GooutListVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    
    var keyValueInt = 4
    var cellData = [CellGooutList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getData()
        
        tblView.delegate = self
        tblView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnGoback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
                var list = [[String:Any]]()
                let keyValue = ["saturday", "sunday", "workday"]
                list = jsonSerialization[keyValue[self!.keyValueInt]]!
                print(list)
                if list.count == 0 {
                    print("nothing")
                    return
                }
                for i in 0...list.count - 1 {
                    let gooutDate: String = String(format: "%@", list[i]["date"] as! CVarArg)
                    let goingoutStatus: String = String(format: "%@", list                    [i]["goingoutStatus"] as! CVarArg)
                    let reason: String = String(format: "%@", list[i]["reason"] as! CVarArg)
                    let id: String = String(format: "%@", list[i]["id"] as! CVarArg)
                    self!.cellData.append(CellGooutList(goOutTime: gooutDate, goingout_status: goingoutStatus, reason: reason, id: id))
                }
                DispatchQueue.main.async { self!.tblView.reloadData() }
            case 204:
                print("nothing")
            case 403:
                if self!.isRelogin() {
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

extension GooutListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = cellData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GooutListCell") as! GooutListCell
        
        cell.setCell(cell: tableCell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "", message: "외출 목록에서 삭제하시겠습니까?", preferredStyle: .alert)
            
            let attributedString = NSAttributedString(string: "삭제", attributes: [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(rawValue: 10)),
                NSAttributedString.Key.foregroundColor : color.mint.getcolor()
                ])
            
            alert.view.tintColor = color.mint.getcolor()
            alert.setValue(attributedString, forKey: "attributedTitle")
            
            let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
                let parameters = ["applyId": Int(self.cellData[indexPath.row].id) as Any] as [String : Any]
                
                let url = URL(string: "https://api.dsm-dms.com/apply/goingout")!
                
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE"
                
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
                    guard let data = data, error == nil else {                                                 // check for fundamental networking error
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse {
                        switch httpStatus.statusCode {
                        case 200:
                            DispatchQueue.main.async {
                                self.showToast(msg: "삭제 성공")
                                self.cellData.remove(at: indexPath.row)
                                self.tblView.deleteRows(at: [indexPath], with: .fade)
                                self.tblView.reloadData()
                            }
                        case 204:
                            DispatchQueue.main.async {
                                self.showToast(msg: "삭제할것이 없습니다")
                            }
                        case 403:
                            if self.isRelogin() {
                                self.showToast(msg: "다시 시도하세요")
                            }
                        default:
                            print("살려주세요")
                        }
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(String(describing: responseString!))")
                }
                task.resume()
            }
            let cancel = UIAlertAction(title: "취소", style: .default)
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

class GooutListCell: UITableViewCell {
    @IBOutlet weak var viewTable: UIView!
    @IBOutlet weak var lblTableTime: UILabel!
    @IBOutlet weak var lblTableReason: UILabel!
    
    func setCell(cell: CellGooutList) {
        lblTableTime.text = cell.goOutTime
        lblTableReason.text = cell.reason
    }
    
    override func awakeFromNib() {
        viewTable.layer.cornerRadius = 17
        viewTable.layer.masksToBounds = false
        viewTable.layer.shadowColor = UIColor.lightGray.cgColor
        viewTable.layer.shadowOpacity = 0.5
        viewTable.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewTable.layer.shadowRadius = 5
        
        viewTable.layer.shouldRasterize = true
        viewTable.layer.rasterizationScale = true ? UIScreen.main.scale : 1
    }
}

class CellGooutList {
    var goOutTime: String
    var reason: String
    var goingout_status: String
    var id: String
    
    init(goOutTime: String, goingout_status: String,reason: String, id: String) {
        self.goOutTime = goOutTime
        self.goingout_status = goingout_status
        self.reason = reason
        self.id = id
    }
}

