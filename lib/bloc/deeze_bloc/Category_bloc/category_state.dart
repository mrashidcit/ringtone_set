part of 'category_bloc.dart';

@immutable
abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class LoadedCategory extends CategoryState {
  List<CategoriesModel>? categories;
  LoadedCategory({this.categories});
}

class Error extends CategoryState {}
