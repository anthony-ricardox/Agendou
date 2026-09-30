<div align="center">

# 📅 Agendou

### Agendamento de serviços simples, confiável e sem conflitos.

Sistema de reservas construído com **Ruby on Rails**, **Hotwire** e **PostgreSQL**,
totalmente containerizado com **Docker** — do zero, sem dependências locais.

<br/>

<img src="https://img.shields.io/badge/Ruby-4.0.6-CC342D?style=for-the-badge&logo=ruby&logoColor=white" alt="Ruby 4.0.6" />
<img src="https://img.shields.io/badge/Rails-8.1-CC0000?style=for-the-badge&logo=rubyonrails&logoColor=white" alt="Rails 8.1" />
<img src="https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL 16" />
<img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker Compose" />
<img src="https://img.shields.io/badge/Hotwire-Turbo%20%2B%20Stimulus-7B61FF?style=for-the-badge" alt="Hotwire" />

<br/><br/>

**[Sobre](#-sobre-o-projeto) · [Funcionalidades](#-funcionalidades) · [Arquitetura](#%EF%B8%8F-arquitetura) · [Stack](#%EF%B8%8F-stack) · [Como rodar](#-como-rodar) · [Roadmap](#%EF%B8%8F-roadmap)**

</div>

<br/>

---

## 🎯 Sobre o projeto

**Agendou** é uma aplicação de agendamento de serviços criada como projeto de estudo prático,
com foco em problemas reais de sistemas de reserva — não apenas em telas bonitas.

> Prestadores definem sua disponibilidade → cadastram seus serviços → clientes encontram horários livres → agendamentos são criados **sem conflito**.

O fluxo completo já está funcionando de ponta a ponta: um usuário se cadastra, vira prestador,
define sua disponibilidade e seus serviços, e clientes conseguem visualizar horários livres
calculados dinamicamente e criar agendamentos — com prevenção real de sobreposição, validada
diretamente no banco de dados.

<table>
<tr>
<td width="50%" valign="top">

🔄 &nbsp;Modelagem relacional com associações complexas
⏱️ &nbsp;Cálculo dinâmico de horários disponíveis
🚫 &nbsp;Prevenção de duplo agendamento
🔐 &nbsp;Autenticação e autorização multiusuário

</td>
<td width="50%" valign="top">

🐳 &nbsp;Ambiente reproduzível com Docker
🌐 &nbsp;Páginas públicas e áreas autenticadas
📦 &nbsp;CRUD completo com escopo por dono
🧠 &nbsp;Regras de negócio validadas no banco

</td>
</tr>
</table>

<br/>

## ✨ Funcionalidades

<div align="center">

| Funcionalidade | Status |
|:--|:--:|
| Autenticação (cadastro, login, logout) | ✅ Concluído |
| Tornar-se prestador de serviços | ✅ Concluído |
| CRUD de serviços oferecidos | ✅ Concluído |
| CRUD de disponibilidade recorrente | ✅ Concluído |
| Listagem pública de prestadores | ✅ Concluído |
| Cálculo dinâmico de horários livres | ✅ Concluído |
| Criação de agendamento com validação de conflito | ✅ Concluído |
| Painel do cliente — *meus agendamentos* | ⏳ Planejado |
| Atualizações em tempo real com Turbo Streams | ⏳ Planejado |
| Lembretes por e-mail com Action Mailer | ⏳ Planejado |
| Cancelamento de agendamentos | ⏳ Planejado |

</div>

<br/>

### 🔒 Regra principal do sistema

> O sistema **não permite** que dois clientes reservem horários sobrepostos para o mesmo prestador.

A verificação de sobreposição considera os dois intervalos simultaneamente:

```sql
starts_at < novo_ends_at
AND
ends_at   > novo_starts_at
```

Essa condição detecta conflito mesmo quando os horários **não são exatamente iguais** —
qualquer intersecção entre os dois intervalos é suficiente para bloquear o agendamento.
A mesma lógica é reaproveitada tanto na **validação do model** (impede salvar um conflito)
quanto no **cálculo de slots disponíveis** (impede sequer oferecer um horário ocupado).

<br/>

## 🏗️ Arquitetura

A estrutura foi pensada para separar claramente **usuários**, **prestadores**, **serviços**,
**disponibilidade** e **agendamentos** — cada um com uma única responsabilidade.

```
                         ┌──────────────┐
                         │     User     │
                         └──────┬───────┘
                                │ 1:1
                                ▼
                         ┌──────────────┐
                         │   Provider   │
                         └──────┬───────┘
                                │
                    ┌───────────┴───────────┐
                    │ 1:N                   │ 1:N
                    ▼                       ▼
             ┌──────────────┐      ┌────────────────┐
             │   Service    │      │  Availability  │
             └──────┬───────┘      └────────────────┘
                    │ 1:N
                    ▼
             ┌────────────────┐        N:1        ┌──────────┐
             │  Appointment   │───────────────────▶│   User   │
             └────────────────┘                    │ (cliente)│
                                                     └──────────┘
```

<div align="center">

| Entidade | Responsabilidade |
|:--|:--|
| `User` | Usuário da plataforma — pode ser cliente, prestador, ou ambos. Autenticado via `has_secure_password` |
| `Provider` | Perfil responsável pela oferta dos serviços |
| `Service` | Serviço oferecido, incluindo duração e preço |
| `Availability` | Janelas recorrentes em que o prestador está disponível |
| `Appointment` | Reserva realizada por um cliente para um serviço específico |

</div>

<br/>

## 🧭 Fluxo da aplicação

```
1. Visitante se cadastra e faz login
2. Usuário logado cria seu perfil de Provider
3. Provider cadastra Services (nome, duração, preço)
4. Provider define Availability (dias e horários recorrentes)
5. Qualquer visitante navega /providers e vê os serviços oferecidos
6. Cliente escolhe um serviço → sistema calcula slots livres automaticamente
7. Cliente escolhe um horário → Appointment é criado com validação de conflito
```

Cada rota é protegida de acordo com sua natureza: páginas de gestão do próprio prestador
exigem login (`before_action :require_login`) e são sempre escopadas ao dono
(`current_user.provider.services`, nunca `Service.find` direto) — prevenindo que um
prestador acesse ou edite dados de outro. Já a listagem de prestadores e seus serviços
é pública, sem exigir autenticação.

<br/>

## 🧠 Decisões técnicas

<details open>
<summary><b>🚫 Prevenção de conflitos</b></summary>
<br/>

A validação de disponibilidade acontece via **query direta no banco**, não apenas em memória —
isso garante consistência mesmo com múltiplas requisições concorrentes:

```ruby
Appointment
  .joins(:service)
  .where(services: { provider_id: provider.id })
  .where.not(id: id)
  .where("starts_at < ? AND ends_at > ?", new_ends_at, new_starts_at)
```

</details>

<details>
<summary><b>🧮 Cálculo de slots disponíveis</b></summary>
<br/>

Para cada um dos próximos 7 dias, o sistema busca a `Availability` do prestador para
aquele dia da semana, divide a janela de horário em blocos do tamanho exato da duração
do serviço, e descarta qualquer bloco que colida com um `Appointment` já existente —
reaproveitando a mesma query de detecção de sobreposição usada na validação do model.

</details>

<details>
<summary><b>🔐 Autorização por escopo, não por checagem manual</b></summary>
<br/>

Em vez de buscar um registro e depois checar se pertence ao usuário, toda consulta já
nasce escopada ao dono: `current_user.provider.services.find(params[:id])`. Se o registro
pertencer a outro prestador, a busca simplesmente não o encontra (404), fechando a
vulnerabilidade clássica de IDOR (Insecure Direct Object Reference).

</details>

<details>
<summary><b>🔢 Status com <code>enum</code></b></summary>
<br/>

O ciclo de vida de um agendamento usa `enum` com valor padrão, evitando *magic numbers*
e garantindo que todo registro nasça com um estado válido:

```ruby
enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, default: :pending
```

</details>

<details>
<summary><b>🐳 Docker + volumes nomeados</b></summary>
<br/>

O ambiente de desenvolvimento é 100% reproduzível via Docker Compose. Um volume dedicado
para as gems (`bundle_data`) evita que o *bind mount* do projeto sobrescreva os arquivos
instalados durante o build da imagem.

</details>

<details>
<summary><b>⚙️ Configuração por ambiente</b></summary>
<br/>

Credenciais e configurações sensíveis são fornecidas via **variáveis de ambiente**,
nunca *hardcoded* no código — a mesma configuração funciona local, em Docker ou em produção.

</details>

<br/>

## 🛠️ Stack

<table>
<tr>
<td valign="top" width="33%">

**Backend**

| Tecnologia | Uso |
|:--|:--|
| Ruby 4.0.6 | Linguagem principal |
| Rails 8.1 | Framework web |
| PostgreSQL 16 | Banco relacional |
| bcrypt | Hash de senhas |

</td>
<td valign="top" width="33%">

**Frontend**

| Tecnologia | Uso |
|:--|:--|
| ERB | Views server-side |
| Hotwire *(planejado)* | Reatividade sem SPA |
| Active Storage *(planejado)* | Upload de arquivos |

</td>
<td valign="top" width="33%">

**Infra & Qualidade**

| Tecnologia | Uso |
|:--|:--|
| Docker Compose | Orquestração local |
| Action Mailer *(planejado)* | E-mails transacionais |
| Rubocop | Lint / padronização |
| Brakeman | Análise de segurança |

</td>
</tr>
</table>

<br/>

## 🚀 Como rodar

### Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

### 1. Clone o repositório

```bash
git clone git@github.com:anthony-ricardox/Agendou.git
cd Agendou
```

### 2. Suba os containers

```bash
docker compose -f docker-compose.dev.yml up -d --build
```

> Na primeira execução, o Docker constrói a imagem e instala todas as gems — pode levar alguns minutos.

### 3. Prepare o banco de dados

```bash
docker compose -f docker-compose.dev.yml exec web bin/rails db:prepare
```

### 4. Acesse a aplicação

```
http://localhost:3000
```

<br/>

### 🧰 Comandos úteis

<div align="center">

| Comando | Descrição |
|:--|:--|
| `... up -d` | Inicia os containers em segundo plano |
| `... up -d --build` | Reconstrói a imagem e inicia |
| `... down` | Para e remove os containers |
| `... down -v` | Remove containers **e volumes** ⚠️ |
| `... ps` | Lista o status dos containers |
| `... logs -f web` | Acompanha os logs do Rails em tempo real |
| `... exec web bin/rails console` | Abre o Rails Console |
| `... exec web bin/rails db:migrate` | Executa migrations pendentes |
| `... exec web bin/rails routes` | Lista todas as rotas da aplicação |

<sub>Prefixo omitido por brevidade: <code>docker compose -f docker-compose.dev.yml</code></sub>

</div>

> ⚠️ **Atenção:** `down -v` remove os volumes nomeados, incluindo os **dados persistidos do PostgreSQL**.

<br/>

## 📂 Estrutura do projeto

```
Agendou/
│
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb   # current_user, require_login
│   │   ├── sessions_controller.rb      # login/logout
│   │   ├── providers_controller.rb     # perfil de prestador (próprio)
│   │   ├── public_providers_controller.rb  # listagem pública
│   │   ├── services_controller.rb      # CRUD de serviços
│   │   ├── availabilities_controller.rb # CRUD de disponibilidade
│   │   └── appointments_controller.rb  # cálculo de slots + criação
│   ├── models/
│   │   ├── user.rb
│   │   ├── provider.rb
│   │   ├── service.rb
│   │   ├── availability.rb
│   │   └── appointment.rb
│   └── views/
│
├── db/
│   ├── migrate/                # Migrations
│   └── schema.rb
│
├── docker-compose.dev.yml
├── Dockerfile.dev
└── README.md
```

<br/>

## 🗺️ Roadmap

<table>
<tr>
<td valign="top" width="50%">

**👤 Prestadores** ✅
- [x] CRUD completo de `Provider`
- [x] CRUD completo de `Service`
- [x] Configuração de disponibilidade recorrente

**📅 Agendamentos** ✅
- [x] Cálculo dinâmico de slots disponíveis
- [x] Validação completa de conflitos
- [x] Criação de agendamento pela web
- [ ] Cancelamento de agendamentos
- [ ] Painel "Meus agendamentos" (cliente e prestador)

</td>
<td valign="top" width="50%">

**⚡ Experiência**
- [ ] Estilização visual (CSS)
- [ ] Turbo Streams em tempo real
- [ ] Drag-and-drop com Stimulus
- [ ] Feedback visual de ações

**📬 Automação & Qualidade**
- [ ] Lembretes por e-mail (Action Mailer)
- [ ] Jobs agendados com Solid Queue
- [ ] Testes automatizados (models, requests, concorrência)
- [ ] Upload de avatar/imagens (Active Storage)

</td>
</tr>
</table>

<br/>

## 📚 Principais aprendizados

> CRUD é apenas o começo. O foco do Agendou está em transformar **regras de negócio em código confiável**.

<div align="center">

`has_many :through` • Autenticação com `has_secure_password` • Autorização por escopo
Detecção de intervalos sobrepostos • Cálculo dinâmico de disponibilidade
Strong Parameters • Containerização com Docker • Debugging de stack traces reais

</div>

<br/>

---

<div align="center">

### 👨‍💻 Autor

**Anthony Ricardo**
Desenvolvido como projeto de estudo prático para explorar Ruby on Rails moderno,
arquitetura de aplicações e problemas reais de sistemas de agendamento.

<a href="https://github.com/anthony-ricardox">
  <img src="https://img.shields.io/badge/GitHub-anthony--ricardox-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" />
</a>

<br/><br/>

**⭐ Se este projeto foi útil ou interessante, considere deixar uma estrela.**

<sub>Feito com Ruby on Rails, Hotwire, PostgreSQL e Docker.</sub>

</div>