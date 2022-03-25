//
//  ViewController.swift
//  Asteroid Neo
//
//  Created by Mac on 24/03/22.
//

import UIKit
import Charts

class HomeViewController: UIViewController {
    
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateLbl: UILabel!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var lineCharView: LineChartView!
    
    @IBOutlet weak var fastestAsteroidLbl: UILabel!
    @IBOutlet weak var closestAsteroidLbl: UILabel!
    @IBOutlet weak var averageSizeLbl: UILabel!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    var viewModel = HomeViewModel()
    var dataChart = [ChartDataEntry]()
    
    var startDateString: String = ""
    var endDateString: String = ""
    
    var startDate = Date()
    var endDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextField()
        lineCharView.rightAxis.enabled = false
        lineCharView.xAxis.labelPosition = .bottom
        viewModel.updateLineChart = { dataChart in
            self.dataChart = dataChart
            DispatchQueue.main.async {
                let set = LineChartDataSet(entries: self.dataChart, label: "\(self.startDateString)  to  \(self.endDate)")
                let data = LineChartData(dataSet: set)
                self.lineCharView.data = data
            }
        }
        viewModel.fastestAstroid = { id, speed in
            DispatchQueue.main.async {
                self.fastestAsteroidLbl.text = "Fastest Astroid is \(id) with speed is \(speed)Km/h"
            }
        }
        
        viewModel.closestAstroid = { id, distance in
            DispatchQueue.main.async {
                self.closestAsteroidLbl.text = "Closest Astroid is \(id) with distance \(distance)Km"
            }
        }
        
        viewModel.averageSizeOfAstroid = { size in
            DispatchQueue.main.async {
                self.averageSizeLbl.text =  "Average Size Of Astroid is \(size)Km"
            }
        }
        
    }
    
    // Setting up functionality for the text Field
    func setUpTextField() {
        startDateTextField.tag = 0
        endDateTextField.tag = 101
//        startDate.maximumDate = Date()
//        startDate.maximumDate = Date()
//        endDate.minimumDate = startDate.date
//        endDate.maximumDate = Date() > Calendar.current.date(byAdding: .day, value: 6, to: startDate.date)! ? Calendar.current.date(byAdding: .day, value: 6, to: startDate.date) : Date()
//        startDateTextField.setInputViewDatePicker(target: self, selector: #selector(tapDoneStartDate))
        
//        startDateTextField.setInputViewDatePicker(minimumDate: nil, maximumDate: Date(), target: self, selector: #selector(tapDoneStartDate))
        
        startDateTextField.setInputViewDatePicker(date: Date(), minimumDate: nil, maximum: nil, target: self, selector: #selector(tapDoneStartDate))
        
        endDateTextField.setInputViewDatePicker(date: Date(), minimumDate: nil, maximum: nil, target: self, selector: #selector(tapDoneEndDate))
        
        
//        startDateTextField.setIn
        
        var date = (Date() > Calendar.current.date(byAdding: .day, value: 6, to: startDate)! ? Calendar.current.date(byAdding: .day, value: 6, to: startDate) : Date())!
        
//        endDateTextField.setInputViewDatePicker(minimumDate: nil, maximumDate: date, target: self, selector: #selector(tapDoneEndDate))
        
//        endDateTextField.setInputViewDatePicker(target: self, selector: #selector(tapDoneEndDate))
    }
    
    

    @IBAction func submitBtnTapped(_ sender: UIButton) {
        
        guard let startDate = startDateTextField.text, startDate.count != 0 else {
            
            // Shaking the text field if start date textfield is empty
            startDateTextField.shake()
            // Showing alert if start date is not given by the user
            ShowNotificationMessages.sharedInstance.warningView(message: "Please enter a start date")
            return
        }
        
        self.startDateString = startDate
        
        guard let endDate = endDateTextField.text, endDate.count != 0 else {
            endDateTextField.shake()
            // Showing the alert if end date is not given by the user
            ShowNotificationMessages.sharedInstance.warningView(message: "Please enter a end date")
            return
        }
        
        self.endDateString = endDate
        callingAPI(startDate: startDate, endDate: endDate)
    }
    
    
    // Method for calling API
    func callingAPI(startDate: String, endDate: String) {
        let baseURLString = "https://api.nasa.gov/neo/rest/v1/feed?start_date=\(startDate)&end_date=\(endDate)&api_key=DEMO_KEY"
        
        // Loader started
        spinner.startAnimating()
        
        viewModel.callingHTPPAPI(api: baseURLString) { sucess in
            DispatchQueue.main.async {
                // Loader stop here
                self.spinner.stopAnimating()
            }
        }
        
    }
    
    
    // Done button functionality
    @objc func tapDoneStartDate() {
        
        if let datePicker = self.startDateTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            startDate = datePicker.date
            // Using the extension for converting the date to the required string
            self.startDateTextField.text = dateformatter.string(from: datePicker.date).convertDateString(dateString: datePicker.date, fromFormat: "YYYY-MM-DD hh:mm:ss ZZZZ", toFormat: "YYYY-MM-dd")
            
            startDateTextField.setInputViewDatePicker(date: startDate, minimumDate: nil, maximum: endDate, target: self, selector: #selector(tapDoneStartDate))
            
            endDateTextField.setInputViewDatePicker(date: endDate, minimumDate: startDate, maximum: Date(), target: self, selector: #selector(tapDoneEndDate))
            
        }
        self.startDateTextField.resignFirstResponder()
    }
    
    // Done button functionality for the end date
    @objc func tapDoneEndDate() {
        if let datePicker = self.endDateTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            endDate = datePicker.date
            self.endDateTextField.text = dateformatter.string(from: datePicker.date).convertDateString(dateString: datePicker.date, fromFormat: "YYYY-MM-DD hh:mm:ss ZZZZ", toFormat: "YYYY-MM-dd")
            startDateTextField.setInputViewDatePicker(date: startDate, minimumDate: Date(), maximum: endDate, target: self, selector: #selector(tapDoneStartDate))
            
            endDateTextField.setInputViewDatePicker(date: endDate, minimumDate: startDate, maximum: Date(), target: self, selector: #selector(tapDoneEndDate))
        }
        // Resigning the text field as the first responder
        self.endDateTextField.resignFirstResponder()
    }
}

