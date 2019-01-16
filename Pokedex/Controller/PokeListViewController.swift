//
//  PokeListViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 10/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

class PokeListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    private var pokedexService: PokedexService!
    private var pokedex: [Pokemon]?
    private var selectedPokemon: PokemonDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPokedexData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedPokemon = nil
    }
    
    private func loadPokedexData() {
        pokedexService = PokedexService()
        pokedexService.getList { pokedex in
            if let pokedex = pokedex {
                self.pokedex = pokedex
                self.tableView.reloadData()
                self.loading.isHidden = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "goToPokemonDetails" {
            if let destination = segue.destination as? PokemonDetailsViewController, let selectedPokemon = selectedPokemon {
                destination.pokemon = selectedPokemon
            }
        }
    }
}

extension PokeListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pokedex = pokedex else {
            return 0
        }
        return pokedex.count
        // return pokedex != nil ? pokedex!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        
        if let pokedex = pokedex {
            let pokemon = pokedex[indexPath.row]
            
            if let name = pokemon.name {
                cell.textLabel?.text = "#\(indexPath.row + 1) \(name)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loading.isHidden = false
        if let pokedex = pokedex, let URL = pokedex[indexPath.row].url {
            pokedexService.getOne(withURL: URL) { pokemon in
                if let pokemon = pokemon {
                    self.loading.isHidden = true
                    
                    //                let pokemonDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PokemonDetailsViewController") as? PokemonDetailsViewController
                    //                pokemonDetailsViewController?.pokemon = pokemon
                    //                self.navigationController?.pushViewController(pokemonDetailsViewController!, animated: true)
                    
                    self.selectedPokemon = pokemon
                    self.performSegue(withIdentifier: "goToPokemonDetails", sender: nil)
                }
            }
        }
    }
}
