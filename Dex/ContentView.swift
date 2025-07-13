//
//  ContentView.swift
//  Dex
//
//  Created by masume çetin on 10.07.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor( \.id)],
        animation: .default)
    private var pokedex
    let fetcher = FetchService()
    private var dynamicPredicate : NSPredicate{
        var predicates  : [NSPredicate] = []
        // search predicate
        if !searchText.isEmpty{
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        //filter by favor predicate
        if filterByFavorites{
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        //combine predicates
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    @State private var searchText = ""
    @State private var filterByFavorites = false
    
    var body: some View {
        if pokedex.isEmpty {
            ContentUnavailableView {
                Label("No Pokemon", image: .nopokemon)
            } description: {
                Text("there aren't any pokemon.\n Fetch some pokemon to get started. ")
            } actions: {
                Button("Fetch Pokemon",systemImage: "antenna.radiowaves.left.and.right"){
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }

        }
        else{
            NavigationStack {
                List {
                    Section {
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value : pokemon) {
                                AsyncImage(url: pokemon.sprite)
                                { image in
                                    image.resizable()
                                        .scaledToFit()
                                }placeholder : {
                                    ProgressView()
                                }
                                .frame(width:100,height: 100)
                                VStack(alignment: .leading) {
                                    HStack{
                                        Text(pokemon.name!.capitalized).fontWeight(.bold)
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    HStack{
                                        ForEach(pokemon.types!, id : \.self){
                                            type in
                                            Text(type.capitalized).font(.subheadline).fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal,13)
                                                .padding(.vertical,5)
                                                .background(Color(type.capitalized))
                                                .clipShape(.capsule)
                                            
                                            
                                        }
                                    }
                                }
                            }
                        }
                    } footer :{
                        if pokedex.count < 151
                        {
                            ContentUnavailableView {
                                Label("Missing Pokemon",image : .nopokemon)
                            } description: {
                                Text("Fetch is inturrepted.\n Fetch the rest of the pokemon")
                            } actions: {
                                Button("Fetch Pokemon",systemImage: "antenna.radiowaves.left.and.right"){
                                    getPokemon(from:pokedex.count+1)
                                }
                                .buttonStyle(.borderedProminent)
                            }

                        }
                    }
                    }
                
                }
                .navigationTitle("Pokedex")
                .searchable(text: $searchText, prompt : "Find a Pokemon")
                .autocorrectionDisabled()
                .onChange(of:searchText){
                    pokedex.nsPredicate = dynamicPredicate
                }
                .onChange(of:filterByFavorites){
                    pokedex.nsPredicate = dynamicPredicate
                }
                .navigationDestination(for: Pokemon.self){
                    pokemon in
                    Text(pokemon.name ?? "")
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button{
                            filterByFavorites.toggle()
                        }
                        label : {
                            Label("Filter By Favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
    private func getPokemon(from id : Int) {
        Task{
            for _ in id..<152{
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(id)
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack;    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    try viewContext.save()
                }
                catch {
                    print(error)
                }
            }
        }
    }
    }
    
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
