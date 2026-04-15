//
//  Requests.swift
//  CSH Drink
//
//  Created by Campbell on 10/3/25.
//

import Foundation

enum InvalidHTTPError: Error {
    case invalid
}

func getDrinks(authToken: String) async -> Result<DrinkMachinesParser, Error> {
    let urlString = "https://drink.csh.rit.edu/drinks"
    
    guard let url = URL(string: urlString) else {
        return .failure(URLError(.badURL))
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return .failure(InvalidHTTPError.invalid)
        }
        
        let decoded = try JSONDecoder().decode(DrinkMachinesParser.self, from: data)
        return .success(decoded)
    } catch {
        return .failure(error)
    }
}
