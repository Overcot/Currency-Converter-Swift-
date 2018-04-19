//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 09.02.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currenciesModel = CurrenciesModel()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.activityIndicator.startAnimating()
        self.label.text = " "

        
        currenciesModel.createCurrencyList { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    //self.label.text = error.localizedDescription
                    //self.activityIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    self.pickerFrom.delegate = self
                    self.pickerTo.delegate = self
                    self.requestCurrentCurrencyRate()
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === pickerTo {
            return currenciesModel.currenciesExcept(number: pickerFrom.selectedRow(inComponent: 0)).count
        }
        return currenciesModel.currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === pickerTo {
            return currenciesModel.currenciesExcept(number: pickerFrom.selectedRow(inComponent: 0))[row]
        }
        return currenciesModel.currencies[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === pickerFrom {
            self.pickerTo.reloadAllComponents()
        }
        self.requestCurrentCurrencyRate()
    }

    func requestCurrentCurrencyRate() {

        let baseCurrencyIndex = self.pickerFrom.selectedRow(inComponent: 0)
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        
        let baseCurrency = currenciesModel.currencies[baseCurrencyIndex]
        let toCurrency = currenciesModel.currenciesExcept(number : pickerFrom.selectedRow(inComponent: 0))[toCurrencyIndex]
        
        currenciesModel.getCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency)  {
            [weak self] (value) in
            DispatchQueue.main.async {
            if let strongSelf = self {
                strongSelf.label.text = value
                strongSelf.activityIndicator.stopAnimating()
                }
            }
        }

    }
}
