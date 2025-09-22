import Foundation
import UserNotifications

@MainActor
class DogViewModel: ObservableObject {
    @Published var dogImageURL: URL?
    
    @Published var likeCount = 0
    @Published var dislikeCount = 0
    
    @Published var breedName = ""
    @Published var errorMessage: String?

    private var repository: DogRepositoryProtocol
    
    init(repository: DogRepositoryProtocol = DogRepository()) {
        self.repository = repository
        Task {
            await fetchRandomDogImage()
        }
    }
    
    func fetchRandomDogImage() async {
        do {
            let url = try await repository.fetchRandomDogImage()
            if let breedName = extractBreedName(from: url.absoluteString) {
                self.breedName = breedName
            } else {
                self.breedName = "No Breed found"
            }
            self.dogImageURL = url
        } catch {
            self.errorMessage = "Error while loading: \(error)"
        }
    }
    
    func likeAction() {
        likeCount += 1
        Task {
            await fetchRandomDogImage()
        }
    }
    
    func dislikeAction() {
        dislikeCount += 1
        Task {
            await fetchRandomDogImage()
        }
    }
    
    func extractBreedName(from urlString: String) -> String? {
        let searchKeyword = "breeds/"

        guard let range = urlString.range(of: searchKeyword) else {
            return nil
        }
        
        let substringFromBreed = urlString[range.upperBound...]
        var breed = ""
        for char in substringFromBreed {
            if char == "/" {
                break
            }
            breed.append(char)
        }
        
        return breed.isEmpty ? nil : breed
    }
    
    func greeting(name: String) -> String {
        return "Welcome to DogLike, \(name)!"
    }
}
