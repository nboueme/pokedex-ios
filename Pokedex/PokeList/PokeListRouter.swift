//
//  PokeListRouter.swift
//  Pokedex
//
//  Created by Nicolas BOUÈME on 22/01/2019.
//  Copyright (c) 2019 Nicolas BOUÈME. All rights reserved.
//

import UIKit

@objc protocol PokeListRoutingLogic {
    func routeToPokeDetails(segue: UIStoryboardSegue?)
}

protocol PokeListDataPassing {
    var dataStore: PokeListDataStore? { get }
}

class PokeListRouter: NSObject, PokeListRoutingLogic, PokeListDataPassing {
    weak var viewController: PokeListViewController?
    var dataStore: PokeListDataStore?
    
    func routeToPokeDetails(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! PokeDetailsViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToPokeDetails(source: dataStore!, destination: &destinationDS)
        } else {
            let storyboard = UIStoryboard(name: "PokeDetails", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "PokeDetailsViewController") as! PokeDetailsViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToPokeDetails(source: dataStore!, destination: &destinationDS)
            navigateToPokeDetails(source: viewController!, destination: destinationVC)
        }
    }
    
    func navigateToPokeDetails(source: PokeListViewController, destination: PokeDetailsViewController) {
        source.show(destination, sender: nil)
    }
    
    func passDataToPokeDetails(source: PokeListDataStore, destination: inout PokeDetailsDataStore) {
        destination.pokemon = source.pokemon
    }
}
