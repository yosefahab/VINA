//
//  ArticleStore.swift
//  VINA
//
//  Created by Youssef Ahab on 29/01/2024.
//

import Foundation
import SwiftUI
import os

@MainActor
/// The ViewModel, used to control the data to be represented
class ArticleStore: ObservableObject {
  static private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: String(describing: ArticleStore.self)
  )
  static private let SERVER_URL: String = "http://127.0.0.1:8080"

  // How many articles to fetch per request
  static private let ARTICLE_FETCH_COUNT: Int = 2
  // TODO: implement custom categories
  static private let ARTICLES_URL: String =
    SERVER_URL + "/articles/science?limit=\(ARTICLE_FETCH_COUNT)"
  static private let BREAKING_NEWS_URL: String =
    SERVER_URL + "/breaking_news/science?limit=\(ARTICLE_FETCH_COUNT)"

  // frequencies to fetch and append news
  static private let APPEND_FREQ_SECS: Double = 5
  static private let FETCH_FREQ_SECS: Double =
    APPEND_FREQ_SECS * Double(ARTICLE_FETCH_COUNT)

  @Published
  var newsBuffer: [ArticleViewModel] = []

  @AppStorage(StorageStrings.HISTORY_SIZE)
  var BUFFER_CAPACITY: Int = Constants.DEFAULT_BUFFER_CAPACITY

  static public var sampleData: [Article] {
    var samples: [Article] = []
    for i in 1...10 {
      samples.append(
        Article(
          id: String(i),
          title: "Some Title For Article\(i)",
          summary: String(
            repeating: "Some Summary for Article\(i).",
            count: 2 * i
          ),
          url: "https://www.news.google.com",
          date: "08-07-2022",
          category: "science"
        )
      )
    }
    assert(ArticleViewModel(article: (samples.first)!).domainName == "google")
    return samples
  }

  public func startFetching() {
    Timer.scheduledTimer(withTimeInterval: Self.FETCH_FREQ_SECS, repeats: true)
    { timer in
      Task {
        //        #if DEBUG
        //        await self.appendRandomArticles()
        //        #else
        await self.fetchNews()
        //        #endif
      }
    }.fire()
  }

  private func fetchNews(isBreakingNews: Bool = false) async {
    do {
      var url: String
      if isBreakingNews {
        url = Self.BREAKING_NEWS_URL
      } else {
        url = Self.ARTICLES_URL
        if let lastArticle = self.newsBuffer.last {
          url += "&offset=\(lastArticle.id)"
        }
      }
      let articles = try await NetworkClient.getNews(url: URL(string: url)!)
      let newsBatch = articles.map {
        ArticleViewModel(article: $0, isBreakingNews: isBreakingNews)
      }
      self.appendNews(articles: newsBatch)
    } catch {
      Self.logger.error("\(error.localizedDescription)")
    }
  }

  private func appendNews(articles: [ArticleViewModel]) {
    for (i, article) in articles.enumerated() {
      DispatchQueue.main.asyncAfter(
        deadline: .now() + 3.0 + (ArticleStore.APPEND_FREQ_SECS * Double(i)),
        execute: {
          if self.newsBuffer.count >= self.BUFFER_CAPACITY {
            self.newsBuffer.removeFirst()
          }
          self.newsBuffer.append(article)
        }
      )
    }
  }

  // MARK: For offline testing
  private func appendRandomArticles() {
    var articles: [ArticleViewModel] = []
    for _ in 0...Self.ARTICLE_FETCH_COUNT {
      let randomIndex = Int.random(in: 0..<ArticleStore.sampleData.count)
      let randomArticle = ArticleStore.sampleData[randomIndex]
      articles.append(
        ArticleViewModel(article: randomArticle, isBreakingNews: Bool.random())
      )
    }
    self.appendNews(articles: articles)
  }
}
