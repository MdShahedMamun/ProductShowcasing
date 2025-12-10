H&M Product Showcasing

A simple, clean, and responsive iOS application that displays a paginated product grid for H&M “jeans” using the jeans Search API.
The project focuses on code quality, performance, accessibility, and best practices—following the requirements of the assignment.


✨ Features

Displays H&M "jeans" in a 2-column grid, edge-to-edge.

Fixed image height with vertical centering.

Infinite scrolling with auto-load more.

Pull-to-refresh (iOS 15+).

Product cards include:

Image

Title

Price

Swatches

Favorite button


🎨 Accessibility

VoiceOver-friendly cards (combined labels).

Dynamic Type support (uses text styles, not fixed fonts).

Fully supports Dark Mode via system colors.


⚙️ Architecture

MVVM

Async/await (Swift Concurrency)

Dependency Injection (mockable services)

Actor-based image cache


🧪 Testing

Unit tests included for some basic functionalities

🔧 Tech Stack

iOS, Swift, SwiftUI

📡 API

H&M Search API (Jeans query):

https://api.hm.com/search-services/v1/sv_se/search/resultpage?touchPoint=ios&query=jeans&page=1


🚀 Getting Started
Requirements

iOS 15+

Xcode 15+

Swift 5.7+

Run
git clone https://github.com/MdShahedMamun/ProductShowcasing
cd ProductShowcasing
open HMProductApp.xcodeproj


Build & run on any iOS simulator.

🧪 Run Tests

Press:

⌘ + U


Or via terminal:

xcodebuild -scheme HMProductApp -destination 'platform=iOS Simulator' test


📝 Future Improvements

Favorites persistence (UserDefaults / SwiftData)

Improved error states

UX improvement


📄 License

This project is for demo and interview purposes only and is not affiliated with H&M.
