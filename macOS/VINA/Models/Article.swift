//
//  Article.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import SwiftUI
import os

struct Article: Decodable {
  let id: String
  let title: String
  let summary: String
  let url: String
  let date: String
  let category: String
}

struct ArticleViewModel: Identifiable {
  let id: String
  let url: String
  let title: String
  let summary: String
  let domainName: String
  let date: String
  let isBreakingNews: Bool

  static private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: ArticleViewModel.self)
  )

  init(article: Article, isBreakingNews: Bool = false) {
    self.id = article.id
    self.title = article.title
    self.summary = article.summary
    self.url = article.url
    self.date = article.date
    self.isBreakingNews = isBreakingNews

    if let host = URL(string: article.url)?.host(percentEncoded: false) {
      Self.logger.info("\(host)")
      let components = host.split(separator: ".").map(String.init)
      if components.count >= 2 {
        self.domainName = components[components.count - 2]
      } else {
        self.domainName = host
      }
    } else {
      self.domainName = "?"
      Self.logger.log("Failed to parse domain name from url: \(article.url)")
    }
  }

  func getName() -> String {
    return "ID: \(self.id)"
  }
}
