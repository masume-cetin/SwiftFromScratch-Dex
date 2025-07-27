//
//  FetchService.swift
//  Dex
//
//  Created by masume çetin on 12.07.2025.
//

import Foundation

struct FetchService {
    enum FetchError: Error {
        case badResponse
    }
    private let baseUrl = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    
    func fetchPokemon (_ id : Int) async throws -> Pokemon {
        let fetchUrl = baseUrl.appending(path: String(id))
        let (data,response) = try await URLSession.shared.data(from: fetchUrl)
        guard let response = response as? HTTPURLResponse , response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        print("Fetched Pokemon : \(pokemon.id) : \(pokemon.name.capitalized)'")
        return pokemon
    }
}
