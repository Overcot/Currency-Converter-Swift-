//
//  Network.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 23.04.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import Foundation

protocol Request {
    var baseHTTPString : String {get}
    var params : String {get}
}


class NetworkManager {
    var getList = UpdateCurrencyListTask()
    var getRate = UpdateCurrencyRateTask()
    
    func updateListRequest(completion: @escaping (Result<[String]>) -> ()) {
        getList.request{ result in
            completion(result)
        }
    }
    
    
    func updateCurrencyRaterequest(baseCurrency: String, toCurrency: String, completion: @escaping (Result<String>) -> ()) {
        getRate.request(baseCurrency: baseCurrency, toCurrency: toCurrency) { result in
            completion(result)
        }
    }
}


class UpdateCurrencyListTask : Request {
    
    
    var baseHTTPString: String
    var params: String
    
    init() {
        self.baseHTTPString = "https://api.fixer.io/latest"
        self.params = ""
    }
    
    func request(completion: @escaping (Result<[String]>) -> ()) {
        print(3)
        let url = URL(string: baseHTTPString)!
        let dataTask = URLSession.shared.dataTask(with: url){
            [weak self] (dataReceived, response, error) in
            print(4)
            guard let strongSelf = self else {
                return
                
            }
            if let error = error {
                completion(.error(error))
                return
            }
            guard let data = dataReceived else {
                completion(.error(ModelError.noData))
                return
            }
            
            let parseResult = strongSelf.parse(data: data)
            completion(parseResult)
        }
        dataTask.resume()
    }
    private func parse(data: Data) -> (Result<[String]>) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let parsedJSON = json else {
                return .error(ModelError.parseError)
            }
            guard let rates = parsedJSON["rates"] as? [String: Double] else {
                return .error(ModelError.noRates)
            }
            return .success(rates.keys.sorted())
        } catch {
            return .error(ModelError.parseError)
        }
    }
}

class UpdateCurrencyRateTask : Request {
    
    let baseHTTPString: String = "https://api.fixer.io/latest"
    let params: String = "?base="
    
    private var baseCurrency: String
    private var toCurrency: String

    init () {
        self.baseCurrency = ""
        self.toCurrency = ""
    }
    
    
    
    func request(baseCurrency: String, toCurrency: String, completion: @escaping (Result<String>) -> Void) {
        
        self.baseCurrency = baseCurrency
        self.toCurrency = toCurrency
        
        let url = URL(string: baseHTTPString + params + self.baseCurrency)!
        
        let dataTask = URLSession.shared.dataTask(with: url){
            [weak self] (dataReceived, response, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(.error(error))
                return
            }
            guard let data = dataReceived else {
                completion(.error(ModelError.noData))
                return
            }
            let parseResult = strongSelf.parse(data: data, toCurrency: strongSelf.toCurrency)
            completion(parseResult)
        }
        dataTask.resume()
    }
    private func parse(data: Data, toCurrency: String) -> (Result<String>){
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let parsedJSON = json else {
                return .error(ModelError.parseError)
            }
            guard let rates = parsedJSON["rates"] as? [String: Double] else {
                return .error(ModelError.noRates)
            }
            guard let rate = rates[toCurrency] else {
                return .error(ModelError.noRates)
            }
            return .success("\(rate)")
        } catch {
            return .error(ModelError.parseError)
        }
    }
}











