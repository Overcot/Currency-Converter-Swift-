//
//  Network.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 23.04.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import Foundation

enum RequestType {
    case updateList
    case updateCurrencyRate(baseCurrency: String, toCurrency: String)
}

protocol UpdateProtocol {
    associatedtype ParserType: ParseProtocol
    var baseHTTPString: String { get }
    var parser: ParserType { get }
    var params: String { get }
    var dataTask: DataTask { get }
    
}


class NetworkManager {
    lazy var getList = UpdateCurrencyList()
    lazy var getRate = UpdateCurrencyRate()
    
    func request(_ typeOfRequest: RequestType, completion: @escaping (ResultProtocol) -> () ){
        switch typeOfRequest {
            case .updateList:
                getList.request{ result in
                    completion(result)
                }
            case .updateCurrencyRate(let baseCurrency, let toCurrency):
                getRate.request(baseCurrency: baseCurrency, toCurrency: toCurrency) { result in
                    completion(result)
                }
        }
    }
}


class UpdateCurrencyList: UpdateProtocol {
    
    let baseHTTPString: String
    let params: String
    let parser: CurrenciesParser
    lazy var dataTask: DataTask = DataTask()
    
    init() {
        self.baseHTTPString = "http://free.currencyconverterapi.com/api/v5/"
        self.params = "currencies"
        self.parser = CurrenciesParser()
    }
    
    func request(completion: @escaping (Result<[String]>) -> ()) {
        let url = URL(string: baseHTTPString+params)!
        
        dataTask.getData(url: url) { [weak self] result in
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

class UpdateCurrencyRate: UpdateProtocol {
    let baseHTTPString: String
    let params: String
    let parser: RateParser
    lazy var dataTask: DataTask = DataTask()

    private var baseCurrency: String
    private var toCurrency: String

    init () {
        self.baseHTTPString = "http://free.currencyconverterapi.com/api/v5/"
        self.params = "convert?q="
        self.parser = RateParser()
        self.baseCurrency = ""
        self.toCurrency = ""
    }
    
    func request(baseCurrency: String, toCurrency: String, completion: @escaping (Result<String>) -> Void) {
        
        self.baseCurrency = baseCurrency
        self.toCurrency = toCurrency
        
        let url = URL(string: baseHTTPString + params + baseCurrency + "_" + toCurrency)!
        
        dataTask.getData(url: url) { [weak self] result in
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
    func getData(url: URL, completion: @escaping(Result<Data>) -> Void ) {
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





