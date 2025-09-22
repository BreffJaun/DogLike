import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DogViewModel()
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text(viewModel.breedName)
                 .font(.largeTitle)
                 .fontWeight(.bold)
                 .foregroundColor(.black)
                 .padding()
                 .background(Color.blue.opacity(0.3))
                 .cornerRadius(10)
            
            Spacer()
            
            if let dogImageURL = viewModel.dogImageURL {
                AsyncImage(url: dogImageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 300, height: 400)
            } else {
                ProgressView()
            }

            Spacer()
            
            HStack {
                Button(action: {
                    viewModel.dislikeAction()
                }) {
                    Image(systemName: "hand.thumbsdown")
                        .font(.system(size: 50))
                }
                .padding()
                
                Button(action: {
                    viewModel.likeAction()
                }) {
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 50))
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
