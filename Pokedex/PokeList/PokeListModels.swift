//
//  PokeListModels.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

struct PokeListModel {
    struct FetchPokedex {
        struct Request {
            var baseURL: String?
        }
        struct Response {
            var pokeListObj: Pokedex?
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var pokedex: [Pokemon]?
            var isError: Bool
            var message: String?
        }
    }
    
    struct FetchPokemon {
        struct Request {
            var URL: String?
        }
        struct Response {
            var pokemon: PokemonDetails?
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var pokemon: PokemonDetails?
            var isError: Bool
            var message: String?
        }
    }
    
    struct GetCatchedPokemon {
        struct Request {
        }
        struct Response {
            var catchedPokemon: String
        }
        struct ViewModel {
            var catchedPokemon: String
        }
    }
}
