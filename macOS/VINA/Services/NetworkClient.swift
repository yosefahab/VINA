//
//  Client.swift
//  VINA
//
//  Created by Youssef Ahab on 18/01/2023.
//

import Foundation

enum NetworkError: Error {
  case invalidResponse
  case notFound
  case noResponse
  case noMoreData
}

enum DataError: Error {
  case invalidData
}

class NetworkClient {
  // singleton

  private init() {}

  /// fetch news from the designated server
  /// - Parameter url: The URL to make the request to
  /// - Returns: data as an Article
  static func getNews(url: URL) async throws -> [Article] {

    let (data, response) = try await URLSession.shared.data(from: url)
    let httpResponse = response as! HTTPURLResponse

    switch httpResponse.statusCode {
    case 200: break
    case 404: throw NetworkError.notFound
    default: throw NetworkError.invalidResponse
    }

    guard let articles = try? JSONDecoder().decode([Article].self, from: data)
    else {
      throw DataError.invalidData
    }

    if articles.isEmpty {
      throw NetworkError.noMoreData
    }
    return articles
  }
}
