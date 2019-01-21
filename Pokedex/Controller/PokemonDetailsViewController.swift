//
//  PokemonDetailsViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 15/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit
import Alamofire

protocol ChildToParentProtocol: class {
    func isCatched(name: String)
}

class PokemonDetailsViewController: UIViewController {

    weak var delegate: ChildToParentProtocol? = nil
    
    @IBOutlet weak var sprite: UIImageView!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var baseExperience: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var catchButton: UIButton!
    
    private var pokedexService = PokedexService()
    var pokemon = PokemonDetails()
    var catched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDetails()
        isCatched()
    }
    
    func getDetails() {
        title = pokemon.name
        
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
    
    func isCatched() {
        if catched {
            catchButton.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            catchButton.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        }
    }

    @IBAction func catchAction(_ sender: UIButton) {
        if !catched {
            self.navigationController?.popViewController(animated: true)
            if let name = pokemon.name {
                delegate?.isCatched(name: name)
            }
        }
    }
}
