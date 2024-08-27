//
//  WordQuizView.swift
//  Personal Dictionary
//
//  Created by CJ Robinson on 8/2/24.
//

import Foundation
import SwiftUI

struct WordQuizView: View {
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @State private var currentWord: Word?
    @State private var options: [String] = []
    @State private var score = 0
    @State private var questionsAnswered = 0
    @State private var showingScore = false
    @State private var answerResult: AnswerResult?
    
    enum AnswerResult {
        case correct, incorrect
    }
    
    var body: some View {
        VStack {
            if let word = currentWord {
                Text("Definition:")
                    .font(.headline)
                Text(word.definition)
                    .padding()
                    .frame(height: 100)
                
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        checkAnswer(option)
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(buttonBackgroundColor(for: option))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .animation(.default, value: answerResult)
                }
                
                Text("Score: \(score)/\(questionsAnswered)")
                    .padding()
            } else {
                Text("Add some bookmarks to start the quiz!")
            }
        }
        .onAppear(perform: nextQuestion)
        .alert(isPresented: $showingScore) {
            Alert(title: Text("Quiz Finished!"),
                  message: Text("Your score is \(score) out of \(questionsAnswered)"),
                  dismissButton: .default(Text("Play Again")) {
                    self.score = 0
                    self.questionsAnswered = 0
                    self.nextQuestion()
                  })
        }
    }
    
    func buttonBackgroundColor(for option: String) -> Color {
        guard let result = answerResult, let word = currentWord else {
            return .blue
        }
        
        if option == word.term {
            return result == .correct ? .green : .red
        } else {
            return .blue
        }
    }
    
    func nextQuestion() {
        guard !bookmarkManager.bookmarks.isEmpty else {
            currentWord = nil
            return
        }
        
        currentWord = bookmarkManager.bookmarks.randomElement()
        answerResult = nil
        
        var newOptions = [currentWord!.term]
        while newOptions.count < 4 && newOptions.count < bookmarkManager.bookmarks.count {
            if let newOption = bookmarkManager.bookmarks.randomElement()?.term,
               !newOptions.contains(newOption) {
                newOptions.append(newOption)
            }
        }
        
        options = newOptions.shuffled()
    }
    
    func checkAnswer(_ selectedAnswer: String) {
        questionsAnswered += 1
        if selectedAnswer == currentWord?.term {
            score += 1
            answerResult = .correct
        } else {
            answerResult = .incorrect
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if questionsAnswered == 10 || questionsAnswered == bookmarkManager.bookmarks.count {
                showingScore = true
            } else {
                nextQuestion()
            }
        }
    }
}
