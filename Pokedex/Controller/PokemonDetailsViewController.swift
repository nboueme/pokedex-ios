//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 15/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

class PokemonDetailsViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    var pokemon = PokemonDetails()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = pokemon.name
    }
}
