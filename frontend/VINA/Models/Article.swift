//
//  Article.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import SwiftUI

struct Article: Decodable {
    
    let title: String
    let summary: String
    let url: String
    let date: String
    let category: String
    
    init(title: String, summary: String, url: String, date: String, category: String) {
        self.title = title
        self.summary = summary
        self.url = url
        self.date = date
        self.category = category
    }
}

struct ArticleViewModel: Identifiable {
    let id: UUID
    let url: String
    let title: String
    let summary: String
    let domainName: String
    let date: String
    let isBreakingNews: Bool
    
    init(article: Article, isBreakingNews: Bool = false) {
        self.id = UUID()
        self.title = article.title
        self.summary = article.summary
        self.url = article.url
        self.date = article.date
        self.isBreakingNews = isBreakingNews
        
        // check if string matches a url
        let regex = try? NSRegularExpression(pattern: "([^\\.]+)\\.[^\\.\\/]+$")
        let matches = regex?.matches(in: self.url, range: NSRange(location: 0, length: self.url.count))
        if let match = matches?.first {
            self.domainName = (self.url as NSString).substring(with: match.range)
        } else {
            self.domainName = "?"
        }
    }
    
    func getName() -> String {
        return "Entry with id \(self.id.uuidString)"
    }
}
