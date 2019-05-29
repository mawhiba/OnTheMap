//
//  NewPinVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class NewPinVC: UIViewController {
    
    var locationCoordinate: CLLocationCoordinate2D!
    var locationName: String!
    
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromNewPinVCShareVC" {
            let vc = segue.destination as! ShareVC
            vc.locationCoordinate = locationCoordinate
            vc.locationName = locationName
        }
    }
    
    @IBAction func cancel(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI(processing: Bool){
        DispatchQueue.main.async {
            if processing {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            self.findButton.isEnabled = !processing
        }
    }
    
    @IBAction func findButton(_ sender: UIButton){
        updateUI(processing: true)
        guard let locationName = locationField.text?.trimmingCharacters(in: .whitespaces), !locationName.isEmpty else {
            alert(title: "Warning", message: "Location shouldn't be empty")
            updateUI(processing: false)
            return
        }
        
        getCoordinateFrom(location: locationName) { (locationCoordinate, error)in
            if let error = error {
                self.alert(title: "Error", message: "Try different city name.")
                print(error.localizedDescription)
                self.updateUI(processing: false)
                return
            }
            self.locationCoordinate = locationCoordinate
            self.locationName = locationName
            self.updateUI(processing: false)
            self.performSegue(withIdentifier: "fromNewPinVCShareVC", sender: self)
        }
    }
    
    func getCoordinateFrom(location: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

}
