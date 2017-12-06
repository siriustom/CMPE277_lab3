//
//  TimeStamp.swift
//  WeatherApp
//
//  Created by Xiaoran Lin on 12/4/17.
//  Copyright © 2017 Xiaoran Lin. All rights reserved.
//

import Foundation
import CoreLocation

struct TimeStamp {
    static let timePath = "https://maps.googleapis.com/maps/api/timezone/json?location"
    static func getLocalTime(location: CLLocationCoordinate2D, timestamp: Int, completion: @escaping (String?) -> ()) {
        let url = TimeStamp.timePath + "=" + "\(location.latitude)" + ","
                    + "\(location.longitude)" + "&timestamp=" + "\(timestamp)"
                    + "&key=AIzaSyA60w7LwV6g-e4R36HfviJ_6Bw0XTSGmpU"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) {
            (timeJson: Data?, response: URLResponse?, error: Error?) in
            if let data = timeJson {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let utc = timestamp
                        var localTime = utc + (json["dstOffset"] as! Int)
                        localTime = localTime + (json["rawOffset"] as! Int)
                        var date = Date(timeIntervalSince1970: TimeInterval(localTime))
//                        print(date)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = DateFormatter.Style.full
                        dateFormatter.timeZone = TimeZone.current
//                        print(dateFormatter.string(from: date as Date))
                        completion(String(describing: date))
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
