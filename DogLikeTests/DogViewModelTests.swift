//
//  DogViewModelTests.swift
//  DogLikeTests
//
//  Created by Jeff Braun on 22.09.25.
//

import Foundation
import Testing
@testable import DogLike

@MainActor
struct DogViewModelTests {
    
    private var viewModel: DogViewModel
    
    init() {
        self.viewModel = DogViewModel()
    }

    @Test(
        arguments: [
            "Balu",
            "Zoey",
            "Cloe"
        ]
    )
    func testGreetings(name: String) async throws {
        let result = viewModel.greeting(name: name)
        #expect(result == "Welcome to DogLike, \(name)!")
    }
    
    @Test func testExtractBreedName_Valid() async throws {
        let url = "https://images.dog.ceo/breeds/pembroke/n02113023_2330.jpg"
        let result = viewModel.extractBreedName(from: url)
        #expect(result == "pembroke")
    }
    
    @Test(
        arguments: [
            "https://images.dog.ceo/pembroke/n02113023_2330.jpg",
            "https://images.dog.ceo/breeds/n02113023_2330.jpg",
            "https://images.dog.ceo/breed/pembroke/n02113023_2330.jpg",
            "https://images.dog.ceo/breeds//n02113023_2330.jpg",
        ]
    )
    func testExtractBreedName_Invalid(url: String) async throws {
        let result = viewModel.extractBreedName(from: url)
        
        if let breed = result {
            let isEmpty = breed.isEmpty
            let containsDot = breed.contains(".")
            let containsNumber = breed.rangeOfCharacter(from: .decimalDigits) != nil
            #expect(containsDot || containsNumber || breed.isEmpty)
        } else {
            #expect(result == nil)
        }
    }
}
