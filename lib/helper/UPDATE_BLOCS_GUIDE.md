# Guide: Update All BLoCs to Handle Network Errors

## Steps to Update Each BLoC:

### 1. Add Imports
```dart
import '../../helper/network_helper.dart';
import '../../helper/network_error_handler_global.dart';
```

### 2. Update Event Handlers

**Before:**
```dart
Future<void> mapSomeEvent(SomeEvent event, Emitter<SomeState> emit) async {
  try {
    emit(SomeStateLoading());
    var response = await someDao.fetchData();
    // ... handle response
  } catch (error) {
    emit(SomeStateFailed(message: "Something went wrong"));
  }
}
```

**After:**
```dart
Future<void> mapSomeEvent(SomeEvent event, Emitter<SomeState> emit) async {
  try {
    emit(SomeStateLoading());
    
    // Check network before making API call
    final hasConnection = await NetworkHelper.hasInternetConnection();
    if (!hasConnection) {
      emit(SomeStateFailed(
        message: 'No internet connection. Please check your network and try again.',
      ));
      return;
    }
    
    var response = await someDao.fetchData();
    // ... handle response
  } catch (error) {
    // Handle network errors with user-friendly messages
    final errorMessage = GlobalNetworkErrorHandler.handleError(error);
    emit(SomeStateFailed(message: errorMessage));
  }
}
```

## BLoCs to Update:

1. ✅ `lib/bloc/home/home_bloc.dart` - DONE
2. `lib/bloc/login/login_bloc.dart`
3. `lib/bloc/profile/profile_bloc.dart`
4. `lib/bloc/friends/friends_bloc.dart`
5. `lib/bloc/professional/professional_bloc.dart`
6. `lib/bloc/post_work/post_work_bloc.dart`
7. `lib/bloc/chart/chart_bloc.dart`
8. `lib/bloc/show_interested/show_interested_bloc.dart`
9. `lib/bloc/register_account/initial_register_bloc.dart`

## Key Points:

- The global network overlay will automatically show when network is lost
- Check network before API calls to provide immediate feedback
- Use `GlobalNetworkErrorHandler.handleError()` for consistent error messages
- The modal will automatically hide when network is restored

