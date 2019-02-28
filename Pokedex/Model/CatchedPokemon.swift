//
//  CatchedPokemon.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 28/02/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import CoreData

class CatchedPokemon : NSManagedObject {
    static var all: [CatchedPokemon] {
        let request: NSFetchRequest<CatchedPokemon> = CatchedPokemon.fetchRequest()
        guard let catchedPokemons = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return catchedPokemons
    }
}
