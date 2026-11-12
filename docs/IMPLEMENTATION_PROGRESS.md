# Repara — Progresso de implementação

> **Fonte de verdade do plano:** `docs/IMPLEMENTATION_SPEC.md`.
>
> Este arquivo existe para continuidade entre sessões/contextos. Antes de retomar,
> leia a spec, este progresso e inspecione o código atual. Não confie apenas na
> memória da conversa.

## Restrições ativas

- **Sem backend.** Nada de HTTP, DTOs de rede, endpoints, auth ou regras de backend.
- **Sem git por enquanto.** Não executar `git init`, commits ou pushes. Os quality
  gates foram adaptados (2026-11-11) para pular `git diff --check` com aviso explícito
  quando não houver repositório.
- **Dados mockados** e câmera/GPS falsos no MVP.
- **Usar o orquestrador do harness** para conduzir as fases; ele delega aos especialistas
  (`flutter-engineer`, `ui-reviewer`, `qa-engineer`, etc.).
- Uma fase por vez; parar ao final de cada fase e reportar evidências.

## Status das fases

| Fase | Status | Observação |
|---|---|---|
| 0 — Fundação | **Concluída (implementação + QA/revisão independentes)** | Revisão independente (2026-11-11) sem achados críticos/altos; gates verdes; `flutter run` manual pendente (sem device) |
| 1 — Design system | Pendente | Próxima fase |
| 2 — Domínio/mocks | Pendente | |
| 3 — Tela Mapa | Pendente | |
| 4 — Captura | Pendente | |
| 5 — Etapas 2/3 e 3/3 | Pendente | |
| 6 — Hardening/QA | Pendente | |

## Fase 0 — o que foi feito

Dependências e assets (registro completo em `docs/DEPENDENCIES.md`):

- `pubspec.yaml`: `flutter_riverpod ^3.5.0`, `go_router ^18.1.4`, `intl ^0.20.3`,
  `flutter_localizations` (SDK); dev: `mocktail ^1.0.5` (desvio aprovado),
  `integration_test` (SDK), `flutter_lints` (template).
- `assets/fonts/Sora.ttf` (SIL OFL), registrada como família `Sora` na seção
  `fonts:` do `pubspec.yaml`.
- `assets/images/capture_placeholder.png` (prévia fake de câmera).

Implementação:

- `lib/app/theme/`: `tokens.dart` (cores, espaçamento, raios, durações, sombras),
  `typography.dart` (escala Sora variável com `fontVariations`, sem import de
  `dart:ui`), `app_theme.dart` (tema claro e tema de captura).
- `lib/main.dart`: entry point delegando para `bootstrap()`.
- `lib/app/bootstrap.dart`: `ProviderScope` + `runApp` + contenção de erros de
  configuração (erro de config nunca é engolido; vira tela de erro).
- `lib/app/app.dart`: `ReparaApp` com `MaterialApp.router`, locale `pt_BR`,
  `supportedLocales`, títulos pt-BR.
- `lib/app/configuration_error_app.dart`: tela de fallback para falha de
  configuração.
- `lib/app/router/app_router.dart`: `AppRoutes` + `appRouterProvider` +
  `buildAppRouter`; rota `/` (`MapPage` placeholder com CTA “Registrar”) e fluxo
  `/report/{capture,details,review,success}` como rotas filhas de `/` (mantém o
  affordance de voltar para o mapa). `/dev/design-system` fica para a Fase 1.
- `lib/core/config/app_config.dart`: `MOCK_MODE`/`MOCK_SCENARIO` via
  `--dart-define`; mock desabilitado por padrão em release (`_defaultMockMode =
  !kReleaseMode`) com `releaseMockDisabledMessage` explicativa; cenário inválido
  lança `AppConfigError` com a lista de valores aceitos.
- `lib/features/map/presentation/pages/map_page.dart`: placeholder identificável.
- `lib/features/report/presentation/pages/`: stubs `capture`, `details`, `review`,
  `success` com textos pt-BR exatos, marcados como “stub da Fase 0; implementação na
  Fase 4/5”.

Testes:

- `test/helpers/pump_app.dart`: `pumpApp` com overrides (tipo `Override` importado de
  `package:flutter_riverpod/misc.dart` — não exportado pelo barrel principal no
  Riverpod 3.5).
- `test/widget_test.dart`: smoke tests — boot na rota `/` com o título “Repara”;
  “Registrar” abre o stub de captura e voltar retorna ao mapa (tap no tooltip
  localizado, pois `tester.pageBack()` assume o tooltip “Back” em inglês); rotas do
  fluxo resolvem para suas páginas stub (com pump de um widget vazio entre rotas —
  trocar overrides de providers funcionais já criados não reexecuta o `create` no
  Riverpod 3.5).
- `test/core/config/app_config_test.dart`: parsing de cenário; cenário inválido falha
  com mensagem clara; guardas de release.
- `test/app/bootstrap_test.dart`: modo mock inicializa o app real; erro de
  configuração mostra a tela de fallback.

Quality gates adaptados para repositório não-git:

- `tool/quality.ps1` e `tool/quality.sh`: pulam `git diff --check` com aviso quando
  não há `.git`. No `.ps1`, as linhas de SKIP usam hífen ASCII em vez de travessão:
  o Windows PowerShell 5.1 não interpreta UTF-8 sem BOM (pwsh não está instalado).
  O `.sh` mantém o travessão.

## Fase 0 — evidências (2026-11-11)

Comandos executados e códigos de saída:

| Comando | Resultado |
|---|---|
| `dart format .` | exit 0 — 18 arquivos, 0 alterados |
| `flutter analyze` | exit 0 — “No issues found!” |
| `flutter test` | exit 0 — 8 testes, todos passando |
| `powershell -ExecutionPolicy Bypass -File tool/quality.ps1` | exit 0 — “QUALITY GATES: PASS (skipped: git whitespace check - not a git repository)” |
| `bash tool/quality.sh` | exit 0 — “QUALITY GATES: PASS (skipped: git whitespace check — not a git repository)” |

`flutter run` NÃO foi executado (sem device/emulador nesta sessão); a inicialização
do app é coberta pelos smoke tests de widget. O critério de aceite “flutter run abre
o app sem erro” permanece como verificação manual pendente.

Decisões registradas em 2026-11-11 (também na spec §2.1/§Fase 0 e em
`docs/DEPENDENCIES.md`):

- `mocktail` 1.0.5 dev-only aprovado como desvio da spec; fakes escritos à mão
  continuam como padrão para serviços do app.
- Quality gates adaptados em vez de `git init`; `git init` + baseline commit ficam
  pendentes de aprovação separada.
- `MOCK_MODE` confirmado como padrão de desenvolvimento: `true` em
  debug/profile, `false` em release (opt-in explícito apenas para builds de
  demonstração).
- Fonte Sora em uso (asset disponível, conforme a regra da spec §Fase 0).

## QA independente (qa-engineer, 2026-11-11)

**Concluída.** Os gates da Fase 0 foram executados de forma independente pelo
`qa-engineer`; a tabela de evidências do implementador acima foi reproduzida
integralmente (mesmos comandos, mesmos códigos de saída):

| Comando | Resultado |
|---|---|
| `flutter pub get` | exit 0 |
| `dart format .` (checagem de formatação) | exit 0 — “Formatted 18 files (0 changed)” |
| `flutter analyze` | exit 0 — “No issues found!” |
| `flutter test` | exit 0 — 8 testes, todos passando |
| `powershell -ExecutionPolicy Bypass -File tool/quality.ps1` | exit 0 — imprime o SKIP explícito da checagem de whitespace do git: “SKIP: no .git directory - repository not initialized …” |
| `bash tool/quality.sh` | exit 0 — imprime o SKIP explícito: “SKIP: no .git directory — repository not initialized …” |

`flutter run` NÃO foi executado (sem device/emulador) e é o único critério
manual em aberto da Fase 0.

**Re-verificação final independente (qa-engineer, 2026-11-11, estado
pós-correções M-1/M-2):** `dart format --output=none --set-exit-if-changed .`
exit 0 (18 arquivos, 0 alterados), `flutter analyze` exit 0 (“No issues
found!”), `flutter test` exit 0 — **9/9 testes**, incluindo o de regressão de
overflow; `tool/quality.ps1` e `tool/quality.sh` exit 0 com o SKIP do git
reportado explicitamente. Sem introdução de rede/DTO/auth/persistência
(greps reexecutados). Veredito do QA: **Fase 0 pode ser fechada**, com
`flutter run` pendente de verificação manual com device (sem bloqueio).

### Revisão independente (ui-reviewer, 2026-11-11)

Sem achados críticos ou altos. Desdobramento registrado:

- **M-1 (médio) corrigido:** `lib/app/configuration_error_app.dart` agora centra
  o conteúdo quando cabe e rola quando não cabe (`SingleChildScrollView`
  envolvendo a `Column` existente, com o `Padding` movido para dentro do
  scroll), preservando textos, tokens e estilos. Teste de regressão adicionado
  em `test/app/bootstrap_test.dart` (“configuration error screen does not
  overflow at 2.0 text scale on a small screen”; escala de texto 2.0 em
  superfície lógica 360×640 — antes da correção falhava com overflow de
  1596 px). Gates reexecutados após as correções: verdes, 9 testes passando
  (incluindo o de regressão).
- **M-2 (médio) documentado:** a restrição de navegação do fluxo de relato
  (push/pop entre etapas, nunca `context.go`; `SuccessPage` sem back automático
  do AppBar) foi registrada no doc comment “Deferred work” de
  `lib/app/router/app_router.dart`.
- **Achados baixos (L-1 a L-7):** registrados como follow-ups com fase-alvo
  (lista abaixo).

### Follow-ups da revisão (achados baixos, com fase-alvo)

- **L-1** — inconsistência de estilo de import (`package:` vs relativo em
  `lib/`) → **Fase 1**.
- **L-2** — validar `MOCK_MODE` como o `MOCK_SCENARIO` é validado (string bruta
  + `AppConfigError`, em vez do fallback silencioso de `bool.fromEnvironment`)
  → **Fase 2**.
- **L-3** — teste direto do glue try/catch do `bootstrap()` (extrair uma
  factory pura de root-app) → **Fase 1/2**.
- **L-4** — cachear `AppTheme.light`/`ReparaTypography.textTheme` como
  `static final` em vez de getters por acesso → **Fase 1** (arquivos de tema
  pré-existentes).
- **L-5** — `errorBuilder` pt-BR no GoRouter (a página de erro padrão renderiza
  em inglês; inalcançável hoje) → **Fase 1+**.
- **L-6** — observar o import de `Override` de
  `package:flutter_riverpod/misc.dart` em upgrades do Riverpod.
- **L-7** — informativo: `ConfigurationErrorApp` não fixa locale; adicionar
  apenas se algum dia ganhar widgets localizados.
- **M-2 (restrição a levar para o plano das Fases 4/5):** navegação intra-fluxo
  com push/pop (nunca `context.go` entre etapas) e `SuccessPage` sem back
  automático (“Voltar ao mapa” via `go('/')` + limpeza do rascunho) — já
  registrada em `lib/app/router/app_router.dart`.

## Próximos passos (Fase 1)

1. Componentes base do design system e galeria `/dev/design-system` (apenas debug).
2. Reconciliar tipografia com a spec §5.2: label 12/600 + caption 12/500.
3. Follow-ups da revisão independente com alvo na Fase 1/1+: L-1 (estilo de
   import), L-3 (factory pura testável do `bootstrap()`), L-4 (cache de tema),
   L-5 (`errorBuilder` pt-BR).
4. Fase 2 depois: domínio, repositório mock, providers; mover `MockScenario` para
   `features/demands/data/mock/` (tarefa documentada em
   `lib/core/config/app_config.dart`); incluir L-2 (validação de `MOCK_MODE`).

## Comando para retomar com o orquestrador

```bash
opencode run --agent orchestrator --auto "Leia AGENTS.md, docs/IMPLEMENTATION_SPEC.md e docs/IMPLEMENTATION_PROGRESS.md. A Fase 0 está implementada, revisada e com QA verde (exceto flutter run, sem device). Planeje a Fase 1 de acordo com a spec e o usuário; não a execute sem aprovação. Não inicialize git. Pare ao final e reporte evidências."
```

## Decisões que continuam pendentes

- Etapas 2/3 e 3/3 (Q1), “Encaminhada” (Q2), “Iluminação apagada” (Q3), controles da
  captura (Q4), busca/Trocar (Q5).
- `git init` + baseline commit (aprovação separada).
