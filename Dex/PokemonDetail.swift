//
//  PokemonDetail.swift
//  Dex
//
//  Created by masume çetin on 14.07.2025.
//

import SwiftUI

struct PokemonDetail: View {
    @Environment(\.modelContext) private var modelContext
    var pokemon : Pokemon
    @State private var showShiny: Bool = false
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color : .black ,radius: 6)
                if pokemon.sprite == nil || pokemon.shiny == nil {
                    AsyncImage(url:showShiny ? pokemon.shinyURL : pokemon.spriteURL){
                        image in
                        image
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(.top,50)
                            .shadow(color:.black ,radius: 6)
                    }
                    placeholder : {
                        ProgressView()
                    }
                } else {
                    (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(.top,50)
                        .shadow(color:.black ,radius: 6)
                }
                
            }
            
            HStack{
                ForEach(pokemon.types,id:\.self){
                    type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color : .white,radius: 1)
                        .padding(.vertical,7)
                        .padding(.horizontal)
                        .background(Color(type.capitalized))
                        .clipShape(.capsule)
                  
                }
                Spacer()
                
                Button{
                    pokemon.favorite.toggle()
                    do{
                        try modelContext.save()
                    }
                    catch {
                        print(error)
                    }
                }label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .font(.largeTitle)
                        .tint(.yellow)
                }
            }
            .padding()
            Text("Stats")
                .font(.title)
                .padding(.bottom,-5)
            Stats(pokemon: pokemon)
        }
        .navigationTitle(pokemon.name.capitalized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button{
                    showShiny.toggle()
                }
                label : {
                    Label("Filter By Favorites", systemImage: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                }
                .tint(showShiny ? .yellow : .primary)
            }
        }
    }
}

#Preview {
    NavigationStack{
        PokemonDetail(pokemon : PersistenceController.previewPokemon)
    }
}
