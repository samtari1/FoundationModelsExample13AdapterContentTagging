//
//  ContentView.swift
//  FoundationModelsExample13AdapterContentTagging
//
//  Created by Quanpeng Yang on 3/5/26.
//

import SwiftUI
import FoundationModels
import Observation

// MARK: - Application Data using contentTagging
@Observable
class ApplicationData {
    var response: AttributedString = ""
    var prompt: String = ""
    
    @ObservationIgnored var model: SystemLanguageModel
    @ObservationIgnored var session: LanguageModelSession
    
    static let shared: ApplicationData = ApplicationData()
    
    private init() {
        // Initialize the contentTagging foundation model
        model = SystemLanguageModel(useCase: .contentTagging)
        session = LanguageModelSession(model: model)
    }
    
    func sendPrompt() async {
        guard !prompt.isEmpty else { return }
        let currentPrompt = prompt
        
        do {
            // Get model response for the prompt
            let answer = try await session.respond(to: currentPrompt)
            
            // Format the output to include the prompt
            var newResponse = AttributedString("Prompt: \(currentPrompt)\n")
            newResponse.font = .system(size: 16, weight: .bold)
            
            var responseContent = AttributedString("Response: \(answer.content)\n\n")
            responseContent.font = .system(size: 16, weight: .regular)
            
            newResponse.append(responseContent)
            
            response.append(newResponse)
        } catch {
            response = AttributedString("Error accessing the model: \(error)")
        }
        
        prompt = ""
    }
}

// MARK: - SwiftUI View
struct ContentView: View {
    @State private var appData = ApplicationData.shared
    
    var body: some View {
        VStack {
            ScrollView {
                Text(appData.response)
                    .padding()
                    .textSelection(.enabled)
            }
            .frame(minHeight: 300)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack {
                TextField("Enter prompt", text: $appData.prompt)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send") {
                    Task {
                        await appData.sendPrompt()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
    }
}

