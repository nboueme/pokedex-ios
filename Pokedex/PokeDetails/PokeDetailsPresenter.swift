//
//  PokeDetailsPresenter.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

protocol PokeDetailsPresentationLogic {
    func presentPokemon(response: PokeDetailsModel.GetPokemon.Response)
    func presentFetchSprite(response: PokeDetailsModel.FetchSprite.Response)
}

class PokeDetailsPresenter: PokeDetailsPresentationLogic {
    weak var viewController: PokeDetailsDisplayLogic?
    
    func presentPokemon(response: PokeDetailsModel.GetPokemon.Response) {
        let viewModel = PokeDetailsModel.GetPokemon.ViewModel(pokemon: response.pokemon, isCatched: response.isCatched)
        viewController?.displayPokemon(viewModel: viewModel)
    }
    
    func presentFetchSprite(response: PokeDetailsModel.FetchSprite.Response) {
        let viewModel = PokeDetailsModel.FetchSprite.ViewModel(sprite: response.sprite, isError: response.isError, message: response.message)
        
        if viewModel.isError {
            viewController?.errorFetchingSprite(viewModel: viewModel)
        } else {
            viewController?.successFetchedSprite(viewModel: viewModel)
        }
    }
}
