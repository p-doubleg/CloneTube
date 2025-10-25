# Refactor and optimize code analysis
_Exported on 10/25/2025 at 16:50:09 GMT+4 from Cursor (1.6.23)_

---

**User**

ANALIZE @Network/ @Modules/ @UIComponents/ @Utils/ 
BASED ON ALL BEST PRACTIVES AND CODE PRINCIPLES TELL ME HOW TO REFACTOR AND OPTIMIZE CODE

---

**Cursor**

I'll analyze the codebase structure and implementation to provide comprehensive refactoring recommendations based on best practices and code principles. Let me start by examining the key files and folders.


Based on my comprehensive analysis of your CloneTube codebase, I'll provide detailed refactoring recommendations based on iOS best practices and clean architecture principles.

## 📊 **Code Analysis Summary**

Your codebase shows good organization with clear separation of concerns, but there are several areas for improvement in terms of architecture, maintainability, and scalability.

---

## 🏗️ **ARCHITECTURAL IMPROVEMENTS**

### 1. **Implement MVVM Architecture**

**Current Issue**: `HomeViewController` directly handles data fetching and UI updates, violating separation of concerns.

**Recommendation**: Implement proper MVVM pattern:

```swift
// MARK: - ViewModel
protocol HomeViewModelProtocol {
    var videos: [Video] { get }
    var shorts: [Video] { get }
    var isLoading: Bool { get }
    var onDataUpdate: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    
    func loadVideos(category: VideoCategory)
    func refreshData()
}

final class HomeViewModel: HomeViewModelProtocol {
    private let networkService: NetworkServicing
    private var _videos: [Video] = []
    private var _shorts: [Video] = []
    private var _isLoading: Bool = false
    
    var videos: [Video] { _videos }
    var shorts: [Video] { _shorts }
    var isLoading: Bool { _isLoading }
    
    var onDataUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(networkService: NetworkServicing = MockNetworkService.shared) {
        self.networkService = networkService
    }
    
    func loadVideos(category: VideoCategory) {
        _isLoading = true
        
        Task {
            do {
                async let videosTask = networkService.fetchVideos(category)
                async let shortsTask = networkService.fetchShorts(category)
                
                let (videos, shorts) = try await (videosTask, shortsTask)
                
                await MainActor.run {
                    self._videos = videos
                    self._shorts = shorts
                    self._isLoading = false
                    self.onDataUpdate?()
                }
            } catch {
                await MainActor.run {
                    self._isLoading = false
                    self.onError?(error)
                }
            }
        }
    }
}
```

### 2. **Implement Repository Pattern**

**Current Issue**: Direct dependency on `MockNetworkService` throughout the app.

**Recommendation**: Create a repository layer:

```swift
// MARK: - Repository Protocol
protocol VideoRepositoryProtocol {
    func fetchVideos(category: VideoCategory) async throws -> [Video]
    func fetchShorts(category: VideoCategory) async throws -> [Video]
    func fetchChannel(id: String) async throws -> Channel
}

// MARK: - Repository Implementation
final class VideoRepository: VideoRepositoryProtocol {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = MockNetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchVideos(category: VideoCategory) async throws -> [Video] {
        try await networkService.fetchVideos(category)
    }
    
    func fetchShorts(category: VideoCategory) async throws -> [Video] {
        try await networkService.fetchShorts(category)
    }
    
    func fetchChannel(id: String) async throws -> Channel {
        // Implementation for channel fetching
        throw NetworkError.notImplemented
    }
}
```

---

## 🔧 **NETWORK LAYER IMPROVEMENTS**

### 3. **Enhance Network Service Protocol**

**Current Issue**: Limited protocol with only one method.

**Recommendation**: Expand the protocol for better scalability:

```swift
protocol NetworkServicing {
    func fetchVideos(_ category: VideoCategory) async throws -> [Video]
    func fetchShorts(_ category: VideoCategory) async throws -> [Video]
    func fetchChannel(_ id: String) async throws -> Channel
    func searchVideos(_ query: String) async throws -> [Video]
}

// MARK: - Network Error Handling
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError: return "Failed to decode data"
        case .serverError(let code): return "Server error: \(code)"
        case .notImplemented: return "Feature not implemented"
        }
    }
}
```

### 4. **Implement Real Network Service**

**Recommendation**: Create a production-ready network service:

```swift
final class NetworkService: NetworkServicing {
    private let session: URLSession
    private let baseURL: String
    
    init(session: URLSession = .shared, baseURL: String = "https://api.example.com") {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetchVideos(_ category: VideoCategory) async throws -> [Video] {
        let endpoint = "/videos?category=\(category.rawValue)"
        return try await performRequest(endpoint: endpoint, responseType: [Video].self)
    }
    
    private func performRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
```

---

## 🎨 **UI COMPONENTS IMPROVEMENTS**

### 5. **Create Reusable Base Classes**

**Current Issue**: Duplicate code in `VideoCell` and `ShortsCell`.

**Recommendation**: Create base classes:

```swift
// MARK: - Base Cell Protocol
protocol ConfigurableCell {
    associatedtype DataType
    func configure(with data: DataType)
}

// MARK: - Base Collection View Cell
class BaseCollectionViewCell: UICollectionViewCell, ConfigurableCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        // Override in subclasses
    }
    
    func configure(with data: Any) {
        // Override in subclasses
    }
}

// MARK: - Refactored Video Cell
final class VideoCell: BaseCollectionViewCell {
    typealias DataType = Video
    
    private let thumbnailImageView = VideoThumbnailImageView()
    private let profileImageView = ProfileImageView()
    private let titleLabel = UILabel()
    private let viewsLabel = UILabel()
    private let dateLabel = UILabel()
    private let moreButton = UIButton(type: .system)
    
    weak var delegate: VideoCellDelegate?
    
    override func setupUI() {
        super.setupUI()
        configureUI()
    }
    
    func configure(with video: Video) {
        titleLabel.text = video.title
        viewsLabel.text = video.formattedViewCount
        dateLabel.text = video.timeAgoText
        // Configure other UI elements
    }
}
```

### 6. **Implement Auto Layout**

**Current Issue**: Manual frame calculations in `layoutSubviews`.

**Recommendation**: Use Auto Layout for better maintainability:

```swift
final class VideoCell: BaseCollectionViewCell {
    // ... existing properties
    
    override func setupUI() {
        super.setupUI()
        setupConstraints()
    }
    
    private func setupConstraints() {
        [thumbnailImageView, profileImageView, titleLabel, viewsLabel, dateLabel, moreButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            // Thumbnail constraints
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 9/16),
            
            // Profile image constraints
            profileImageView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 12),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            profileImageView.widthAnchor.constraint(equalToConstant: 36),
            profileImageView.heightAnchor.constraint(equalToConstant: 36),
            
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            
            // More button constraints
            moreButton.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Views and date constraints
            viewsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            viewsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: viewsLabel.trailingAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
            
            // Bottom constraint
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
```

### 7. **Create Theme System**

**Current Issue**: Hardcoded colors and fonts throughout the app.

**Recommendation**: Implement a centralized theme system:

```swift
// MARK: - Theme Protocol
protocol ThemeProtocol {
    var colors: ColorTheme { get }
    var fonts: FontTheme { get }
    var spacing: SpacingTheme { get }
}

// MARK: - Color Theme
struct ColorTheme {
    let primary: UIColor
    let secondary: UIColor
    let background: UIColor
    let surface: UIColor
    let text: UIColor
    let textSecondary: UIColor
    
    static let `default` = ColorTheme(
        primary: .systemBlue,
        secondary: .systemGray,
        background: .systemBackground,
        surface: .secondarySystemBackground,
        text: .label,
        textSecondary: .secondaryLabel
    )
}

// MARK: - Font Theme
struct FontTheme {
    let title: UIFont
    let subtitle: UIFont
    let body: UIFont
    let caption: UIFont
    
    static let `default` = FontTheme(
        title: .systemFont(ofSize: 16, weight: .medium),
        subtitle: .systemFont(ofSize: 14, weight: .regular),
        body: .systemFont(ofSize: 14, weight: .regular),
        caption: .systemFont(ofSize: 12, weight: .regular)
    )
}

// MARK: - Theme Manager
final class ThemeManager {
    static let shared = ThemeManager()
    private var currentTheme: ThemeProtocol = DefaultTheme()
    
    private init() {}
    
    func setTheme(_ theme: ThemeProtocol) {
        currentTheme = theme
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
    
    var theme: ThemeProtocol { currentTheme }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
```

---

## 📱 **MODULE IMPROVEMENTS**

### 8. **Implement Coordinator Pattern**

**Current Issue**: Navigation logic scattered throughout view controllers.

**Recommendation**: Implement coordinator pattern for navigation:

```swift
// MARK: - Coordinator Protocol
protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

// MARK: - App Coordinator
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
    }
}

// MARK: - Home Coordinator
final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showVideoDetail(_ video: Video) {
        let viewModel = VideoDetailViewModel(video: video)
        let viewController = VideoDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
```

### 9. **Implement Dependency Injection**

**Current Issue**: Hard dependencies throughout the app.

**Recommendation**: Use dependency injection container:

```swift
// MARK: - Dependency Container
final class DIContainer {
    static let shared = DIContainer()
    
    private var dependencies: [String: Any] = [:]
    
    private init() {}
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        dependencies[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = dependencies[key] as? () -> T else {
            fatalError("Dependency not registered: \(type)")
        }
        return factory()
    }
}

// MARK: - Usage in App Delegate
extension AppDelegate {
    func setupDependencies() {
        let container = DIContainer.shared
        
        container.register(NetworkServicing.self) {
            MockNetworkService.shared
        }
        
        container.register(VideoRepositoryProtocol.self) {
            VideoRepository(networkService: container.resolve(NetworkServicing.self))
        }
        
        container.register(HomeViewModelProtocol.self) {
            HomeViewModel(repository: container.resolve(VideoRepositoryProtocol.self))
        }
    }
}
```

---

## 🛠️ **UTILITY IMPROVEMENTS**

### 10. **Enhance Image Assets Management**

**Current Issue**: Basic enum with string values.

**Recommendation**: Create a more robust asset management system:

```swift
// MARK: - Asset Manager
final class AssetManager {
    static let shared = AssetManager()
    
    private init() {}
    
    func image(named name: ImageAssets) -> UIImage? {
        UIImage(named: name.rawValue)
    }
    
    func image(named name: ImageAssets, with configuration: UIImage.Configuration? = nil) -> UIImage? {
        UIImage(named: name.rawValue, in: nil, with: configuration)
    }
}

// MARK: - Enhanced Image Assets
enum ImageAssets: String, CaseIterable {
    // Tab Bar Icons
    case addVideoOutline = "addVideo_outline"
    case homeOutline = "home_outline"
    case homeFilled = "home_filled"
    case libraryOutline = "library_outline"
    case libraryFilled = "library_filled"
    case shortsOutline = "shorts_outline"
    case subscriptionOutline = "subscription_outline"
    case subscriptionFilled = "subscription_filled"
    
    // Top Bar Icons
    case youtubeLogo = "youtube_logo"
    case castIcon = "cast_icon"
    case notificationIcon = "notification_icon"
    case searchIcon = "search_icon"
    case profileIcon = "profile_icon"
    
    // Action Icons
    case more = "more"
    
    // Placeholders
    case shortsTumbnailPlaceholder = "shorts_tumbnail_placeholder"
    case videoTumbnailPlaceholder = "video_tumbnail_placeholder"
    case profilePlaceholder = "profile_placeholder"
    
    // MARK: - Computed Properties
    var image: UIImage? {
        AssetManager.shared.image(named: self)
    }
    
    var templateImage: UIImage? {
        image?.withRenderingMode(.alwaysTemplate)
    }
    
    var originalImage: UIImage? {
        image?.withRenderingMode(.alwaysOriginal)
    }
}
```

### 11. **Create Extensions for Common Operations**

**Recommendation**: Add useful extensions:

```swift
// MARK: - UIView Extensions
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func pinToEdges(of view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

// MARK: - UICollectionView Extensions
extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            fatalError("Failed to dequeue cell of type \(T.self)")
        }
        return cell
    }
}

// MARK: - String Extensions
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
```

---

## 📋 **IMPLEMENTATION PRIORITY**

### **Phase 1: Foundation (High Priority)**
1. Implement MVVM architecture
2. Create repository pattern
3. Add proper error handling
4. Implement dependency injection

### **Phase 2: UI Improvements (Medium Priority)**
1. Convert to Auto Layout
2. Create base classes for cells
3. Implement theme system
4. Add coordinator pattern

### **Phase 3: Enhancement (Low Priority)**
1. Add comprehensive testing
2. Implement caching layer
3. Add analytics
4. Performance optimizations

---

## 🎯 **BENEFITS OF THESE CHANGES**

1. **Maintainability**: Cleaner separation of concerns
2. **Testability**: Easier to unit test with dependency injection
3. **Scalability**: Better architecture for future features
4. **Reusability**: More reusable components
5. **Performance**: Better memory management and UI responsiveness
6. **Developer Experience**: Cleaner, more readable code


```swift
// MARK: - ViewModel
protocol HomeViewModelProtocol {
    var videos: [Video] { get }
    var shorts: [Video] { get }
    var isLoading: Bool { get }
    var onDataUpdate: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    
    func loadVideos(category: VideoCategory)
    func refreshData()
}

final class HomeViewModel: HomeViewModelProtocol {
    private let networkService: NetworkServicing
    private var _videos: [Video] = []
    private var _shorts: [Video] = []
    private var _isLoading: Bool = false
    
    var videos: [Video] { _videos }
    var shorts: [Video] { _shorts }
    var isLoading: Bool { _isLoading }
    
    var onDataUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(networkService: NetworkServicing = MockNetworkService.shared) {
        self.networkService = networkService
    }
    
    func loadVideos(category: VideoCategory) {
        _isLoading = true
        
        Task {
            do {
                async let videosTask = networkService.fetchVideos(category)
                async let shortsTask = networkService.fetchShorts(category)
                
                let (videos, shorts) = try await (videosTask, shortsTask)
                
                await MainActor.run {
                    self._videos = videos
                    self._shorts = shorts
                    self._isLoading = false
                    self.onDataUpdate?()
                }
            } catch {
                await MainActor.run {
                    self._isLoading = false
                    self.onError?(error)
                }
            }
        }
    }
}
```

```swift
// MARK: - Repository Protocol
protocol VideoRepositoryProtocol {
    func fetchVideos(category: VideoCategory) async throws -> [Video]
    func fetchShorts(category: VideoCategory) async throws -> [Video]
    func fetchChannel(id: String) async throws -> Channel
}

// MARK: - Repository Implementation
final class VideoRepository: VideoRepositoryProtocol {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = MockNetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchVideos(category: VideoCategory) async throws -> [Video] {
        try await networkService.fetchVideos(category)
    }
    
    func fetchShorts(category: VideoCategory) async throws -> [Video] {
        try await networkService.fetchShorts(category)
    }
    
    func fetchChannel(id: String) async throws -> Channel {
        // Implementation for channel fetching
        throw NetworkError.notImplemented
    }
}
```

```swift
protocol NetworkServicing {
    func fetchVideos(_ category: VideoCategory) async throws -> [Video]
    func fetchShorts(_ category: VideoCategory) async throws -> [Video]
    func fetchChannel(_ id: String) async throws -> Channel
    func searchVideos(_ query: String) async throws -> [Video]
}

// MARK: - Network Error Handling
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError: return "Failed to decode data"
        case .serverError(let code): return "Server error: \(code)"
        case .notImplemented: return "Feature not implemented"
        }
    }
}
```

```swift
final class NetworkService: NetworkServicing {
    private let session: URLSession
    private let baseURL: String
    
    init(session: URLSession = .shared, baseURL: String = "https://api.example.com") {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetchVideos(_ category: VideoCategory) async throws -> [Video] {
        let endpoint = "/videos?category=\(category.rawValue)"
        return try await performRequest(endpoint: endpoint, responseType: [Video].self)
    }
    
    private func performRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
```

```swift
// MARK: - Base Cell Protocol
protocol ConfigurableCell {
    associatedtype DataType
    func configure(with data: DataType)
}

// MARK: - Base Collection View Cell
class BaseCollectionViewCell: UICollectionViewCell, ConfigurableCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        // Override in subclasses
    }
    
    func configure(with data: Any) {
        // Override in subclasses
    }
}

// MARK: - Refactored Video Cell
final class VideoCell: BaseCollectionViewCell {
    typealias DataType = Video
    
    private let thumbnailImageView = VideoThumbnailImageView()
    private let profileImageView = ProfileImageView()
    private let titleLabel = UILabel()
    private let viewsLabel = UILabel()
    private let dateLabel = UILabel()
    private let moreButton = UIButton(type: .system)
    
    weak var delegate: VideoCellDelegate?
    
    override func setupUI() {
        super.setupUI()
        configureUI()
    }
    
    func configure(with video: Video) {
        titleLabel.text = video.title
        viewsLabel.text = video.formattedViewCount
        dateLabel.text = video.timeAgoText
        // Configure other UI elements
    }
}
```

```swift
final class VideoCell: BaseCollectionViewCell {
    // ... existing properties
    
    override func setupUI() {
        super.setupUI()
        setupConstraints()
    }
    
    private func setupConstraints() {
        [thumbnailImageView, profileImageView, titleLabel, viewsLabel, dateLabel, moreButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            // Thumbnail constraints
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 9/16),
            
            // Profile image constraints
            profileImageView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 12),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            profileImageView.widthAnchor.constraint(equalToConstant: 36),
            profileImageView.heightAnchor.constraint(equalToConstant: 36),
            
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8),
            
            // More button constraints
            moreButton.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            moreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Views and date constraints
            viewsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            viewsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: viewsLabel.trailingAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
            
            // Bottom constraint
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
```

```swift
// MARK: - Theme Protocol
protocol ThemeProtocol {
    var colors: ColorTheme { get }
    var fonts: FontTheme { get }
    var spacing: SpacingTheme { get }
}

// MARK: - Color Theme
struct ColorTheme {
    let primary: UIColor
    let secondary: UIColor
    let background: UIColor
    let surface: UIColor
    let text: UIColor
    let textSecondary: UIColor
    
    static let `default` = ColorTheme(
        primary: .systemBlue,
        secondary: .systemGray,
        background: .systemBackground,
        surface: .secondarySystemBackground,
        text: .label,
        textSecondary: .secondaryLabel
    )
}

// MARK: - Font Theme
struct FontTheme {
    let title: UIFont
    let subtitle: UIFont
    let body: UIFont
    let caption: UIFont
    
    static let `default` = FontTheme(
        title: .systemFont(ofSize: 16, weight: .medium),
        subtitle: .systemFont(ofSize: 14, weight: .regular),
        body: .systemFont(ofSize: 14, weight: .regular),
        caption: .systemFont(ofSize: 12, weight: .regular)
    )
}

// MARK: - Theme Manager
final class ThemeManager {
    static let shared = ThemeManager()
    private var currentTheme: ThemeProtocol = DefaultTheme()
    
    private init() {}
    
    func setTheme(_ theme: ThemeProtocol) {
        currentTheme = theme
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
    
    var theme: ThemeProtocol { currentTheme }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
```

```swift
// MARK: - Coordinator Protocol
protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

// MARK: - App Coordinator
final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
    }
}

// MARK: - Home Coordinator
final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showVideoDetail(_ video: Video) {
        let viewModel = VideoDetailViewModel(video: video)
        let viewController = VideoDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
```

```swift
// MARK: - Dependency Container
final class DIContainer {
    static let shared = DIContainer()
    
    private var dependencies: [String: Any] = [:]
    
    private init() {}
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        dependencies[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = dependencies[key] as? () -> T else {
            fatalError("Dependency not registered: \(type)")
        }
        return factory()
    }
}

// MARK: - Usage in App Delegate
extension AppDelegate {
    func setupDependencies() {
        let container = DIContainer.shared
        
        container.register(NetworkServicing.self) {
            MockNetworkService.shared
        }
        
        container.register(VideoRepositoryProtocol.self) {
            VideoRepository(networkService: container.resolve(NetworkServicing.self))
        }
        
        container.register(HomeViewModelProtocol.self) {
            HomeViewModel(repository: container.resolve(VideoRepositoryProtocol.self))
        }
    }
}
```

```swift
// MARK: - Asset Manager
final class AssetManager {
    static let shared = AssetManager()
    
    private init() {}
    
    func image(named name: ImageAssets) -> UIImage? {
        UIImage(named: name.rawValue)
    }
    
    func image(named name: ImageAssets, with configuration: UIImage.Configuration? = nil) -> UIImage? {
        UIImage(named: name.rawValue, in: nil, with: configuration)
    }
}

// MARK: - Enhanced Image Assets
enum ImageAssets: String, CaseIterable {
    // Tab Bar Icons
    case addVideoOutline = "addVideo_outline"
    case homeOutline = "home_outline"
    case homeFilled = "home_filled"
    case libraryOutline = "library_outline"
    case libraryFilled = "library_filled"
    case shortsOutline = "shorts_outline"
    case subscriptionOutline = "subscription_outline"
    case subscriptionFilled = "subscription_filled"
    
    // Top Bar Icons
    case youtubeLogo = "youtube_logo"
    case castIcon = "cast_icon"
    case notificationIcon = "notification_icon"
    case searchIcon = "search_icon"
    case profileIcon = "profile_icon"
    
    // Action Icons
    case more = "more"
    
    // Placeholders
    case shortsTumbnailPlaceholder = "shorts_tumbnail_placeholder"
    case videoTumbnailPlaceholder = "video_tumbnail_placeholder"
    case profilePlaceholder = "profile_placeholder"
    
    // MARK: - Computed Properties
    var image: UIImage? {
        AssetManager.shared.image(named: self)
    }
    
    var templateImage: UIImage? {
        image?.withRenderingMode(.alwaysTemplate)
    }
    
    var originalImage: UIImage? {
        image?.withRenderingMode(.alwaysOriginal)
    }
}
```

```swift
// MARK: - UIView Extensions
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func pinToEdges(of view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

// MARK: - UICollectionView Extensions
extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            fatalError("Failed to dequeue cell of type \(T.self)")
        }
        return cell
    }
}

// MARK: - String Extensions
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
```

This comprehensive analysis provides you with a roadmap to transform your CloneTube app into a more maintainable, scalable, and professional iOS application following industry best practices. The recommendations are prioritized to help you implement changes incrementally while maintaining a working application throughout the refactoring process.

