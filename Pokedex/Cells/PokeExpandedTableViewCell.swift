//
//  PokeExpandedTableViewCell.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 30/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

class PokeExpandedTableViewCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonSprite: UIImageView!
    
    // MARK: Variables
    var index: IndexPath?
    var shouldCollapse: ((IndexPath?) -> Void)?
    
    // MARK: UI
    func setup(data: Pokemon, isCatched: Bool) {
        if let pokemonName = data.name {
            pokemonNameLabel.text = pokemonName
            backgroundColor = isCatched ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : .clear
        }
    }
    
    // MARK: Actions
    @IBAction func didTapCollapse(_ sender: UIButton) {
        shouldCollapse?(index)
    }
}
