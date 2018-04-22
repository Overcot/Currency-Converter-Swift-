import UIKit

enum Result<T> {
    case success(T)
    case error(Error)
}

enum ModelError: Error {
    case noData
    case parseError
    case noRates
}

// хз как не харккодить валюты

class CurrenciesModel {
    var currencies : [String] =  ["RUB", "EUR", "USD"]
    // MARK: NEED TO UPDATE API REQUEST
    var accessKey = "90cb887181e63c6dac1aeab215e4bd4c"
    

    func printCurrencyList() {
        print("Currency List - ", currencies)
    }
    func currenciesExcept(number : Int) -> [String] {
        var currenciesExceptBase = currencies
        currenciesExceptBase.remove(at: number)
        
        return currenciesExceptBase
    }

    func createCurrencyList(completion: @escaping (Result<[String]>) -> Void) {
        requestCurrencyList() { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let currencies):
                strongSelf.currencies = currencies
            case .error(_):
                break
            }
            completion(result)

        }
    }
    
    
    func getCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (Result<String>) -> Void) {
        requestBaseCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) {
            result in
            completion(result)

        }
    }
    
    
    
    
    private func requestCurrencyList(completion: @escaping (Result<[String]>) -> ()) {
        let url = URL(string: "https://api.fixer.io/latest")!
        
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
            
            let parseResult = strongSelf.parseCurrencyResponseList(data: data)
            completion(parseResult)
        }
        dataTask.resume()
    }
    
    private func parseCurrencyResponseList(data: Data) -> (Result<[String]>) {
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
    
    
    
    
    private func requestBaseCurrencyRate(baseCurrency : String, toCurrency : String,  completion: @escaping (Result<String>) -> Void) {
        let url = URL(string: "https://api.fixer.io/latest?base=" + baseCurrency)!
        
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
            let parseResult = strongSelf.parseCurrencyRatesResponse(data: data, toCurrency: toCurrency)
            completion(parseResult)
        }
        dataTask.resume()
    }
    
    private func parseCurrencyRatesResponse(data: Data, toCurrency: String) -> (Result<String>){
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

