/// Passed as [ModalRoute.settings.arguments] when navigating to home.
enum TutorialLaunch {
  /// After registration — always show the tutorial.
  newUser,

  /// From FAQs — replay even if already completed.
  replay,
}
