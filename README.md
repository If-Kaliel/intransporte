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

## Projeto

A proposta do INTransporte é tornar o uso do transporte público mais acessível. O ponto inteligente poderá oferecer avisos sonoros, seleção de ônibus por totem e um botão de emergência. O aplicativo complementa o projeto mostrando ônibus em trajeto e pontos com acessibilidade.

## Descrição da solução

O app apresenta uma tela inicial e uma prévia do mapa com ônibus e pontos acessíveis. Nesta versão, os dados são exemplos estáticos. A conexão com a API Java será feita quando ela estiver disponível.

## Funcionalidades

- Abrir o mapa a partir da tela inicial.
- Visualizar uma prévia ilustrativa de um trajeto.
- Consultar pontos acessíveis e previsões de chegada de exemplo.
- Tocar em um ponto para ver seus detalhes.
- Aumentar o tamanho do texto para facilitar a leitura.

## Telas

| Tela | O que tem |
|---|---|
| Inicial | Apresentação do app, opção de aumentar as letras e acesso ao mapa |
| Mapa | Prévia ilustrativa do trajeto, lista de pontos acessíveis e detalhes ao tocar em um ponto |

## Fluxo de navegação

```text
Inicial ──> Mapa ──> Detalhes do ponto
```

## Escopo atual

O mapa e as informações exibidas são demonstrativos. Ainda não há localização em tempo real nem conexão da interface com a API.

## Preparação para a API Java

O serviço em `lib/servicos/api_servico.dart` prepara as chamadas de login, consulta de pontos e linhas por ponto. A lista de pontos é lida de `_embedded.pontos`, e os metadados de paginação são mantidos em `page`. A URL base será informada quando o endereço do servidor estiver disponível.

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
└── telas/
    ├── tela_inicial.dart
    └── tela_mapa.dart
```

## Próximos passos

- Conectar o aplicativo à API Java.
- Trocar a prévia ilustrativa por um mapa real.
- Validar as informações de acessibilidade dos pontos.
