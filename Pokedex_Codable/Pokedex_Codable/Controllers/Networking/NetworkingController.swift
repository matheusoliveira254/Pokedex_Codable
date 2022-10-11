//
//  NetworkingController.swift
//  Pokedex_Codable
//
//  Created by Karl Pfister on 2/7/22.
//

import Foundation
import UIKit.UIImage

class NetworkingController {
    
    private static let baseURLString = "https://pokeapi.co"
    private static let kPokemonComponent = "pokemon"
    private static let kApiComponent = "api"
    private static let kV2Component = "v2"
    
    static func fetchPokedex(completion: @escaping (Result<Pokedex, ResultError>) -> Void) {
        //create url
        guard let baseURL = URL(string: baseURLString) else {completion(.failure(.invalidURL(baseURLString))); return}
        let apiURL = baseURL.appendingPathComponent(kApiComponent)
        let v2URL = apiURL.appendingPathComponent(kV2Component)
        let finalURL = v2URL.appendingPathComponent(kPokemonComponent)
        print(finalURL)
        
        //Url Session
        URLSession.shared.dataTask(with: finalURL) { data, _, error in
            if let error {
                completion(.failure(.thrownError(error)))
            }
            guard let unwrappedData = data else {completion(.failure(.noData)); return}
            
            do {
                let pokedex = try JSONDecoder().decode(Pokedex.self, from: unwrappedData)
                completion(.success(pokedex))
            } catch {
                completion(.failure(.unableToDecode))
            }
        }.resume()
    }
    
    static func fetchPokemon(with urlString: String, completion: @escaping (Result<Pokemon, ResultError>) -> Void) {

        guard let finalURL = URL(string: urlString) else {completion(.failure(.invalidURL(urlString))); return}
        print(finalURL)

        URLSession.shared.dataTask(with: finalURL) { dTaskData, _, error in
            if let error = error {
                print("Encountered error: \(error.localizedDescription)")
                completion(.failure(.thrownError(error)))
            }

            guard let pokemonData = dTaskData else {completion(.failure(.noData)); return}

            do {
                let pokemon = try JSONDecoder().decode(Pokemon.self, from: pokemonData)
                completion(.success(pokemon))
            } catch {
                completion(.failure(.unableToDecode))
            }
        }.resume()
    }
    
    static func fetchImage(for imageString: String, completion: @escaping (Result<UIImage, ResultError>) -> Void) {
        
        guard let imageURL = URL(string: imageString) else {completion(.failure(.invalidURL(imageString))); return}
        
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            if let error = error {
                print("There was an error", error.localizedDescription)
                completion(.failure(.thrownError(error)))
            }
            guard let data = data else {completion(.failure(.noData)); return}
            
            guard let pokemonImage = UIImage(data: data) else {completion(.failure(.unableToDecode)); return}
            completion(.success(pokemonImage))
        }.resume()
    }
}// end
