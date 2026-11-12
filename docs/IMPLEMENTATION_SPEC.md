# Repara — Spec de implementação frontend

> **Versão:** 1.0 · **Data:** 2026-11-11 · **Status:** proposta para aprovação
>
> **Escopo desta spec:** cliente Flutter apenas. O backend Java ainda não existe; toda a
> leitura/escrita será feita sobre dados mockados e interfaces substituíveis.
>
> **Fonte visual:** `Repara.pdf` — protótipo mobile 390 × 844, com as telas **01 Mapa** e
> **02 Captura** (1 de 3).
>
> **Documentos que continuam mandando:** `AGENTS.md`, `docs/ARCHITECTURE.md`,
> `docs/API_CONTRACT.md`, `docs/DEFINITION_OF_DONE.md` e `docs/WORKFLOW.md`.

---

## 1. Resumo executivo

O Repara é um app cidadão para registrar problemas urbanos. Cada relato é uma
**ocorrência**; ocorrências do mesmo problema são agrupadas em uma **demanda**. A
contagem exibida nos pinos e nos cards é de **relatos independentes**, não de demandas.

O PDF mostra duas telas:

1. **01 Mapa** — mapa da região, demandas próximas, CTA “Registrar”.
2. **02 Captura** — etapa 1 de 3 do fluxo de nova ocorrência, com câmera e localização.

O que falta no PDF (etapas 2/3 e 3/3, sucesso, lista completa, busca) será tratado como
**proposta**, explicitamente marcada, até validação de produto/design. Nada disso deve ser
apresentado como contrato fechado.

**Decisões propostas para esta primeira versão:**

- Riverpod para estado e go_router para navegação (as duas já são sugestões do harness;
  exigem aprovação antes de entrar no `pubspec.yaml`).
- Mapa estilizado com `CustomPaint`, sem tiles externos e sem chave de API nesta fase.
- Câmera e GPS **falsos** (`FakeCaptureService`, `FakeLocationService`) atrás de interfaces
  substituíveis. Permissões e hardware real ficam para o pós-MVP.
- Repositório em memória (`MockReparaRepository`), determinístico, com cenários de
  sucesso, vazio, erro e lentidão. **Nenhum HTTP, nenhum DTO e nenhum endpoint inventado.**
- 7 fases (0 a 6), cada uma com gate de qualidade e revisão independente.

---

## 2. Contexto e estado atual

### 2.1 O que existe hoje

| Item | Estado |
|---|---|
| App Flutter | Scaffold padrão com contador em `lib/main.dart` |
| Flutter/Dart | Flutter 3.47.1 · Dart 3.13.1 (stable) |
| Estado | Nenhuma biblioteca de estado instalada |
| Navegação | Nenhum roteador instalado |
| Backend | Inexistente. `docs/API_CONTRACT.md` tem schemas de domínio, mas **não tem endpoints, auth, base URL nem formatos de resposta** |
| Testes | Apenas o `widget_test.dart` padrão do contador |
| Git | O diretório ainda não é um repositório git; em 2026-11-11 foi decidido adaptar os quality gates (`tool/quality.ps1`/`tool/quality.sh`) para ignorar `git diff --check` com aviso explícito quando não houver repositório |
| Harness | `AGENTS.md`, agentes, skills e quality gates presentes |

### 2.2 Consequências para o plano

- Podemos modelar o domínio a partir dos schemas existentes, mas **não podemos criar
  rotas, campos de resposta, autenticação ou regras de matching**.
- O app precisa rodar e ser demonstrável sem backend, com dados mockados explícitos.
- A camada de dados deve ser trocável sem reescrever a UI. Isso é feito por uma interface
  de repositório e serviços falsos, não por HTTP prematuro.
- O `git init` e a aprovação de dependências são pré-requisitos da Fase 0.

---

## 3. Escopo, premissas e não-escopo

### 3.1 Dentro do escopo desta iniciativa

- Shell do app, tema, rotas e injeção de dependências.
- Tela **01 Mapa** completa: cabeçalho, seletor de região, mapa estilizado, pinos,
  CTA “Registrar”, bottom sheet com demandas próximas e interações.
- Fluxo **Nova ocorrência**: etapa 1/3 (captura), etapas 2/3 e 3/3 propostas, envio mock
  e tela de sucesso.
- Estados explícitos de loading, sucesso, vazio e erro em todas as telas com dados.
- Acessibilidade, responsividade, testes, documentação e quality gates.
- Dados mockados determinísticos e cenários de teste.

### 3.2 Fora do escopo agora

- Backend Java, HTTP, OpenAPI, autenticação, refresh token, persistência remota.
- Câmera e GPS reais, permissões de sistema, upload de imagens.
- Mapas reais com tiles (Google Maps, Mapbox, OpenStreetMap) e geocodificação.
- Login, cadastro, perfil, “minhas ocorrências”, acompanhamento de protocolo.
- App do gestor, revisão de matching, administração.
- Push notifications, analytics, crash reporting, deep links, modo offline.
- Internacionalização além de pt-BR e tema escuro global.
- Publicação em lojas, assinatura, CI/CD de release.

### 3.3 Premissas

| ID | Premissa | Impacto se falsa |
|---|---|---|
| A1 | O uso é anônimo nesta versão; não há tela de login. O schema permite `ocorrencia.usuario` nulo. | Fluxo de auth teria que entrar antes do registro |
| A2 | Idioma único: pt-BR. | Textos e localizações precisam de i18n |
| A3 | Referência visual: 390 × 844; suportar de 360 × 640 a 430 × 932 em retrato. | Layout pode precisar de outra estratégia |
| A4 | Os dados mockados são de demonstração e nunca devem ser apresentados como dados reais. | Risco de produto/QA |
| A5 | O fluxo tem 3 etapas; o PDF só mostra a primeira. As etapas 2/3 e 3/3 são propostas. | Retrabalho na Fase 5 |
| A6 | O status exibido como “Encaminhada” é um rótulo de apresentação, não um novo status de domínio. | Precisa de novo enum ou campo no backend |
| A7 | O termo “Iluminação apagada” do PDF não existe no seed do contrato; será tratado como título exibido de uma demanda de “Poste caído”. | Pode ser uma quinta categoria real |
| A8 | O envio mock não simula matching nem altera os contadores do mapa. | Demonstração pode parecer “sem efeito” após enviar |
| A9 | Sem câmera/GPS reais, a captura usa uma prévia simulada e uma localização fixa de precisão ±8 m. | Permissões e hardware entram no pós-MVP |
| A10 | O rascunho vive em memória e é perdido ao fechar o app. | Persistência local não está no MVP |

---

## 4. O que está no PDF vs. o que é inferido

O PDF tem **uma única página** com as duas telas lado a lado. Os frames são cortados na
borda inferior da página — por isso os controles de baixo da captura não aparecem. Isso não
é uma escolha de design; é uma limitação do artefato.

| Tela / elemento | Evidência no PDF | Status |
|---|---|---|
| 01 Mapa — cabeçalho, região, pinos, CTA, sheet | Visível | **Especificado** |
| 02 Captura — etapa 1/3 | Visível | **Especificado** |
| Controles inferiores da captura | Cortados na borda do PDF | **Inferido** (Q4) |
| Etapas 2/3 e 3/3 | Não aparecem | **Proposta** (Q1) |
| Tela de sucesso | Não aparece | **Proposta** |
| “Ver lista” | Botão visível, destino não | **Proposta:** expandir o sheet (Q10) |
| “Trocar” região | Botão visível, destino não | **Proposta:** sheet com 3 regiões mockadas (Q5) |
| Busca (ícone de lupa) | Ícone visível, destino não | **P2 opcional:** busca local mockada; se não aprovada, remover o ícone (Q5) |
| “Iluminação apagada” | Card parcialmente visível | **Proposta:** título de uma demanda de “Poste caído” (Q3) |
| “Encaminhada” | Chip visível | **Proposta:** rótulo de `EM_ANDAMENTO` (Q2) |

> Regra: tudo marcado como inferido/proposta deve ser validado antes de ser tratado como
> requisito fechado. O agente implementador não deve “completar” o contrato por conta própria.

---

## 5. Referência visual e design tokens

### 5.1 Cores (aproximadas do PDF — validar na Fase 1)

| Token | Hex | Uso |
|---|---|---|
| `brand.primary` | `#26684D` | Ícone da marca, ações verdes |
| `brand.ink` | `#0E3B2C` | Wordmark “Repara” |
| `brand.soft` | `#D9EEE5` | Fundos suaves, realce |
| `accent.amber` | `#F2A324` | CTA “Registrar” e obturador |
| `accent.amberPressed` | `#D98B14` | Estado pressionado |
| `canvas` | `#F5F7F6` | Fundo geral |
| `surface` | `#FFFFFF` | Cabeçalho, cards, sheet |
| `surface.muted` | `#EEF3EF` | Thumbnails, campos |
| `map.canvas` | `#E8EDE9` | Fundo do mapa |
| `map.block` | `#F2F5F2` | Quadras claras |
| `map.blockAlt` | `#DDE9E0` | Quadras verdes |
| `map.road` | `#FFFFFF` | Vias |
| `map.water` | `#DCE9ED` | Área de água |
| `ink` | `#1A2420` | Texto principal |
| `ink.muted` | `#66716B` | Texto secundário |
| `border` | `#E1E7E2` | Bordas e divisores |
| `status.encaminhada.bg` | `#E9E1FA` | Fundo do chip “Encaminhada” |
| `status.encaminhada.fg` | `#5B3EA8` | Texto do chip |
| `marker.buraco` | `#1F5B8A` | Pino azul (provisório — Q11) |
| `marker.esgoto` | `#985B04` | Pino âmbar/marrom (provisório — Q11) |
| `marker.dejeto` | `#26684D` | Pino verde (provisório — Q11) |
| `marker.poste` | `#6B52A5` | Pino roxo (provisório — Q11) |
| `capture.bg` | `#1F2529` | Fundo da tela de captura |
| `capture.surface` | `#2C353A` | Painel da câmera |
| `capture.surfaceAlt` | `#343E43` | Superfícies elevadas |
| `capture.chip` | `#14181B` | Chip de localização |
| `capture.text` | `#F4F7F5` | Texto claro |
| `capture.textMuted` | `#A7B1AC` | Texto secundário claro |
| `error` | `#B3261E` | Erros |
| `success` | `#1F6B50` | Sucesso |

### 5.2 Tipografia

A fonte do protótipo parece uma sans geométrica. **Proposta:** `Sora` (licença OFL),
embutida como asset (sem `google_fonts` em runtime). Se o asset/licença não for aprovado,
usar a fonte padrão do Flutter e registrar o desvio visual; a troca deve acontecer em um
único ponto (`app/theme/typography.dart`).

| Estilo | Tamanho / altura | Peso | Uso |
|---|---|---|---|
| `display` | 28 / 34 | 700 | Wordmark, títulos de impacto |
| `h1` | 24 / 30 | 700 | Título de tela |
| `h2` | 20 / 26 | 600 | Título de seção |
| `h3` | 18 / 24 | 600 | Título de sheet/card |
| `title` | 16 / 22 | 600 | Títulos de cards, app bar |
| `body` | 15 / 22 | 400 | Texto corrido |
| `bodySmall` | 13 / 18 | 400 | Subtítulos, endereços |
| `label` | 12 / 16 | 600 | Chips, badges, botões pequenos |
| `caption` | 12 / 16 | 500 | Texto auxiliar |

### 5.3 Espaçamento, raios e elevação

- Espaçamento base: `4, 8, 12, 16, 20, 24, 32, 40`.
- Padding horizontal das telas: `16`.
- Raios: `8` (badges), `12` (tiles/inputs), `16` (cards), `24` (sheet/preview), `999` (pills).
- Toque mínimo: `48 × 48`, mesmo quando o desenho visual for menor.
- Sombra do CTA: `0 8 24 rgba(242,163,36,0.28)`.
- Sombra do sheet: `0 -8 32 rgba(26,36,32,0.08)`.
- Duração padrão de transição: `180–220 ms`, `easeOut`; respeitar `MediaQuery.disableAnimations`.

### 5.4 Medidas de referência (390 × 844)

**Tela 01 — Mapa**

| Região | Medida aproximada |
|---|---|
| Cabeçalho | 64 de altura + safe area; padding 16 |
| Logo | tile 40 × 40, raio 12 |
| Wordmark | 24–28, peso 700 |
| Botão de busca | 40 × 40, raio 12, borda 1 |
| Seletor de região | altura 48, raio 14, margem 16; texto 15; “Trocar” 14/600 verde |
| Mapa | ocupa o restante; pinos ~42 × 50; badge 22 |
| CTA | 56 de altura, raio 28, padding horizontal 20; ícone “+” 20 |
| Sheet | altura inicial ~30% (≈250), raio superior 24, handle 36 × 4 |
| Card | 76–80 de altura, raio 16, borda 1; thumbnail 64 × 64, raio 12 |
| Título do sheet | 18/600; “Ver lista” 14/600 verde |
| Chip de status | altura 24, raio 999, padding 8–10; texto 11–12/600 |

**Tela 02 — Captura**

| Região | Medida aproximada |
|---|---|
| Barra superior | 56 de altura; “Cancelar” à esquerda, título central, pill “1 de 3” à direita |
| Pill de etapa | ~64 × 28, raio 14, fundo `capture.surfaceAlt` |
| Preview | margem 16, raio 24, ocupa o espaço central |
| Cantos de enquadramento | 28 × 28, traço 3, raio 8 |
| Chip de localização | altura 36, raio 18, fundo `capture.chip`; ícone verde + texto 13/600 |
| Instrução inferior | 13–14, `capture.textMuted`, centralizada |
| Obturador | 72–76, círculo âmbar; anel externo sutil |

### 5.5 Ícones

Usar Material Icons na primeira versão (pin, search, plus, compass, camera, check,
error). Ícones específicos do protótipo podem ser substituídos por SVG depois, sem mudar
a estrutura dos componentes. Não criar assets proprietários sem licença.

---

## 6. Arquitetura e decisões técnicas

### 6.1 Decisões propostas (precisam de aprovação)

| Decisão | Proposta | Motivo | Alternativa |
|---|---|---|---|
| Estado | `flutter_riverpod` | Já sugerido em `docs/ARCHITECTURE.md`; testável; bom para `AsyncValue` | `provider`/`bloc` |
| Navegação | `go_router` | Rotas declarativas, guards e deep links futuros | Navigator 1.0 |
| HTTP | **Nenhum agora** | Backend inexistente; evitar contrato especulativo | `dio`/`http` no pós-MVP |
| Mapa | `CustomPaint` estilizado | Fidelidade visual, offline, testável, sem chave | `flutter_map` no pós-MVP |
| Câmera | `FakeCaptureService` | Sem permissões/hardware no MVP | `camera` no pós-MVP |
| GPS | `FakeLocationService` | Sem permissões/hardware no MVP | `geolocator` no pós-MVP |
| Persistência | Nenhuma | Rascunho efêmero | `shared_preferences`/`sqflite` depois |
| Serialização | Nenhuma | Sem rede | `json_serializable`/`freezed` depois |
| Fonte | Sora (asset) | Aproximação do protótipo | Fonte padrão + desvio documentado |

> Aprovações humanas exigidas pelo harness: adicionar dependências, inicializar git e
> qualquer mudança de contrato. A Fase 0 não começa sem essas decisões.
>
> Se a prioridade for uma demo com hardware real, a Fase 4 pode usar `camera`/`geolocator`
> em vez dos fakes, mantendo as mesmas interfaces. Isso adiciona permissões, dependências e
> testes em dispositivo, e exige aprovação separada; o restante do plano não muda.

### 6.2 Organização de pastas (árvore-alvo)

```text
lib/
  main.dart
  app/
    app.dart
    bootstrap.dart
    router/
      app_router.dart
    theme/
      app_theme.dart
      tokens.dart
      typography.dart
  core/
    formatting/
      plural.dart
      distance.dart
    widgets/
      app_error_view.dart
      app_empty_view.dart
      app_skeleton.dart
      primary_button.dart
      status_chip.dart
      step_badge.dart
  features/
    demands/
      domain/
        entities/
          categoria.dart
          coordenada.dart
          demanda.dart
          demanda_proxima.dart
          status_demanda.dart
        failures/
          repara_failure.dart
        repositories/
          repara_repository.dart
      data/
        mock/
          fixtures.dart
          mock_repara_repository.dart
          mock_scenario.dart
    map/
      application/
        nearby_demands_controller.dart
        map_region.dart
      presentation/
        pages/
          map_page.dart
        widgets/
          map_header.dart
          location_pill.dart
          stylized_map.dart
          map_marker.dart
          nearby_demands_sheet.dart
          demand_card.dart
          location_picker_sheet.dart
          demand_search_sheet.dart   # P2
    report/
      domain/
        nova_ocorrencia_draft.dart
        resultado_envio.dart
        report_step.dart
      application/
        report_draft_controller.dart
        report_submission_controller.dart
      data/
        fake_capture_service.dart
        fake_location_service.dart
      presentation/
        pages/
          capture_page.dart
          details_page.dart
          review_page.dart
          success_page.dart
        widgets/
          capture_top_bar.dart
          camera_preview.dart
          framing_guides.dart
          location_chip.dart
          category_selector.dart
          report_summary.dart
  dev/
    design_system_gallery.dart
```

A árvore é um alvo, não uma ordem para criar camadas vazias. Para recursos pequenos,
omitir o que não tem uso real.

### 6.3 Navegação

| Rota | Tela | Observações |
|---|---|---|
| `/` | `MapPage` | Entrada do app |
| `/report/capture` | `CapturePage` | Etapa 1/3 |
| `/report/details` | `DetailsPage` | Etapa 2/3 (proposta) |
| `/report/review` | `ReviewPage` | Etapa 3/3 (proposta) |
| `/report/success` | `SuccessPage` | Recebe `ResultadoEnvio` via `extra`; se ausente, redireciona para `/` |
| `/dev/design-system` | Galeria de componentes | Apenas em debug |

Regras:

- O CTA “Registrar” abre `/report/capture`.
- “Cancelar” na captura volta ao mapa; se houver foto/rascunho, pedir confirmação.
- O rascunho é propriedade do fluxo, não de cada página. Sair do fluxo limpa o rascunho.
- `ReviewPage` exige rascunho completo; caso contrário, redireciona para a etapa anterior.
- `SuccessPage` não deve ser acessível sem resultado; usar `redirect`/guard.
- O “Voltar ao mapa” da tela de sucesso usa `go('/')` e limpa o rascunho.

### 6.4 Estado (Riverpod)

| Provider | Tipo | Responsabilidade |
|---|---|---|
| `mockScenarioProvider` | `Provider<MockScenario>` | Cenário atual; sobrescrito em testes |
| `reparaRepositoryProvider` | `Provider<ReparaRepository>` | Retorna `MockReparaRepository` |
| `nearbyDemandsControllerProvider` | `AsyncNotifierProvider` | Carrega demandas da região, expõe `AsyncValue` |
| `selectedRegionProvider` | `NotifierProvider` | Região atual (Centro Histórico etc.) |
| `selectedDemandIdProvider` | `StateProvider<int?>` | Pino/card selecionado |
| `reportDraftProvider` | `NotifierProvider<ReportDraftController, NovaOcorrenciaDraft>` | Rascunho do fluxo |
| `reportSubmissionProvider` | `AsyncNotifierProvider` ou `NotifierProvider` com estado selado | Envio mock e estados |
| `captureServiceProvider` | `Provider<CaptureService>` | Fake no MVP |
| `locationServiceProvider` | `Provider<LocationService>` | Fake no MVP |

Regras:

- Widgets não fazem chamadas ao repositório diretamente; usam controllers/providers.
- Estados assíncronos usam `AsyncValue` ou classes seladas; não usar combinações de
  booleanos que permitam estados impossíveis.
- O sheet, seleção de pino e controlador de animação são estado efêmero de UI, mantido
  localmente no widget, não em provider global.
- Testes devem conseguir sobrescrever o repositório e os serviços sem tocar em widgets.

### 6.5 Fronteira de dados e mock mode

- `ReparaRepository` é uma interface de domínio. Ela **não** representa endpoints HTTP.
- `MockReparaRepository` é a única implementação nesta fase.
- Nenhum JSON, DTO de rede, interceptor, base URL ou header é criado agora.
- Cenários via `--dart-define=MOCK_SCENARIO=success|empty|error|slow`; padrão `success`.
- Latência simulada padrão: 350 ms. Testes usam 0 ms ou `FakeAsync`.
- `MOCK_MODE` é um `bool.fromEnvironment`: padrão `true` em desenvolvimento e `false` em
  release. Para uma build de demonstração em release, passar
  `--dart-define=MOCK_MODE=true`; sem isso, o app falha com mensagem clara de configuração
  (o backend ainda não existe). Nenhuma build de demonstração deve ser distribuída como
  produção.
- A tela de sucesso não precisa dizer “simulação” ao usuário do protótipo, mas o modo mock
  deve estar documentado no README/dev. Não inventar protocolo oficial; usar um código
  claramente fictício no mock.

---

## 7. Modelo de dados e fixtures

### 7.1 Entidades de domínio (derivadas do contrato existente)

| Tipo | Campos | Origem |
|---|---|---|
| `Categoria` | `id`, `codigo`, `nome`, `raioMatchingMetros` | `API_CONTRACT.md` §2 |
| `Coordenada` | `latitude`, `longitude` | Representação local de `geography(Point)`; não é DTO |
| `Demanda` | `id`, `categoria`, `localizacao`, `status`, `numeroProtocolo?`, `criadoEm`, `atualizadoEm`, `encerradoEm?` | `API_CONTRACT.md` §3 |
| `StatusDemanda` | `aberta`, `emAndamento`, `resolvida`, `rejeitada` | `API_CONTRACT.md` §6 |
| `DemandaProxima` | `id`, `categoria`, `tituloExibicao`, `enderecoFormatado`, `relatos`, `distanciaMetros`, `status`, `posicaoMapa` | **Read model da demo**; `tituloExibicao`, `enderecoFormatado`, `relatos`, `distanciaMetros` e `posicaoMapa` não existem no schema |
| `NovaOcorrenciaDraft` | `categoria?`, `descricao`, `localizacao?`, `precisaoGps?`, `foto?`, `criadoEm` | Rascunho local; não é payload de API |
| `ResultadoEnvio` | `codigoRastreio`, `registradoEm` | **Mock**; a resposta real é desconhecida (Q7) |

Regras de apresentação:

- Rótulos de status: `ABERTA` → “Aberta”; `EM_ANDAMENTO` → “Encaminhada” (provisório);
  `RESOLVIDA` → “Resolvida”; `REJEITADA` → “Rejeitada”.
- Badge do pino = número de relatos daquela demanda.
- “12 demandas por perto” = contagem de demandas, não de relatos.
- Pluralização: “1 relato” / “N relatos”; “1 demanda” / “N demandas”.
- Não exibir “Encaminhada” como se fosse um valor do enum; é um rótulo de UI.

### 7.2 Fixtures mockadas

Catálogo (do contrato): Buraco (raio 50 m), Esgoto (100 m), Poste caído (30 m),
Dejeto (80 m).

Centro inicial: Porto Alegre · Centro Histórico (`-30.0277, -51.2287`, aproximado).
Raio de exibição do mapa: 2.000 m (constante de UI da demo; não é regra de matching).

| # | Categoria | Título exibido (mock) | Endereço (mock) | Relatos | Status | Pino |
|---|---|---|---|---:|---|---|
| 1 | Buraco | Buraco na via | Av. Ipiranga, 240 | 4 | EM_ANDAMENTO | azul, badge 4 |
| 2 | Poste caído | Iluminação apagada | Rua dos Andradas, 1020 | 7 | ABERTA | roxo, badge 7 |
| 3 | Dejeto | Lixo acumulado | Praça da Alfândega | 1 | ABERTA | verde, badge 1 |
| 4 | Esgoto | Vazamento de esgoto | Av. Borges de Medeiros, 500 | 3 | EM_ANDAMENTO | âmbar, badge 3 |
| 5 | Buraco | Buraco na via | Rua da Praia, 180 | 2 | ABERTA | fora do viewport |
| 6 | Buraco | Buraco na via | Av. Salgado Filho, 90 | 5 | EM_ANDAMENTO | fora do viewport |
| 7 | Esgoto | Esgoto a céu aberto | Rua Sete de Setembro, 300 | 2 | EM_ANDAMENTO | fora do viewport |
| 8 | Dejeto | Entulho na calçada | Rua Marechal Floriano, 45 | 1 | ABERTA | fora do viewport |
| 9 | Poste caído | Poste sem iluminação | Av. Alberto Bins, 700 | 3 | EM_ANDAMENTO | fora do viewport |
| 10 | Buraco | Buraco na via | Rua Uruguai, 120 | 2 | ABERTA | fora do viewport |
| 11 | Dejeto | Descarte irregular | Av. Venâncio Aires, 400 | 1 | ABERTA | fora do viewport |
| 12 | Esgoto | Vazamento | Rua Demétrio Ribeiro, 85 | 1 | ABERTA | fora do viewport |

Observações:

- Os títulos e endereços acima são **dados de demonstração**, não campos do backend.
- A demanda #2 usa “Iluminação apagada” como título para preservar a fidelidade ao PDF,
  mas sua categoria continua sendo `POSTE_CAIDO`.
- As 12 fixtures acima são ativas para manter a contagem “12 demandas por perto”. Para
  testar o filtro de demandas terminais, adicionar uma 13ª fixture `RESOLVIDA` fora do raio;
  ela não entra na lista. A regra de exibição de terminais no mapa é desconhecida (Q13).
- Os 4 pinos visíveis reproduzem os badges 1, 3, 4 e 7 do protótipo. Os demais ficam fora
  do viewport ou não são desenhados; a lista contém as 12.

### 7.3 Interface do repositório

```dart
abstract interface class ReparaRepository {
  Future<List<DemandaProxima>> demandasProximas({
    required Coordenada centro,
    double raioMetros = 2000,
  });

  Future<List<Categoria>> categorias();

  Future<ResultadoEnvio> registrarOcorrencia(NovaOcorrenciaDraft draft);
}
```

Isso descreve as necessidades atuais da UI, não endpoints. Não criar métodos “para depois”
sem uso concreto.

### 7.4 Falhas e estados

- `ReparaFailure` selada com categorias: `dadosIndisponiveis`, `envioFalhou`,
  `localizacaoIndisponivel`, `capturaFalhou`, `desconhecida`.
- Mensagens de UI amigáveis; nunca exibir stack trace, detalhes internos ou dados pessoais.
- Repositório mock lança falhas tipadas nos cenários `error`; não capturar e ignorar.
- Envio não deve duplicar: desabilitar o botão durante `submitting` e usar guarda no
  controller.
- Sair da captura com rascunho sujo exige confirmação.

---

## 8. Especificação das telas

### 8.1 Tela 01 — Mapa

**Objetivo:** mostrar demandas próximas e dar acesso ao registro de uma nova ocorrência.

**Estrutura, de cima para baixo:**

1. **Status bar / safe area** do sistema.
2. **Cabeçalho branco**
   - Tile verde 40 × 40 com ícone de pin branco.
   - Wordmark “Repara” em `brand.ink`, 24–28/700.
   - Botão de busca 40 × 40 com lupa, borda sutil, à direita.
3. **Seletor de região**
   - Pill outlined com ícone de bússola, texto “Porto Alegre · Centro Histórico” e
     “Trocar” em verde.
   - Toque em “Trocar” abre um bottom sheet com 3 regiões mockadas.
4. **Mapa**
   - Fundo `map.canvas` com quadras, vias, área verde e água desenhadas em `CustomPaint`.
   - Ponto azul de localização do usuário com halo.
   - 4 pinos principais com cor de categoria, ícone e badge branco com contagem.
   - Pino selecionado cresce levemente e ganha sombra; não depender só de cor.
   - Toque no pino seleciona a demanda e rola o card correspondente para a área visível.
5. **CTA “Registrar”**
   - Pill âmbar com ícone “+”, sombra suave, 56 de altura.
   - Posicionado acima do sheet, à direita, com margem 16.
   - Abre `/report/capture`.
6. **Bottom sheet de demandas**
   - Handle, título “12 demandas por perto”, ação “Ver lista”.
   - Lista vertical de cards; rolagem interna; sheet arrastável.
   - “Ver lista” expande o sheet para ~85% da tela, sem criar outra rota.
   - Card: thumbnail 64 × 64 (ícone da categoria sobre fundo suave), título, endereço,
     “4 relatos”, chip “Encaminhada”.
   - Toque no card seleciona o pino e recolhe o sheet para a posição inicial.

**Estados:**

| Estado | Comportamento |
|---|---|
| Loading | Skeleton no cabeçalho/sheet; mapa visível sem pinos; CTA visível |
| Sucesso | Pinos + lista + contagem |
| Vazio | Mapa sem pinos; sheet com “Nenhuma demanda por perto” e CTA de registrar |
| Erro | Mapa visível; sheet/card de erro com “Tentar novamente” |
| Seleção | Pino e card destacados; card visível |

**Interações P1:** CTA, pinos, cards, “Ver lista”, “Trocar”, arrastar sheet.
**P2 opcional:** busca local por título/endereço/categoria. Se não aprovada, remover o
ícone de busca do layout (não deixar botão sem ação).

> Prioridade: **P1 = obrigatório** para a fase; **P2 = opcional**, sujeito a aprovação e
> sem bloquear o fluxo principal.

**Acessibilidade:**

- Semântica do mapa: “Mapa do Centro Histórico com 12 demandas próximas”.
- Cada pino: “Buraco na via, 4 relatos, Encaminhada”; alvo de 48 × 48.
- O sheet deve ser operável por leitor de tela e teclado; foco inicial no título.
- Não usar apenas cor para diferenciar categorias/status.

### 8.2 Tela 02 — Captura (etapa 1/3)

**Objetivo:** capturar a imagem do problema e confirmar a localização.

**Estrutura:**

- Fundo `capture.bg`; tema escuro apenas nesta tela.
- Barra superior:
  - “Cancelar” (texto claro) à esquerda; ação de voltar com confirmação se houver rascunho.
  - Título central “Nova ocorrência” 16/600.
  - Pill “1 de 3” à direita, com semântica “Etapa 1 de 3”.
- Preview da câmera:
  - Container com raio 24 e margem 16, preenchendo o centro.
  - Prévia simulada (gradiente/ilustração escura) até a integração real.
  - Cantos de enquadramento brancos nos quatro cantos.
  - Chip de localização no topo: “Local capturado · precisão ±8 m”, com ícone verde.
  - Instrução inferior: “Enquadre o problema dentro das marcas”.
- Controles inferiores:
  - Obturador circular âmbar de 72–76, centralizado.
  - Controles laterais (galeria/alternar câmera) **não** fazem parte do MVP até o design
    confirmar o que está cortado no PDF (Q4). Não criar botões mortos.
- A captura simulada pode usar `RepaintBoundary.toImage()` da própria prévia para gerar
  bytes de imagem; alternativa: asset placeholder. Não adicionar pacote de câmera ainda.

**Estados:**

| Estado | Comportamento |
|---|---|
| Adquirindo localização | Chip “Obtendo localização…” com indicador discreto |
| Localização pronta | Chip com precisão ±8 m; obturador habilitado |
| Localização indisponível | Chip de erro; obturador desabilitado com explicação |
| Capturando | Feedback breve; evitar duplo toque |
| Capturado | Foto no rascunho; avança para etapa 2/3 |

**Acessibilidade:**

- Obturador com label “Tirar foto” e estado habilitado/desabilitado.
- “Cancelar” com label “Cancelar nova ocorrência”.
- Contraste do texto claro sobre fundo escuro; não depender do chip verde.
- Instrução também disponível para leitor de tela.

### 8.3 Etapa 2/3 — Detalhes (proposta, Q1)

- Mesma barra superior, agora “2 de 3”.
- Miniatura da foto capturada com ação “Refazer foto” (volta à captura).
- Seletor de categoria com as 4 categorias do contrato (Buraco, Esgoto, Poste caído,
  Dejeto), em chips/cards acessíveis.
- Campo “Descrição” multiline, com contador se houver limite; validação local.
- Resumo da localização (endereço mock e precisão).
- CTA “Continuar” (âmbar) habilitado apenas com categoria e descrição válidas.
- Voltar preserva o rascunho.

### 8.4 Etapa 3/3 — Revisão e envio (proposta, Q1)

- Barra superior “3 de 3”.
- Card de resumo: foto, categoria, descrição, localização, precisão.
- Ações “Voltar” (texto) e “Enviar ocorrência” (âmbar).
- Ao enviar:
  - `submitting`: botão com loading, bloqueio de duplo toque e de voltar.
  - `error`: banner com mensagem amigável e “Tentar novamente”; rascunho preservado.
  - `success`: navega para `/report/success` com `ResultadoEnvio`.
- Não simular matching nem alterar contadores do mapa.

### 8.5 Sucesso (proposta)

- Ícone de check em círculo verde.
- Título “Ocorrência registrada”.
- Texto curto explicando que o relato foi recebido.
- Card com “Código de acompanhamento” e código mock (ex.: `REP-DEMO-000123`),
  claramente fictício.
- CTA “Voltar ao mapa” (âmbar) e ação secundária “Registrar outra” (opcional).
- Ao voltar, limpar rascunho e recarregar o mapa.

### 8.6 Copy deck

**Exato do PDF:**

- “Repara”
- “Porto Alegre · Centro Histórico”
- “Trocar”
- “12 demandas por perto”
- “Ver lista”
- “Buraco na via”
- “Av. Ipiranga, 240 · 4 relatos”
- “Encaminhada”
- “Iluminação apagada”
- “Nova ocorrência”
- “Cancelar”
- “1 de 3”
- “Local capturado · precisão ±8 m”
- “Enquadre o problema dentro das marcas”

**Propostas (marcar como tal até validação):**

- “Nenhuma demanda por perto” / “Tente outra região ou registre uma nova ocorrência.”
- “Não foi possível carregar as demandas.” / “Tentar novamente”
- “Obtendo localização…”
- “Localização indisponível”
- “Categoria”
- “Descrição”
- “Continuar”
- “Enviar ocorrência”
- “Ocorrência registrada”
- “Código de acompanhamento”
- “Voltar ao mapa”
- “Descartar ocorrência?” / “Seu rascunho será perdido.” / “Manter” / “Descartar”
- “1 relato” / “N relatos”; “1 demanda” / “N demandas”

---

## 9. Fases de implementação

### 9.1 Visão geral

| Fase | Entrega | Depende de | Tamanho | Gate principal |
|---|---|---|---|---|
| 0 | Fundação, dependências, rotas, git e gates | Aprovações humanas | P/M | App roda + analyze/test verdes |
| 1 | Design system, tokens e componentes base | Fase 0 | M | Galeria + ui-reviewer |
| 2 | Domínio, repositório mock, providers e fixtures | Fase 1 | M | Testes unitários |
| 3 | Tela 01 Mapa completa (mapa + sheet + interações) | Fase 2 | G | Widget/golden + ui-reviewer |
| 4 | Tela 02 Captura (etapa 1/3) e rascunho | Fase 3 | M | Widget + ui-reviewer |
| 5 | Etapas 2/3 e 3/3, envio mock e sucesso | Fase 4 | G | Fluxo integrado + QA |
| 6 | Hardening, acessibilidade, testes e docs | Fase 5 | M | QA final + ui-reviewer |

> Executar **uma fase por vez**. O orquestrador deve parar ao final de cada fase e
> apresentar evidências; a fase seguinte exige aprovação implícita ou explícita do humano.

---

### Fase 0 — Fundação do projeto e governança

**Objetivo:** deixar o app executável, com dependências aprovadas, rotas, locale,
configuração de mock e quality gates funcionando.

**Pré-requisitos / aprovações:**

- Aprovar `flutter_riverpod` e `go_router`. `flutter_localizations` é SDK; ainda assim,
  registrar no `pubspec.yaml`. Não adicionar biblioteca de mocks: as interfaces já serão
  implementadas por fakes/spies escritos à mão.
  > **Decisão 2026-11-11:** dependências aprovadas (`flutter_riverpod` 3.5.0,
  > `go_router` 18.1.4, `intl` 0.20.3, `flutter_localizations`). Desvio aprovado pelo
  > humano: `mocktail` 1.0.5 adicionado como dependência *dev-only*; fakes escritos à
  > mão continuam como padrão para serviços do app. Registrado em
  > `docs/DEPENDENCIES.md`.
- Aprovar `git init` (ou adaptar o quality gate para um repositório não-git).
  > **Decisão 2026-11-11:** qualidade adaptada em vez de `git init` — os gates agora
  > pulam `git diff --check` com aviso quando não há repositório. `git init` fica
  > pendente de aprovação separada.
- Resolver a fonte (Q6) apenas se o asset já estiver disponível; caso contrário, usar a
  fonte padrão e registrar o desvio.
- Confirmar que o projeto pode ter `MOCK_MODE` como padrão de desenvolvimento.

**Entregáveis:**

- [ ] Dependências adicionadas com versões compatíveis com Flutter 3.47.1/Dart 3.13.1,
      registradas e justificadas em `docs/DEPENDENCIES.md`.
- [ ] `lib/main.dart` substituído por bootstrap real: `ReparaApp` + `MaterialApp.router`.
- [ ] Tema mínimo, locale `pt_BR` e `supportedLocales`.
- [ ] `app_router.dart` com `/` e uma `MapPage` placeholder; rota `/dev/design-system`
      apenas em debug (pode ficar para a Fase 1).
- [ ] Configuração `MOCK_SCENARIO`/`MOCK_MODE` com guarda para release.
- [ ] Estrutura inicial de pastas e helper de testes `pumpApp` com overrides.
- [ ] `test/widget_test.dart` padrão substituído por smoke test do app/rota.
- [ ] `git init` + baseline commit, se aprovado; `.gitignore` revisado.
- [ ] Decisões registradas em `docs/ARCHITECTURE.md`/`docs/DEPENDENCIES.md`.

**Critérios de aceite:**

- [ ] `flutter run` abre o app sem erro e mostra uma tela inicial identificável.
- [ ] `flutter analyze` sem issues; `dart format` limpo; testes passam.
- [ ] `tool/quality.ps1` (Windows) ou `tool/quality.sh` roda até o fim, ou cada comando
      indisponível é reportado como NOT RUN.
- [ ] Nenhum endpoint, DTO de rede ou dependência não aprovada foi adicionado.
- [ ] O modo mock está documentado e não pode vazar silenciosamente para release.

**Testes mínimos:**

- Smoke test: app inicializa, rota `/` resolve, título “Repara” aparece.
- Teste de configuração: cenário mock inválido falha com mensagem clara (se aplicável).

**Fora desta fase:** qualquer tela real, dados mockados, componentes visuais finais.

**Delegação:** `flutter-engineer` implementa; `qa-engineer` roda gates. `ui-reviewer` só
entra se houver decisão visual relevante.

**Risco:** dependências atrasarem. Mitigação: aprovar antes de iniciar; não instalar
pacotes “só por garantia”.

---

### Fase 1 — Design system e shell visual

**Objetivo:** criar a base visual tokenizada que as telas vão reutilizar, sem hardcodes.

**Entregáveis:**

- [ ] `app/theme/tokens.dart` com cores, espaçamento, raios, sombras, durações e tamanhos.
- [ ] `app/theme/typography.dart` com a escala e a fonte aprovada.
- [ ] `app/theme/app_theme.dart` com `ThemeData` claro; tokens escuros para a captura.
- [ ] Componentes base:
  - `PrimaryButton` (âmbar, loading, disabled, 56 de altura).
  - `StatusChip` (enum → rótulo/cor, contraste).
  - `StepBadge` (“1 de 3”).
  - `SurfaceCard`, `AppSkeleton`, `AppEmptyView`, `AppErrorView`.
  - `LocationPill`.
- [ ] Galeria `/dev/design-system` em debug, mostrando tokens e estados dos componentes.
- [ ] Testes de widget dos componentes (toque mínimo, semântica, disabled/loading).
- [ ] Golden opcional da galeria em 390 × 844.

**Critérios de aceite:**

- [ ] Nenhum widget de feature usa cor/espaçamento/raio hardcoded; tudo vem de tokens.
- [ ] Contraste de texto >= 4.5:1 (texto normal) e >= 3:1 (texto grande/ícones).
- [ ] Componentes funcionam com text scale 1.3 e 2.0 sem overflow.
- [ ] `StatusChip` mapeia `ABERTA`/`EM_ANDAMENTO`/`RESOLVIDA`/`REJEITADA` e aceita label
      de apresentação para “Encaminhada”.
- [ ] Galeria não aparece em release.
- [ ] `ui-reviewer` sem findings críticos/altos.

**Testes mínimos:** widget tests dos componentes; golden da galeria se o ambiente
permitir; verificação manual de contraste.

**Fora desta fase:** telas completas, dados e navegação do fluxo.

**Delegação:** `flutter-engineer` implementa; `ui-reviewer` revisa; `qa-engineer` valida.

**Risco:** a fonte exata não estar definida. Mitigação: tokenizar a família e registrar o
desvio; não bloquear a fase por isso.

---

### Fase 2 — Domínio, dados mockados e estado

**Objetivo:** entregar o modelo tipado, o repositório mock e os controllers que alimentam
as telas, sem UI de feature.

**Entregáveis:**

- [ ] Entidades e enums de `features/demands/domain` conforme §7.1.
- [ ] `ReparaRepository` + `ReparaFailure` tipada.
- [ ] `MockReparaRepository` com fixtures §7.2, cenários e latência configurável.
- [ ] `MockScenario` via `--dart-define`.
- [ ] Providers de repositório, cenário, região e `nearbyDemandsControllerProvider`.
- [ ] `reportDraftProvider` com operações `setPhoto`, `setCategory`, `setDescription`,
      `setLocation`, `reset`, `isComplete`.
- [ ] Formatação de pluralização/distância em `core/formatting`.
- [ ] Testes unitários de domínio, filtro por distância, mapeamento de status, cenários
      vazio/erro e validação do rascunho.

**Critérios de aceite:**

- [ ] `domain/` não importa Flutter, `dio`, JSON ou widgets.
- [ ] `MockReparaRepository` retorna as 12 demandas no Centro Histórico e aplica o raio.
- [ ] `empty` retorna lista vazia; `error` lança `ReparaFailure.dadosIndisponiveis`;
      `slow` respeita a latência; `success` é determinístico.
- [ ] Nenhum DTO/JSON/HTTP foi criado.
- [ ] Nenhum campo de exibição (`tituloExibicao`, `enderecoFormatado`, `relatos`) é
      apresentado como contrato de backend; a origem mock está documentada.
- [ ] Testes unitários passam e cobrem os cenários.

**Fora desta fase:** telas, navegação, câmera/GPS.

**Delegação:** `flutter-engineer`; `qa-engineer` para testes. `api-contract` pode ser
consultado apenas para conferir os campos já documentados; não pode inventar endpoints.

**Risco:** confundir read model com contrato. Mitigação: comentários/doc e proibição de
criar DTO de rede.

---

### Fase 3 — Tela 01 Mapa

**Objetivo:** entregar a tela inicial completa e navegável, fiel ao PDF.

**Entregáveis:**

- [ ] `MapPage` com cabeçalho, seletor de região, mapa, pinos e CTA.
- [ ] `StylizedMapCanvas` em `CustomPaint` com ruas, quadras, área verde e água.
- [ ] `MapMarker` com badge de relatos, estados normal/selecionado e semântica.
- [ ] `NearbyDemandsSheet` arrastável com título/contagem, “Ver lista” e cards.
- [ ] `DemandCard` com thumbnail, título, endereço, relatos e chip de status.
- [ ] Estados loading/sucesso/vazio/erro do mapa e do sheet.
- [ ] Seleção pino ↔ card, “Ver lista” expandindo o sheet, “Trocar” abrindo seletor de
      região mockado e recarregando as demandas.
- [ ] Busca local P2 (se aprovada); se não, remover o ícone.
- [ ] Rota `/report/capture` mínima com top bar “Cancelar” para o CTA ter destino;
      conteúdo completo na Fase 4.
- [ ] Testes de widget/golden e verificação manual em 360/390/430.

**Critérios de aceite:**

- [ ] Cabeçalho, seletor, CTA e sheet seguem as medidas/tokens da §5.
- [ ] “12 demandas por perto” usa a contagem de demandas; badges usam relatos.
- [ ] O sheet abre em ~30%, expande com “Ver lista” e volta ao arrastar.
- [ ] Pinos e cards são acessíveis por leitor de tela e teclado.
- [ ] Loading, vazio e erro são visualmente distintos e acionáveis.
- [ ] CTA abre a captura; “Cancelar” volta ao mapa.
- [ ] Nenhum overflow em 360 × 640 com text scale 1.3.
- [ ] Golden do estado de sucesso em 390 × 844 aprovado ou diferenças justificadas.

**Testes mínimos:**

- Widget: loading → sucesso; vazio; erro + retry; 12 cards; seleção; “Ver lista”;
  “Trocar” região; CTA/navegação.
- Golden: mapa no estado de sucesso.
- Semântica: labels dos pinos e CTA.

**Fora desta fase:** captura completa, etapas 2/3 e 3/3, envio.

**Delegação:** `flutter-engineer`; `ui-reviewer`; `qa-engineer`.

**Risco:** o mapa customizado consumir tempo. Mitigação: timebox; começar com formas
simples e evoluir; não adicionar tiles/keys.

---

### Fase 4 — Tela 02 Captura (etapa 1/3)

**Objetivo:** implementar a etapa 1 do fluxo de nova ocorrência, com captura simulada e
localização fake, mantendo o rascunho.

**Entregáveis:**

- [ ] `CapturePage` escura com top bar, pill “1 de 3”, preview, cantos, chip de localização
      e instrução.
- [ ] `LocationService` fake: estado “adquirindo” → “pronto” com precisão ±8 m; cenário
      indisponível para testes.
- [ ] `CaptureService` fake com `RepaintBoundary.toImage()` ou asset placeholder.
- [ ] Obturador com estados habilitado/capturando; salva a foto no `reportDraftProvider`.
- [ ] Diálogo de descarte ao cancelar com rascunho sujo.
- [ ] Rota `/report/details` mínima (top bar “2 de 3”) para o obturador avançar; formulário
      completo na Fase 5.
- [ ] Testes de widget: estados de localização, captura, cancelamento e navegação.

**Critérios de aceite:**

- [ ] A tela corresponde ao layout escuro do PDF (sem os controles não definidos).
- [ ] Obturador desabilitado enquanto a localização não estiver pronta; se estiver
      indisponível, continua desabilitado com explicação.
- [ ] Captura não duplica ao tocar duas vezes; foto fica no rascunho.
- [ ] “Cancelar” sem rascunho volta direto; com foto, pede confirmação.
- [ ] Nenhuma permissão de câmera/GPS é solicitada nesta fase.
- [ ] Sem botões mortos: controles laterais não existem até definição (Q4).
- [ ] Semântica correta para leitor de tela e alvos de 48.

**Testes mínimos:**

- Widget: localização adquirindo/pronta/indisponível; toque no obturador; duplo toque;
  diálogo de descarte; transição para etapa 2.
- Golden da tela de captura em 390 × 844.

**Fora desta fase:** câmera real, permissões, galeria, flash, alternar câmera.

**Delegação:** `flutter-engineer`; `ui-reviewer`; `qa-engineer`.

**Risco:** o PDF corta os controles inferiores. Mitigação: implementar só o obturador e
registrar Q4; não inventar UI.

---

### Fase 5 — Etapas 2/3 e 3/3, envio mock e sucesso

**Objetivo:** completar o fluxo de nova ocorrência de ponta a ponta com dados mockados.

**Entregáveis:**

- [ ] `DetailsPage` (2/3): foto com “Refazer”, seletor de categoria, descrição, resumo de
      localização e CTA “Continuar” com validação.
- [ ] `ReviewPage` (3/3): resumo completo, “Voltar” e “Enviar ocorrência”.
- [ ] `ReportSubmissionController` com estados idle/submitting/error/success; bloqueio de
      duplo envio; retry sem perder o rascunho.
- [ ] `SuccessPage` com código mock, “Voltar ao mapa” e limpeza do rascunho.
- [ ] Guards de rota: review exige rascunho completo; success exige resultado.
- [ ] Confirmação ao voltar/sair com rascunho sujo.
- [ ] Testes de unidade/validação, widget e integração do fluxo completo.
- [ ] Mensagens de erro amigáveis e acessíveis.

**Critérios de aceite:**

- [ ] Fluxo: mapa → captura → detalhes → revisão → sucesso → mapa.
- [ ] Sem categoria ou descrição, “Continuar” fica desabilitado e explica o motivo.
- [ ] Voltar preserva foto, categoria e descrição.
- [ ] Envio com sucesso mostra código mock e não altera contadores do mapa.
- [ ] Envio com erro mostra banner e permite retry; nada é perdido.
- [ ] Toques repetidos não criam dois envios.
- [ ] Nenhum endpoint/response field é inventado; `ResultadoEnvio` é explicitamente mock.
- [ ] Teste de integração do fluxo passa com serviços fake.

**Testes mínimos:**

- Unit: `isComplete`, validação, transições de envio.
- Widget: etapa 2 vazia/preenchida, etapa 3, loading, erro, sucesso, duplo toque.
- Integration: fluxo completo com `MockReparaRepository` e serviços fake.

**Fora desta fase:** matching real, upload de imagem, protocolo oficial, persistência.

**Delegação:** `flutter-engineer`; `ui-reviewer`; `qa-engineer`.

**Risco:** as etapas 2/3 e 3/3 não existem no PDF. Mitigação: implementar a proposta de
§8.3/§8.4 de forma isolada e ajustável; Q1 deve ser respondida antes do polimento final.

---

### Fase 6 — Hardening, acessibilidade, testes e documentação

**Objetivo:** elevar a qualidade para um demo confiável e deixar o projeto pronto para a
próxima fase (integração real).

**Entregáveis:**

- [ ] Cenários de mock acessíveis para QA (`success`, `empty`, `error`, `slow`).
- [ ] Loading/erro/vazio/sucesso em todas as telas com dados; retry funcional.
- [ ] Auditoria de acessibilidade: semântica, foco, contraste, text scale 1.3/2.0,
      alvos de toque, `disableAnimations`.
- [ ] Responsividade 360 × 640, 390 × 844, 430 × 932; teclado nos formulários.
- [ ] Performance: `const` onde aplicável, mapa em `RepaintBoundary`, sem trabalho
      pesado em `build`, listas com keys estáveis.
- [ ] Goldens finais de mapa/captura; teste de integração estável.
- [ ] Atualização de `docs/ARCHITECTURE.md` com decisões (Riverpod, go_router, mock,
      mapa/câmera/GPS).
- [ ] Registro das questões abertas (§13) em documento próprio ou na spec.
- [ ] Relatório final do QA com comandos, resultados e limitações.

**Critérios de aceite:**

- [ ] `dart format --output=none --set-exit-if-changed .` passa.
- [ ] `flutter analyze` passa sem issues.
- [ ] `flutter test` passa (unit + widget + integration).
- [ ] `tool/quality.ps1`/`.sh` passa ou tem cada bloqueio reportado como NOT RUN.
- [ ] `git diff --check` passa (após git init).
- [ ] Nenhum segredo/dado sensível em código/log.
- [ ] Nenhuma dependência nova sem registro/aprovação.
- [ ] `ui-reviewer` sem findings críticos/altos; `qa-engineer` reporta PASS.
- [ ] Demo manual aprovada em 390 × 844 (e ao menos um tamanho menor).

**Testes finais:**

- Suíte completa; golden tests; integração do fluxo; checklist manual de a11y.

**Fora desta fase:** backend, câmera/GPS reais, mapas reais, deploy.

**Delegação:** `qa-engineer` conduz; `ui-reviewer` revisa; `flutter-engineer` corrige;
`security-reviewer` só entra se houver auth/rede/dados sensíveis (não é o caso agora).

---

## 10. Estratégia de testes e quality gates

### 10.1 Pirâmide

| Nível | O que cobrir |
|---|---|
| Unitário | Domínio, filtros de distância, status labels, pluralização, validação do rascunho, estados de envio |
| Widget | Estados de mapa/sheet/captura/formulários; interações; semântica; text scale |
| Golden | Mapa (sucesso) e captura (pronto) em 390 × 844 |
| Integração | Mapa → captura → detalhes → revisão → sucesso → mapa, com fakes |
| Manual | Visual em 360/390/430; contraste; leitor de tela; teclado; reduce motion |

### 10.2 Matriz mínima por tela

| Área | Loading | Vazio | Erro | Sucesso | A11y |
|---|---|---|---|---|---|
| Mapa | Sim | Sim | Sim + retry | Sim | Sim |
| Sheet | Sim | Sim | Sim | Sim | Sim |
| Captura | Sim (GPS) | N/A | GPS indisponível | Foto capturada | Sim |
| Etapa 2 | N/A | N/A | Categorias falham | Formulário válido | Sim |
| Etapa 3 | Enviando | N/A | Envio falha + retry | Envio concluído | Sim |
| Sucesso | N/A | N/A | N/A | Sim | Sim |

### 10.3 Comandos de verificação

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test test/features/map          # foco
flutter test test/features/report       # foco
bash tool/quality.sh                    # macOS/Linux/Git Bash
pwsh -File tool/quality.ps1             # Windows
git diff --check
```

Regras:

- Um check não executado é **NOT RUN**, nunca PASS.
- Não desabilitar lint, teste ou assertion para ficar verde.
- Falha de ambiente (sem device, sem SDK, sem git) é reportada separadamente de falha de
  código.
- `flutter test` precisa cobrir os testes novos; não basta rodar um arquivo isolado.

### 10.4 Aprovação por fase

- Fases 0–2: `flutter-engineer` + `qa-engineer`.
- Fases 3–5: `flutter-engineer` + `ui-reviewer` + `qa-engineer`.
- Fase 6: `qa-engineer` + `ui-reviewer`; `security-reviewer` apenas se o escopo mudar
  para rede/auth/armazenamento sensível.

---

## 11. Definition of Done

Uma fase só termina quando, no mínimo:

- [ ] Critérios de aceite da fase foram atendidos.
- [ ] A arquitetura e o contrato documentado foram respeitados.
- [ ] Nenhum endpoint, campo de resposta, auth ou regra de negócio foi inventado.
- [ ] Loading, sucesso, vazio e erro estão modelados onde há dados.
- [ ] Acessibilidade e responsividade foram consideradas e verificadas.
- [ ] Testes cobrem comportamento e casos de borda relevantes.
- [ ] `dart format` passa.
- [ ] `flutter analyze` passa.
- [ ] `flutter test` passa.
- [ ] `tool/quality.*` passa ou os bloqueios estão reportados como NOT RUN.
- [ ] `git diff --check` passa (após git init).
- [ ] Nenhum segredo/dado pessoal é logado ou commitado.
- [ ] Findings críticos/altos de review resolvidos ou aceitos explicitamente.
- [ ] Relatório final lista arquivos, comandos executados, resultados e riscos restantes.

---

## 12. Riscos

| Risco | Sev. | Mitigação |
|---|---|---|
| Etapas 2/3 e 3/3 inventadas divergirem do design real | Alto | Isolar em `features/report`; validar Q1 antes do polimento; UI simples e adaptável |
| Rótulo “Encaminhada” não existir no enum | Alto | Tratar como label de `EM_ANDAMENTO`; Q2 antes de integrar backend |
| “Iluminação apagada” não existir no catálogo | Alto | Usar como título de `POSTE_CAIDO`; Q3 antes de finalizar fixtures |
| Mocks confundidos com dados reais | Alto | Modo demo documentado; guarda de release; nenhum HTTP; revisão de segurança se necessário |
| Fonte/tokens divergirem | Médio | Galeria de design system; tokens centralizados; ui-reviewer |
| Mapa customizado consumir muito tempo | Médio | Timebox; formas simples; sem tiles/keys; evoluir depois |
| Scope creep (busca, lista, detalhes, auth) | Médio | P2/out of scope; uma fase por vez; Q5/Q10 |
| Goldens frágeis entre ambientes | Baixo | Gerar em CI; congelar fonte; revisão manual como fallback |
| Sem teste em dispositivo físico | Médio | Checklist manual em emulador + dispositivo quando disponível |
| Git não inicializado quebra quality gate | Baixo | Resolver na Fase 0 com aprovação |

---

## 13. Questões abertas (resolver antes da fase indicada)

| ID | Pergunta | Proposta/default | Bloqueia |
|---|---|---|---|
| Q1 | Quais são o conteúdo e o layout das etapas 2/3 e 3/3? | §8.3/§8.4 desta spec | Fase 5 (polimento) |
| Q2 | “Encaminhada” é um novo status ou label de `EM_ANDAMENTO`? | Label de `EM_ANDAMENTO` | Fase 2 |
| Q3 | “Iluminação apagada” é uma 5ª categoria ou título de “Poste caído”? | Título de `POSTE_CAIDO` | Fase 2 |
| Q4 | Quais controles existem na parte inferior da captura (cortada no PDF)? | Apenas obturador no MVP | Fase 4 |
| Q5 | O que “Trocar” e a busca devem fazer? | Regiões mockadas + busca local P2 | Fase 3 |
| Q6 | Qual é a fonte oficial e os tokens exatos? | Sora + paleta aproximada | Fase 1 (fonte), Fase 3 (visual) |
| Q7 | Qual é a resposta real de criação de ocorrência (protocolo, código, IDs)? | Mock `REP-DEMO-*`; não é contrato | Fase 5 |
| Q8 | Foto e descrição são obrigatórias? Quais limites? | Foto obrigatória na demo; descrição não vazia, limite 2000 | Fase 5 |
| Q9 | Câmera/GPS reais entram no MVP? | Não; fakes agora | Pós-MVP |
| Q10 | “Ver lista” abre tela nova ou expande o sheet? | Expande o sheet | Fase 3 |
| Q11 | Cores/ícones por categoria e status | Mapa provisório da §5.1 | Fase 1/3 |
| Q12 | Há autenticação ou o relato é anônimo? | Anônimo; usuário nulo é permitido pelo schema | Pós-MVP |
| Q13 | Demandas terminais aparecem no mapa? | Apenas ativas na demo | Fase 2 |

---

## 14. Backlog pós-MVP (não executar agora)

- Integração HTTP real somente após OpenAPI/contrato fechado: client centralizado, DTOs,
  mapeamento de erros, timeouts, auth/refresh conforme o backend.
- Token de dispositivo e eventual autenticação.
- Câmera e GPS reais com permissões, tratamento de negação e testes em dispositivos.
- Mapas reais com tiles e chave gerenciada fora do binário; geocodificação/reverse geocode.
- Busca e filtros reais; lista completa/detalhe da demanda; acompanhamento por protocolo.
- Upload/compressão de imagens e armazenamento.
- “Minhas ocorrências”, notificações, deep links.
- App do gestor, revisão de matching, administração.
- Tema escuro global, i18n, analytics, crash reporting, offline queue.
- Acessibilidade com leitor de tela real e auditoria formal.

---

## 15. Como executar com o harness

### 15.1 Prompt base

```text
@orchestrator Execute a Fase N — <nome> de docs/IMPLEMENTATION_SPEC.md.

Leia AGENTS.md, docs/IMPLEMENTATION_SPEC.md e os docs relacionados.
Escopo permitido: somente os entregáveis da Fase N.
Não inicie a fase seguinte. Não invente endpoints, campos de API, auth ou regras de
negócio. Use os mocks definidos na spec e mantenha a fronteira de dados.

Delegue implementação ao flutter-engineer, revisão ao ui-reviewer (se a fase tiver UI)
e verificação ao qa-engineer. Ao final, pare e reporte:
- arquivos alterados;
- comandos executados com exit code;
- resultados PASS/FAIL/NOT RUN;
- findings de review e riscos restantes.
```

### 15.2 Ordem recomendada

1. Aprovar dependências, git e as questões abertas com bloqueio na fase correspondente
   (ver §13).
2. Executar Fase 0 e revisar o diff.
3. Fase 1 (design system) e aprovação visual.
4. Fase 2 (domínio/mocks) e testes.
5. Fase 3 (mapa) e revisão de UI.
6. Fase 4 (captura) e revisão de UI.
7. Fase 5 (fluxo completo) e teste integrado.
8. Fase 6 (hardening) e QA final.

### 15.3 Regras de convivência com o harness

- O orquestrador não deve iniciar duas fases no mesmo turno.
- O implementador não revisa o próprio trabalho como única revisão.
- O QA não edita código; reporta falhas reproduzíveis.
- O `security-reviewer` só é acionado quando o escopo incluir auth, rede, permissões ou
  dados sensíveis.
- Qualquer mudança de contrato exige atualização de `docs/API_CONTRACT.md` com fatos
  verificados, nunca suposições.

---

## 16. Critério de sucesso da iniciativa

A iniciativa está concluída quando:

- [ ] O app abre no mapa, mostra 12 demandas mockadas e permite trocar de região.
- [ ] O CTA “Registrar” leva à captura 1/3 e o fluxo completo chega ao sucesso.
- [ ] Todos os estados (loading/vazio/erro/sucesso) são demonstráveis.
- [ ] O visual das duas telas do PDF está fiel em 390 × 844.
- [ ] Acessibilidade básica e responsividade foram verificadas.
- [ ] A suíte de testes e os quality gates passam com evidência.
- [ ] Nenhum endpoint ou comportamento de backend foi inventado.
- [ ] As questões abertas restantes estão documentadas e priorizadas.

---

### Anexo A — Decisões que precisam de “sim” humano antes da Fase 0

1. Adicionar `flutter_riverpod`, `go_router` e `flutter_localizations`.
2. Inicializar git (ou adaptar `tool/quality.ps1`).
3. Usar `Sora` como fonte (asset) ou aceitar a fonte padrão com desvio visual.
4. Confirmar que o MVP aceita câmera/GPS falsos e mapa estilizado.
5. Confirmar que o relato é anônimo nesta fase.

### Anexo B — Arquivos que provavelmente serão tocados na primeira entrega

- `pubspec.yaml`, `pubspec.lock`
- `lib/main.dart`
- `lib/app/app.dart`, `lib/app/router/app_router.dart`, `lib/app/theme/*`
- `lib/features/map/**`, `lib/features/demands/**`, `lib/features/report/**`
- `test/**`, `integration_test/**`
- `docs/ARCHITECTURE.md`, `docs/DEPENDENCIES.md`, `docs/IMPLEMENTATION_SPEC.md`

> Este anexo é orientativo; o orquestrador deve sempre inspecionar o estado real antes de
> editar e evitar refatorações fora do escopo.
