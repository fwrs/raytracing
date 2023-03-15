//
//  Utils.swift
//  raytracing
//
//  Created by Ilya Kulinkovich on 15/3/23.
//

import Foundation

extension Optional {
    func expect(orFailWith errorMessage: String = .init()) -> Wrapped {
        guard let self else { fatalError(errorMessage) }
        return self
    }
}
