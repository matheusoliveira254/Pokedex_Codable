//
//  PokedexTableViewController.swift
//  Pokedex_Codable
//
//  Created by Karl Pfister on 2/7/22.
//

import UIKit

class PokedexTableViewController: UITableViewController {
    
    var pokedex: Pokedex?
    var pokedexResults: [PokemonResults] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkingController.fetchPokedex(with: URL(string: "https://pokeapi.co/api/v2/pokemon")!) { [weak self] result in
            switch result {
            case .success(let pokedex):
                self?.pokedex = pokedex
                self?.pokedexResults = pokedex.results
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("There was an error!", error.errorDescription!)
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pokedexResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath) as? PokemonTableViewCell else {return UITableViewCell()}
        let pokemonURLString = pokedexResults[indexPath.row].url
        cell.updateViews(pokemonURlString: pokemonURLString)
        return cell
    }
    
    //Pagination
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastPokedexIndex = pokedexResults.count - 1
        guard let pokedex = pokedex, let nextURL = URL(string: pokedex.next) else {return}
        
        if indexPath.row == lastPokedexIndex {
            NetworkingController.fetchPokedex(with: nextURL) { [weak self] result in
                switch result {
                case .success(let pokedex):
                    self?.pokedex = pokedex
                    self?.pokedexResults.append(contentsOf: pokedex.results)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print("There was an error!", error.errorDescription!)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard segue.identifier == "toDetailVC",
              let destinationVC = segue.destination as? PokemonViewController,
              let indexPath = tableView.indexPathForSelectedRow else {return}
        
        let pokemonToSend = pokedexResults[indexPath.row]
        NetworkingController.fetchPokemon(with: pokemonToSend.url) {result in
            switch result {
            case .success(let pokemon):
                DispatchQueue.main.async {
                    destinationVC.pokemon = pokemon
                }
            case .failure(let error):
                print("There was an error!", error.errorDescription!)
            }
        }
    }
}

