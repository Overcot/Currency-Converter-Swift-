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

class CurrenciesModel {
    var currencies : [String]
    let networkManager : NetworkManager
    init () {
        self.currencies = []
        self.networkManager = NetworkManager()
    }
    

    func currenciesExcept(number : Int) -> [String] {
        var currenciesExceptBase = currencies
        currenciesExceptBase.remove(at: number)
        
        return currenciesExceptBase
    }

    func createCurrencyList(completion: @escaping (Result<[String]>) -> Void) {
        
        
        networkManager.updateListRequest {
            [weak self] result in
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
        
        networkManager.updateCurrencyRaterequest(baseCurrency: baseCurrency, toCurrency: toCurrency) { result in
            completion(result)
        }

    }
    
    
    
    

    
}

