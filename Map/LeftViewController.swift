
//
//  LeftViewController.swift
//  Map
//
//  Created by 123 on 2017/6/15.
//  Copyright © 2017年 123. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableview: UITableView!
    let Locationmodel = LocationModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        Locationmodel.loadData()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(LongPress))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.5
        tableview.addGestureRecognizer(longPress)
        tableview.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: "update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(regain(_:)), name: NSNotification.Name(rawValue: "regain"), object: nil)
        tableview.backgroundColor = UIColor.white
        tableview.separatorStyle = .none
    }
    
    func update (_ notification:NSNotification) {
        Locationmodel.loadData()
        tableview.reloadData()
    }
    
    func regain (_ notification:NSNotification) {
        tableview.setEditing(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func LongPress(gestureRecongnizer:UILongPressGestureRecognizer) {
        if gestureRecongnizer.state == UIGestureRecognizerState.began {
            
        }
        if gestureRecongnizer.state == UIGestureRecognizerState.ended {
            if tableview.isEditing == false {
                tableview.setEditing(true, animated: true)
            }
            else{
                tableview.setEditing(false, animated: true)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return Locationmodel.LocationList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "location", for: indexPath) as! TableViewCell
        if indexPath.section == 0 {
            cell.title.text = "你的位置"
            let la = Double((locationNow?.coordinate.latitude)!)
            let lo = Double((locationNow?.coordinate.longitude)!)
            cell.coordinate.text = "\(la),\(lo)"
            cell.bottomview.isHidden = false
        }
        else {
            cell.title.text = Locationmodel.LocationList[indexPath.row].title
            cell.coordinate.text = "\(Locationmodel.LocationList[indexPath.row].latitude),\(Locationmodel.LocationList[indexPath.row].longitude)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            Locationmodel.loadData()
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Selectlocation"), object: Locationmodel.LocationList[indexPath.row]))
        }
        else {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Selectlocation"), object: nil))
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(indexPath.row)
            Locationmodel.loadData()
            Locationmodel.LocationList.remove(at: indexPath.row)
            Locationmodel.saveData()
            tableView.deleteRows(at: [indexPath], with: .top)
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "deleterow"), object: nil))
            //            self.tableView.setEditing(true, animated: true)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        Locationmodel.loadData()
        let content = Locationmodel.LocationList[sourceIndexPath.row]
        Locationmodel.LocationList.remove(at: sourceIndexPath.row)
        Locationmodel.LocationList.insert(content, at: destinationIndexPath.row)
        Locationmodel.saveData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    //MARK: 隐藏状态栏
    //    override var prefersStatusBarHidden: Bool{
    //        return true
    //    }
}
