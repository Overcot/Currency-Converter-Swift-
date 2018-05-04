//
//  Network.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 23.04.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import Foundation



protocol Request {
    associatedtype ParserCurrencies: BaseParser
    var baseHTTPString: String {get}
    var parser: BaseParser {get}
    var dataTask: DataTask {get}
}

class NetworkManager {
    lazy var getList = UpdateCurrencyListTask()
    lazy var getRate = UpdateCurrencyRateTask()
    
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


class UpdateCurrencyListTask {
    
    
    
    
    let baseHTTPString: String
    let parser: ParserCurrencies
    lazy var dataTask: DataTask = DataTask()
    
    
    init() {
        self.baseHTTPString = "http://free.currencyconverterapi.com/api/v5/"
        self.parser = ParserCurrencies()
        
    }
    
    func request(completion: @escaping (Result<[String]>) -> ()) {
        let url = URL(string: baseHTTPString+"currencies")!
        
        dataTask.createDataTask(url: url) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .success(let data):
                    let parseResult = strongSelf.parser.parse(data: data)
                    switch parseResult {
                        case .success(let list):
                            completion(.success(list))
                        case .error(let error):
                            completion(.error(error))
                    }
                case .error(let error):
                    completion(.error(error))
            }
        }
    }
}

class UpdateCurrencyRateTask {
    let baseHTTPString: String
    let parser = ParserRate()
    
    var params: String
    lazy var dataTask: DataTask = DataTask()

    private var baseCurrency: String
    private var toCurrency: String

    init () {
        self.baseHTTPString = "http://free.currencyconverterapi.com/api/v5/"
        self.params = "convert?q="
        self.baseCurrency = ""
        self.toCurrency = ""
    }
    func request(baseCurrency: String, toCurrency: String, completion: @escaping (Result<String>) -> Void) {
        
        self.baseCurrency = baseCurrency
        self.toCurrency = toCurrency
        
        let url = URL(string: baseHTTPString + params + baseCurrency + "_" + toCurrency)!
        
        dataTask.createDataTask(url: url) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .success(let data):
                    let parseResult = strongSelf.parser.parse(data: data)
                    switch parseResult {
                        case .success(let rate):
                            completion(.success("\(rate)"))
                        case .error(let error):
                            completion(.error(error))
                    }
                case .error(let error):
                    completion(.error(error))
            }
        }
    }
}


class DataTask {
    func createDataTask(url: URL, completion: @escaping(Result<Data>) -> Void ) {
        let dataTask = URLSession.shared.dataTask(with: url) {
            (dataReceived, response, error) in
            if let error = error {
                completion(.error(error))
                return
            }
            guard let data = dataReceived else {
                completion(.error(ModelError.noData))
                return
            }
            completion(.success(data))
        }
        dataTask.resume()
    }
}





