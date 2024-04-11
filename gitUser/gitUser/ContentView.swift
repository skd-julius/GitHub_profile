//
//  ContentView.swift
//  gitUser
//
//  Created by Skd Julius on 4/10/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
        
            Text(user?.name ?? "Login Placeholder")
                .bold()
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            
            Text(user?.bio ?? "Bio placeholder")
                .padding()
            Spacer()
        }
        .padding()
        
        .task {
            do {
                user = try await getUser()
            } catch loginError.noURL {
                print("invalid url")
            } catch loginError.invalidResponse {
                print("invalid response")
            } catch loginError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }

    func getUser () async throws -> GitHubUser {
        let url = "https://api.github.com/users/skd-julius"
        guard let urlReqest = URL(string: url) else {
            throw loginError.noURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: urlReqest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw loginError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw loginError.invalidData
        }
    }  
}

struct GitHubUser: Codable {
    var name: String
    var avatarUrl: String
    var bio: String
}

enum loginError: Error {
    case networkError
    case noURL
    case invalidResponse
    case invalidData
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

