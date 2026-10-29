import 'package:flutter/widgets.dart';

import '../app/app_scope.dart';

/// Estado de um carregamento: carregando, sucesso ou erro.
sealed class AsyncState<T> {
  const AsyncState();
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.data);

  final T data;
}

class AsyncFailure<T> extends AsyncState<T> {
  const AsyncFailure(this.error);

  final Object error;
}

/// Carrega dados da API e recarrega quando o cenário muda ou os dados são restaurados.
///
/// A tela implementa [load] e lê [loadState] no `build`.
mixin AsyncLoader<W extends StatefulWidget, T> on State<W> {
  AsyncState<T> loadState = AsyncLoading<T>();

  AppServices get services => AppScope.of(context);

  int _requestId = 0;
  Listenable? _changes;

  Future<T> load(AppServices services);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final changes = services.dataChanges;
    if (!identical(changes, _changes)) {
      _changes?.removeListener(reload);
      _changes = changes..addListener(reload);
      _fetch(notify: false);
    }
  }

  @override
  void dispose() {
    _changes?.removeListener(reload);
    super.dispose();
  }

  /// Busca de novo. Respostas antigas que chegarem depois são descartadas.
  Future<void> reload() => _fetch(notify: true);

  Future<void> _fetch({required bool notify}) async {
    final requestId = ++_requestId;
    if (notify) {
      setState(() => loadState = AsyncLoading<T>());
    } else {
      // Primeira busca, ainda antes do build: não precisa de setState.
      loadState = AsyncLoading<T>();
    }
    try {
      final data = await load(services);
      if (mounted && requestId == _requestId) setState(() => loadState = AsyncData<T>(data));
    } catch (error) {
      if (mounted && requestId == _requestId) setState(() => loadState = AsyncFailure<T>(error));
    }
  }

  /// Atualiza os dados localmente, sem nova busca (ex.: depois de cancelar uma reserva).
  void setData(T data) => setState(() => loadState = AsyncData<T>(data));
}
