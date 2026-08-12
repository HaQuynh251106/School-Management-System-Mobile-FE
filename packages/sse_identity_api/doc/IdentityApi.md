# sse_identity_api.api.IdentityApi

## Load the API package
```dart
import 'package:sse_identity_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminResetUserPassword**](IdentityApi.md#adminresetuserpassword) | **POST** /users/{id}/reset-password |
[**changeMyPassword**](IdentityApi.md#changemypassword) | **PUT** /me/password |
[**createUser**](IdentityApi.md#createuser) | **POST** /users |
[**forgotPassword**](IdentityApi.md#forgotpassword) | **POST** /auth/forgot-password |
[**getCurrentUser**](IdentityApi.md#getcurrentuser) | **GET** /me |
[**getUser**](IdentityApi.md#getuser) | **GET** /users/{id} |
[**listUsers**](IdentityApi.md#listusers) | **GET** /users |
[**lockUser**](IdentityApi.md#lockuser) | **POST** /users/{id}/lock |
[**login**](IdentityApi.md#login) | **POST** /auth/login |
[**logout**](IdentityApi.md#logout) | **POST** /auth/logout |
[**refreshSession**](IdentityApi.md#refreshsession) | **POST** /auth/refresh |
[**resetPassword**](IdentityApi.md#resetpassword) | **POST** /auth/reset-password |
[**unlockUser**](IdentityApi.md#unlockuser) | **POST** /users/{id}/unlock |
[**updateMyProfile**](IdentityApi.md#updatemyprofile) | **PUT** /me/profile |


# **adminResetUserPassword**
> AdminResetPasswordResponse adminResetUserPassword(id, adminResetPasswordRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final String id = id_example; // String |
final AdminResetPasswordRequest adminResetPasswordRequest = ; // AdminResetPasswordRequest |

try {
    final response = api.adminResetUserPassword(id, adminResetPasswordRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->adminResetUserPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |
 **adminResetPasswordRequest** | [**AdminResetPasswordRequest**](AdminResetPasswordRequest.md)|  | [optional]

### Return type

[**AdminResetPasswordResponse**](AdminResetPasswordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **changeMyPassword**
> ChangePasswordResponse changeMyPassword(changePasswordRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final ChangePasswordRequest changePasswordRequest = ; // ChangePasswordRequest |

try {
    final response = api.changeMyPassword(changePasswordRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->changeMyPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordRequest** | [**ChangePasswordRequest**](ChangePasswordRequest.md)|  |

### Return type

[**ChangePasswordResponse**](ChangePasswordResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createUser**
> User createUser(createUserRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final CreateUserRequest createUserRequest = ; // CreateUserRequest |

try {
    final response = api.createUser(createUserRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->createUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createUserRequest** | [**CreateUserRequest**](CreateUserRequest.md)|  |

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **forgotPassword**
> ForgotPasswordResponse forgotPassword(forgotPasswordRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final ForgotPasswordRequest forgotPasswordRequest = ; // ForgotPasswordRequest |

try {
    final response = api.forgotPassword(forgotPasswordRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->forgotPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordRequest** | [**ForgotPasswordRequest**](ForgotPasswordRequest.md)|  |

### Return type

[**ForgotPasswordResponse**](ForgotPasswordResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getCurrentUser**
> User getCurrentUser()



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();

try {
    final response = api.getCurrentUser();
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->getCurrentUser: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUser**
> User getUser(id)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final String id = id_example; // String |

try {
    final response = api.getUser(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->getUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listUsers**
> List<User> listUsers(role, q, classId)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final String role = role_example; // String |
final String q = q_example; // String |
final String classId = classId_example; // String |

try {
    final response = api.listUsers(role, q, classId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->listUsers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **role** | **String**|  | [optional]
 **q** | **String**|  | [optional]
 **classId** | **String**|  | [optional]

### Return type

[**List&lt;User&gt;**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **lockUser**
> User lockUser(id)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final String id = id_example; // String |

try {
    final response = api.lockUser(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->lockUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **login**
> LoginResponse login(loginRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final LoginRequest loginRequest = ; // LoginRequest |

try {
    final response = api.login(loginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  |

### Return type

[**LoginResponse**](LoginResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logout**
> OkResponse logout(logoutRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final LogoutRequest logoutRequest = ; // LogoutRequest |

try {
    final response = api.logout(logoutRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->logout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logoutRequest** | [**LogoutRequest**](LogoutRequest.md)|  | [optional]

### Return type

[**OkResponse**](OkResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshSession**
> TokenResponse refreshSession(refreshRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final RefreshRequest refreshRequest = ; // RefreshRequest |

try {
    final response = api.refreshSession(refreshRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->refreshSession: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshRequest** | [**RefreshRequest**](RefreshRequest.md)|  | [optional]

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetPassword**
> OkResponse resetPassword(resetPasswordRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final ResetPasswordRequest resetPasswordRequest = ; // ResetPasswordRequest |

try {
    final response = api.resetPassword(resetPasswordRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->resetPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordRequest** | [**ResetPasswordRequest**](ResetPasswordRequest.md)|  |

### Return type

[**OkResponse**](OkResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unlockUser**
> User unlockUser(id)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final String id = id_example; // String |

try {
    final response = api.unlockUser(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->unlockUser: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  |

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateMyProfile**
> User updateMyProfile(updateMyProfileRequest)



### Example
```dart
import 'package:sse_identity_api/api.dart';

final api = SseIdentityApi().getIdentityApi();
final UpdateMyProfileRequest updateMyProfileRequest = ; // UpdateMyProfileRequest |

try {
    final response = api.updateMyProfile(updateMyProfileRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->updateMyProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateMyProfileRequest** | [**UpdateMyProfileRequest**](UpdateMyProfileRequest.md)|  |

### Return type

[**User**](User.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
