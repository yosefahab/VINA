//
//  Article.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import SwiftUI

struct Article: Decodable {
    let id: String
    let title: String
    let summary: String
    let url: String
    let date: String
    let category: String
    
    init(id: String, title: String, summary: String, url: String, date: String, category: String) {
        self.id = id
        self.title = title
        self.summary = summary
        self.url = url
        self.date = date
        self.category = category
    }
}

struct ArticleViewModel: Identifiable {
    let id: String
    let url: String
    let title: String
    let summary: String
    let domainName: String
    let date: String
    let isBreakingNews: Bool
    
    init(article: Article, isBreakingNews: Bool = false) {
        self.id = article.id
        self.title = article.title
        self.summary = article.summary
        self.url = article.url
        self.date = article.date
        self.isBreakingNews = isBreakingNews
        
        // extract the domain name from the url by checking the substring before the ".com" part
        if let match = self.url.range(of: "(?<=\\.)([^./]+)(?=\\.com)", options: .regularExpression) {
            self.domainName = String(self.url[match])
        } else {
            self.domainName = "?"
        }
    }
    
    func getName() -> String {
        return "Entry with id \(self.id)"
    }
}
