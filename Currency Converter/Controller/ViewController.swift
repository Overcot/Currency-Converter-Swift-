//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 09.02.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import UIKit


// когда запускаем без интернета а потом включаем то при обновлении списков хочется чтобы сохранялись текущие значения в pickerview
// init launch - нет прописанных валют в лейблах
// странно стал обновлятся пикер и лейблы когда мы хотим аля одинаковые валюты взять
class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var labelValueToCurrency: UILabel!
    
    @IBOutlet weak var labelNameFromCurrency: UILabel!
    @IBOutlet weak var labelNameToCurrency: UILabel!
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currenciesModel = CurrenciesModel()
    
    var needToUpdateList = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        updateList()


        
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
        self.labelValueToCurrency.text = " "
        if pickerView === pickerFrom {
            self.labelNameFromCurrency.text = currenciesModel.currencies[row]
        }
        if pickerView == pickerTo {
            self.labelNameToCurrency.text = currenciesModel.currencies[row]
        }
        self.activityIndicator.startAnimating()
        if needToUpdateList {
            updateList()
            self.pickerFrom.reloadAllComponents()
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
            [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .success(let currencyRate):
                    strongSelf.labelValueToCurrency.text = currencyRate
                case .error(let error):
                    strongSelf.labelValueToCurrency.text = error.localizedDescription
                    strongSelf.needToUpdateList = true
                }
                strongSelf.activityIndicator.stopAnimating()
            }
        }
    }
    func updateList() {
        currenciesModel.createCurrencyList {
            [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    strongSelf.pickerFrom.reloadAllComponents()
                    strongSelf.pickerTo.reloadAllComponents()
                    strongSelf.requestCurrentCurrencyRate()
                }
            case .error(let error):
                DispatchQueue.main.async {
                    strongSelf.labelValueToCurrency.text = error.localizedDescription
                    strongSelf.activityIndicator.stopAnimating()
                }
                strongSelf.needToUpdateList = true
            }

        }
    }
}
