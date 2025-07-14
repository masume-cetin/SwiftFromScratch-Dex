//
//  Persistence.swift
//  Dex
//
//  Created by masume çetin on 10.07.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var previewPokemon : Pokemon {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let result = try! context.fetch(fetchRequest)
        return result.first!
    }
    

    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
            let newPokemon = Pokemon(context: viewContext)
        newPokemon.id = 6
        newPokemon.name = "Charizard"
        newPokemon.hp = 78
        newPokemon.attack = 84
        newPokemon.defense = 78
        newPokemon.specialAttack = 109
        newPokemon.specialDefense = 85
        newPokemon.speed = 100
        newPokemon.types = ["Flying","Fire"]
        newPokemon.sprite = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png")
        newPokemon.shiny = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/6.png")
       
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            
                print(error)
            }
        })
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
