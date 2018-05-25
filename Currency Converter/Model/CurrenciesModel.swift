import UIKit
import CoreData

protocol ResultProtocol {
    
}
enum Result<T>: ResultProtocol {
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
    var selectedCurrency: Int
    let networkManager : NetworkManager
    init () {
        self.currencies = []
        self.selectedCurrency = 0
        self.networkManager = NetworkManager()
    }
    

    func currenciesExcept(number : Int) -> [String] {
        var currenciesExceptBase = currencies
        currenciesExceptBase.remove(at: number)
        return currenciesExceptBase
    }

    func updateCurrencyList(completion: @escaping (Result<[String]>) -> Void) {
        networkManager.request(.updateList) {
            [weak self] result in
            guard let strongSelf = self else { return }
            guard let result = result as? Result<[String]> else {return}
            switch result {
                case .success(let currencies):
                    strongSelf.currencies = currencies
                case .error(_):
                    break
            }
            completion(result)

        }
    }

    
    func updateCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (Result<String>) -> Void) {
        networkManager.request(.updateCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency)) { result in
            guard let result = result as? Result<String> else {return}
            completion(result)
        }
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Currencies")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}

