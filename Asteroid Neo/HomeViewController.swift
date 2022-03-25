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
    
    var startDate: String = ""
    var endDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextField()
        lineCharView.rightAxis.enabled = false
        lineCharView.xAxis.labelPosition = .bottom
        viewModel.updateLineChart = { dataChart in
            self.dataChart = dataChart
            DispatchQueue.main.async {
                let set = LineChartDataSet(entries: self.dataChart, label: "\(self.startDate)  to  \(self.endDate)")
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
    
    
    
    // Setting up functionality for the
    func setUpTextField() {
        startDateTextField.tag = 0
        endDateTextField.tag = 101
        startDateTextField.setInputViewDatePicker(target: self, selector: #selector(tapDoneStartDate))
        endDateTextField.setInputViewDatePicker(target: self, selector: #selector(tapDoneEndDate))
    }
    
    

    @IBAction func submitBtnTapped(_ sender: UIButton) {
        
        guard let startDate = startDateTextField.text, startDate.count != 0 else {
            startDateTextField.shake()
            ShowNotificationMessages.sharedInstance.warningView(message: "Please enter a start date")
            return
        }
        
        self.startDate = startDate
        
        guard let endDate = endDateTextField.text, endDate.count != 0 else {
            endDateTextField.shake()
            ShowNotificationMessages.sharedInstance.warningView(message: "Please enter a end date")
            return
        }
        
        self.endDate = endDate
        callingAPI(startDate: startDate, endDate: endDate)
    }
    
    func callingAPI(startDate: String, endDate: String) {
        
        
        let baseURLString = "https://api.nasa.gov/neo/rest/v1/feed?start_date=\(startDate)&end_date=\(endDate)&api_key=DEMO_KEY"
        
        spinner.startAnimating()
        
        viewModel.callingHTPPAPI(api: baseURLString) { sucess in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
            }
        }
        
    }
    
    
    // Done button functionality
    
    @objc func tapDoneStartDate() {
        
        if let datePicker = self.startDateTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            self.startDateTextField.text = dateformatter.string(from: datePicker.date).convertDateString(dateString: datePicker.date, fromFormat: "YYYY-MM-DD hh:mm:ss ZZZZ", toFormat: "YYYY-MM-dd")
        }
        self.startDateTextField.resignFirstResponder()
    }
    
    @objc func tapDoneEndDate() {
        
        if let datePicker = self.endDateTextField.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .medium
            self.endDateTextField.text = dateformatter.string(from: datePicker.date).convertDateString(dateString: datePicker.date, fromFormat: "YYYY-MM-DD hh:mm:ss ZZZZ", toFormat: "YYYY-MM-dd")
        }
        self.endDateTextField.resignFirstResponder()
    }
}

