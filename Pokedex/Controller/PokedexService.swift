//
//  PokedexService.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 14/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import Foundation
import Alamofire

class PokedexService {
    let pokeAPIBaseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")
    
    func getList(completion: @escaping ([Pokemon]?) -> Void) {
        Alamofire.request(pokeAPIBaseURL!).responseData { response in
            do {
                if response.result.isSuccess {
                    let jsonDecoder = JSONDecoder()
                    if let jsonData = response.result.value {
                        let pokedex = try jsonDecoder.decode(Pokedex.self, from: jsonData)
                        completion(pokedex.results!)
                    } else {
                        completion(nil)
                    }
                } else if response.result.isFailure {
                    switch response.error!._code {
                    case NSURLErrorTimedOut:
                        print("Network Timeout!")
                        break
                    case NSURLErrorNotConnectedToInternet:
                        print("You're not connected to Internet!")
                        break
                    default:
                        print(response.error!._code)
                    }
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
    }
}
