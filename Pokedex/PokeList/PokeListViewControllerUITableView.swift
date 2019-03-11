//
//  PokeListViewControllerUITableView.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 28/02/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

extension PokeListViewController: UITableViewDelegate, UITableViewDataSourcePrefetching {
    func bindPokedexToTableView() {
        currentPokedex.bind(to: tableView.rx.items) { tableView, row, pokemon in
            let indexPath = IndexPath(row: row, section: 0)

            if self.currentCellExpandedIndex == indexPath {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedCell", for: indexPath) as! PokeExpandedTableViewCell
                if let pokemonName = pokemon.name, let URL = pokemon.url {
                    self.canGoToPokeDetails = false
                    let isCatched = self.catchedPokemons.index(of: pokemonName) != nil ? true : false
                    cell.setup(data: pokemon, isCatched: isCatched)
                    self.interactor?.fetchPokemon(request: PokeListModel.FetchPokemon.Request(URL: URL, isCatched: isCatched))
                }
                
                cell.index = indexPath
                cell.shouldCollapse = { [weak self] index in
                    self?.currentCellCollapsedIndex = index
                    self?.currentCellExpandedIndex = nil
                    if let indexPath = index {
                        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                    }
                }
                
                if let sprite = self.currentPokemonSprite {
                    cell.pokemonSprite.image = sprite
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedCell", for: indexPath) as! PokeCollapsedTableViewCell
                if let pokemonName = pokemon.name {
                    cell.setup(data: pokemon, isCatched: self.catchedPokemons.index(of: pokemonName) != nil ? true : false)
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
        }.disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loading.isHidden = false
        
        if let pokemonName = currentPokedex.value[indexPath.row].name, let URL = currentPokedex.value[indexPath.row].url {
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
