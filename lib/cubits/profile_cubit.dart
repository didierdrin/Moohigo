import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;
  ProfileLoaded(this.userData);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseFirestore _firestore;
  
  // Assuming a userId is passed or we get it from auth. 
  // For demo, we might fix a userId or fetch the first one.
  final String userId = "example_user_id"; 

  ProfileCubit({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(ProfileInitial()) {
    loadProfile();
  }

  void loadProfile() async {
    emit(ProfileLoading());
    try {
      // In real app, use FirebaseAuth.instance.currentUser.uid
      // await Future.delayed(Duration(seconds: 1)); // Mock delay
      
      // Mock data for now if no firebase auth
      final data = {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'address': '123 Legal Avenue, Kigali',
      };
      
      emit(ProfileLoaded(data));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
