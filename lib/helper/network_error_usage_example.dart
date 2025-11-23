// Example of how to use network error handling in BLoC files
// 
// This file shows examples - you can delete it after implementing

import 'dart:io';
import 'package:http/http.dart' as http;
import 'network_helper.dart';
import 'network_error_handler.dart';

// Example 1: In BLoC event handler with try-catch
/*
Future<void> mapSomeEvent(
  SomeEvent event, 
  Emitter<SomeState> emit
) async {
  try {
    // Check network before making API call
    final hasConnection = await NetworkHelper.hasInternetConnection();
    if (!hasConnection) {
      emit(SomeStateFailed(
        message: 'No internet connection. Please check your network settings.'
      ));
      return;
    }

    // Make your API call
    var response = await someDao.fetchData();
    
    // Handle response
    if (response.statusCode == 200) {
      // Success handling
      emit(SomeStateSuccess(data: data));
    } else {
      emit(SomeStateFailed(
        message: NetworkErrorHandler.handleHttpError(response, null)
      ));
    }
  } catch (error) {
    // Handle network errors
    if (NetworkHelper.isNetworkError(error)) {
      emit(SomeStateFailed(
        message: NetworkHelper.getNetworkErrorMessage(error)
      ));
    } else {
      emit(SomeStateFailed(
        message: 'An error occurred. Please try again.'
      ));
    }
  }
}
*/

// Example 2: Using handleNetworkCall with retry
/*
Future<void> mapSomeEventWithRetry(
  SomeEvent event, 
  Emitter<SomeState> emit
) async {
  try {
    emit(SomeStateLoading());
    
    final result = await NetworkHelper.handleNetworkCall(
      networkCall: () async {
        var response = await someDao.fetchData();
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception('Failed to fetch data');
        }
      },
      maxRetries: 2,
      retryDelay: Duration(seconds: 2),
    );
    
    emit(SomeStateSuccess(data: result));
  } catch (error) {
    emit(SomeStateFailed(
      message: error.toString()
    ));
  }
}
*/

// Example 3: In UI (Widget) - showing error snackbar
/*
BlocListener<SomeBloc, SomeState>(
  listener: (context, state) {
    if (state is SomeStateFailed) {
      if (NetworkHelper.isNetworkError(state.message)) {
        NetworkErrorHandler.showNetworkErrorSnackBar(
          context,
          NetworkHelper.getNetworkErrorMessage(state.message),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    }
  },
  child: YourWidget(),
)
*/

// Example 4: Checking network before user action
/*
ElevatedButton(
  onPressed: () async {
    final hasConnection = await NetworkErrorHandler.checkNetworkBeforeOperation(
      context,
      showError: true,
    );
    
    if (hasConnection) {
      // Proceed with action
      bloc.add(SomeEvent());
    }
  },
  child: Text('Submit'),
)
*/

