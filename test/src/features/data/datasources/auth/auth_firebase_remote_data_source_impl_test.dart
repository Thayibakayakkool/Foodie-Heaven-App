import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodie_heaven/src/features/data/datasources/auth/auth_firebase_remote_data_source_impl.dart';
import 'package:foodie_heaven/src/features/domain/entities/user_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late AuthFirebaseRemoteDataSourceImpl authFirebase;
  late MockAuth mockAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockAuth();
    authFirebase = AuthFirebaseRemoteDataSourceImpl(firebaseAuth: mockAuth);
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
  });

  group('AuthFirebaseRemoteDataSourceImpl class-', () {
    test('should call sendPasswordResetEmail with correct email', () async {
      // Arrange
      final String email = 'test@example.com';

      when(() => mockAuth.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) => Future.value());
      // Act
      await authFirebase.forgotPassword(email);

     // Assert
      verify(() => mockAuth.sendPasswordResetEmail(email: email)).called(1);
    });
  });

  test('getCurrentUserId returns the current user id when logged in', () async {
    // Arrange
    when(() => mockUser.uid).thenReturn('testUid');
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    // Act
    final result = await authFirebase.getCurrentUserId();
    // Assert
    expect(result, 'testUid');
  });

  group('isLogIn', () {
    test('isLogIn returns true when there is a user', () async {
      // Arrange
      when(() => mockUser.uid).thenReturn('testUid');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      // Act
      final result = await authFirebase.isLogIn();
    // Assert
      expect(result, true);
    });

    test('isLogIn returns false when there is no use', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);
      // Act
      final result = await authFirebase.isLogIn();
     // Assert
      expect(result, false);
    });
  });

  test('Successful login', () async {
    // Arrange
    final userEntity =
        UserEntity(email: 'test@example.com', password: 'password123');

    when(() => mockAuth.signInWithEmailAndPassword(
            email: userEntity.email!, password: userEntity.password!))
        .thenAnswer((_) async => mockUserCredential);
    // Act
    await authFirebase.logIn(userEntity);
   // Assert
    verify(() => mockAuth.signInWithEmailAndPassword(
        email: userEntity.email!, password: userEntity.password!)).called(1);
  });

  test('logOut', () async {
    // Arrange
    when(() => mockAuth.signOut()).thenAnswer((_) => Future.value());
    // Act
    await authFirebase.logOut();
    // Assert
    verify(() => mockAuth.signOut()).called(1);
  });

  test('successfully signs up the user', () async {
    // Arrange
    final userEntity =
        UserEntity(email: 'test@example.com', password: 'password123');

    when(() => mockAuth.createUserWithEmailAndPassword(
            email: userEntity.email!, password: userEntity.password!))
        .thenAnswer((_) async => mockUserCredential);
    // Act
    await authFirebase.signUp(userEntity);
   // Assert
    verify(() => mockAuth.createUserWithEmailAndPassword(
        email: userEntity.email!, password: userEntity.password!)).called(1);
  });
}
