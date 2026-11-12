# Only front now

# Java Backend API Contract — fill with verified facts

This document is the source of truth for frontend/backend integration. Do not invent missing values.

## Environments
| Environment | Base URL | Notes |
|---|---|---|
| Local development | UNKNOWN | Confirm emulator/device networking requirements |
| Staging | UNKNOWN | |
| Production | UNKNOWN | |

## Authentication
- Scheme: UNKNOWN
- Login endpoint: UNKNOWN
- Access token format/location: UNKNOWN
- Refresh flow and endpoint: UNKNOWN
- Logout/revocation behavior: UNKNOWN
- Token expiry semantics: UNKNOWN

## API conventions
- API versioning: UNKNOWN
- Content type: UNKNOWN
- Date/time format and timezone: UNKNOWN
- Pagination: UNKNOWN
- Correlation/request ID header: UNKNOWN
- Standard error envelope: UNKNOWN

## Endpoint inventory
| Feature | Method | Exact path | Request schema | Response schema | Auth | Source |
|---|---|---|---|---|---|---|
| Example — replace | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN | UNKNOWN |

## Error mapping
Document actual status codes and response bodies. Do not assume conventional meanings if the backend contract differs.

## Contract change process
1. Backend owner updates OpenAPI/schema or this document.
2. Frontend updates DTOs/mappers/client tests.
3. Review compatibility and migration impact.
4. Do not ship assumptions as facts.



# SCHEMAS FOR BASE

  ## Sumário

  1. [Identidade](#1-identidade) — `Usuario`, `Gestor`, `Dispositivo`
  2. [Catálogo](#2-catálogo) — `Categoria`
  3. [Núcleo do Domínio](#3-núcleo-do-domínio) — `Demanda`, `Ocorrencia`, `Imagem`
  4. [Matching](#4-matching) — `Score`, `MatchingOcorrencia`, `RevisaoMatching`*
  5. [Auditoria](#5-auditoria) — `HistoricoStatusDemanda`
  6. [Enums](#6-enums)
  7. [Diagrama ER](#7-diagrama-er)

  ---

  ## 1. Identidade

  ### 👤 `Usuario` → tabela `usuario`
  Cidadão cadastrado que pode enviar ocorrências identificadas.

  | Campo (Java)  | Coluna         | Tipo           | Nulo | Restrições            |
  |---------------|----------------|----------------|:----:|-----------------------|
  | `id`          | `id`           | `BIGINT`       | ❌   | PK, identity          |
  | `nomeUsuario` | `nome_usuario` | `VARCHAR(50)`  | ❌   | UNIQUE                |
  | `nome`        | `nome`         | `VARCHAR(120)` | ❌   |                       |
  | `email`       | `email`        | `VARCHAR(160)` | ❌   | UNIQUE                |
  | `hashSenha`   | `hash_senha`   | `VARCHAR(255)` | ❌   |                       |
  | `criadoEm`    | `criado_em`    | `TIMESTAMPTZ`  | ❌   | `@CreationTimestamp`  |

  ### 🛡️ `Gestor` → tabela `gestor`
  Operador do sistema (revisa matchings e altera status de demandas).

  | Campo (Java)  | Coluna         | Tipo           | Nulo | Restrições                          |
  |---------------|----------------|----------------|:----:|-------------------------------------|
  | `id`          | `id`           | `BIGINT`       | ❌   | PK, identity                        |
  | `nomeUsuario` | `nome_usuario` | `VARCHAR(50)`  | ❌   | UNIQUE                              |
  | `nome`        | `nome`         | `VARCHAR(120)` | ❌   |                                     |
  | `email`       | `email`        | `VARCHAR(160)` | ❌   | UNIQUE                              |
  | `hashSenha`   | `hash_senha`   | `VARCHAR(255)` | ❌   |                                     |
  | `papel`       | `papel`        | `VARCHAR(30)`  | ❌   | enum [`Papel`](#papel)              |
  | `criadoEm`    | `criado_em`    | `TIMESTAMPTZ`  | ❌   | `@CreationTimestamp`                |

  ### 📱 `Dispositivo` → tabela `dispositivo`
  Identidade do aparelho. O token é emitido pelo cliente e serve como chave primária.

  | Campo (Java) | Coluna      | Tipo          | Nulo | Restrições                     |
  |--------------|-------------|---------------|:----:|--------------------------------|
  | `token`      | `token`     | `VARCHAR(64)` | ❌   | PK (natural), não atualizável  |
  | `criadoEm`   | `criado_em` | `TIMESTAMPTZ` | ❌   | `@CreationTimestamp`           |

  ---

  ## 2. Catálogo

  ### 🏷️ `Categoria` → tabela `categoria`
  Categoria é **dado, não enum**: o raio do candidate retrieval é calibrado por categoria sem precisar de deploy.

  | Campo (Java)         | Coluna                 | Tipo           | Nulo | Restrições          |
  |----------------------|------------------------|----------------|:----:|---------------------|
  | `id`                 | `id`                   | `INTEGER`      | ❌   | PK, identity        |
  | `codigo`             | `codigo`               | `VARCHAR(50)`  | ❌   | UNIQUE              |
  | `nome`               | `nome`                 | `VARCHAR(120)` | ❌   |                     |
  | `raioMatchingMetros` | `raio_matching_metros` | `INTEGER`      | ❌   | `CHECK (> 0)`       |

  **Carga inicial (V6), com raios provisórios:**

  | Código        | Nome        | Raio (m) |
  |---------------|-------------|---------:|
  | `BURACO`      | Buraco      | 50       |
  | `ESGOTO`      | Esgoto      | 100      |
  | `POSTE_CAIDO` | Poste caído | 30       |
  | `DEJETO`      | Dejeto      | 80       |

  ---

  ## 3. Núcleo do Domínio

  > **Ocorrência** = relato individual de um cidadão.
  > **Demanda** = problema urbano consolidado, que agrupa várias ocorrências.

  ### 📍 `Demanda` → tabela `demanda`

  | Campo (Java)      | Coluna             | Tipo                    | Nulo | Restrições                                   |
  |-------------------|--------------------|-------------------------|:----:|----------------------------------------------|
  | `id`              | `id`               | `BIGINT`                | ❌   | PK, identity                                 |
  | `categoria`       | `categoria_id`     | `INTEGER`               | ❌   | FK → `categoria.id` (LAZY)                   |
  | `localizacao`     | `localizacao`      | `geography(Point,4326)` | ❌   | Posição consolidada (da 1ª ocorrência) · GiST |
  | `status`          | `status`           | `VARCHAR(20)`           | ❌   | enum [`StatusDemanda`](#statusdemanda)       |
  | `numeroProtocolo` | `numero_protocolo` | `VARCHAR(50)`           | ✅   | Protocolo oficial, transcrito pelo gestor    |
  | `criadoEm`        | `criado_em`        | `TIMESTAMPTZ`           | ❌   | `@CreationTimestamp`                         |
  | `atualizadoEm`    | `atualizado_em`    | `TIMESTAMPTZ`           | ❌   | `@UpdateTimestamp`                           |
  | `encerradoEm`     | `encerrado_em`     | `TIMESTAMPTZ`           | ✅   | Ver invariante abaixo                        |

  **Invariante:** `encerrado_em` é preenchido **se e somente se** o status for terminal (`RESOLVIDA` ou `REJEITADA`).

  ### 📝 `Ocorrencia` → tabela `ocorrencia`

  | Campo (Java)           | Coluna                   | Tipo                    | Nulo | Restrições                                      |
  |------------------------|--------------------------|-------------------------|:----:|-------------------------------------------------|
  | `id`                   | `id`                     | `BIGINT`                | ❌   | PK, identity                                    |
  | `codigoRastreio`       | `codigo_rastreio`        | `VARCHAR(20)`           | ❌   | UNIQUE, não atualizável                         |
  | `demanda`              | `demanda_id`             | `BIGINT`                | ✅   | FK → `demanda.id` · nulo até a consolidação     |
  | `categoria`            | `categoria_id`           | `INTEGER`               | ❌   | FK → `categoria.id`                             |
  | `usuario`              | `usuario_id`             | `BIGINT`                | ✅   | FK → `usuario.id` · nulo = relato anônimo       |
  | `dispositivo`          | `dispositivo_token`      | `VARCHAR(64)`           | ❌   | FK → `dispositivo.token`                        |
  | `descricao`            | `descricao`              | `TEXT`                  | ❌   |                                                 |
  | `localizacao`          | `localizacao`            | `geography(Point,4326)` | ❌   | GiST                                            |
  | `precisaoGps`          | `precisao_gps`           | `DOUBLE PRECISION`      | ✅   | `CHECK (>= 0)`                                  |
  | `status`               | `status`                 | `VARCHAR(20)`           | ❌   | enum [`StatusOcorrencia`](#statusocorrencia)    |
  | `embeddingTexto`       | `embedding_texto`        | `vector(1024)`          | ✅   | Gerado de forma assíncrona                      |
  | `modeloEmbeddingTexto` | `modelo_embedding_texto` | `VARCHAR(60)`           | ✅   | Obrigatório se houver embedding                 |
  | `criadoEm`             | `criado_em`              | `TIMESTAMPTZ`           | ❌   | `@CreationTimestamp`                            |
  | `atualizadoEm`         | `atualizado_em`          | `TIMESTAMPTZ`           | ❌   | `@UpdateTimestamp`                              |

  **Invariantes:**
  - `demanda_id` é preenchido **se e somente se** `status ∈ {ASSOCIADA, NOVA_DEMANDA}`.
  - Não existe embedding sem o modelo que o gerou: `embedding_texto IS NULL OR modelo_embedding_texto IS NOT NULL`.

  ### 🖼️ `Imagem` → tabela `imagem`
  O arquivo binário fica no object storage. A tabela guarda só a referência e os metadados.

  | Campo (Java)         | Coluna                | Tipo           | Nulo | Restrições                         |
  |----------------------|-----------------------|----------------|:----:|------------------------------------|
  | `id`                 | `id`                  | `BIGINT`       | ❌   | PK, identity                       |
  | `ocorrencia`         | `ocorrencia_id`       | `BIGINT`       | ❌   | FK → `ocorrencia.id`               |
  | `chaveArmazenamento` | `chave_armazenamento` | `VARCHAR(255)` | ❌   | UNIQUE, não atualizável            |
  | `tipoConteudo`       | `tipo_conteudo`       | `VARCHAR(100)` | ❌   | MIME type                          |
  | `tamanhoBytes`       | `tamanho_bytes`       | `BIGINT`       | ❌   | `CHECK (> 0)`                      |
  | `embedding`          | `embedding`           | `vector(1024)` | ✅   | Gerado de forma assíncrona         |
  | `modeloEmbedding`    | `modelo_embedding`    | `VARCHAR(60)`  | ✅   | Obrigatório se houver embedding    |
  | `criadoEm`           | `criado_em`           | `TIMESTAMPTZ`  | ❌   | `@CreationTimestamp`               |

  > **Embeddings:** `voyage-multimodal-3.5` com 1024 dimensões. Texto e imagem saem do mesmo modelo e vivem no mesmo espaço vetorial, então são comparáveis.     
  **Não há índice HNSW de propósito:** a similaridade só é calculada contra as demandas candidatas, que já passaram pelo filtro de geo e categoria.

  ---

  ## 4. Matching

  ### 📊 `Score` → tabela `score`
  Score de cada sinal para um par (ocorrência, demanda candidata). A categoria não tem score porque já é usada como filtro no retrieval.

  | Campo (Java)       | Coluna              | Tipo               | Nulo | Restrições                          |
  |--------------------|---------------------|--------------------|:----:|-------------------------------------|
  | `id`               | `id`                | `BIGINT`           | ❌   | PK, identity                        |
  | `ocorrencia`       | `ocorrencia_id`     | `BIGINT`           | ❌   | FK → `ocorrencia.id`                |
  | `demanda`          | `demanda_id`        | `BIGINT`           | ❌   | FK → `demanda.id`                   |
  | `scoreLocalizacao` | `score_localizacao` | `DOUBLE PRECISION` | ❌   | `[0, 1]`                            |
  | `scoreImagem`      | `score_imagem`      | `DOUBLE PRECISION` | ✅   | `[0, 1]` · nulo se o sinal faltar   |
  | `scoreDescricao`   | `score_descricao`   | `DOUBLE PRECISION` | ✅   | `[0, 1]` · nulo se o sinal faltar   |
  | `criadoEm`         | `criado_em`         | `TIMESTAMPTZ`      | ❌   | `@CreationTimestamp`                |

  **Unique:** `(ocorrencia_id, demanda_id)` · todos os campos são imutáveis (`updatable = false`).

  ### 🔗 `MatchingOcorrencia` → tabela `matching_ocorrencia`
  Resultado do matching para o par: score final e decisão. A linha é **imutável** (só recebe INSERT).

  | Campo (Java)       | Coluna                 | Tipo               | Nulo | Restrições                                |
  |--------------------|------------------------|--------------------|:----:|-------------------------------------------|
  | `id`               | `id`                   | `BIGINT`           | ❌   | PK, identity                              |
  | `ocorrencia`       | `ocorrencia_id`        | `BIGINT`           | ❌   | FK → `ocorrencia.id`                      |
  | `demandaCandidata` | `demanda_candidata_id` | `BIGINT`           | ❌   | FK → `demanda.id`                         |
  | `scoreFinal`       | `score_final`          | `DOUBLE PRECISION` | ❌   | `[0, 1]`                                  |
  | `decisao`          | `decisao`              | `VARCHAR(20)`      | ❌   | enum [`DecisaoMatching`](#decisaomatching) |
  | `versaoModelo`     | `versao_modelo`        | `VARCHAR(120)`     | ✅   |                                           |
  | `criadoEm`         | `criado_em`            | `TIMESTAMPTZ`      | ❌   | `@CreationTimestamp`                      |

  **Unique:** `(ocorrencia_id, demanda_candidata_id)`, que garante a idempotência do worker.

  ### ✅ `RevisaoMatching`* → tabela `revisao_matching`
  Decisão do operador sobre um matching que foi para revisão.
  > \* **Existe só na migration (V4).** Ainda não há entidade JPA. O enum `DecisaoRevisao` já existe.

  | Coluna                   | Tipo          | Nulo | Restrições                                   |
  |--------------------------|---------------|:----:|----------------------------------------------|
  | `id`                     | `BIGINT`      | ❌   | PK, identity                                 |
  | `matching_ocorrencia_id` | `BIGINT`      | ❌   | FK → `matching_ocorrencia.id` · UNIQUE       |
  | `gestor_id`              | `BIGINT`      | ❌   | FK → `gestor.id`                             |
  | `decisao`                | `VARCHAR(20)` | ❌   | enum [`DecisaoRevisao`](#decisaorevisao)     |
  | `criado_em`              | `TIMESTAMPTZ` | ❌   |                                              |

  ---

  ## 5. Auditoria

  ### 🕓 `HistoricoStatusDemanda` → tabela `historico_status_demanda`
  Trilha de transições de status de uma demanda. Todos os campos são imutáveis.

  | Campo (Java)     | Coluna            | Tipo          | Nulo | Restrições                                          |
  |------------------|-------------------|---------------|:----:|-----------------------------------------------------|
  | `id`             | `id`              | `BIGINT`      | ❌   | PK, identity                                        |
  | `demanda`        | `demanda_id`      | `BIGINT`      | ❌   | FK → `demanda.id`                                   |
  | `gestor`         | `gestor_id`       | `BIGINT`      | ✅   | FK → `gestor.id` · nulo = transição feita pelo sistema |
  | `statusAnterior` | `status_anterior` | `VARCHAR(20)` | ✅   | `StatusDemanda` · nulo na criação da demanda        |
  | `statusNovo`     | `status_novo`     | `VARCHAR(20)` | ❌   | `StatusDemanda`                                     |
  | `alteradoEm`     | `alterado_em`     | `TIMESTAMPTZ` | ❌   | Preenchido pela aplicação (não usa `@CreationTimestamp`) |

  ---

  ## 6. Enums

  #### `StatusDemanda`
  | Valor          | Terminal? |
  |----------------|:---------:|
  | `ABERTA`       | ❌        |
  | `EM_ANDAMENTO` | ❌        |
  | `RESOLVIDA`    | ✅        |
  | `REJEITADA`    | ✅        |

  > Demandas terminais não entram como candidatas no matching (`isTerminal()`).

  #### `StatusOcorrencia`
  `RECEBIDA` → `PROCESSANDO` → `ASSOCIADA` | `EM_REVISAO` | `NOVA_DEMANDA`

  #### `DecisaoMatching`
  `ASSOCIAR` · `REVISAR` · `CRIAR_DEMANDA`

  #### `DecisaoRevisao`
  `ASSOCIAR` · `NAO_ASSOCIAR`

  #### `Papel`
  `USUARIO` · `SERVIDOR_PUBLICO`

  #### `TipoSinal` *(não persistido)*
  `GEO` · `TEXTO` · `IMAGEM`

  ---

  ## 7. Diagrama ER

  ```mermaid
  erDiagram
      CATEGORIA ||--o{ DEMANDA : classifica
      CATEGORIA ||--o{ OCORRENCIA : classifica
      USUARIO |o--o{ OCORRENCIA : relata
      DISPOSITIVO ||--o{ OCORRENCIA : envia
      DEMANDA |o--o{ OCORRENCIA : agrupa
      OCORRENCIA ||--o{ IMAGEM : possui
      OCORRENCIA ||--o{ SCORE : avaliada
      DEMANDA ||--o{ SCORE : candidata
      OCORRENCIA ||--o{ MATCHING_OCORRENCIA : avaliada
      DEMANDA ||--o{ MATCHING_OCORRENCIA : candidata
      MATCHING_OCORRENCIA ||--o| REVISAO_MATCHING : revisada
      GESTOR ||--o{ REVISAO_MATCHING : decide
      DEMANDA ||--o{ HISTORICO_STATUS_DEMANDA : registra
      GESTOR |o--o{ HISTORICO_STATUS_DEMANDA : altera
  ```

  ## Índices relevantes (V5)

  | Índice                                        | Tabela                     | Finalidade                                   |
  |-----------------------------------------------|----------------------------|----------------------------------------------|
  | `idx_demanda_localizacao` (GiST)              | `demanda`                  | `ST_DWithin` no candidate retrieval          |
  | `idx_demanda_categoria_ativa` (parcial)       | `demanda`                  | Só demandas `ABERTA` / `EM_ANDAMENTO`        |
  | `idx_ocorrencia_localizacao` (GiST)           | `ocorrencia`               | Consultas geoespaciais                       |
  | `idx_ocorrencia_demanda`                      | `ocorrencia`               | Demanda → ocorrências                        |
  | `idx_ocorrencia_status`                       | `ocorrencia`               | Filas de processamento e revisão             |
  | `idx_ocorrencia_dispositivo_categoria_criado` | `ocorrencia`               | Contenção anti-spam                          |
  | `idx_imagem_ocorrencia`                       | `imagem`                   | Ocorrência → imagens                         |
  | `idx_score_demanda`                           | `score`                    | Busca por demanda                            |
  | `idx_matching_demanda_candidata`              | `matching_ocorrencia`      | Busca por demanda candidata                  |
  | `idx_historico_demanda`                       | `historico_status_demanda` | Timeline da demanda                          |

      DEMANDA ||--o{ SCORE : candidata
      OCORRENCIA ||--o{ MATCHING_OCORRENCIA : avaliada
      DEMANDA ||--o{ MATCHING_OCORRENCIA : candidata
      MATCHING_OCORRENCIA ||--o| REVISAO_MATCHING : revisada
      GESTOR ||--o{ REVISAO_MATCHING : decide
      DEMANDA ||--o{ HISTORICO_STATUS_DEMANDA : registra
      GESTOR |o--o{ HISTORICO_STATUS_DEMANDA : altera
  ```

  ## Índices relevantes (V5)

  | Índice                                        | Tabela                     | Finalidade                                   |
  |-----------------------------------------------|----------------------------|----------------------------------------------|
  | `idx_demanda_localizacao` (GiST)              | `demanda`                  | `ST_DWithin` no candidate retrieval          |
  | `idx_demanda_categoria_ativa` (parcial)       | `demanda`                  | Só demandas `ABERTA` / `EM_ANDAMENTO`        |
  | `idx_ocorrencia_localizacao` (GiST)           | `ocorrencia`               | Consultas geoespaciais                       |
  | `idx_ocorrencia_demanda`                      | `ocorrencia`               | Demanda → ocorrências                        |
  | `idx_ocorrencia_status`                       | `ocorrencia`               | Filas de processamento e revisão             |
  | `idx_ocorrencia_dispositivo_categoria_criado` | `ocorrencia`               | Contenção anti-spam                          |
  | `idx_imagem_ocorrencia`                       | `imagem`                   | Ocorrência → imagens                         |
  | `idx_score_demanda`                           | `score`                    | Busca por demanda                            |
  | `idx_matching_demanda_candidata`              | `matching_ocorrencia`      | Busca por demanda candidata                  |
  | `idx_historico_demanda`                       | `historico_status_demanda` | Timeline da demanda                          |

  Encontrei duas diferenças entre o código e o banco:
  - A tabela revisao_matching não tem entidade JPA. Ela existe na migration V4 e o enum DecisaoRevisao já foi criado, mas falta a classe Java.
  - O papel USUARIO aparece no enum Papel do Gestor. É o mesmo nome da entidade de cidadão, então vale confirmar se é isso mesmo que você quer.

