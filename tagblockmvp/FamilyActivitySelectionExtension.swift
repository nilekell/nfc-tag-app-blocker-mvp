//
//  FamilyActivitySelectionExtension.swift
//  tagblockmvp
//
//  Created by Nile Kelly on 03/02/2024.
//

import Foundation
import FamilyControls

extension FamilyActivitySelection {
    func jsonString() -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Error encoding FamilyActivitySelection")
                return nil
            }
            return jsonString
        } catch {
            print("Error encoding FamilyActivitySelection: \(error)")
            return nil
        }
    }
    
    static func from(jsonString: String) -> FamilyActivitySelection? {
        guard let data = jsonString.data(using: .utf8) else {
            print("Error converting string to Data")
            return nil
        }
        
        let decoder = JSONDecoder()
        do {
            let familyActivitySelection = try decoder.decode(FamilyActivitySelection.self, from: data)
            return familyActivitySelection
        } catch {
            print("Error decoding FamilyActivitySelection: \(error)")
            return nil
        }
    }
}

