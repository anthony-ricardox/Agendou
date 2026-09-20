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

O projeto vai além do CRUD tradicional e explora, de propósito, conceitos que separam
uma aplicação de estudo de uma aplicação **pronta para produção**:

<table>
<tr>
<td width="50%" valign="top">

🔄 &nbsp;Modelagem relacional com associações complexas
⏱️ &nbsp;Controle de disponibilidade e intervalos de tempo
🚫 &nbsp;Prevenção de duplo agendamento
🧵 &nbsp;Concorrência e consistência de dados

</td>
<td width="50%" valign="top">

🌎 &nbsp;Tratamento de timezones
📬 &nbsp;Processamento assíncrono e notificações
🐳 &nbsp;Ambiente reproduzível com Docker
🔐 &nbsp;Autorização multiusuário

</td>
</tr>
</table>

<br/>

## ✨ Funcionalidades

<div align="center">

| Funcionalidade | Status |
|:--|:--:|
| Cadastro de prestadores e serviços | 🚧 Em desenvolvimento |
| Definição de disponibilidade recorrente | 🚧 Em desenvolvimento |
| Agendamento com validação de conflitos | 🚧 Em desenvolvimento |
| Painel do cliente — *meus agendamentos* | ⏳ Planejado |
| Atualizações em tempo real com Turbo Streams | ⏳ Planejado |
| Lembretes por e-mail com Action Mailer | ⏳ Planejado |

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
| `User` | Usuário da plataforma — pode ser cliente, prestador, ou ambos |
| `Provider` | Perfil responsável pela oferta dos serviços |
| `Service` | Serviço oferecido, incluindo duração e preço |
| `Availability` | Janelas recorrentes em que o prestador está disponível |
| `Appointment` | Reserva realizada por um cliente para um serviço específico |

</div>

<br/>

## 🧠 Decisões técnicas

<details open>
<summary><b>🚫 Prevenção de conflitos</b></summary>
<br/>

A validação de disponibilidade acontece via **query direta no banco**, não apenas em memória —
isso garante consistência mesmo com múltiplas requisições concorrentes:

```ruby
Appointment
  .where(service: { provider_id: provider.id })
  .where.not(id: id)
  .where("starts_at < ? AND ends_at > ?", new_ends_at, new_starts_at)
```

</details>

<details>
<summary><b>🔢 Status com <code>enum</code></b></summary>
<br/>

O ciclo de vida de um agendamento usa `enum`, evitando *magic numbers* e deixando
as regras de negócio expressivas e legíveis:

```ruby
enum :status, { pending: 0, confirmed: 1, cancelled: 2 }
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

</td>
<td valign="top" width="33%">

**Frontend**

| Tecnologia | Uso |
|:--|:--|
| Hotwire | Reatividade sem SPA |
| Turbo | Navegação e updates parciais |
| Stimulus | Comportamento JS |
| Active Storage | Upload de arquivos |

</td>
<td valign="top" width="33%">

**Infra & Qualidade**

| Tecnologia | Uso |
|:--|:--|
| Docker Compose | Orquestração local |
| Action Mailer | E-mails transacionais |
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
docker compose -f docker-compose.dev.yml up --build
```

> Na primeira execução, o Docker constrói a imagem e instala todas as gems — pode levar alguns minutos.

### 3. Prepare o banco de dados

Em um **segundo terminal**:

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
| `... up` | Inicia os containers |
| `... up --build` | Reconstrói a imagem e inicia |
| `... down` | Para e remove os containers |
| `... down -v` | Remove containers **e volumes** ⚠️ |
| `... exec web bin/rails console` | Abre o Rails Console |
| `... exec web bin/rails db:migrate` | Executa migrations pendentes |
| `... exec web bin/rails db:prepare` | Cria/atualiza o banco de dados |

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
│   ├── javascript/
│   │   └── controllers/       # Stimulus Controllers
│   ├── mailers/                # Action Mailer
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

**👤 Prestadores**
- [ ] CRUD completo de `Provider`
- [ ] CRUD completo de `Service`
- [ ] Configuração de disponibilidade recorrente
- [ ] Gestão dos próprios agendamentos

**📅 Agendamentos**
- [ ] Cálculo dinâmico de slots disponíveis
- [ ] Seleção visual de horários
- [ ] Validação completa de conflitos
- [ ] Cancelamento de agendamentos

</td>
<td valign="top" width="50%">

**⚡ Experiência**
- [ ] Drag-and-drop com Stimulus
- [ ] Turbo Streams em tempo real
- [ ] Painel "Meus agendamentos"
- [ ] Feedback visual de ações

**📬 Automação & Qualidade**
- [ ] Lembretes por e-mail
- [ ] Jobs com Solid Queue
- [ ] Autorização multiusuário
- [ ] Testes de models, requests e concorrência

</td>
</tr>
</table>

<br/>

## 📚 Principais aprendizados

> CRUD é apenas o começo. O foco do Agendou está em transformar **regras de negócio em código confiável**.

<div align="center">

`has_many :through` • Validação de regras de negócio • Detecção de intervalos sobrepostos
Consistência de dados • Concorrência entre requisições • Timezones
Background jobs • Notificações assíncronas • Containerização • Segurança e análise estática

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
