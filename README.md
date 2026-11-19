# INTransporte

Aplicativo mobile acadêmico feito em Flutter para o projeto de ponto de ônibus inteligente.

## Integrantes

| Nome | RM |
|---|---|
| Kaliel Aquino | RM567587 |
| Andre Matuda | RM566733 |
| Paulo Diedrich | RM567618 |
| Guilherme Barca | RM568517 |
| Guilherme Feitosa | RM566842 |

## Link do vídeo do YouTube: (https://youtu.be/d-DOIrmki2M)

## Projeto

A proposta do INTransporte é tornar o uso do transporte público mais acessível. O ponto inteligente poderá oferecer avisos sonoros, seleção de ônibus por totem e um botão de emergência. O aplicativo complementa o projeto mostrando ônibus em trajeto e pontos com acessibilidade.

## Descrição da solução

O INTransporte é um aplicativo Flutter que reúne uma prévia interativa de mapa e uma consulta de pontos e linhas de ônibus pela API Java do grupo. O mapa usa uma cidade fictícia como demonstração; os pontos e as linhas da consulta vêm da API.

## Público beneficiado

A solução é pensada para cidadãos que usam o transporte público, com atenção especial a pessoas cegas ou com baixa visão e a pessoas com mobilidade reduzida. O projeto completo prevê recursos de acessibilidade no ponto inteligente, como avisos sonoros e seleção de ônibus. No aplicativo atual, os dados de acessibilidade ainda não são fornecidos pela API, e o mapa é ilustrativo.

## Objetivos de Desenvolvimento Sustentável

- **ODS 11 — Cidades e Comunidades Sustentáveis:** apoiar o acesso a um transporte público mais inclusivo.
- **ODS 10 — Redução das Desigualdades:** considerar as necessidades de pessoas com deficiência no acesso ao transporte.

Essas relações descrevem os objetivos do projeto acadêmico; não representam uma avaliação de impacto já realizada.

## Funcionalidades

- Abrir o mapa a partir da tela inicial.
- Visualizar uma prévia ilustrativa de um trajeto.
- Entrar na API Java e carregar os pontos cadastrados.
- Filtrar pontos pelo endereço e navegar pelas páginas retornadas pela API.
- Tocar em um ponto para consultar as linhas vinculadas a ele.
- Aumentar o tamanho do texto para facilitar a leitura.

## Telas

| Tela | O que tem |
|---|---|
| Inicial | Apresentação do app, opção de aumentar as letras e acesso ao mapa |
| Mapa | Prévia ilustrativa da cidade, com marcadores interativos e acesso à consulta da API |
| Pontos de ônibus | Login, filtro por endereço e paginação dos pontos retornados pela API |
| Detalhes do ponto | Endereço do ponto e lista de linhas vinculadas |
| Detalhes da linha | Descrição e intervalo da linha |
| Sobre o INTransporte | Resumo do projeto e dos limites dos dados da demonstração |

## Fluxo de navegação

```text
Inicial ──> Mapa ──> Pontos ──> Detalhes do ponto ──> Detalhes da linha
             └──> Sobre
```

## Escopo atual

O mapa do trajeto ainda é ilustrativo, pois a API não retorna coordenadas. A lista de pontos e as linhas vinculadas vêm da API depois do login. A API também ainda não fornece informações de acessibilidade dos pontos.

## Uso de inteligência artificial generativa

Foi feito uso mínimo para geração de funções que fogem do conhecimento do grupo ou do que foi visto em aula em benefício do aplicativo em si para que fique melhor para o usuário final.

## Preparação para a API Java

O serviço em `lib/servicos/api_servico.dart` chama `POST /auth/login`, `GET /api/pontos` e `GET /api/pontos/{id}/linhas`. A lista HAL é lida de `_embedded.pontos`, e a busca por endereço e a paginação usam os parâmetros da API.

No emulador Android, a URL padrão é `http://10.0.2.2:8080`, que aponta para o computador onde a API está rodando. Para outro endereço, execute com `--dart-define=API_URL=http://endereco-do-servidor:8080`. O tráfego HTTP sem TLS fica liberado apenas no manifesto de debug.

## Como executar

Com o Flutter instalado, na pasta do projeto execute:

```bash
flutter pub get
flutter run
```

## Tecnologias utilizadas

- Flutter
- Dart
- Material Design

## Estrutura do projeto

```text
lib/
├── main.dart
├── tema.dart
├── config/
├── modelos/
├── servicos/
└── telas/
    ├── tela_inicial.dart
    ├── tela_mapa.dart
    ├── tela_pontos.dart
    ├── tela_ponto_detalhe.dart
    ├── tela_linha_detalhe.dart
    └── tela_sobre.dart
```
