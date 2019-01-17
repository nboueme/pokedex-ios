//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 15/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit
import Alamofire

class PokemonDetailsViewController: UIViewController {

    @IBOutlet weak var sprite: UIImageView!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var baseExperience: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    private var pokedexService = PokedexService()
    var pokemon = PokemonDetails()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sprite.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        sprite.layer.borderWidth = 8
        sprite.layer.cornerRadius = 6.0
        
        if let spriteURL = pokemon.sprites?.front_default {
            pokedexService.getSprite(withURL: spriteURL) { sprite in
                if let sprite = sprite {
                    self.loading.isHidden = true
                    self.sprite.image = sprite
                }
            }
        }
        
        id.text = "#\(pokemon.id!)"
        name.text = pokemon.name?.uppercased()
        height.text = "Height: \(pokemon.height!)"
        weight.text = "Weight: \(pokemon.weight!)"
        baseExperience.text = "Base experience: \(pokemon.base_experience!)"
    }
}
