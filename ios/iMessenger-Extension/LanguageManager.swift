//
//  LanguageManager.swift
//

import UIKit


final class LanguageManager {
  //Shared
  //MARK:- Shared
  static let shared = LanguageManager()
  
  //MARK:- Initilizer
  private init(){}
  
  func getCurrentLanguageCode() -> String {
    //      return Bundle.getLanguage()
    guard let userDefaults = UserDefaults(suiteName: "group.com.xxx.appName"),
          let lanCode = userDefaults.object(forKey: "language") as? String, lanCode.isEmpty == false else { return "en" }
    return lanCode.filter { $0 != "\"" }
  }
  
  func setCurrentLanguageCode(_ lanCode:String){
    guard let userDefaults = UserDefaults(suiteName: "group.com.xxx.appName") else { return }
    userDefaults.set(lanCode, forKey: "language")
    userDefaults.synchronize()
  }
}

public func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
