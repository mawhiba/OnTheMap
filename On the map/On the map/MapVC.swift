//
//  MapVC.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 23/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapVC: UIViewController {
    var studentsLocations: [StudentLocation]! {
        return Global.shared.studentsLocations
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        if (studentsLocations == nil) {
            reloadStudentsLocations(self)
        }
        else {
            DispatchQueue.main.async {
                self.updateAnnotations()
            }
        }
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
                self.updateAnnotations()
            }
        }
    }
    
    func updateAnnotations() {
        var annotaions = [MKPointAnnotation]()
        for studentLocation in studentsLocations {

            let lat = CLLocationDegrees(studentLocation.latitude ?? 0)
            let long = CLLocationDegrees(studentLocation.longitude ?? 0)
            //let lat = studentLocation.latitude
            //let long = studentLocation.longitude
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentLocation.firstName ?? ""
            let last = studentLocation.lastName ?? ""
            let mediaURL = studentLocation.mediaURL ?? ""
            
            let annotaion = MKPointAnnotation()
            annotaion.coordinate = coordinate
            annotaion.title = "\(first) \(last)"
            annotaion.subtitle = mediaURL
            
            if !mapView.annotations.contains(where: {$0.title == annotaion.title}) {
                annotaions.append(annotaion)
            }
        }
        
        print("New annotations = ", annotaions.count)
        mapView.addAnnotations(annotaions)
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let reuseId = "pinId"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            guard let toOpen = view.annotation?.subtitle!, let url = URL(string: toOpen) else {return}
            app.open(url, options: [:], completionHandler: nil)
        }
    }
}
