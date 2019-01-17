//
//  PokemonDetails.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 15/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import Foundation

struct PokemonDetails: Codable {
    var id: Int?
    var base_experience: Int?
    var height: Int?
    var name: String?
    var sprites: Sprites?
    var weight: Int?
}
