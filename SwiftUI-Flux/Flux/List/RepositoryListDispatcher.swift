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
    private var cancellables: [AnyCancellable] = []

    func register(callback: @escaping (RepositoryListAction) -> ()) {
        let actionStream = actionSubject.sink(receiveValue: callback)
        cancellables += [actionStream]
    }
    
    func dispatch(_ action: RepositoryListAction) {
        actionSubject.send(action)
    }
}
