import SwiftUI
import ConfettiSwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DogViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    
    @State private var showWelcomeBackAlert = false
    @State private var likeButtonPressed = false
    @State private var dislikeButtonPressed = false
    @State private var triggerConfetti = 0
    @State private var triggerDislikeConfetti = 0
    @State private var headlineClicked = false
    @State private var imageScale: CGFloat = 0.5
    @State private var offset = CGSize.zero
    
    var body: some View {
        VStack {
            
            Spacer()
            Button {
                headlineClicked.toggle()
            } label: {
                Text(viewModel.breedName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(10)
                    .scaleEffect(headlineClicked ? 1.5 : 1.0)
            }
            
            Spacer()
            
            if let dogImageURL = viewModel.dogImageURL {
                AsyncImage(url: dogImageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .scaleEffect(imageScale)
                        .offset(offset)
                        .rotationEffect(.degrees(offset.width / 20.0))
                        .gesture(
                            SimultaneousGesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        if gesture.translation.width > 100 {
                                            swipeRight()
                                        } else if gesture.translation.width < -100 {
                                            swipeLeft()
                                        } else {
                                            withAnimation(.spring()) {
                                                offset = .zero
                                            }
                                        }
                                    },
                                MagnifyGesture()
                                    .onChanged { gesture in
                                        imageScale = gesture.magnification
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            imageScale = 1.0
                                        }
                                    }
                            )
                        )
                        .onAppear {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                imageScale = 1.0
                            }
                        }
                        .onChange(of: viewModel.dogImageURL) {
                            imageScale = 0.5
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                imageScale = 1.0
                            }
                        }
                        .onTapGesture {
                            guard let url = viewModel.dogImageURL else {
                                return
                            }
                            print(url)
                        }
                        .onLongPressGesture(minimumDuration: 1.5) {
                            likeDog()
                        }
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 300, height: 400)
            } else {
                ProgressView()
            }
            
            Spacer()
            
            HStack {
                // MARK: DISLIKE
                Button(action: {
                    dislikeDog()
                }) {
                    Image(systemName: dislikeButtonPressed ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(dislikeButtonPressed ? .red : .blue)
                        .scaleEffect(dislikeButtonPressed ? 1.5 : 1.0)
                        .shadow(color: dislikeButtonPressed ? .red.opacity(0.5) : .clear, radius: 10)
                }
                .confettiCannon(
                    trigger: $triggerDislikeConfetti,
                    num: 20,
                    confettis: [.shape(.roundedCross), .shape(.triangle), .shape(.slimRectangle)],
                    colors: [.red, .gray],
                    confettiSize: 12,
                    radius: 100,
                    repetitions: 1,
                    repetitionInterval: 0.5
                )
                
                // MARK: LIKE
                Button(action: {
                    likeDog()
                }) {
                    Image(systemName: likeButtonPressed ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(likeButtonPressed ? .green : .blue)
                        .scaleEffect(likeButtonPressed ? 1.5 : 1.0)
                        .shadow(color: likeButtonPressed ? .green.opacity(0.5) : .clear, radius: 10)
                    
                }
                .padding()
                .confettiCannon(
                    trigger: $triggerConfetti,
                    num: 25,
                    confettis: [.shape(.circle), .shape(.triangle), .shape(.square), .shape(.slimRectangle), .shape(.roundedCross)],
                    colors: [.red, .blue, .green, .yellow, .purple, .orange, .pink, .cyan],
                    confettiSize: 15,
                    radius: 125,
                    repetitions: 1,
                    repetitionInterval: 1
                )
            }
            
            
            Spacer()
        }
        .onAppear {
            if notificationViewModel.areNotificationsAllowed == nil {
                notificationViewModel.requestPermission()
            }
            notificationViewModel.resetBadgeCount()
            
            viewModel.notificationViewModel = notificationViewModel
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenAppActionTriggered"))) { _ in
            showWelcomeBackAlert = true
        }
        .alert("Willkommen zurück!", isPresented: $showWelcomeBackAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func likeDog() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            likeButtonPressed.toggle()
            triggerConfetti += 1
        }
        viewModel.likeAction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                likeButtonPressed = false
            }
        }
    }
    
    private func dislikeDog() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
            dislikeButtonPressed.toggle()
            triggerDislikeConfetti += 1
        }
        viewModel.dislikeAction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                dislikeButtonPressed = false
            }
        }
    }
    
    private func swipeRight() {
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = CGSize(width: 500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero
            likeDog()
        }
    }
    
    private func swipeLeft() {
        withAnimation(.easeInOut(duration: 0.3)) {
            offset = CGSize(width: -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero
            dislikeDog()
        }
    }
}

#Preview {
    ContentView()
}
