//
//  RepositoryListActionCreatorTests.swift
//  SwiftUI-FluxTests
//
//  Created by Yusuke Kita on 6/15/19.
//  Copyright © 2019 Yusuke Kita. All rights reserved.
//

import Foundation
import Combine
import XCTest
@testable import SwiftUI_Flux

final class RepositoryListActionCreatorTests: XCTestCase {
    private let dispatcher: RepositoryListDispatcher = .shared
    
    func test_updateRepositoriesWhenOnAppear() {
        let apiService = MockAPIService()
        apiService.stub(for: SearchRepositoryRequest.self) { _ in
            Publishers.Once<SearchRepositoryResponse, APIServiceError>(
                SearchRepositoryResponse(
                    items: [.init(id: 1, fullName: "foo", owner: .init(id: 2, login: "bar", avatarUrl: URL(string: "baz")!))]
                )
            )
            .eraseToAnyPublisher()
        }
        let actionCreator = makeActionCreator(apiService: apiService)
        var repositories: [Repository] = []
        dispatcher.register { (action) in
            switch action {
            case .updateRepositories(let value): repositories.append(contentsOf: value)
            default: break
            }
        }
        
        actionCreator.onAppear()
        XCTAssertTrue(!repositories.isEmpty)
    }
    
    func test_serviceErrorWhenOnAppear() {
        let apiService = MockAPIService()
        apiService.stub(for: SearchRepositoryRequest.self) { _ in
            Publishers.Once<SearchRepositoryResponse, APIServiceError>(
                APIServiceError.responseError
            ).eraseToAnyPublisher()
        }
        let actionCreator = makeActionCreator(apiService: apiService)
        let expectation = self.expectation(description: "error")
        var errorShown = false
        dispatcher.register { (action) in
            switch action {
            case .showError:
                errorShown = true
                XCTAssertTrue(errorShown)
                expectation.fulfill()
            default: break
            }
        }
        
        actionCreator.onAppear()
        wait(for: [expectation], timeout: 3.0)
    }
    
    func test_logListViewWhenOnAppear() {
        let trackerService = MockTrackerService()
        let actionCreator = makeActionCreator(trackerService: trackerService)
        
        actionCreator.onAppear()
        XCTAssertTrue(trackerService.loggedTypes.contains(.listView))
    }
    
    func test_showIconEnabledWhenOnAppear() {
        let experimentService = MockExperimentService()
        experimentService.stubs[.showIcon] = true
        let actionCreator = makeActionCreator(experimentService: experimentService)
        var iconShown = false
        dispatcher.register { (action) in
            switch action {
            case .showIcon: iconShown = true
            default: break
            }
        }
        
        actionCreator.onAppear()
        XCTAssertTrue(iconShown)
    }
    
    func test_showIconDisabledWhenOnAppear() {
        let experimentService = MockExperimentService()
        experimentService.stubs[.showIcon] = false
        let actionCreator = makeActionCreator(experimentService: experimentService)
        var iconShown = false
        dispatcher.register { (action) in
            switch action {
            case .showError: iconShown = true
            default: break
            }
        }
        
        actionCreator.onAppear()
        XCTAssertFalse(iconShown)
    }
    
    private func makeActionCreator(
        apiService: APIServiceType = MockAPIService(),
        trackerService: TrackerType = MockTrackerService(),
        experimentService: ExperimentServiceType = MockExperimentService()
        ) -> RepositoryListActionCreator {
        return .init(
            dispatcher: dispatcher,
            apiService: apiService,
            trackerService: trackerService,
            experimentService: experimentService
        )
    }
}
