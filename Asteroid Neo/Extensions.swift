//
//  Extensions.swift
//  Asteroid Neo
//
//  Created by Mac on 25/03/22.
//

import Foundation
import UIKit

extension UITextField {
    // date picker view extension for integrating it into the textField
    func setInputViewDatePicker(date: Date, minimumDate: Date? = nil, maximum: Date? = nil, target: Any, selector: Selector) {
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: AppConfiguration.screenWidth, height: 216))
    
        datePicker.datePickerMode = .date
        
        if minimumDate != nil {
            datePicker.minimumDate = minimumDate
        }
        
        if maximum != nil {
            datePicker.maximumDate = maximum
        }
        
        
        datePicker.date = date
        if #available(iOS 14, *) {
          datePicker.preferredDatePickerStyle = .wheels
          datePicker.sizeToFit()
        }
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: AppConfiguration.screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
}


extension String {
    func convertDateString(dateString : Date, fromFormat sourceFormat : String!, toFormat desFormat : String!) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sourceFormat
        let date = dateFormatter.date(from: dateFormatter.string(from: dateString))
        dateFormatter.dateFormat = desFormat
        return dateFormatter.string(from: date!)
    }
}

extension UIView {
    // Extension of the View for the shake animation
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
