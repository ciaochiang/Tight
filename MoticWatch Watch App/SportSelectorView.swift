//
//  SportSelectorView.swift
//  MoticWatch Watch App
//
//  Created by Ciao Chiang on 2023/10/17.
//

import SwiftUI

struct SportSelectorView: View {
    @StateObject var viewModel: SportSelectorViewModel
    
    init(viewModel: SportSelectorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SportSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        let depenedency = SportSelectorViewModelDependencyImp(logger: Logger.init(configuration: AppConfiguration.loggerConfig))
        let viewModel = SportSelectorViewModel(dependency: depenedency)
        SportSelectorView(viewModel: viewModel)
    }
}
