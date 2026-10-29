# Instruções para agentes de IA

Projeto base fictício ("Rota") em Flutter, usado para testar ferramentas de design e código. A descrição completa, as rotas e os cenários estão no [README.md](README.md).

## Comandos

- `flutter pub get`: Instala as dependências.
- `flutter run -d web-server --web-port 8080 --no-web-resources-cdn`: Servidor de desenvolvimento em `http://localhost:8080`.
- `flutter analyze`: Análise estática. Precisa terminar com "No issues found!" antes de concluir qualquer mudança.
- `flutter test`: Testes de widget e de unidade. Precisam passar antes de concluir qualquer mudança.
- `flutter build web --no-web-resources-cdn`: Build da web. Precisa funcionar antes de concluir qualquer mudança.

## Convenções

- Interface, comentários e documentação em português brasileiro. Nomes de código (classes, variáveis, arquivos) em inglês.
- Use sempre os tokens de `lib/design_system/tokens`: cores com `context.rotaColors`, sombras com `context.rotaShadows`, e `RotaSpacing`, `RotaRadius`, `RotaTypography` e `RotaMotion`. Nunca use cores, tamanhos ou espaçamentos soltos.
- Componentes reutilizáveis ficam em `lib/design_system/components`, com prefixo `Rota`, e são exportados por `lib/design_system/design_system.dart`. Componentes de domínio ficam em `lib/features/`.
- Uma página por rota em `lib/pages/`. Toda rota nova entra em `lib/app/routes.dart`, com nome em `AppRoutes`. Navegue com `context.goNamed`.
- Toda tela que carrega dados usa o mixin `AsyncLoader` (`lib/utils/async_loader.dart`), que recarrega quando o cenário muda, e trata os estados de loading, erro e vazio.
- Não adicione dependências, fontes da web ou imagens remotas sem necessidade: o projeto precisa rodar offline e dentro de sandboxes. Ilustrações são desenhadas em código ou ficam em `assets/`.
- Não use `SharedPreferences` direto. Use `KeyValueStore` (`lib/utils/storage.dart`), que cai para memória quando o storage está bloqueado.
- Os dados são fictícios e ficam em `lib/api/data.dart`. Não coloque dados pessoais reais nem segredos no repositório.
- Testes ficam em `test/` e usam o helper `pumpRotaApp` (`test/helpers/pump_app.dart`), que abre o app numa rota com storage em memória e atraso curto na API.
