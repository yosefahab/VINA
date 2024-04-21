//
//  ArticleView.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import Foundation
import SwiftUI

struct ArticleView: View {
    let article: ArticleViewModel
    @State private var isHovered: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            if (article.isBreakingNews) {
                Text("BREAKING NEWS")
                    .font(.title)
                    .bold()
            }
            Text(article.title)
                .font(.title)
                .fontWeight(.semibold)
                .padding(article.isBreakingNews ? .bottom : .vertical)
            
            Text(article.summary)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding(.bottom)
            
            HStack {
                articleSource
                Spacer()
                articleDate
            }
            .font(.footnote)
            .padding(.bottom, 5)
        }
        .foregroundColor(article.isBreakingNews ? .red : .white)
        .padding(.horizontal)
    }
    
    private var articleDate: some View {
        HStack {
            Text("Date:")
            Text(article.date)
        }
        .font(.footnote)
    }
    private var articleSource: some View {
        HStack {
            Text("Source:")
            Link(article.domainName, destination: URL(string: article.url)!)
                .underline()
                .foregroundColor(.blue)
                .onHover { isHovered in
                    self.isHovered = isHovered
                    DispatchQueue.main.async {
                        if (self.isHovered) {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
        }
        .font(.footnote)
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        let randomIndex = Int.random(in: 0..<ArticleStore.sampleData.count)
        VStack {
            ArticleView(article: ArticleViewModel(article: ArticleStore.sampleData[randomIndex], isBreakingNews: false))
            Divider()
            ArticleView(article: ArticleViewModel(article: ArticleStore.sampleData[randomIndex], isBreakingNews: true))
        }
    }
}
