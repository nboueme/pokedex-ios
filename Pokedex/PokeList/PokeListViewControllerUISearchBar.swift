//
//  PokeListViewControllerUISearchBar.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 28/02/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

extension PokeListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentCellCollapsedIndex = nil
        currentCellExpandedIndex = nil
        currentPokedex = searchText.count > 0 ? pokedex.filter({$0.name!.lowercased().contains(searchText.lowercased())}) : pokedex
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        currentCellCollapsedIndex = nil
        currentCellExpandedIndex = nil
        searchBar.text = String()
        currentPokedex = pokedex
        tableView.reloadData()
    }
}
