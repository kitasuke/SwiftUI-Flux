//
//  RepositoryListDispatcher.swift
//  SwiftUI-Flux
//
//  Created by Yusuke Kita on 6/15/19.
//  Copyright © 2019 Yusuke Kita. All rights reserved.
//

import Foundation
import Combine

final class RepositoryListDispatcher {
    static let shared = RepositoryListDispatcher()
    
    private let actionSubject = PassthroughSubject<RepositoryListAction, Never>()
    
    func register(callback: @escaping (RepositoryListAction) -> ()) {
        _ = actionSubject.sink(receiveValue: callback)
    }
    
    func dispatch(_ action: RepositoryListAction) {
        actionSubject.send(action)
    }
}
