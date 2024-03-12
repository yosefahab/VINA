//
//  NewsSheetView.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import Foundation
import SwiftUI

struct NewsSheetView: View {
    @EnvironmentObject private var viewModel: ArticleStore
    
    @AppStorage(StorageStrings.AUTO_SCROLL) var autoScroll: Bool = true
    
    @State private var backgroundColor: Color = .blue
    
    var body: some View {
        VStack(alignment: .center) {
            header
            newsList
            if viewModel.newsBuffer.isEmpty {
                ProgressView("Fetching News...")
                    .progressViewStyle(.circular)
                    .padding(.vertical)
            }
        }
        .background(Background())
        .onAppear{viewModel.startFetching()}
        
    }
    private var newsList: some View {
        // FIXME: vibration behavior when scrolling
        // TODO: add narration functionality
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ForEach(viewModel.newsBuffer.reversed(), id: \.id) { article in
                        ArticleView(article: article).id(article.id)
                        Divider()
                    }
                }
            }
            .onChange(of: viewModel.newsBuffer.count) { () in
                if autoScroll == false { return }
                withAnimation {
                    scrollProxy.scrollTo(viewModel.newsBuffer.last?.id, anchor: .top)
                }
            }
        }
    }
    private var header: some View {
        VStack {
            Text("Latest News")
                .padding()
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Divider()
                .padding([.leading,.trailing], 50)
                .padding(.bottom)
        }
    }
}

struct NewsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NewsSheetView().environmentObject(ArticleStore())
    }
}
