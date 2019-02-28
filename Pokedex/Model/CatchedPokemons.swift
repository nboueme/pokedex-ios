//
//  CatchedPokemons.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 28/02/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

class CatchedPokemons {
    private struct Keys {
        static let catchedPokemons = "catchedPokemons"
    }
    
    static var array : [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: Keys.catchedPokemons) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.catchedPokemons)
        }
    }
}
