# Tight

Tight is a fitness tracking application for iOS and Apple Watch that helps users monitor and optimize their workout sessions. It provides tools for tracking exercises, managing workout plans, and maintaining a consistent fitness routine.

## Features

### iOS App
- **Workout Tracking**: Record and monitor your exercise sessions
- **Exercise Library**: Comprehensive collection of exercises categorized by body region
- **Training Log**: Keep track of your workout history and progress
- **Rest Timer**: Built-in rest timer between sets
- **Live Activities**: Dynamic Island support for real-time workout tracking
- **HealthKit Integration**: Sync workout data with Apple Health

### Apple Watch App
- **On-the-Go Tracking**: Track your workouts directly from your Apple Watch
- **Exercise Controls**: Complete sets, skip rest periods, or end workouts
- **Progress Visualization**: Visual indicators of workout progress
- **Real-time Metrics**: Monitor time, sets, and other workout metrics

## Technical Details

- **Framework**: Built with SwiftUI
- **Data Management**: Uses SwiftData for persistence
- **Integration**: HealthKit, WatchConnectivity, CloudKit
- **iOS Requirement**: iOS 17.0+
- **WatchOS Requirement**: watchOS 10.0+
- **CI/CD**: Configured with CircleCI
- **Deployment**: Uses Fastlane for automated deployment

## Categories of Exercises

- **Upper Body**: Bench Press, Push-Up, Pull-Up, Shoulder Press, and more
- **Lower Body**: Squat, Deadlift, Lunge, Leg Press, and more
- **Core**: Plank, Russian Twist, Crunch, Leg Raise, and more
- **Compound/Full-Body**: Clean and Jerk, Kettlebell Swing, Burpee, and more

## Project Structure

- **Models**: Exercise definitions, training session content, and data schema
- **Scenes**: Different views in the application
- **Components**: Reusable UI components
- **Managers**: Business logic and service management
- **Extensions**: Swift extensions for added functionality
- **Utils**: Utility functions and helpers

## Development

Built by Ciao Chiang

## License

© 2024 Tight Lab. All Rights Reserved. 