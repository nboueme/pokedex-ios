//
//  PokeListViewControllerUITableView.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 28/02/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

extension PokeListViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPokedex.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentCellExpandedIndex == indexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedCell", for: indexPath) as! PokeExpandedTableViewCell
            let pokemon = currentPokedex[indexPath.row]
            if let pokemonName = pokemon.name, let URL = pokemon.url {
                canGoToPokeDetails = false
                let isCatched = catchedPokemons.index(of: pokemonName) != nil ? true : false
                cell.setup(data: pokemon, isCatched: isCatched)
                interactor?.fetchPokemon(request: PokeListModel.FetchPokemon.Request(URL: URL, isCatched: isCatched))
            } else {
                cell.setup(data: pokemon, isCatched: false)
            }
            cell.index = indexPath
            cell.shouldCollapse = { [weak self] index in
                self?.currentCellCollapsedIndex = index
                self?.currentCellExpandedIndex = nil
                if let indexPath = index {
                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                }
            }
            
            if let sprite = currentPokemonSprite {
                cell.pokemonSprite.image = sprite
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedCell", for: indexPath) as! PokeCollapsedTableViewCell
            let pokemon = currentPokedex[indexPath.row]
            if let pokemonName = pokemon.name {
                cell.setup(data: pokemon, isCatched: catchedPokemons.index(of: pokemonName) != nil ? true : false)
            } else {
                cell.setup(data: pokemon, isCatched: false)
            }
            cell.index = indexPath
            cell.shouldExpand = { [weak self] index in
                var toBeReloaded: [IndexPath] = []
                if let previouslyExpanded = self?.currentCellExpandedIndex {
                    toBeReloaded.append(previouslyExpanded)
                }
                self?.currentCellExpandedIndex = index
                self?.currentCellCollapsedIndex = nil
                if let indexPath = index {
                    toBeReloaded.append(indexPath)
                }
                guard !toBeReloaded.isEmpty else { return }
                tableView.reloadRows(at: toBeReloaded, with: UITableView.RowAnimation.automatic)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loading.isHidden = false
        
        if let pokemonName = currentPokedex[indexPath.row].name, let URL = currentPokedex[indexPath.row].url {
            canGoToPokeDetails = true
            let isCatched = catchedPokemons.index(of: pokemonName) != nil ? true : false
            interactor?.fetchPokemon(request: PokeListModel.FetchPokemon.Request(URL: URL, isCatched: isCatched))
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            if let _ = nextPokemonURL {
                loading.isHidden = false
            }
            interactor?.fetchPokedex(request: PokeListModel.FetchPokedex.Request(baseURL: nextPokemonURL))
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 >= pokedex.count
    }
}
