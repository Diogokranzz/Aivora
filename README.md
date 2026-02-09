# Aivora - Sistema de Qualificacao de Leads Empresarial

Aivora e um sistema de qualificacao de leads de alta performance, seguro e escalavel, projetado para ambientes corporativos. Combina um motor de decisao em C++ com uma camada de orquestracao low-code (n8n) e analise avancada de dados (Metabase).

## Arquitetura

O sistema e composto por quatro microsservicos isolados rodando em Docker:

1.  **Aivora Core (C++)**: Motor de decisao standalone. Alta performance, baixa latencia e protegido por autenticacao via API Key.
2.  **Orquestrador (n8n)**: Gerencia a ingestao de dados (Webhooks), normalizacao e comunicacao entre servicos.
3.  **Banco de Dados (PostgreSQL)**: Armazenamento otimizado com indices para recuperacao rapida de informacoes.
4.  **Analytics (Metabase)**: Dashboard de inteligencia de negocios para insights em tempo real.

## Recursos de Seguranca

-   **Autenticacao de API**: O Core C++ e protegido pelo header `X-API-KEY`.
-   **Gerenciamento de Segredos**: Credenciais sensiveis (IDs, Chaves, Senhas) sao gerenciadas via arquivos `.env` e segredos do Docker. O acesso as variaveis de ambiente e estritamente controlado.
-   **Validacao de Entrada**: Validacao rigorosa contra JSON malformado e verificacoes numericas negativas.
-   **Isolamento de Rede**: Os servicos se comunicam via rede interna do Docker; apenas as portas necessarias sao expostas.

## Configuracao e Deploy

### Pre-requisitos

-   Docker & Docker Compose
-   Git

### Instalacao

1.  **Clonar o repositorio:**
    ```bash
    git clone https://github.com/Diogokranzz/Aivora.git
    cd Aivora
    ```

2.  **Configurar Seguranca:**
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

4.  **Acessar Servicos:**
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

## Licenca

Software Proprietario. A copia não autorizada deste arquivo, por qualquer meio, é estritamente proibida.
