# Rota (Flutter)

App fictício de reserva de experiências de viagem pelo Brasil, feito em Flutter. Serve como projeto base para testar ferramentas de design e código (importação de repositório, Code Layers do Figma, agentes de IA, cursos etc.).

É a versão Flutter do [test-project-react](https://github.com/edufrodrigues/test-project-react), com as mesmas telas, dados e textos.

Todos os dados são falsos e ficam no próprio dispositivo. Não há backend, chamadas externas, fontes da web ou imagens remotas: o projeto roda offline.

## Como rodar

Requer Flutter 3.47.8 (stable) com Dart 3.13.7, a versão usada para criar o projeto.

```bash
flutter pub get
```

```bash
flutter run -d chrome --no-web-resources-cdn
```

A flag `--no-web-resources-cdn` faz o Flutter servir o CanvasKit localmente em vez de baixá-lo de um CDN. Sem ela, o app precisa de internet para abrir na web.

Para servir numa porta fixa e abrir em qualquer navegador (é o que o preview do Claude Code usa, via `.claude/launch.json`):

```bash
flutter run -d web-server --web-port 8080 --no-web-resources-cdn
```

O app abre em `http://localhost:8080`.

| Comando | O que faz |
|---|---|
| `flutter run -d chrome --no-web-resources-cdn` | Roda na web com hot reload |
| `flutter build web --no-web-resources-cdn` | Build de produção em `build/web` |
| `flutter test` | Testes de widget e de unidade |
| `flutter analyze` | Análise estática com `flutter_lints`, sem avisos |

### Plataformas

- **Web**: É a plataforma principal, testada e com build verificado.
- **Android**: As pastas foram geradas, mas o build não foi testado. Precisa de um JDK instalado (`flutter doctor` mostra o que falta).
- **iOS**: As pastas foram geradas, mas o build só roda em macOS com Xcode.

## Telas e rotas

As rotas usam [go_router](https://pub.dev/packages/go_router) com nomes, definidos em [lib/app/routes.dart](lib/app/routes.dart). Na web, cada rota é um link que pode ser aberto direto.

| Tela | Rota | Nome | Estados disponíveis |
|---|---|---|---|
| Explorar | `/` | `explore` | Loading (skeleton), erro com "tentar de novo", vazio, sem resultados na busca, sucesso |
| Detalhe da experiência | `/experiencias/:id` | `experience` | Loading, não encontrada, erro, sucesso |
| Reserva (formulário) | `/experiencias/:id/reservar` | `booking` | Validação por campo, máscara de telefone, enviando, erro no envio mantendo os dados, sucesso |
| Confirmação | `/reserva/:codigo/confirmada` | `confirmation` | Loading, não encontrada, sucesso |
| Minhas reservas | `/reservas` | `bookings` | Abas (próximas, passadas, canceladas), vazio por aba, diálogo de cancelamento, toast |
| Perfil | `/perfil` | `profile` | Formulário com salvar, troca de tema (claro, escuro, sistema), preferências com switches |
| Página não encontrada | qualquer outra | | 404 |

Fluxo principal: Explorar → Detalhe → Reserva → Confirmação → Minhas reservas.

As rotas ficam aninhadas em `/`, então o botão voltar (do app, do navegador ou do Android) sempre tem para onde ir: da reserva volta ao detalhe, do detalhe volta à lista.

Os filtros da tela Explorar ficam na URL (`?q=paraty&categoria=natureza&ordem=menor-preco`), assim como a aba de reservas (`?aba=passadas`).

Experiências disponíveis, para montar links: `mergulho-baia-do-sancho`, `trilha-pai-inacio`, `saveiro-ilhas-paraty`, `vinhos-vale-dos-vinhedos`, `sabores-ver-o-peso`, `balao-boituva`, `rafting-jacare-pepira`, `caminhada-ouro-preto` e `estrelas-jalapao`. Reservas de exemplo: `RT-7Q2K`, `RT-3MZ8` e `RT-9HXA`.

## Simulador de cenários

A API falsa ([lib/api/fake_api.dart](lib/api/fake_api.dart)) responde de acordo com o cenário ativo. Troque pelo botão flutuante "Cenário" no canto inferior direito ou, na web, pela URL:

| URL | Comportamento |
|---|---|
| `?cenario=normal` | Dados de exemplo com atraso de cerca de 0,8 s |
| `?cenario=lento` | Atraso de 4 s, para observar os loadings |
| `?cenario=erro` | Todas as chamadas falham |
| `?cenario=vazio` | Listas vazias e detalhes "não encontrados" |
| `?cenario=erro-envio` | As telas carregam, mas reservar, cancelar e salvar o perfil falham |

Exemplos:

- `http://localhost:8080/?cenario=lento` mostra o skeleton da lista por 4 segundos.
- `http://localhost:8080/reservas?cenario=vazio` mostra o estado vazio das reservas.
- `http://localhost:8080/experiencias/trilha-pai-inacio/reservar?cenario=erro-envio` permite ver o erro ao confirmar a reserva.

O cenário da URL é lido quando o app abre e fica em memória. Ao recarregar a página sem o `?cenario=`, ele volta para "normal". Reservas, perfil e tema ficam salvos no dispositivo (no `localStorage`, na web). Para voltar ao estado inicial, use "Restaurar dados de exemplo" no painel de cenários.

## Estrutura

```
lib/
  main.dart           Inicialização: URLs, datas em pt-BR, storage e cenário
  api/                Modelos, dados de exemplo, cenários e API falsa
  app/                App, rotas, serviços globais (AppScope) e tema
  design_system/
    tokens/           Cores, sombras, tipografia, espaçamento, raios e movimento
    components/       Componentes reutilizáveis (prefixo Rota)
    rota_theme.dart   ThemeData claro e escuro montado a partir dos tokens
  features/
    booking/          Validação do formulário e máscara de telefone
    experiences/      Ilustração em CustomPainter e card de experiência
    layout/           Cabeçalho, rodapé, painel de cenários e layouts de página
  pages/              Uma página por rota
  utils/              Datas, formatação, storage seguro, busca sem acento e AsyncLoader
assets/fonts/inter/   Fonte Inter local e sua licença (OFL)
test/                 Testes de widget e de unidade, com o helper pumpRotaApp
web/                  index.html, manifest e ícones da versão web
android/, ios/        Projetos nativos gerados pelo flutter create
```

## Design system

Os tokens ficam em [lib/design_system/tokens](lib/design_system/tokens), com os mesmos valores do `tokens.css` da versão React:

- **Cores**: `RotaColors`, uma `ThemeExtension` com base, marca e feedback. O tema escuro troca só essa extensão. Leia com `context.rotaColors`.
- **Sombras**: `RotaShadows`, também uma `ThemeExtension`, lida com `context.rotaShadows`.
- **Tipografia**: `RotaTypography`, com tamanhos, pesos, entrelinhas e estilos prontos (`display`, `title`, `sectionTitle`, `body`, `label`, `caption` etc.).
- **Espaçamento e forma**: `RotaSpacing` (escala de 4 px: `s1` = 4, `s4` = 16), `RotaRadius`, `RotaLayout` (largura do container e pontos de quebra) e `RotaMotion`.

O tema (claro, escuro ou sistema) é escolhido na tela de Perfil.

Componentes em [lib/design_system/components](lib/design_system/components):

- `RotaButton`: variantes `primary`, `secondary`, `ghost` e `danger`, tamanhos `sm`, `md` e `lg`, ícone e estado `loading`.
- `RotaTextField` e `RotaSelect`: com `label`, `hint`, `error` e `required`.
- `RotaCheckbox`, `RotaSwitch` e `RotaChip`.
- `RotaBadge` e `RotaAlert`: tons `neutral`, `primary`, `success`, `warning`, `danger` e `info`.
- `RotaCard`, `RotaAvatar`, `RotaRating`, `RotaBreadcrumb` e `RotaTabs`.
- `RotaSkeleton`, `RotaEmptyState` e `RotaErrorState`.
- `RotaDialog` (com `showRotaDialog`) e toast (com `showRotaToast`, sobre o SnackBar do Material).

As ilustrações das experiências são desenhadas em código ([experience_art.dart](lib/features/experiences/experience_art.dart)) com um `CustomPainter`, a partir de uma paleta por experiência.

## Stack

- Flutter 3.47.8 e Dart 3.13.7
- go_router 18.1.2 para rotas nomeadas e deep links
- shared_preferences 2.5.6 para guardar reservas, perfil e tema
- intl (versão fixada pelo SDK) e flutter_localizations para datas, moeda e widgets em pt-BR
- flutter_lints 6.0.0 para a análise estática
- Material Icons (vêm no SDK) e fonte Inter 4.1 local

Não há pacote de gerenciamento de estado: os serviços ficam num `InheritedWidget` ([AppScope](lib/app/app_scope.dart)) e as telas usam `ChangeNotifier`, `ValueNotifier` e `ListenableBuilder`.

## Duplicar para testes

Para criar cópias de teste, copie a pasta sem os arquivos de build e de cache, e rode `flutter pub get` na cópia. Esses arquivos são grandes, guardam caminhos absolutos da pasta original e são recriados sozinhos.

No PowerShell:

```powershell
robocopy "C:\Projects\design-ops\test-project-flutter" "C:\Projects\design-ops\test-project-flutter-teste-1" /E /XD build .dart_tool .gradle Pods .symlinks ephemeral /XF .flutter-plugins-dependencies
```

```powershell
cd "C:\Projects\design-ops\test-project-flutter-teste-1"; flutter pub get
```

O `robocopy` retorna código 1 quando copia arquivos com sucesso. Isso é normal.

A pasta `.git` vem junto na cópia, então cada teste começa do mesmo commit inicial. Para ver o que uma ferramenta alterou, rode `git status` ou `git diff` na cópia.

## Roteamento com hash

Algumas ferramentas servem o app dentro de um iframe ou em uma subpasta, e aí as rotas normais (`/reservas`) podem não funcionar. Nesse caso, rode ou gere o build com:

```bash
flutter run -d chrome --no-web-resources-cdn --dart-define=ROUTER=hash
```

As rotas passam a usar `#` (`/#/reservas`). O cenário também pode ir na URL nesse modo: `/#/reservas?cenario=vazio`.

Para servir o build em uma subpasta, use também `--base-href /caminho/` no `flutter build web`.

## Observações

- O Flutter web desenha a interface num `<canvas>`, não em HTML. Ferramentas que leem o DOM e o CSS não veem os componentes como elementos. Para ajudar, o app liga a árvore de acessibilidade na web ([lib/main.dart](lib/main.dart)), que cria no DOM elementos com os textos, botões e campos. Isso também é o que leitores de tela usam.
- A pasta `.claude/launch.json` configura o servidor de desenvolvimento para o preview do Claude Code. Outras ferramentas ignoram esse arquivo.
- As datas disponíveis e as reservas de exemplo são calculadas a partir do dia atual, então o app nunca mostra só datas vencidas.
- A fonte Inter é distribuída sob a SIL Open Font License, incluída em [assets/fonts/inter/OFL.txt](assets/fonts/inter/OFL.txt).
