//
//  Parse.swift
//  Currency Converter
//
//  Created by Alex Ivashko on 04.05.2018.
//  Copyright © 2018 Alex Ivashko. All rights reserved.
//

import Foundation

protocol ParseProtocol {
    associatedtype T
    func parse(data: Data) -> Result<T>
}
extension ParseProtocol {
    func parseJSON(data: Data) -> Result<[String: Any]> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let parsedJSON = json else {
                return .error(ModelError.parseError)
            }
            return .success(parsedJSON)
        } catch  {
            return .error(ModelError.noData)
        }
    }
}


class CurrenciesParser: ParseProtocol {

    func parse(data: Data) -> Result<[String]> {
        let result = parseJSON(data: data)
        switch result {
            case .success(let parsedJSON):
                guard let rates = parsedJSON["results"] as? [String: Any] else {
                    return .error(ModelError.noRates)
                }
                return .success(Array(rates.keys).sorted())
            case .error(let error):
                return .error(error)
        }
    }
}

class RateParser: ParseProtocol {
    func parse(data: Data) -> Result<Double> {
        let result = parseJSON(data: data)
        switch result {
            case .success(let parsedJSON):
                guard let results = parsedJSON["results"] as? [String: Any] else {
                    return .error(ModelError.parseError)
                }
                guard let rateInfo = results[Array(results)[0].key] as? [String: Any] else {
                    return .error(ModelError.parseError)
                }
                guard let rate = rateInfo["val"] as? Double else {
                    return .error(ModelError.noRates)
                }
                return .success(rate)
            case .error(let error):
                return .error(error)
        }
    }
}
