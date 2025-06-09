import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'model_bloc.dart';
import 'model_event.dart';
import 'model_repo.dart';
import 'model_state.dart';

class ModelHomePage extends StatelessWidget {
  const ModelHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ModelBloc(ModelRepository())..add(FetchModelsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Modeller')),
        body: BlocBuilder<ModelBloc, ModelState>(
          builder: (context, state) {
            if (state is ModelLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ModelLoaded) {
              return ListView.builder(
                itemCount: state.models.length,
                itemBuilder: (context, index) {
                  final model = state.models[index];
                  return ListTile(
                    leading: Image.network(model.pic),
                    title: Text(model.title),
                    subtitle: Text(model.category),
                  );
                },
              );
            } else if (state is ModelError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
