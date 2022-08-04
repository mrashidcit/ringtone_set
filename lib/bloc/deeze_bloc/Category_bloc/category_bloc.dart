import 'package:bloc/bloc.dart';
import 'package:deeze_app/bloc/deeze_bloc/Category_bloc/category_repo.dart';

import 'package:meta/meta.dart';

import '../../../models/categories.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository = CategoryRepository();
  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategory>((event, emit) async {
      // TODO: implement event handler
      emit(await _categoryRepository.getCategories());
    });
  }
}
