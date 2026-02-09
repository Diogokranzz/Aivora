# Aivora : Sistema de Qualificação de Leads Empresarial

Aivora é um sistema de qualificação de leads de alta performance, seguro e escalável, projetado para ambientes corporativos. Combina um motor de decisão em C++ com uma camada de orquestração low-code (n8n) e análise avançada de dados (Metabase).

## Arquitetura

O sistema é composto por quatro microsserviços isolados rodando em Docker:

1.  **Aivora Core (C++)**: Motor de decisão standalone. Alta performance, baixa latência e protegido por autenticação via API Key.
2.  **Orquestrador (n8n)**: Gerencia a ingestão de dados (Webhooks), normalização e comunicação entre serviços.
3.  **Banco de Dados (PostgreSQL)**: Armazenamento otimizado com índices para recuperação rápida de informações.
4.  **Analytics (Metabase)**: Dashboard de inteligência de negócios para insights em tempo real.

## Recursos de Segurança

-   **Autenticação de API**: O Core C++ é protegido pelo header `X-API-KEY`.
-   **Gerenciamento de Segredos**: Credenciais sensíveis (IDs, Chaves, Senhas) são gerenciadas via arquivos `.env` e segredos do Docker. O acesso às variáveis de ambiente é estritamente controlado.
-   **Validação de Entrada**: Validação rigorosa contra JSON malformado e verificações numéricas negativas.
-   **Isolamento de Rede**: Os serviços se comunicam via rede interna do Docker; apenas as portas necessárias são expostas.

## Configuração e Deploy

### Pré-requisitos

-   Docker & Docker Compose
-   Git

### Instalação

1.  **Clonar o repositorio:**
    ```bash
    git clone https://github.com/Diogokranzz/Aivora.git
    cd Aivora
    ```

2.  **Configurar Segurança:**
    Crie um arquivo `.env` no diretorio raiz (nao faca commit deste arquivo):
    ```env
    TELEGRAM_CHAT_ID=seu_chat_id_telegram
    POSTGRES_PASSWORD=senha_segura_db
    N8N_BASIC_AUTH_PASSWORD=senha_segura_n8n
    ```

3.  **Deploy:**
    ```bash
    sudo docker compose up --build -d
    ```

4.  **Acessar Serviços:**
    -   **n8n (Fluxos de Trabalho):** `http://localhost:5680`
    -   **Metabase (Dashboard):** `http://localhost:3000`
    -   **Endpoint da API:** `http://localhost:8080/v1/sniper/qualify` (Requer Header `X-API-KEY`)

## Uso da API (Interno)

**Endpoint:** `POST /v1/sniper/qualify`
**Headers:** `X-API-KEY: aivora-secure-key-2025`

**Payload:**
```json
{
  "income": 50000,
  "verified": true
}
```

**Resposta (200 OK):**
```json
{
  "score": 100,
  "priority": "CRITICAL",
  "engine": "Aivora-CPP-Core-v1"
}
```

## Licença

Software Proprietário. A cópia não autorizada deste arquivo, por qualquer meio, é estritamente proibida.
