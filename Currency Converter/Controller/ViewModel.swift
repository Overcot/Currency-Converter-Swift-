//
//  ViewModel.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 16.05.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import Foundation

class ViewModel {

    
    
    var currenciesModel = CurrenciesModel()
    var needToUpdateList: Bool = true
    var amountOfCurrencies: Int {
        get {
            return currenciesModel.currencies.count
        }
    }
    
    
    func updateBaseToCurrentCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (Result<String>, String, String) -> ()) {
        currenciesModel.updateCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency)  { result in
            completion(result, baseCurrency, toCurrency)
        }
    }
    func updateList(completion: @escaping (Result<[String]>) -> ()) {
        currenciesModel.updateCurrencyList { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success:
                strongSelf.needToUpdateList = false
            case .error:
                strongSelf.needToUpdateList = true
            }
            completion(result)
        }
    }
    func getBaseCurrencyNameByIndex(_ index: Int) -> String {
        return currenciesModel.currencies[index]
    }
    func getToCurrencyNameByIndex(_ index: Int) -> String {
        return currenciesModel.currenciesExcept(number: currenciesModel.selectedCurrency)[index]
    }
    func updateSelectedCurrency(_ selectedIndex: Int) {
        currenciesModel.selectedCurrency = selectedIndex
    }
    func getCurrencyNameByIndex(_ index: Int) -> String {
        return currenciesModel.currencies[index]
    }
}
