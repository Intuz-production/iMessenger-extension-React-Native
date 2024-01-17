//
//  LocalizationHelper.swift
//  iMessenger-Extension
//
//  Created by Hard Patel on 16/01/24.
//

import Foundation
import UIKit

//Get Localize String
extension String {
    
    var bundle: Bundle {
        return Bundle.main
    }
    
    func localizedString() -> String {
      return bundle.localizedString(forKey: self, value: "", table: LanguageManager.shared.getCurrentLanguageCode())
    }
}
