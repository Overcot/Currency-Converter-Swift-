//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 09.02.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var labelValueToCurrency: UILabel!
    @IBOutlet weak var labelValueFromCurrency: UILabel!
    
    @IBOutlet weak var labelNameFromCurrency: UILabel!
    @IBOutlet weak var labelNameToCurrency: UILabel!
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelEqualSign: UILabel!
    
    var currenciesModel = CurrenciesModel()
    
    var needToUpdateList = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        viewInitialization()
        
        updateList(completion: handlerAfterUpdateList)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        // Dispose of any resources that can be recreated.
    }
    
    private func viewInitialization() {
        
        self.activityIndicator.hidesWhenStopped = true
        
        self.labelEqualSign.isHidden = true
        self.labelValueFromCurrency.isHidden = true
        self.labelValueToCurrency.isHidden = true
        
        self.pickerFrom.isHidden = true
        self.pickerTo.isHidden = true

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currenciesModel.currencies.count > 0 {
            if pickerView === pickerTo {
                return currenciesModel.currencies.count - 1
            }
            return currenciesModel.currencies.count
        }
        return 0
        

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currenciesModel.currencies.count > 0 {
            if pickerView === pickerTo {
                return currenciesModel.currenciesExcept(number: pickerFrom.selectedRow(inComponent: 0))[row]
            }
            return currenciesModel.currencies[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.labelValueToCurrency.text = " "
        self.labelEqualSign.isHidden = true
        self.activityIndicator.startAnimating()

        
        
        self.pickerFrom.reloadAllComponents()
        self.pickerTo.reloadAllComponents()
        
        self.labelNameFromCurrency.text = getBaseCurrency()
        self.labelNameToCurrency.text = getToCurrency()
        
        self.requestCurrentCurrencyRate()
    }

    func requestCurrentCurrencyRate() {
        
        let baseCurrency = getBaseCurrency()
        let toCurrency = getToCurrency()
        
        currenciesModel.getCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency)  {
            [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .success(let currencyRate):
                    strongSelf.labelValueToCurrency.text = currencyRate
                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.labelEqualSign.isHidden = false
                case .error(let error):
                    
                    strongSelf.errorHandle(error: error)
                }
                strongSelf.labelNameFromCurrency.text = baseCurrency
                strongSelf.labelNameToCurrency.text = toCurrency
            }
        }
    }
    func updateList(completion : @escaping () -> ()) {
        currenciesModel.createCurrencyList {
            [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success:
                strongSelf.needToUpdateList = false
                DispatchQueue.main.async {
                    strongSelf.pickerFrom.reloadAllComponents()
                    strongSelf.pickerTo.reloadAllComponents()
                    strongSelf.requestCurrentCurrencyRate()
                    completion()
                }
            case .error(let error):
                strongSelf.errorHandle(error: error)
                
            }

        }
    }
    
    private func getBaseCurrency() -> String {
        let baseCurrencyIndex = self.pickerFrom.selectedRow(inComponent: 0)
        let baseCurrency = currenciesModel.currencies[baseCurrencyIndex]
        return baseCurrency
    }
    private func getToCurrency() -> String {
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        let toCurrency = currenciesModel.currenciesExcept(number : pickerFrom.selectedRow(inComponent: 0))[toCurrencyIndex]
        return toCurrency
    }
    
    
    private func errorHandle(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            if strongSelf.needToUpdateList {
                strongSelf.updateList(completion: strongSelf.handlerAfterUpdateList)
            }
            strongSelf.needToUpdateList = true
        }))
        self.present(alert, animated: true)
    }
    
    private func handlerAfterUpdateList() {

        self.labelEqualSign.isHidden = false
        self.labelValueFromCurrency.isHidden = false
        self.labelValueToCurrency.isHidden = false
        
        self.pickerFrom.isHidden = false
        self.pickerTo.isHidden = false
        
        self.pickerFrom.reloadAllComponents()
        self.pickerTo.reloadAllComponents()
        
        self.activityIndicator.stopAnimating()
        
        
        self.labelNameFromCurrency.text = self.getBaseCurrency()
        self.labelNameToCurrency.text = self.getToCurrency()

    }
    
    
}
