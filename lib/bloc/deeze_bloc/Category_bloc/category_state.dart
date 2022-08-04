part of 'category_bloc.dart';

@immutable
abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class LoadedCategory extends CategoryState {
  Categories? categories;
  LoadedCategory({this.categories});
}

class Error extends CategoryState {}
