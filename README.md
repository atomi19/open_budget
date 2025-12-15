# Open Budget
Open Budget is open-source, cross-platform budgeting application 

## Getting started 
### Dependencies
- [Drift](https://pub.dev/packages/drift)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
### Developer dependencies
- [build_runner](https://pub.dev/packages/build_runner)


### Setup

1. Clone the repo:
```bash 
git clone https://github.com/atomi19/open_budget.git
```

2. Navigate to the project directory:
```bash
cd open_budget
```

3. Get dependencies:
```bash
flutter pub get
```

4. Database setup (this will generate database.g.dart):
```
dart run build_runner build
```

5. Run the project on mobile (ios, android) or desktop (linux, windows, macos)
```
flutter run
```

## License
This project is licensed under the [GNU GENERAL PUBLIC LICENSE Version 3](LICENSE.txt)