//
//  RepositoryListActionCreator.swift
//  SwiftUI-Flux
//
//  Created by Yusuke Kita on 6/15/19.
//  Copyright © 2019 Yusuke Kita. All rights reserved.
//

import Foundation
import Combine

final class RepositoryListActionCreator {
    private let dispatcher: RepositoryListDispatcher
    private let apiService: APIServiceType
    private let trackerService: TrackerType
    private let experimentService: ExperimentServiceType
    private let onAppearSubject = PassthroughSubject<Void, Never>()
    private let responseSubject = PassthroughSubject<SearchRepositoryResponse, Never>()
    private let errorSubject = PassthroughSubject<APIServiceError, Never>()
    private let trackingSubject = PassthroughSubject<TrackEventType, Never>()
    private var cancellables: [AnyCancellable] = []

    init(dispatcher: RepositoryListDispatcher = .shared,
         apiService: APIServiceType = APIService(),
         trackerService: TrackerType = TrackerService(),
         experimentService: ExperimentServiceType = ExperimentService()) {
        self.dispatcher = dispatcher
        self.apiService = apiService
        self.trackerService = trackerService
        self.experimentService = experimentService
        
        bindData()
        bindActions()
    }
    
    func bindData() {
        let request = SearchRepositoryRequest()
        let responsePublisher = onAppearSubject
            .flatMap { [apiService] _ in
                apiService.response(from: request)
                    .catch { [weak self] error -> Publishers.Empty<SearchRepositoryResponse, Never> in
                        self?.errorSubject.send(error)
                        return .init()
                }
        }
        
        let responseStream = responsePublisher
            .share()
            .subscribe(responseSubject)
        
        _ = trackingSubject
            .sink(receiveValue: trackerService.log)
        
        let trackingStream = onAppearSubject
            .map { .listView }
            .subscribe(trackingSubject)
        
        cancellables += [
            responseStream,
            trackingStream
        ]
    }
    
    func bindActions() {
        _ = responseSubject
            .map { $0.items }
            .sink(receiveValue: { [dispatcher] in dispatcher.dispatch(.updateRepositories($0)) })
        
        _ = errorSubject
            .map { error -> String in
                switch error {
                case .responseError: return "network error"
                case .parseError: return "parse error"
                }
            }
            .sink(receiveValue: { [dispatcher] in dispatcher.dispatch(.updateErrorMessage($0)) })
        
        _ = errorSubject
            .map { _ in }
            .sink(receiveValue: { [dispatcher] in dispatcher.dispatch(.showError) })
        
        _ = onAppearSubject
            .filter { [experimentService] _ in
                experimentService.experiment(for: .showIcon)
            }
            .sink(receiveValue: { [dispatcher] in dispatcher.dispatch(.showIcon) })
    }
    
    func onAppear() {
        onAppearSubject.send(())
    }
}