//
//  PokeListInteractor.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

protocol PokeListBusinessLogic {
    func fetchPokedex(request: PokeListModel.FetchPokedex.Request)
    func fetchPokemon(request: PokeListModel.FetchPokemon.Request)
    func getCatchedPokemon(request: PokeListModel.GetCatchedPokemon.Request)
}

protocol PokeListDataStore {
    var pokemon: PokemonDetails? { get set }
    var catchedPokemon: String? { get set }
    var selectedIsCatched: Bool { get set }
}

class PokeListInteractor: PokeListBusinessLogic, PokeListDataStore {
    var presenter: PokeListPresentationLogic?
    var worker: PokeListWorker?
    var pokemon: PokemonDetails?
    var catchedPokemon: String?
    var selectedIsCatched = false
    
    func fetchPokedex(request: PokeListModel.FetchPokedex.Request) {
        if let baseURL = request.baseURL {
            worker = PokeListWorker()
            worker?.fetchPokedex(withURL: baseURL, success: { response in
                self.presenter?.presentFetchPokedex(response: response)
            }, fail: { response in
                self.presenter?.presentFetchPokedex(response: response)
            })
        } else {
            self.presenter?.presentFetchPokedex(response: PokeListModel.FetchPokedex.Response(pokeListObj: nil, isError: true, message: "Fields may not be empty."))
        }
    }
    
    func fetchPokemon(request: PokeListModel.FetchPokemon.Request) {
        if let URL = request.URL {
            selectedIsCatched = request.isCatched
            worker = PokeListWorker()
            worker?.fetchPokemon(withURL: URL, success: { response in
                self.pokemon = response.pokemon
                self.presenter?.presentFetchPokemon(response: response)
            }, fail: { response in
                self.presenter?.presentFetchPokemon(response: response)
            })
        } else {
            self.presenter?.presentFetchPokemon(response: PokeListModel.FetchPokemon.Response(pokemon: nil, isError: true, message: "Fields may not be empty."))
        }
    }
    
    func getCatchedPokemon(request: PokeListModel.GetCatchedPokemon.Request) {
        if let name = catchedPokemon {
            let response = PokeListModel.GetCatchedPokemon.Response(catchedPokemon: name)
            presenter?.presentCatchedPokemon(response: response)
        }
    }
}
