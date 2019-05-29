//
//  UdacityAPI.swift
//  On the map
//
//  Created by Mawhiba Al-Jishi on 22/09/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UdacityAPI {
    
    static func postSession(with email: String, password: String, completion: @escaping ([String:Any]?, Error?) -> ())
    {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(nil,error)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            let result = try! JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
            completion(result,nil)
        }
        task.resume()
    }
    
    static func deleteSession(completion: @escaping (Error?) -> ())
    {
        var request = URLRequest(url: URL(string : "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookiesStorage = HTTPCookieStorage.shared
        for cookie in sharedCookiesStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(error)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8))
            completion(nil)
        }
        task.resume()
    }
    
    class Parse {
        
        static func postStudentLocation(link: String, locationCoordinate: CLLocationCoordinate2D, locationName: String, completion: @escaping (Error?) -> ())
        {
            var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
            request.httpMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"uniqueKey\": \"54321\", \"firstName\": \"John\", \"lastName\": \"Doe\", \"mapString\": \"\(locationName)\", \"mediaURL\": \"\(link)\", \"latitude\": \(locationCoordinate.latitude), \"longitude\": \(locationCoordinate.longitude)}".data(using: .utf8)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil { // Handle error…
                    completion(error)
                    return
                }
                print(String(data: data!, encoding: .utf8)!)
                completion(nil)
            }
            task.resume()
        }
        
        static func getStudentLocation(completion: @escaping ([StudentLocation]?, Error?) -> ())
        {
            let BASE_URL = "https://parse.udacity.com/parse/classes/StudentLocation"
            var request = URLRequest(url: URL(string: BASE_URL + "?limit=100&order=-updatedAt")!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion(nil,error)
                    return
                }
                let dict = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String:Any]
                guard let results = dict["results"] as? [[String:Any]] else {return}
                let resultsData = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
                let studentsLocations = try! JSONDecoder().decode([StudentLocation].self, from: resultsData)
                Global.shared.studentsLocations = studentsLocations
                completion(studentsLocations,nil)
            }
            task.resume()
        }
    }
    
}