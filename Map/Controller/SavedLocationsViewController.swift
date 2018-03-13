//
//  SavedLocationsViewController.swift
//  Rendezvous
//
//  Created by Admin on 7/6/16.
//  Copyright © 2016 Trose Technologies. All rights reserved.
//

import UIKit
import RealmSwift

protocol SavedLocationsViewControllerDelegate {
  func updateLocationField(_ location: SavedLocation)
}
class SavedLocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet var tableView: UITableView!
  
  let realm = try! Realm()
  lazy var savedLocations: Results<SavedLocation> = { self.realm.objects(SavedLocation.self).sorted(byProperty: "locationName")}()
  
  var delegate: SavedLocationsViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.savedLocations.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Saved") as! SavedLocationTableViewCell
    let item = savedLocations[(indexPath as NSIndexPath).row]
    cell.locationName?.text = item.locationName
    cell.locationAddress?.text = item.locationAddress
    cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      realm.beginWrite()
      realm.delete(self.savedLocations[(indexPath as NSIndexPath).row])
      do {
        try realm.commitWrite()
      }
      catch let error as NSError {
        print("Realm Object Delete Error: \(error)")
      }
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.delegate?.updateLocationField(self.savedLocations[(indexPath as NSIndexPath).row])
    self.navigationController?.popViewController(animated: true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
