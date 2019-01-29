//
//  PokeDetailsViewController.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

protocol PokeDetailsDisplayLogic: class {
    func displayPokemon(viewModel: PokeDetailsModel.GetPokemon.ViewModel)
    func successFetchedSprite(viewModel: PokeDetailsModel.FetchSprite.ViewModel)
    func errorFetchingSprite(viewModel: PokeDetailsModel.FetchSprite.ViewModel)
}

class PokeDetailsViewController: UIViewController, PokeDetailsDisplayLogic {
    var interactor: PokeDetailsBusinessLogic?
    var router: (NSObjectProtocol & PokeDetailsRoutingLogic & PokeDetailsDataPassing)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        print("PokeDetailsViewController: deinit")
    }
    
    private func setup() {
        let viewController = self
        let interactor = PokeDetailsInteractor()
        let presenter = PokeDetailsPresenter()
        let router = PokeDetailsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor?.getPokemon(request: PokeDetailsModel.GetPokemon.Request())
    }
    
    @IBOutlet weak var sprite: UIImageView!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var baseExperience: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var catchButton: UIButton!
    
    var pokemon = PokemonDetails()
    var catched: Bool = false
    
    func displayPokemon(viewModel: PokeDetailsModel.GetPokemon.ViewModel) {
        pokemon = viewModel.pokemon
        getDetails()
        isCatched()
    }
    
    func getDetails() {
        title = pokemon.name
        
        sprite.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        sprite.layer.borderWidth = 8
        sprite.layer.cornerRadius = 6.0
        interactor?.fetchSprite(request: PokeDetailsModel.FetchSprite.Request(URL: pokemon.sprites?.front_default))
        
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
    
    func successFetchedSprite(viewModel: PokeDetailsModel.FetchSprite.ViewModel) {
        loading.isHidden = true
        sprite.image = viewModel.sprite
    }
    
    func errorFetchingSprite(viewModel: PokeDetailsModel.FetchSprite.ViewModel) {
        print(viewModel.message!)
    }
    
    @IBAction func catchAction(_ sender: UIButton) {
        if !catched, pokemon.name != nil {
            router?.routeToPokeList(segue: nil)
        }
    }
}
