//
//  ListVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

class ListVC: UITableViewController {
    let cellId = "cellId"
    
    var studentsLocations: [StudentLocation]! {
        return Global.shared.studentsLocations
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (studentsLocations == nil){
            reloadStudentsLocations(self)
        }
        else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem){
        UdacityAPI.deleteSession { (error) in
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func postPin(_ sender: Any){
        if UserDefaults.standard.value(forKey: "studentLocation") != nil {
            let alert = UIAlertController(title: "You have already posted a student location. Do you want to overwrite your current location ?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Overwrite", style: .destructive, handler: { (action) in
                self.performSegue(withIdentifier: "mapToNewLocation", sender: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "mapToNewLocation", sender: self)
        }
    }
    
    @IBAction func reloadStudentsLocations(_ sender:Any){
        UdacityAPI.Parse.getStudentLocation { (_, error) in
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsLocations?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = studentsLocations[indexPath.row].firstName
        cell.detailTextLabel?.text = studentsLocations[indexPath.row].mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentsLocations[indexPath.row]
        guard let toOpen = studentLocation.mediaURL , let url = URL(string: toOpen) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
