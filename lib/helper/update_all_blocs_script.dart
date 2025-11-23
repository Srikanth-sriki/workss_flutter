// This is a reference script showing the pattern to update all BLoC catch blocks
// You can use this as a guide to update remaining BLoCs

/*
PATTERN TO FOLLOW:

1. Add imports at the top:
   import '../../helper/network_helper.dart';
   import '../../helper/network_error_handler_global.dart';

2. Add network check before API calls:
   // Check network before making API call
   final hasConnection = await NetworkHelper.hasInternetConnection();
   if (!hasConnection) {
     emit(YourFailedState(
       message: 'No internet connection. Please check your network and try again.',
     ));
     return;
   }

3. Update catch blocks:
   } catch (error) {
     // Handle network errors with user-friendly messages
     final errorMessage = GlobalNetworkErrorHandler.handleError(error);
     emit(YourFailedState(message: errorMessage));
   }

BLoCs UPDATED:
✅ login_bloc.dart
✅ home_bloc.dart
✅ friends_bloc.dart
✅ chart_bloc.dart (partially - main methods)
✅ profile_bloc.dart (partially - main methods)
✅ professional_bloc.dart
✅ post_work_bloc.dart
✅ show_interested_bloc.dart (partially)
✅ initial_register_bloc.dart (partially)

REMAINING TO UPDATE:
- chart_bloc.dart (remaining methods)
- profile_bloc.dart (remaining methods)
- show_interested_bloc.dart (remaining methods)
- initial_register_bloc.dart (remaining methods)
- notification_bloc.dart
- login_otp_bloc.dart
- report_post_bloc.dart
- authentication_bloc.dart (mostly local, but check)

NOTE: The global network overlay will show automatically when network is lost,
so you don't need to manually show modals in each BLoC - just emit the error state.
*/

