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
    @FetchRequest<Pokemon>(
        sortDescriptors: [])
    private var all
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
        if all.isEmpty {
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
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL)
                                    { image in
                                        image.resizable()
                                            .scaledToFit()
                                    }placeholder : {
                                        ProgressView()
                                    }
                                    .frame(width:100,height: 100)
                                } else {
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100,height: 100)
                                }
                                
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
                            .swipeActions(edge:.leading) {
                                Button(pokemon.favorite ? "Remove From Favorites" : "Add To Favorites",systemImage : "star")
                                {
                                    pokemon.favorite.toggle()
                                    do {
                                        try viewContext.save()
                                    }
                                    catch{
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer :{
                        if all.count < 151
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
                    PokemonDetail()
                        .environmentObject(pokemon)
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
        }
    private func getPokemon(from id : Int) {
        Task{
            for i in id..<152{
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack;    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.spriteURL = fetchedPokemon.spriteURL
                    pokemon.shinyURL = fetchedPokemon.shinyURL
                
                    
                    try viewContext.save()
                }
                catch {
                    print(error)
                }
            }
            storeSprites()
        }
    }
    private func storeSprites() {
        Task{
            do{
                for pokemon in all {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    
                    try viewContext.save()
                    
                    print("Sprites stored : \(pokemon.id) : \(pokemon.name!.capitalized)")
                }
            } catch{
                print(error)
            }
        }
    }
    }
    
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
