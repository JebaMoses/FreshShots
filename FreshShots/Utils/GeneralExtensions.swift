//
//  GeneralExtensions.swift
//  FreshShots
//
//  Created by Jeba Moses on 17/10/22.
//

import Foundation

extension Optional where Wrapped == String {
    var isEmptyOrNil: Bool {
        guard let self else { return true }
        return self.isEmpty
    }
}
