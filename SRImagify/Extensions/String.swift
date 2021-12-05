//
//  String.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/5/21.
//

import Foundation
//MARK: - String Extension
/// this extension helps us to read the localized string from localizable file
extension String{
    func Localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}
