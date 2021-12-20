//
//  TableViewNoticeVC.swift
//  DMS-Practice
//
//  Created by leedonggi on 27/12/2018.
//  Copyright © 2018 leedonggi. All rights reserved.
//

import UIKit

public var isDismissed = false

class TableViewNoticeVC: UIViewController {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    var cellData = [CellNotice]()
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(doSomething), for: .valueChanged)
        tblView.refreshControl = refreshControl
        
        tblView.alpha = 0
        tblView.delegate = self
        tblView.dataSource = self
        
        isDismissed = true
        imgArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        viewMain.backgroundColor = color.mint.getcolor()
        viewMain.layer.cornerRadius = 17
        dropShadow(view: viewMain, color: UIColor(named: "barColor")!, offSet: CGSize(width: 3, height: 3))
        lblTitle.textColor = UIColor.white
        lblDetail.textColor = UIColor.white
        
        let notice = UITapGestureRecognizer(target: self, action:  #selector(self.noticeAction))
        self.viewMain.addGestureRecognizer(notice)
        
        switch paramInt {
        case 0:
            lblTitle.text = "공지사항"
            lblDetail.text = "사감부에서 게시한 공지사항을 열람합니다"
            url = "notice"
        case 1:
            lblTitle.text = "기숙사 규정"
            lblDetail.text = "사감부에서 게시한 규정을 열람합니다"
            url = "rule"
        case 2:
            lblTitle.text = "자주하는 질문"
            lblDetail.text = "자주하는 질문을 열람합니다"
            url = "qna"
        default:
            showError(0)
        }
        
        getData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.tblView.alpha = 1
        }
    }
    
    @objc func noticeAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func doSomething(refreshControl: UIRefreshControl) {
        dismiss(animated: false, completion: nil)
    }
    
    func getData() {
        var request = URLRequest(url: URL(string: "https://api.dsm-dms.com/"+url)!)
        request.httpMethod = "GET"
        request.addValue("iOS", forHTTPHeaderField: "User-Agent")
        request.addValue(getDate(), forHTTPHeaderField: "X-Date")
        request.addValue(getCrypto(), forHTTPHeaderField: "User-Data")
        URLSession.shared.dataTask(with: request){
            [weak self] data, res, err in
            guard self != nil else { return }
            if let err = err { print(err.localizedDescription); return }
            print((res as! HTTPURLResponse).statusCode)
            switch (res as! HTTPURLResponse).statusCode{
            case 200:
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: [[String: Any]]]
                
                print("\(jsonSerialization)")
                var list = [[String: Any]]()
                if self!.url == "notice" {
                    list = jsonSerialization["noticeList"]!
                } else if self!.url == "rule" {
                    list = jsonSerialization["ruleList"]!
                }
                if list.count == 0 {
                    
                } else {
                    for i in 0...list.count - 1 {
                        let title: String = String(format: "%@", list[i]["title"] as! CVarArg)
                        let postDate: String = String(format: "%@", list[i]["postDate"] as! CVarArg)
                        let id: String = String(format: "%@", list[i]["id"] as! CVarArg)
                        self!.cellData.append(CellNotice(title: title, date: postDate, code: id))
                    }
                    DispatchQueue.main.async { self!.tblView.reloadData() }
                }
            case 403:
                if self!.isRelogin() {
                    self!.getData()
                }
            default:
                self!.cellData = [CellNotice(title: "네트워크 상태를 확인하세요", date: "2019-10-02", code: "so sad")]
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

extension TableViewNoticeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = cellData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeListCell") as! NoticeListCell
        
        cell.setCell(cell: tableCell)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 105;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rvc = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailNoticeVC else {
            return
        }
        rvc.paramId = cellData[indexPath.row].code
        rvc.paramUrl = url
        self.present(rvc, animated: true)
    }
}

class NoticeListCell: UITableViewCell {
    @IBOutlet weak var viewTable: UIView!
    @IBOutlet weak var lblTableTitle: UILabel!
    @IBOutlet weak var lblTableDate: UILabel!
    
    func setCell(cell: CellNotice) {
        lblTableTitle.text = cell.title
        lblTableDate.text = cell.date
    }
    
    override func awakeFromNib() {
        viewTable.layer.cornerRadius = 17
        viewTable.layer.masksToBounds = false
        viewTable.layer.shadowColor = UIColor(named: "barColor")!.cgColor
        viewTable.layer.shadowOpacity = 0.5
        viewTable.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewTable.layer.shadowRadius = 5

        viewTable.layer.shouldRasterize = true
        viewTable.layer.rasterizationScale = true ? UIScreen.main.scale : 1
    }
}

class CellNotice {
    var title: String
    var date: String
    var code: String
    
    init(title: String, date: String, code: String) {
        self.title = title
        self.date = date
        self.code = code
    }
}
