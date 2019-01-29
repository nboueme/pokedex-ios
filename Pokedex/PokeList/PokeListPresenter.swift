//
//  PokeListPresenter.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

protocol PokeListPresentationLogic {
    func presentFetchPokedex(response: PokeListModel.FetchPokedex.Response)
    func presentFetchPokemon(response: PokeListModel.FetchPokemon.Response)
    func presentCatchedPokemon(response: PokeListModel.GetCatchedPokemon.Response)
}

class PokeListPresenter: PokeListPresentationLogic {
    weak var viewController: PokeListDisplayLogic?
    
    func presentFetchPokedex(response: PokeListModel.FetchPokedex.Response) {
        let viewModel = PokeListModel.FetchPokedex.ViewModel(pokedex: response.pokeListObj?.results, next: response.pokeListObj?.next, isError: response.isError, message: response.message)
        
        if viewModel.isError {
            viewController?.errorFetchingPokedex(viewModel: viewModel)
        } else {
            viewController?.successFetchedPokedex(viewModel: viewModel)
        }
    }
    
    func presentFetchPokemon(response: PokeListModel.FetchPokemon.Response) {
        let viewModel = PokeListModel.FetchPokemon.ViewModel(pokemon: response.pokemon, isError: response.isError, message: response.message)
        
        if viewModel.isError {
            viewController?.errorFetchingPokemon(viewModel: viewModel)
        } else {
            viewController?.successFetchedPokemon(viewModel: viewModel)
        }
    }
    
    func presentCatchedPokemon(response: PokeListModel.GetCatchedPokemon.Response) {
        let viewModel = PokeListModel.GetCatchedPokemon.ViewModel(catchedPokemon: response.catchedPokemon)
        viewController?.displayCatchedPokemon(viewModel: viewModel)
    }
}
