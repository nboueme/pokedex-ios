//
//  PokeDetailsModels.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

enum PokeDetailsModel {
    struct GetPokemon {
        struct Request {
        }
        struct Response {
            var pokemon: PokemonDetails
            var isCatched: Bool
        }
        struct ViewModel {
            var pokemon: PokemonDetails
            var isCatched: Bool
        }
    }
    
    struct FetchSprite {
        struct Request {
            var URL: String?
        }
        struct Response {
            var sprite: UIImage?
            var isError: Bool
            var message: String?
        }
        struct ViewModel {
            var sprite: UIImage?
            var isError: Bool
            var message: String?
        }
    }
}
