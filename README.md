# bocchi.tv - Cross Platform Anime Streaming App

![bocchi.tv Banner](https://github.com/shivam-kumar-shah/bocchi_flutter/assets/134827809/a7355fcf-5f8e-4e76-acf1-7be57d032f67)

## Description

Bocchi.tv is a cross-platform anime streaming application built using Flutter. It provides a seamless and user-friendly interface for anime enthusiasts to stream their favorite shows. This project is a labor of love and a true passion project. The app utilizes a self-hosted backend for data fetching and employs on-device web scraping using the HTML package to fetch stream URLs and episode lists from animepahe.com. The backend then processes the stream URLs into a usable format supported by Flutter.

The application uses Provider as the state management library, SQLite as the on-device database for storing watch history and watchlist, and Consumit for some of the backend functionality.

## Features

- Stream anime episodes seamlessly.
- Store watch history and create a watchlist.
- Cross-platform compatibility for Android and iOS.

## Technologies Used

- Flutter
- `provider` as a state management library
- `html` package for web scraping
- `sqllite` for on-device database
- [consumet](https://github.com/consumet/consumet.ts) for backend integration

## Backend

Backend is hosted at - [bocchi.tv Backend](https://relieved-cyan-tuxedo.cyclic.app/)

## Getting Started

To run this project locally, follow these steps:

1. Clone the repository:

```bash
  git clone https://github.com/shivam-kumar-shah/bocchi_flutter && cd bocchi_flutter
```

3. Install the required dependencies using:

```bash
   flutter pub get
```

3. Start the app on your preferred emulator or connected device using:

```bash
  flutter run
```

## Building the Application

To build the Bocchi.tv application, follow these instructions:

1. Open a terminal or command prompt.

2. Navigate to the project directory:

```bash
  cd /path/to/bocchi.tv
```
3. To build a smaller bundle size optimized for specific device architectures, use the following command:

```bash
   flutter build --split-per-abi
```

> This command will generate separate APK files for different device architectures (arm64-v8a, armeabi-v7a, etc.). This is recommended for reducing the app size.

4. If you prefer a larger bundle that is architecture-independent, use the following command:

```bash
  flutter build
```

> This command will generate a single APK file that can run on various device architectures. Keep in mind that this option may result in a larger app size.

5. After the build process is complete, you can find the generated APK files in the `build/app/outputs/flutter-apk` directory.

## Usage

1. Open the application on your device.
2. Browse the extensive anime library.
3. Select your desired show and start streaming.

## Contributing

Contributions are welcome! If you have any ideas, bug fixes, or improvements, please open an issue or submit a pull request.

## Contact

For any inquiries or feedback, feel free to contact us at [shivam-kumar-shah@outlook.com](mailto:shivam-kumar-shah@outlook.com).

---

*Happy Streaming!* 📺✨

---

## Showcase

<div style = "display:grid; grid-template-columns:repeat(3,1fr); gap:50px;">
<img src = "https://user-images.githubusercontent.com/105339885/218025764-db7f765b-adfc-409f-8544-8beafa5e4280.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025768-d46f5e82-695b-4fbb-89ae-5c5969de6ded.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025774-edafcd34-b6fc-4bc1-859d-626b7318c193.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025778-9178ba8f-0936-40e3-9acd-f9537fc8e8e7.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025784-49011709-e26f-4d2e-afdd-dabe081e8cf8.png" width="30%"/>
<img src = "https://user-images.githubusercontent.com/105339885/218025753-2cacc438-3602-4608-9f58-e57f2d7ea923.png" width="30%"/>
</div>

---
