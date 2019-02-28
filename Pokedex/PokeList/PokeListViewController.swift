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
        
        for catchedPokemon in CatchedPokemon.all {
            if let pokemonName = catchedPokemon.name {
                catchedPokemons.append(pokemonName)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.getCatchedPokemon(request: PokeListModel.GetCatchedPokemon.Request())
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    private(set) var pokedex: [Pokemon] = [] {
        didSet {
            currentPokedex = pokedex
        }
    }
    var currentPokedex: [Pokemon] = []
//    private(set) var catchedPokemons = CatchedPokemons.array
    private(set) var catchedPokemons: [String] = []
    private(set) var nextPokemonURL: String?
    var currentCellExpandedIndex: IndexPath?
    var currentCellCollapsedIndex: IndexPath?
    var canGoToPokeDetails = false
    private var currentPokemon: PokemonDetails?
    private(set) var currentPokemonSprite: UIImage?
    
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
//            CatchedPokemons.array = catchedPokemons
            saveCatchedPokemon(named: viewModel.catchedPokemon)
            tableView.reloadData()
        }
    }
    
    func saveCatchedPokemon(named name: String) {
        let catchedPokemon = CatchedPokemon(context: AppDelegate.viewContext)
        catchedPokemon.name = name
        try? AppDelegate.viewContext.save()
    }
}
