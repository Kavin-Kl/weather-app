import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'my_bloc_event.dart';
part 'my_bloc_state.dart';

class MyBlocBloc extends Bloc<MyBlocEvent, MyBlocState> {
  MyBlocBloc() : super(MyBlocInitial()) {
    on<MyBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
