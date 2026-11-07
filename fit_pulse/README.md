# Fit Pulse – Flutter Fitness Tracker (Web)

## Run
```
flutter create . --platforms=web      # run once inside this folder (adds web/ support files)
flutter pub get
flutter run -d chrome
```
Build: `flutter build web`

## Concept map
- Widgets: Container, Row, Column, Stack, Wrap, ListView, GridView, Card, Chip, Buttons, Dismissible
- Responsive: MediaQuery + LayoutBuilder (BottomNav < 600px, Rail 600-899px, extended Rail >= 900px, adaptive grid columns, max-width content)
- Navigation: named routes via onGenerateRoute, pushNamed with arguments, pushReplacementNamed, custom page transition
- Animations: TweenAnimationBuilder (ring, bars, stat cards), AnimatedSwitcher (tabs, status chip), AnimatedContainer (water), AnimatedSize (signup field), Hero
- State: Provider (ChangeNotifier AppState) + StatefulWidgets
- Theme/custom widgets: AppTheme (light/dark), PageFrame, AppCard, GradientButton, StatCard, ProgressRing, WeekBars
- Forms: login/signup, add workout, edit profile with validators
