# Mobile Engineering Harness — Flutter + Dart + Java API

Harness de engenharia para usar OpenCode com DeepSeek V4.1 Flash em projetos Flutter.
O backend é uma aplicação Java externa; este repositório contém somente padrões e ferramentas do frontend.

## O que vem incluído

- `AGENTS.md`: regras permanentes do projeto.
- `.opencode/agents/`: orquestrador e especialistas.
- `.opencode/skills/`: conhecimento operacional carregado sob demanda.
- `opencode.json`: agente principal e permissões de delegação.
- `analysis_options.yaml`: baseline de análise Dart.
- `tool/quality.*`: quality gates locais (Bash e PowerShell).
- `.github/workflows/flutter-quality.yml`: CI para Flutter.
- `docs/`: arquitetura, contrato HTTP, Definition of Done e fluxo de trabalho.

## Instalação

1. Faça backup/commit do projeto Flutter atual.
2. Extraia este pacote na raiz do projeto Flutter. Mescle pastas existentes; não sobrescreva configurações próprias sem revisar.
3. Ajuste `pubspec.yaml` conforme `docs/DEPENDENCIES.md`. O pacote não substitui seu `pubspec.yaml`.
4. Execute `flutter pub get`.
5. Execute `dart format .`.
6. Execute `bash tool/quality.sh` (macOS/Linux/Git Bash) ou `pwsh -File tool/quality.ps1` (Windows).
7. Abra OpenCode na raiz do projeto e confirme:
   - `/connect` → DeepSeek → selecione `deepseek-flash` (nome atual do DeepSeek V4.1 Flash).
   - `/agents` ou `opencode agent list` para verificar agentes disponíveis.
   - Use `@orchestrator` ou deixe-o como agente padrão.

## Modelo e API

A configuração do modelo é feita pelo fluxo `/connect` do OpenCode, não por chave gravada no repositório.
Nunca coloque API keys em `opencode.json`, `.env` versionado ou arquivos de skill.
DeepSeek API usa atualmente o model ID `deepseek-flash`. Confira preço, limites e compatibilidade na documentação oficial antes de uso intensivo.

## Modo mock (dados falsos)

O backend ainda não existe, então o app roda por padrão em modo mock nos builds de
desenvolvimento: `MOCK_MODE` assume `true` em debug/profile. O cenário de dados é
escolhido em tempo de compilação com `--dart-define`:

```bash
flutter run                                        # success (padrão)
flutter run --dart-define=MOCK_SCENARIO=empty      # lista vazia
flutter run --dart-define=MOCK_SCENARIO=error      # erro
flutter run --dart-define=MOCK_SCENARIO=slow      # lentidão
```

Cenário inválido falha na inicialização com mensagem listando os valores aceitos.
Em release, `MOCK_MODE` é `false` por padrão e o app mostra uma tela de erro de
configuração em vez de dados falsos; uma build de demonstração exige opt-in
explícito com `--dart-define=MOCK_MODE=true` e não deve ser distribuída como
produção. Implementação: `lib/core/config/app_config.dart`.

## Primeiro uso sugerido

Peça:

> @orchestrator Analise este projeto sem alterar arquivos. Identifique arquitetura atual, pontos de risco, comandos de validação disponíveis e proponha um plano de adoção incremental deste harness. Não invente endpoints da API Java.

Depois de revisar o plano:

> @orchestrator Implemente somente a primeira etapa aprovada. Delegue implementação, revisão e QA. Não altere contratos de API sem evidência/documentação.

## Princípios de segurança

- Agentes revisores são somente leitura.
- Comandos destrutivos, deploy, publicação, push e alterações fora do workspace exigem aprovação humana.
- Não compartilhar segredos com o modelo.
- Nunca desabilitar testes ou enfraquecer regras para fazer o pipeline passar.
- O harness é um sistema de apoio: revise diffs e aprove decisões sensíveis.

## Importante

Este pacote é um baseline reutilizável, não conhece ainda os endpoints, autenticação, arquitetura ou convenções reais da sua aplicação Java. Preencha `docs/API_CONTRACT.md` com o contrato verdadeiro antes de implementar integrações.
