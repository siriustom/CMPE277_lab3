//
//  Weather.swift

import Foundation
import CoreLocation

struct Weather {
    var status:String
    var icon:String
    var curTemp:Double
    var minTemp:Double
    var maxTemp:Double
    var dateAndTime:String
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init() {
        self.status = ""
        self.icon = ""
        self.curTemp = 0.0
        self.minTemp = 0.0
        self.maxTemp = 0.0
        self.dateAndTime = ""
    }
    init(json:[String:Any]) throws {
        //status and icon init
        if let weather = json["weather"] as? [[String: Any]] {
            guard let description = weather[0]["description"] as? String else {
                throw SerializationError.missing("description is missing")
            }
            guard let iconName = weather[0]["icon"] as? String else {
                throw SerializationError.missing("icon is missing")
            }
            self.status = description
            self.icon = iconName
        } else {
            throw SerializationError.missing("weather is missing")
        }
        //temperature init
        if let main = json["main"] as? [String: Any] {
            guard let currentTemp = main["temp"] as? Double else {
                throw SerializationError.missing("temp is missing")
            }
            guard let minimumTemp = main["temp_min"] as? Double else {
                throw SerializationError.missing("temp_min is missing")
            }
            guard let maximumTemp = main["temp_max"] as? Double else {
                throw SerializationError.missing("temp_max is missing")
            }
            self.curTemp = (currentTemp - 273) * 1.8 + 32
            self.minTemp = (minimumTemp - 273) * 1.8 + 32
            self.maxTemp = (maximumTemp - 273) * 1.8 + 32
        } else {
            throw SerializationError.missing("main is missing")
        }
        
        if let dtx = json["dt_txt"] as? String {
            self.dateAndTime = dtx
        } else if let dt = json["dt"] as? Int {
            self.dateAndTime = String(dt)
        } else {
            throw SerializationError.missing("dateAndTime is missing")
        }
    }
    
    static let baseCurPath = "https://api.openweathermap.org/data/2.5/weather?"
    static let baseForcaPath = "https://api.openweathermap.org/data/2.5/forecast?"
    
    static func todayWeather (withLocation location: CLLocationCoordinate2D, completion: @escaping (Weather?) -> ()) {
        let url = baseCurPath + "lat=" + "\(location.latitude)"
            + "&lon=" + "\(location.longitude)" + "&appid=03cfa53eec6b63b649c563b74b288c04"
        let requestForCur = URLRequest(url: URL(string: url)!)
        let taskForCur = URLSession.shared.dataTask(with: requestForCur) {
            (dataCur:Data?, response:URLResponse?, error:Error?) in
            if let data = dataCur {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let weather = try? Weather(json: json) {
                            completion(weather)
                        } else {
                            print("weather has not been initiated")
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        taskForCur.resume()
    }
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        let url = baseForcaPath + "lat=" + "\(location.latitude)"
            + "&lon=" + "\(location.longitude)" + "&appid=03cfa53eec6b63b649c563b74b288c04"
        let requestForecast = URLRequest(url: URL(string: url)!)
        var forecastArray:[Weather] = []
        let taskForecast = URLSession.shared.dataTask(with: requestForecast) {
            (dataFor:Data?, response:URLResponse?, error:Error?) in
            if let data = dataFor {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let list = json["list"] as? [[String: Any]] {
                            for l in list {
                                if let forecastPart = try? Weather(json: l) {
                                    forecastArray.append(forecastPart)
                                } else {
                                    print("forecast has not been initiated")
                                }
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        taskForecast.resume()
    }
}
