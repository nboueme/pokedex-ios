//
//  PokeDetailsRouter.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 28/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

@objc protocol PokeDetailsRoutingLogic {
    func routeToPokeList(segue: UIStoryboardSegue?)
}

protocol PokeDetailsDataPassing {
    var dataStore: PokeDetailsDataStore? { get }
}

class PokeDetailsRouter: NSObject, PokeDetailsRoutingLogic, PokeDetailsDataPassing {
    weak var viewController: PokeDetailsViewController?
    var dataStore: PokeDetailsDataStore?
    
    func routeToPokeList(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! PokeListViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToPokeList(source: dataStore!, destination: &destinationDS)
        } else {
            let index = viewController!.navigationController!.viewControllers.count - 2
            let destinationVC = viewController?.navigationController?.viewControllers[index] as! PokeListViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToPokeList(source: dataStore!, destination: &destinationDS)
            navigateToPokeList(source: viewController!, destination: destinationVC)
        }
    }
    
    func navigateToPokeList(source: PokeDetailsViewController, destination: PokeListViewController) {
        source.navigationController?.popViewController(animated: true)
    }
    
    func passDataToPokeList(source: PokeDetailsDataStore, destination: inout PokeListDataStore) {
        destination.catchedPokemon = source.pokemon?.name
    }
}
