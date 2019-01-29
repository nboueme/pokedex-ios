//
//  PokeListWorker.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit
import Alamofire

typealias pokedexResponseHandler = (_ response: PokeListModel.FetchPokedex.Response) -> ()
typealias pokemonResponseHandler = (_ response: PokeListModel.FetchPokemon.Response) -> ()

class PokeListWorker {
    func fetchPokedex(withURL: String, success: @escaping(pokedexResponseHandler), fail: @escaping(pokedexResponseHandler)) {
        Alamofire.request(withURL).responseData { response in
            do {
                if response.result.isSuccess {
                    let jsonDecoder = JSONDecoder()
                    if let jsonData = response.result.value {
                        let pokedex = try jsonDecoder.decode(Pokedex.self, from: jsonData)
                        success(PokeListModel.FetchPokedex.Response(pokeListObj: pokedex, isError: false, message: nil))
                    } else {
                        fail(PokeListModel.FetchPokedex.Response(pokeListObj: nil, isError: true, message: "There is nothing to see here!"))
                    }
                } else if response.result.isFailure {
                    var message = String()
                    if let error = response.error {
                        message = self.handleError(code: error._code)
                    }
                    fail(PokeListModel.FetchPokedex.Response(pokeListObj: nil, isError: true, message: message))
                }
            } catch {
                fail(PokeListModel.FetchPokedex.Response(pokeListObj: nil, isError: true, message: "JSON decoding doesn't work!"))
            }
        }
    }
    
    func fetchPokemon(withURL: String, success: @escaping(pokemonResponseHandler), fail: @escaping(pokemonResponseHandler)) {
        Alamofire.request(withURL).responseData { response in
            do {
                if response.result.isSuccess {
                    let jsonDecoder = JSONDecoder()
                    if let jsonData = response.result.value {
                        let pokemon = try jsonDecoder.decode(PokemonDetails.self, from: jsonData)
                        success(PokeListModel.FetchPokemon.Response(pokemon: pokemon, isError: false, message: nil))
                    } else {
                        fail(PokeListModel.FetchPokemon.Response(pokemon: nil, isError: true, message: "There is nothing to see here!"))
                    }
                } else if response.result.isFailure {
                    var message = String()
                    if let error = response.error {
                        message = self.handleError(code: error._code)
                    }
                    fail(PokeListModel.FetchPokemon.Response(pokemon: nil, isError: true, message: message))
                }
            } catch {
                fail(PokeListModel.FetchPokemon.Response(pokemon: nil, isError: true, message: "JSON decoding doesn't work!"))
            }
        }
    }
    
    private func handleError(code: NSInteger) -> String {
        var message = String()
        
        switch code {
        case NSURLErrorTimedOut:
            message = "Network Timeout!"
            break
        case NSURLErrorNotConnectedToInternet:
            message = "You're not connected to Internet!"
            break
        default:
            message = "\(code)"
        }
        
        return message
    }
}
