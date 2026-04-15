//
//  Types.swift
//  CSH Drink
//
//  Created by Campbell on 10/3/25.
//

import Foundation

// Parse a single drink machine and all of its items.
struct DrinkMachine: Decodable, Hashable {
    // A possible item sold by a machine.
    struct Slot: Decodable, Hashable {
        // An individual item in a lot in a machine.
        struct Item: Decodable, Hashable {
            let id: Int
            let name: String
            let price: Int
        }
        let active: Bool
        let count: Int?
        let empty: Bool
        let item: Item
        let machine: Int
        let number: Int
    }
    let id: Int
    let display_name: String
    let is_online: Bool
    let name: String
    let slots: [Slot]
}

// Struct that probably doesn't need to exist but this made parsing the list of drink machines easy.
struct DrinkMachinesParser: Decodable {
    let machines: [DrinkMachine]
}

// Struct that represents the reponse from checking a user's drink credits.
struct CreditsReponse: Decodable, Hashable {
    struct User: Decodable, Hashable {
        let cn: String
        let drinkBalance: String
        let uid: String
    }
    let message: String
    let user: User
}

// Struct that represents a selected item used when making a request to drop it.
struct SelectedItem: Codable, Hashable {
    let machine: String
    let slot: Int
    let cost: Int
}

// Struct that represents the response sent back after a drop finished.
struct DropResponse: Decodable, Hashable {
    let message: String
    let drinkBalance: Int?
}
