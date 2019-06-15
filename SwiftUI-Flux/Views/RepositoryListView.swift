//
//  ContentView.swift
//  SwiftUI-MVVM
//
//  Created by Yusuke Kita on 6/5/19.
//  Copyright © 2019 Yusuke Kita. All rights reserved.
//

import SwiftUI

struct RepositoryListView : View {
    @ObjectBinding var store: RepositoryListStore = .shared
    private var actionCreator: RepositoryListActionCreator
    
    init(actionCreator: RepositoryListActionCreator = .init()) {
        self.actionCreator = actionCreator
    }
    
    var body: some View {
        NavigationView {
            List(store.repositories) { repository in
                RepositoryListRow(repository: repository)
            }
            .presentation($store.isErrorShown) { () -> Alert in
                Alert(title: Text("Error"), message: Text(store.errorMessage))
            }
            .navigationBarTitle(Text("Repositories"))
        }
        .onAppear(perform: { self.actionCreator.onAppear() })
    }
}

#if DEBUG
struct RepositoryListView_Previews : PreviewProvider {
    static var previews: some View {
        RepositoryListView()
    }
}
#endif
