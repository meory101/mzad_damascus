/**
 * Created by Eng.Eyad AlSayed on 2/26/2024.
 */

import 'package:flutter/cupertino.dart';

import 'api_error_method.dart';
import 'api_error_response_entity.dart';
import 'api_failures.dart';
import 'api_status_code.dart';

class ErrorEntity {
  String errorMessage;
  int statusCode;
  int errorCode;

  ErrorEntity({
    this.errorMessage = '',
    this.errorCode = 0,
    this.statusCode = 0,
  });
}

//Function To Handel Failure Of Api Calls
//By Mapping Abstract Faliure Classes (Server Failure, Empty Cache Failure ,Offline Failure)

abstract class ApiErrorHandler {
  static Future<ErrorEntity> mapFailure({
    BuildContext? buildContext,
    required ApiFailure failure,
  }) {
    ErrorEntity errorEntity = ErrorEntity();
    switch (failure.runtimeType) {
      case const (ApiServerFailure):
        {
          return handleApiServerFailure(
              buildContext: buildContext,
              failure: failure as ApiServerFailure,
              errorEntity: errorEntity);
        }
      case const (EmptyApiCacheFailure):
        {
          return handleEmptyApiCacheFailure(
              failure: failure as EmptyApiCacheFailure,
              errorEntity: errorEntity);
        }
      case const (OfflineApiFailure):
        {
          return handleOfflineApiFailure(
              failure: failure as OfflineApiFailure, errorEntity: errorEntity);
        }
      default:
        {
          errorEntity.errorMessage = "someThingWentWrong";
          return Future.value(errorEntity);
        }
    }
  }

  static Future<ErrorEntity> handleApiServerFailure(
      {BuildContext? buildContext,
      required ApiServerFailure failure,
      required ErrorEntity errorEntity}) {
    if ((failure.response?.body ?? "").isNotEmpty) {
      final ErrorResponseEntity errorResponseEntity;
      try {
        errorResponseEntity =
            errorResponseEntityFromJson(failure.response?.body ?? '{}');

        errorEntity.errorMessage = errorResponseEntity.message;
        errorEntity.statusCode = failure.response?.statusCode ?? 0;
        errorEntity.errorCode = errorResponseEntity.errorCode;
        if (buildContext != null &&
            ApiStatusCode.invalidSessionToken() == errorEntity.errorCode) {
          ApiErrorMethod.invalidSessionToken(context: buildContext);
        }
      } catch (e) {
        errorEntity.errorMessage = "serverError";
      }
    }
    return Future.value(errorEntity);
  }

  static Future<ErrorEntity> handleEmptyApiCacheFailure(
      {required EmptyApiCacheFailure failure,
      required ErrorEntity errorEntity}) {
    errorEntity.errorMessage = "thereIsNoCachedData";
    return Future.value(errorEntity);
  }

  static Future<ErrorEntity> handleOfflineApiFailure(
      {required OfflineApiFailure failure, required ErrorEntity errorEntity}) {
    errorEntity.errorMessage = failure.message;
    return Future.value(errorEntity);
  }
}
