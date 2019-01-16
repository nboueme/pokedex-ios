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
        if let withURL = pokeAPIBaseURL {
            Alamofire.request(withURL).responseData { response in
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
                        self.handleError(code: response.error!._code)
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                }
            }
        }
    }
    
    func getOne(withURL: String, completion: @escaping (PokemonDetails?) -> Void) {
        Alamofire.request(withURL).responseData { response in
            do {
                if response.result.isSuccess {
                    let jsonDecoder = JSONDecoder()
                    if let jsonData = response.result.value {
                        let pokemon = try jsonDecoder.decode(PokemonDetails.self, from: jsonData)
                        completion(pokemon)
                    } else {
                        completion(nil)
                    }
                } else if response.result.isFailure {
                    self.handleError(code: response.error!._code)
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
    }
    
    private func handleError(code: NSInteger) {
        switch code {
        case NSURLErrorTimedOut:
            print("Network Timeout!")
            break
        case NSURLErrorNotConnectedToInternet:
            print("You're not connected to Internet!")
            break
        default:
            print(code)
        }
    }
}
