//
//  UIViewController.swift
//  SRImagify
//
//  Created by Siamak Rostami on 12/5/21.
//

import Foundation
import UIKit

//MARK: - UIViewController Extension
/// an action sheet helper that helps us to show errors
extension UIViewController{
    
    func showActionSheet(title: String, message: String, style: UIAlertController.Style, actions: [UIAlertAction?]){
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for action in actions{
            if let action = action{
                actionSheetController.addAction(action)
            }
        }
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func actionMessageOK(_ completion: (() -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { action in
            completion?()
        }
    }
    
    func actionMessageCancel(_ completion: (() -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { action in
            completion?()
        }
    }
    
    func actionMessageClose(_ completion: (() -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .default) { action in
            completion?()
        }
    }
    
    func actionMessageRetry(_ completion: (() -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("retry", comment: ""), style: .default) { action in
            completion?()
        }
    }
    
    func actionMessage(_ title : String, style : UIAlertAction.Style, _ completion: (() -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: style) { action in
            completion?()
        }
    }
    
    
    
}
