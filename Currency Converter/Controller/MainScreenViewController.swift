//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 09.02.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import UIKit
import CoreData


class MainScreenViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var labelValueToCurrency: UILabel!
    @IBOutlet weak var labelValueFromCurrency: UILabel!
    
    @IBOutlet weak var labelNameFromCurrency: UILabel!
    @IBOutlet weak var labelNameToCurrency: UILabel!
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelEqualSign: UILabel!
    
    var viewModel = ViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        self.activityIndicator.hidesWhenStopped = true
        
        hideElements()
        
        viewModel.updateList(completion: handlerAfterUpdateList)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        // Dispose of any resources that can be recreated.
    }
    
    private func hideElements() {
        changeElementVisibility(true)
    }
    private func showElements() {
        changeElementVisibility(false)
    }
    
    private func changeElementVisibility(_ state: Bool) {
        DispatchQueue.main.async {
            self.labelEqualSign.isHidden = state
            self.labelValueFromCurrency.isHidden = state
            self.labelValueToCurrency.isHidden = state
            
            self.pickerFrom.isHidden = state
            self.pickerTo.isHidden = state
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if viewModel.needToUpdateList == false {
            if pickerView === pickerTo {
                return viewModel.amountOfCurrencies - 1
            }
            return viewModel.amountOfCurrencies
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if viewModel.needToUpdateList == false {
            if pickerView == pickerTo {
                return viewModel.getToCurrencyNameByIndex(row)
            }
            return viewModel.getBaseCurrencyNameByIndex(row)
        }
        return ""

    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.labelValueToCurrency.text = " "
        self.labelEqualSign.isHidden = true
        self.activityIndicator.startAnimating()
        
        if pickerView == pickerFrom {
            viewModel.updateSelectedCurrency(row)
        }
        
        self.pickerFrom.reloadAllComponents()
        self.pickerTo.reloadAllComponents()
        
        let baseCurrencyName = getBaseCurrencyName(baseCurrencyIndex: self.pickerFrom.selectedRow(inComponent: 0))
        let toCurrencyName = getToCurrencyName(toCurrencyIndex: self.pickerTo.selectedRow(inComponent: 0))
        
        self.labelNameFromCurrency.text = baseCurrencyName
        self.labelNameToCurrency.text = toCurrencyName
        
        viewModel.updateBaseToCurrentCurrencyRate(baseCurrency: baseCurrencyName, toCurrency: toCurrencyName, completion: handlerAfterUpdateRate)
    }
    
    func handlerAfterUpdateList(result: Result<[String]>) {
        switch result {
            case .success:
                showElements()
                DispatchQueue.main.async {
                    self.pickerFrom.reloadAllComponents()
                    self.pickerTo.reloadAllComponents()
                    let baseCurrencyName = self.getBaseCurrencyName(baseCurrencyIndex: self.pickerFrom.selectedRow(inComponent: 0))
                    let toCurrencyName = self.getToCurrencyName(toCurrencyIndex: self.pickerTo.selectedRow(inComponent: 0))
                    
                    self.labelNameFromCurrency.text = baseCurrencyName
                    self.labelNameToCurrency.text = toCurrencyName
                    
                    self.viewModel.updateBaseToCurrentCurrencyRate(baseCurrency: baseCurrencyName, toCurrency: toCurrencyName, completion: self.handlerAfterUpdateRate)
            }
            case .error(let error):
                    errorHandle(error: error) {
                        self.viewModel.updateList(completion: self.handlerAfterUpdateList)
                }

        }


        


    }
    private func handlerAfterUpdateRate(result: Result<String>, baseCurrency: String, toCurrency: String) {
        switch result {
        case .success(let currencyRate):
            DispatchQueue.main.async {
                self.labelEqualSign.isHidden = false
                
                self.activityIndicator.stopAnimating()
                self.labelValueToCurrency.text = currencyRate
                self.labelNameFromCurrency.text = baseCurrency
                self.labelNameToCurrency.text = toCurrency
            }
        case .error(let error):
            errorHandle(error: error) {
                self.viewModel.updateBaseToCurrentCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency, completion: self.handlerAfterUpdateRate)
            }
        }

    }
    
    
    private func getBaseCurrencyName(baseCurrencyIndex: Int) -> String {
        return viewModel.getBaseCurrencyNameByIndex(baseCurrencyIndex)
    }
    private func getToCurrencyName(toCurrencyIndex: Int) -> String {
        return viewModel.getToCurrencyNameByIndex(toCurrencyIndex)
       
    }

    func errorHandle(error: Error, completion: @escaping () -> ()) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { action in
            completion()
        }))
        self.present(alert, animated: true)
    }
}
