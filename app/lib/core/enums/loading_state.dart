/// Loading state enum for UI components
/// 
/// Represents different states of data loading in the application.
/// Used primarily in controllers to manage UI state.
enum LoadingState {
  /// Initial loading state - showing loading indicator
  loading,
  
  /// Data loaded successfully
  success,
  
  /// Error occurred during loading
  error,
  
  /// Data loaded successfully but empty
  empty,
}
