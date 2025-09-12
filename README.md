# Clauselens - Legal Documents Simplified

A Flutter application built with MVC (Model-View-Controller) architecture that simplifies legal document analysis using AI.

## 🏗️ Architecture Overview

This project follows the **MVC (Model-View-Controller)** pattern for clean separation of concerns and maintainable code.

### 📁 Project Structure

```
lib/
├── core/                    # Core application layer
│   ├── theme/              # App theming and styling
│   │   └── app_theme.dart  # Color scheme, typography, and theme data
│   └── utils/              # Utility classes and helpers
│       └── responsive_utils.dart # Responsive design utilities
├── models/                  # Data models (MVC Model layer)
│   ├── user_model.dart     # User data model
│   └── auth_state_model.dart # Authentication state model
├── controllers/             # Business logic (MVC Controller layer)
│   └── auth_controller.dart # Authentication logic and state management
├── presentation/            # UI layer (MVC View layer)
│   ├── views/              # Screen implementations
│   │   └── landing_view.dart # Landing page with gradient animations
│   └── widgets/            # Reusable UI components
│       ├── gradient_text.dart      # Animated gradient text widget
│       ├── gradient_button.dart    # Gradient border button widget
│       └── background_decoration.dart # Background geometric patterns
└── main.dart               # Application entry point
```

## 🎨 Design Features

### Responsive Design
- **Mobile**: Optimized for screens < 600px width
- **Tablet**: Optimized for screens 600px - 1200px width  
- **Desktop**: Optimized for screens > 1200px width

### Color Scheme
- **Primary**: Dark gray (#1A1A1A)
- **Secondary**: Medium gray (#6B7280)
- **Background**: Pure white (#FFFFFF)
- **Accent Colors**: Purple to green gradient (#8B5CF6 → #10B981)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Headlines**: 48px/36px/28px (Desktop/Tablet/Mobile)
- **Body Text**: 18px/16px/14px (Desktop/Tablet/Mobile)

## ✨ Key Features

### Animated Gradient Text
The "Simplified" text features:
- Individual letter colors (blue, purple, red, orange, yellow, green)
- Continuous rotation animation
- Smooth color transitions

### Interactive Buttons
- **Gradient borders** with purple-to-green transitions
- **Pulsing animation** for the main CTA button
- **Responsive sizing** for different screen sizes

### Background Elements
- Subtle geometric lines and partial circles
- Light gray patterns for visual interest
- Non-intrusive design elements

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/clauselens.git
   cd clauselens
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Dependencies

- **provider**: State management
- **http**: API communication
- **shared_preferences**: Local storage
- **google_fonts**: Typography support

## 🔧 Development

### Adding New Features

1. **Models**: Create data models in `lib/models/`
2. **Controllers**: Add business logic in `lib/controllers/`
3. **Views**: Implement UI screens in `lib/presentation/views/`
4. **Widgets**: Create reusable components in `lib/presentation/widgets/`

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

## 📱 Platform Support

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Built with ❤️ using Flutter and MVC Architecture**
