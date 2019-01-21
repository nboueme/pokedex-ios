//
//  PokeListViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 10/01/2019.
//  Copyright © 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

class PokeListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    private var pokedexService = PokedexService()
    private var pokedex: [Pokemon] = [] {
        didSet {
           currentPokedex = pokedex
        }
    }
    private var selectedPokemon: PokemonDetails?
    private var catchedPokemons: [String] = []
    private var currentPokedex: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPokedexData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedPokemon = nil
    }
    
    private func loadPokedexData() {
        pokedexService.getList { pokedex in
            if let pokedex = pokedex {
                self.pokedex = pokedex
                self.tableView.reloadData()
                self.loading.isHidden = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PokemonDetailsViewController,
            segue.identifier == "goToPokemonDetails",
            let selectedPokemon = selectedPokemon {
            vc.pokemon = selectedPokemon
            if let pokemonName = selectedPokemon.name,
                let _ = catchedPokemons.index(of: pokemonName) {
                vc.catched = true
            }
            vc.delegate = self
        }
    }
}

extension PokeListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPokedex.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        
        let pokemon = currentPokedex[indexPath.row]
            
        if let pokemonName = pokemon.name {
            cell.textLabel?.text = pokemonName
            cell.backgroundColor = catchedPokemons.index(of: pokemonName) != nil ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loading.isHidden = false
        
        if let URL = currentPokedex[indexPath.row].url {
            pokedexService.getOne(withURL: URL) { pokemon in
                if let pokemon = pokemon {
                    self.loading.isHidden = true
                    self.selectedPokemon = pokemon
                    self.performSegue(withIdentifier: "goToPokemonDetails", sender: nil)
                }
            }
        }
        
        // let pokemonDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "PokemonDetailsViewController") as? PokemonDetailsViewController
        // pokemonDetailsViewController?.pokemon = pokemon
        // self.navigationController?.pushViewController(pokemonDetailsViewController!, animated: true)
    }
}

extension PokeListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentPokedex = searchText.count > 0 ? pokedex.filter({$0.name!.lowercased().contains(searchText.lowercased())}) : pokedex
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        currentPokedex = pokedex
        tableView.reloadData()
    }
}

extension PokeListViewController: ChildToParentProtocol {
    func isCatched(name: String) {
        catchedPokemons.append(name)
        tableView.reloadData()
    }
}
