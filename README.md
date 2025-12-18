# 🚗 Car Maintenance Tracker

Aplicativo Flutter para gerenciamento de manutenção de veículos, permitindo cadastrar múltiplos carros e acompanhar todo o histórico de manutenções, custos e estatísticas.

## 📱 Funcionalidades

### Gerenciamento de Carros
- ✅ Cadastro de múltiplos carros com apelido, fabricante, modelo e ano
- ✅ Edição e exclusão de carros
- ✅ Seleção de imagem do carro (galeria ou câmera)
- ✅ Lista de todos os carros cadastrados

### Controle de Manutenções
- ✅ Cadastro completo de manutenções com:
  - Data da manutenção
  - Título da manutenção
  - Descrição do problema
  - Peças substituídas
  - Custo total
  - Nome do mecânico
  - Quilometragem do veículo
  - Notas adicionais
- ✅ Edição e exclusão de manutenções
- ✅ Visualização detalhada de cada manutenção
- ✅ Histórico paginado de manutenções (5 por vez com botão "Carregar mais")

### Estatísticas e Relatórios
- ✅ Dias desde a última manutenção
- ✅ Total gasto em manutenções
- ✅ Quantidade total de manutenções realizadas
- ✅ Contador de registros no histórico

### Interface
- ✅ Splash screen animada
- ✅ Design moderno e responsivo
- ✅ Navegação intuitiva

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework multiplataforma
- **MongoDB** - Banco de dados NoSQL na nuvem
- **mongo_dart** - Driver MongoDB para Dart
- **flutter_dotenv** - Gerenciamento de variáveis de ambiente
- **image_picker** - Seleção de imagens (galeria/câmera)
- **shared_preferences** - Armazenamento local de preferências
- **intl** - Internacionalização e formatação de datas
- **path_provider** - Acesso a diretórios do dispositivo

## 📋 Pré-requisitos

- Flutter SDK (versão 3.5.4 ou superior)
- Dart SDK
- Conta MongoDB Atlas (ou servidor MongoDB próprio)
- Xcode (para iOS) ou Android Studio (para Android)

## 🚀 Como Configurar

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd car_maintenance_tracker
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Configure as variáveis de ambiente

1. Copie o arquivo `.env.example` para `.env`:
```bash
cp .env.example .env
```

2. Edite o arquivo `.env` e adicione sua string de conexão do MongoDB:
```env
MONGODB_CONNECTION_STRING=mongodb+srv://usuario:senha@cluster.mongodb.net/
DATABASE_NAME=CarMaintenance
```

**⚠️ Importante**: O arquivo `.env` contém informações sensíveis e não deve ser commitado no Git. Ele já está configurado no `.gitignore`.

### 4. Execute o aplicativo

```bash
# Para iOS
flutter run

# Para Android
flutter run

# Para um dispositivo específico
flutter devices
flutter run -d <device-id>
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/
│   ├── car_model.dart        # Modelo de dados do carro
│   └── maintenance_model.dart # Modelo de dados da manutenção
├── screens/
│   ├── splash_screen.dart     # Tela de splash
│   ├── cars_list_screen.dart  # Lista de carros
│   ├── add_car_screen.dart    # Adicionar/editar carro
│   ├── home_screen.dart       # Tela principal com estatísticas
│   ├── add_maintenance_screen.dart # Adicionar/editar manutenção
│   └── maintenance_detail_screen.dart # Detalhes da manutenção
└── services/
    └── database_service.dart  # Serviço de conexão com MongoDB
```

## 🎨 Características da Interface

- **Cards Informativos**: Estatísticas exibidas em cards visuais
- **Paginação**: Histórico de manutenções com carregamento progressivo
- **Imagens Circulares**: Fotos dos carros exibidas em formato circular
- **Animações**: Splash screen com animações suaves
- **Floating Action Buttons**: Botões flutuantes para ações principais

## 🔒 Segurança

- Credenciais do banco de dados armazenadas em arquivo `.env` (não versionado)
- Validação de dados em formulários
- Tratamento de erros em operações de banco de dados

## 📝 Modelos de Dados

### Car (Carro)
- `id`: Identificador único
- `nickname`: Apelido do carro
- `manufacturer`: Fabricante
- `model`: Modelo
- `year`: Ano

### MaintenanceRecord (Registro de Manutenção)
- `id`: Identificador único
- `carId`: ID do carro vinculado
- `serviceDate`: Data da manutenção
- `title`: Título da manutenção
- `problemDescription`: Descrição do problema
- `replacedParts`: Lista de peças substituídas
- `cost`: Custo total
- `mechanicName`: Nome do mecânico
- `notes`: Notas adicionais
- `km`: Quilometragem do veículo

## 🐛 Solução de Problemas

### Erro ao carregar .env
- Certifique-se de que o arquivo `.env` está na raiz do projeto
- Execute `flutter clean` e `flutter pub get`
- Faça um rebuild completo do app (não apenas hot reload)

### Erro de conexão com MongoDB
- Verifique se a string de conexão no `.env` está correta
- Confirme que o IP está liberado no MongoDB Atlas (Network Access)
- Verifique as credenciais de usuário e senha

### Erro ao selecionar imagem
- Verifique as permissões de câmera e galeria no dispositivo
- No iOS, verifique o `Info.plist` para permissões de câmera

## 📄 Licença

Este projeto é privado e de uso pessoal.

## 👨‍💻 Desenvolvido por

Car Maintenance Tracker - Sistema de gerenciamento de manutenção de veículos

---

**Versão**: 1.0.0+1
