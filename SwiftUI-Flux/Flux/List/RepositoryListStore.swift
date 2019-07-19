//
//  RepositoryListStore.swift
//  SwiftUI-Flux
//
//  Created by Yusuke Kita on 6/15/19.
//  Copyright © 2019 Yusuke Kita. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class RepositoryListStore: BindableObject {
    static let shared = RepositoryListStore()
    let willChange: AnyPublisher<Void, Never>
    private let willChangeSubject = PassthroughSubject<Void, Never>()
    
    private(set) var repositories: [Repository] = [] {
        didSet { willChangeSubject.send(()) }
    }
    var isErrorShown = false {
        didSet { willChangeSubject.send(()) }
    }
    var errorMessage = ""
    private(set) var shouldShowIcon = false {
        didSet { willChangeSubject.send(()) }
    }
    
    init(dispatcher: RepositoryListDispatcher = .shared) {
        willChange = willChangeSubject.eraseToAnyPublisher()
        
        dispatcher.register { [weak self] (action) in
            guard let strongSelf = self else { return }
            
            switch action {
            case .updateRepositories(let repositories): strongSelf.repositories = repositories
            case .updateErrorMessage(let message): strongSelf.errorMessage = message
            case .showError: strongSelf.isErrorShown = true
            case .showIcon: break
            }
        }
    }
}
