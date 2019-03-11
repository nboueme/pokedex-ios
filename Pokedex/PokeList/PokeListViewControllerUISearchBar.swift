//
//  PokeListViewControllerUISearchBar.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 28/02/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

extension PokeListViewController: UISearchBarDelegate {
    func searchPokemons() {
        searchBar
            .rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] query in
                self.currentCellCollapsedIndex = nil
                self.currentCellExpandedIndex = nil
                self.currentPokedex.accept(query.count > 0 ? self.pokedex.filter({$0.name!.lowercased().contains(query.lowercased())}) : self.pokedex)
            })
            .disposed(by: disposeBag)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currentCellCollapsedIndex = nil
        currentCellExpandedIndex = nil
        searchBar.text = String()
        currentPokedex.accept(pokedex)
    }
}
