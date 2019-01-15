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
    
    var pokedexService: PokedexService!
    var pokedex: [Pokemon]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPokedexData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
}

extension PokeListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let pokedex = pokedex {
            return pokedex.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        let pokemon = pokedex![indexPath.row]
        
        cell.textLabel?.text = pokemon.name
        cell.detailTextLabel?.text = "#\(indexPath.row + 1)"
        
        return cell
    }
}
