//
//  PokeListViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit
import Alamofire

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
        tableView.register(UINib(nibName: "PokeExpandedTableViewCell", bundle: nil), forCellReuseIdentifier: "ExpandedCell")
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
    private var currentCellExpandedIndex: IndexPath?
    private var currentCellCollapsedIndex: IndexPath?
    private var canGoToPokeDetails = false
    private var currentPokemon: PokemonDetails?
    private var currentPokemonSprite: UIImage?
    
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
        if currentPokemon?.name != viewModel.pokemon?.name {
            currentPokemon = viewModel.pokemon
            if canGoToPokeDetails {
                if let _ = viewModel.pokemon {
                    loading.isHidden = true
                    router?.routeToPokeDetails(segue: nil)
                }
            } else {
                // TODO: Sprite request
                Alamofire.request((viewModel.pokemon?.sprites?.front_default)!).responseData { response in
                    if response.result.isSuccess {
                        print("everything is ok")
                        self.currentPokemonSprite = UIImage(data: response.data!, scale: 1)
                        self.tableView.reloadRows(at: [self.currentCellExpandedIndex!], with: UITableView.RowAnimation.automatic)
                    }
                }
            }
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
        if currentCellExpandedIndex == indexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedCell", for: indexPath) as! PokeExpandedTableViewCell
            let pokemon = currentPokedex[indexPath.row]
            if let pokemonName = pokemon.name, let URL = pokemon.url {
                canGoToPokeDetails = false
                let isCatched = catchedPokemons.index(of: pokemonName) != nil ? true : false
                cell.setup(data: pokemon, isCatched: isCatched)
                interactor?.fetchPokemon(request: PokeListModel.FetchPokemon.Request(URL: URL, isCatched: isCatched))
            } else {
                cell.setup(data: pokemon, isCatched: false)
            }
            cell.index = indexPath
            cell.collapseDelegate = self
            if let sprite = currentPokemonSprite {
                cell.pokemonSprite.image = sprite
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedCell", for: indexPath) as! PokeCollapsedTableViewCell
            let pokemon = currentPokedex[indexPath.row]
            if let pokemonName = pokemon.name {
                cell.setup(data: pokemon, isCatched: catchedPokemons.index(of: pokemonName) != nil ? true : false)
            } else {
                cell.setup(data: pokemon, isCatched: false)
            }
            cell.index = indexPath
            cell.expandDelegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loading.isHidden = false

        if let pokemonName = currentPokedex[indexPath.row].name, let URL = currentPokedex[indexPath.row].url {
            canGoToPokeDetails = true
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

private extension PokeListViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row + 1 >= pokedex.count
    }
}

extension PokeListViewController : ExpandDelegate, CollapseDelegate {
    func didExpand(index: IndexPath?) {
        var toBeReloaded: [IndexPath] = []
        if let previouslyExpanded = currentCellExpandedIndex {
            toBeReloaded.append(previouslyExpanded)
        }
        currentCellExpandedIndex = index
        currentCellCollapsedIndex = nil
        if let indexPath = index {
            toBeReloaded.append(indexPath)
        }
        guard !toBeReloaded.isEmpty else { return }
        tableView.reloadRows(at: toBeReloaded, with: UITableView.RowAnimation.automatic)
    }
    
    func didCollapse(index: IndexPath?) {
        currentCellCollapsedIndex = index
        currentCellExpandedIndex = nil
        if let indexPath = index {
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
