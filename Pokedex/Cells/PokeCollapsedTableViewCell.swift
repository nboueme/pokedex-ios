//
//  PokeCollapsedTableViewCell.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 30/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

class PokeCollapsedTableViewCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    // MARK: Variables
    var index: IndexPath?
    var shouldExpand: ((IndexPath?) -> Void)?
    
    // MARK: UI
    func setup(data: Pokemon, isCatched: Bool) {
        if let pokemonName = data.name {
            pokemonNameLabel.text = pokemonName
            backgroundColor = isCatched ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : .clear
        }
    }
    
    // MARK: Actions
    @IBAction func didTapExpand(_ sender: UIButton) {
        shouldExpand?(index)
    }
}
