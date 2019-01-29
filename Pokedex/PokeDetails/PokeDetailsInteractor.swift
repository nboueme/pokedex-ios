//
//  PokeDetailsInteractor.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

protocol PokeDetailsBusinessLogic {
    func getPokemon(request: PokeDetailsModel.GetPokemon.Request)
    func fetchSprite(request: PokeDetailsModel.FetchSprite.Request)
}

protocol PokeDetailsDataStore {
    var pokemon: PokemonDetails? { get set }
}

class PokeDetailsInteractor: PokeDetailsBusinessLogic, PokeDetailsDataStore {
    var presenter: PokeDetailsPresentationLogic?
    var worker: PokeDetailsWorker?
    var pokemon: PokemonDetails?
    
    func getPokemon(request: PokeDetailsModel.GetPokemon.Request) {
        if let pokemon = pokemon {
            let response = PokeDetailsModel.GetPokemon.Response(pokemon: pokemon)
            presenter?.presentPokemon(response: response)
        }
    }
    
    func fetchSprite(request: PokeDetailsModel.FetchSprite.Request) {
        if let URL = request.URL {
            worker = PokeDetailsWorker()
            worker?.fetchSprite(withURL: URL, success: { response in
                self.presenter?.presentFetchSprite(response: response)
            }, fail: { response in
                self.presenter?.presentFetchSprite(response: response)
            })
        } else {
            self.presenter?.presentFetchSprite(response: PokeDetailsModel.FetchSprite.Response(sprite: nil, isError: true, message: "Fields may not be empty."))
        }
    }
}
