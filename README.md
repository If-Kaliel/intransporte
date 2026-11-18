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
- Entrar na API Java e carregar os pontos cadastrados.
- Filtrar pontos pelo endereço e navegar pelas páginas retornadas pela API.
- Tocar em um ponto para consultar as linhas vinculadas a ele.
- Aumentar o tamanho do texto para facilitar a leitura.

## Telas

| Tela | O que tem |
|---|---|
| Inicial | Apresentação do app, opção de aumentar as letras e acesso ao mapa |
| Mapa | Prévia ilustrativa, busca paginada de pontos da API e consulta das linhas de cada ponto |

## Fluxo de navegação

```text
Inicial ──> Mapa ──> Login da API ──> Ponto ──> Linhas
```

## Escopo atual

O mapa do trajeto ainda é ilustrativo, pois a API não retorna coordenadas. A lista de pontos e as linhas vinculadas vêm da API depois do login. A API também ainda não fornece informações de acessibilidade dos pontos.

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
└── telas/
    ├── tela_inicial.dart
    └── tela_mapa.dart
```

## Próximos passos

- Conectar o aplicativo à API Java.
- Trocar a prévia ilustrativa por um mapa real.
- Validar as informações de acessibilidade dos pontos.
