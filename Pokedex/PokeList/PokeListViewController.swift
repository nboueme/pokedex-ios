//
//  PokeListViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

protocol PokeListDisplayLogic: class {
    func successFetchedPokedex(viewModel: PokeListModel.FetchPokedex.ViewModel)
    func errorFetchingPokedex(viewModel: PokeListModel.FetchPokedex.ViewModel)
    func successFetchedPokemon(viewModel: PokeListModel.FetchPokemon.ViewModel)
    func errorFetchingPokemon(viewModel: PokeListModel.FetchPokemon.ViewModel)
    func displayCatchedPokemon(viewModel: PokeListModel.GetCatchedPokemon.ViewModel)
}

class PokeListViewController: UIViewController, PokeListDisplayLogic {
    var interactor: PokeListBusinessLogic?
    var router: (NSObjectProtocol & PokeListRoutingLogic & PokeListDataPassing)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        let interactor = PokeListInteractor()
        let presenter = PokeListPresenter()
        let router = PokeListRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let URL = "https://pokeapi.co/api/v2/pokemon/"
        interactor?.fetchPokedex(request: PokeListModel.FetchPokedex.Request(baseURL: URL))
        tableView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.getCatchedPokemon(request: PokeListModel.GetCatchedPokemon.Request())
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private var pokedex: [Pokemon] = [] {
        didSet {
            currentPokedex = pokedex
        }
    }
    private var currentPokedex: [Pokemon] = []
    private var catchedPokemons: [String] = []
    private var nextPokemonURL: String?
    
    func successFetchedPokedex(viewModel: PokeListModel.FetchPokedex.ViewModel) {
        if pokedex.count > 0 {
            if let pokedex = viewModel.pokedex {
                for pokemon in pokedex {
                    self.pokedex.append(pokemon)
                }
            }
        } else {
            if let pokedex = viewModel.pokedex {
                self.pokedex = pokedex
            }
        }
        
        self.nextPokemonURL = viewModel.next
        
        tableView.reloadData()
        loading.isHidden = true
    }
    
    func errorFetchingPokedex(viewModel: PokeListModel.FetchPokedex.ViewModel) {
        print(viewModel.message!)
    }
    
    func successFetchedPokemon(viewModel: PokeListModel.FetchPokemon.ViewModel) {
        if viewModel.pokemon != nil {
            loading.isHidden = true
            router?.routeToPokeDetails(segue: nil)
        }
    }
    
    func errorFetchingPokemon(viewModel: PokeListModel.FetchPokemon.ViewModel) {
        print(viewModel.message!)
    }
    
    func displayCatchedPokemon(viewModel: PokeListModel.GetCatchedPokemon.ViewModel) {
        if !catchedPokemons.contains(viewModel.catchedPokemon) {
            catchedPokemons.append(viewModel.catchedPokemon)
            tableView.reloadData()
        }
    }
}

extension PokeListViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
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
//            cell.textLabel?.text = "#\(indexPath.row + 1) \(pokemonName)"
            cell.backgroundColor = catchedPokemons.index(of: pokemonName) != nil ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loading.isHidden = false
        
        if let pokemonName = currentPokedex[indexPath.row].name, let URL = currentPokedex[indexPath.row].url {
            let isCatched = catchedPokemons.index(of: pokemonName) != nil ? true : false
            interactor?.fetchPokemon(request: PokeListModel.FetchPokemon.Request(URL: URL, isCatched: isCatched))
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            if let _ = nextPokemonURL {
                loading.isHidden = false
            }
            interactor?.fetchPokedex(request: PokeListModel.FetchPokedex.Request(baseURL: nextPokemonURL))
        }
    }
}

extension PokeListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentPokedex = searchText.count > 0 ? pokedex.filter({$0.name!.lowercased().contains(searchText.lowercased())}) : pokedex
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = String()
        currentPokedex = pokedex
        tableView.reloadData()
    }
}

private extension PokeListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 >= pokedex.count
    }
}
