# INTransporte

Aplicativo mobile em Flutter para acompanhar ônibus em trajeto e localizar pontos com acessibilidade.

## Objetivo

O INTransporte faz parte de um projeto acadêmico sobre pontos de ônibus inteligentes. A proposta é ajudar as pessoas a planejar seus deslocamentos e encontrar pontos acessíveis.

## Escopo inicial

- Tela inicial com acesso ao mapa.
- Prévia ilustrativa de um trajeto de ônibus.
- Lista de pontos acessíveis e previsão de chegada de exemplo.

Os dados exibidos nesta versão são estáticos. A integração com a API Java será feita quando ela estiver disponível.

## Próximos passos

- Conectar o aplicativo à API Java.
- Trocar a prévia ilustrativa por um mapa real.
- Validar as informações de acessibilidade dos pontos.

## Tecnologias

- Flutter
- Dart

## Como executar

Com o Flutter instalado, na pasta do projeto execute:

```bash
flutter pub get
flutter run
```

## Estrutura

- `lib/main.dart`: inicialização do aplicativo.
- `lib/telas/`: telas inicial e do mapa.
- `lib/tema.dart`: cores e estilos básicos.
