# Aivora: High Availability & Intelligence OS

**Subtítulo:** Sistema Distribuído de Automação de Leads e Defesa Ativa.

## 1. Visão Geral do Projeto

A Aivora é um ecossistema de software focado em Alta Disponibilidade (HA) e Segurança Ofensiva. O objetivo principal é servir como um "Sniper de Leads" para o mercado imobiliário e corporativo, operando em uma infraestrutura que nunca dorme e se protege automaticamente contra ameaças.

## 2. Arquitetura Técnica (Stack Ultra Avançada & Custo Zero)

O sistema é desenhado para rodar inteiramente em camadas gratuitas de nível enterprise, eliminando custos de servidor enquanto mantém performance máxima.

| Camada | Tecnologia | Função no Sistema |
| --- | --- | --- |
| DNS & Load Balancer | Cloudflare | Proteção DDoS, certificado SSL e distribuição de tráfego entre nós. |
| Orquestração | K3s (Kubernetes) | Garante o Auto-Healing: se um container cair, o K3s sobe outro instantaneamente. |
| Computação (VPS) | Oracle Cloud (ARM) | 2 a 4 instâncias com 24GB de RAM total (nó mestre + nós de trabalho). |
| Banco de Dados | Cloudflare D1 / Supabase | Banco SQL relacional com replicação global e backup automático. |
| Backend / API | Python (FastAPI) & Go | Motores de processamento de dados e integração com n8n para automação. |
| Armazenamento | Cloudflare R2 | Bucket para documentos, fotos de imóveis e logs de segurança (S3-compatible). |

## 3. O "Plano de Guerra" Funcional

### A. Valor para as Empresas (B2B)

- **Operação Ininterrupta:** por ser um sistema HA, a empresa não perde vendas por "site fora do ar".
- **Módulo Sniper:** captura automática de leads em redes sociais e portais, qualificando o potencial de compra via IA antes de entregar ao corretor.
- **Custo de Infraestrutura Zero:** otimização total do Free Tier, permitindo que a empresa escale sem taxas mensais de servidor.

### B. Valor para os Clientes (Usuário Final)

- **Privacidade Blindada:** implementação de protocolos de segurança baseados em Pentesting (OWASP Top 10) para proteger dados sensíveis.
- **Baixa Latência:** graças ao Cloudflare Edge, o sistema responde na velocidade da luz em qualquer lugar do Brasil.

## 4. Configuração de Segurança (DNA de Pentester)

Diferente de sistemas comuns, a Aivora inclui um Módulo de Defesa Ativa:

- **Monitoramento de Logs:** scripts em Python que analisam tráfego via Wireshark/Tshark em tempo real.
- **Firewall Dinâmico:** integração com a API do Cloudflare para banir IPs que tentam realizar ataques de força bruta ou varredura de portas (Nmap).

## 5. Próximos Passos de Execução (O Prompt de Implementação)

Para começar agora, aqui está a ordem de comando:

1. **Provisionamento:** criar as instâncias ARM na Oracle Cloud com Ubuntu 24.04.
2. **Rede:** apontar o domínio aivora.com.br (comprado no Registro.br) para o Cloudflare.
3. **Cluster:** rodar o script de instalação do K3s unindo as instâncias em um único cluster HA.
4. **Automação:** configurar o container do n8n dentro do Kubernetes para gerenciar os fluxos de leads.

## 6. Script de Instalação: Cluster K3s em High Availability

Para rodar nas instâncias ARM da Oracle Cloud, use o K3s com um banco de dados externo (ex.: Supabase/PostgreSQL) para garantir que, se o nó mestre cair, o cluster continue vivo.

### No Nó Mestre (Server 1)

```bash
curl -sfL https://get.k3s.io | sh -s - server \
  --datastore-endpoint="postgres://user:password@hostname:5432/dbname" \
  --token="TOKEN_ULTRA_SECRETO_AIVORA" \
  --tls-san="IP_PUBLICO_DO_CLOUDFLARE_OU_VM"
```

### Nos Nós de Trabalho (Agents)

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://IP_DO_MESTRE:6443 K3S_TOKEN=TOKEN_ULTRA_SECRETO_AIVORA sh -
```

## 7. Estrutura de Dados: Módulo Sniper (D1 / SQL)

Tabela inicial para qualificação de leads:

```sql
CREATE TABLE leads_sniper (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    origem TEXT, -- Ex: Facebook, Instagram, LinkedIn
    score_ia INTEGER DEFAULT 0, -- Qualificação de 0 a 100
    status TEXT DEFAULT 'quente',
    contato_verificado BOOLEAN DEFAULT FALSE,
    ultima_interacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_captura DATE DEFAULT (DATE('now'))
);
```

## 8. Defesa Ativa: Automação Cloudflare (Python)

Esboço do "Firewall Dinâmico" integrando a API da Cloudflare:

```python
import requests

def ban_ip_cloudflare(bad_ip):
    api_url = "https://api.cloudflare.com/client/v4/zones/SEU_ZONE_ID/firewall/access_rules/rules"
    headers = {
        "X-Auth-Email": "seu_email@aivora.com.br",
        "X-Auth-Key": "SUA_API_KEY",
        "Content-Type": "application/json"
    }
    data = {
        "mode": "block",
        "configuration": {"target": "ip", "value": bad_ip},
        "notes": "Ataque detectado pelo Módulo Aivora Defense"
    }
    response = requests.post(api_url, headers=headers, json=data)
    return response.status_code
```

## 9. Deploy do n8n em Alta Disponibilidade (Kubernetes)

Para fechar o Passo 4 do plano de execução, salve o manifesto abaixo como `n8n-deploy.yaml` e aplique com `kubectl apply -f n8n-deploy.yaml`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: n8n
  labels:
    app: n8n
spec:
  replicas: 2 # Alta Disponibilidade: 2 instâncias rodando
  selector:
    matchLabels:
      app: n8n
  template:
    metadata:
      labels:
        app: n8n
    spec:
      containers:
      - name: n8n
        image: n8nio/n8n:latest
        ports:
        - containerPort: 5678
        env:
        - name: DB_TYPE
          value: postgresdb
        - name: DB_POSTGRESDB_HOST
          value: "seu-host-do-supabase.com"
        - name: DB_POSTGRESDB_USER
          value: "postgres"
        - name: DB_POSTGRESDB_PASSWORD
          value: "sua-senha-segura"
        - name: N8N_ENCRYPTION_KEY
          value: "chave-mestra-aivora"
---
apiVersion: v1
kind: Service
metadata:
  name: n8n-service
spec:
  selector:
    app: n8n
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5678
  type: ClusterIP
```

### O que isso faz pelo projeto Aivora?

- **Resiliência:** se uma das VMs da Oracle Cloud cair, o n8n continua processando os leads na outra.
- **Escalabilidade:** aumente para 3 ou 4 réplicas se o volume de leads crescer.
- **Persistência:** como os dados estão no Supabase, você nunca perde um fluxo de automação.

### Dica de Pentester para o Passo 2 (Rede)

Ao configurar o Cloudflare, ative o **Authenticated Origin Pulls**. Isso garante que o cluster K3s na Oracle Cloud só aceite conexões vindas da Cloudflare, bloqueando tentativas de acesso direto via IP.

## 10. Manifesto Ingress: Expondo a Aivora ao Mundo

Salve como `aivora-ingress.yaml`. Ele conecta o tráfego que vem do Cloudflare diretamente ao serviço interno do n8n de forma balanceada.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: aivora-ingress
  annotations:
    kubernetes.io/ingress.class: "traefik" # K3s já vem com Traefik por padrão
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
  - host: aivora.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: n8n-service
            port:
              number: 80
```

### Nota de Segurança Avançada (Step-by-Step)

Para garantir que o **Authenticated Origin Pulls** funcione:

1. Baixe o certificado de CA da Cloudflare.
2. Crie um Secret no Kubernetes com esse certificado.
3. Configure o Traefik para exigir esse certificado em todas as conexões de entrada.

Isso torna o IP da Oracle Cloud invisível e inútil para atacantes externos; o sistema só "fala" com a Cloudflare.

## 11. Fluxo Inicial do Sniper (Lógica n8n)

Para que o Passo 4 seja produtivo, você precisa de um workflow que conecte as pontas. Abaixo está a lógica recomendada para montar no n8n (e um exemplo em JSON no arquivo `workflows/n8n-sniper-workflow.json`).

1. **Webhook Trigger:** recebe dados de formulários ou ferramentas de scraping.
2. **AI Predictor (HTTP Request):** envia os dados para uma API de IA (Groq/Llama3) para classificar o lead entre 0 e 100 com base na intenção de compra.
3. **IF Node:** se `score_ia > 80`, o lead é considerado "Quente".
4. **SQL Node:** insere os dados na tabela `leads_sniper` do banco.
5. **Notification (Telegram/Discord):** envia alerta imediato para o corretor com o link do perfil do lead.

## 12. Checklist de Segurança para o Lançamento

Antes de dar o `kubectl apply` final, valide:

- [ ] **Segredos no K8s:** nunca coloque senhas diretamente no YAML. Use `kubectl create secret generic aivora-db-pass`.
- [ ] **Namespace Isolado:** rode o projeto em um namespace próprio (`kubectl create namespace aivora`) para organizar melhor o cluster.
- [ ] **Rate Limiting:** configure o Cloudflare para limitar requisições por IP, evitando que bots saturem seu Worker de IA.

## 13. Core Engine: Aivora Sniper em C++ (Performance Multithread)

Para performance crítica e baixo consumo de recursos, o coração do sistema pode ser implementado em **C++20**, utilizando processamento multithread nativo para lidar com milhares de requisições de leads simultâneas. Frameworks como **Crow** ou **Drogon** oferecem APIs extremamente rápidas e fáceis de integrar ao K3s.

### Racional Técnico

- **Eficiência de memória:** binários em C++ operam com footprint reduzido (ex.: ~10 MB), enquanto stacks interpretadas tendem a consumir mais.
- **Controle de concorrência:** uso de `std::jthread` e `std::mutex` para garantir integridade no processamento do Sniper.
- **Arquitetura ARM64:** compilação otimizada para os processadores Ampere da Oracle Cloud.

### Exemplo de Engine com Framework Crow

```cpp
#include "crow.h"
#include <iostream>

int main() {
    crow::SimpleApp app;

    // Endpoint de Qualificação Ultra Rápida
    CROW_ROUTE(app, "/v1/sniper/qualify").methods("POST"_method)
    ([](const crow::request& req){
        auto data = crow::json::load(req.body);
        if (!data) return crow::response(400);

        // Lógica de Score (Exemplo de Baixa Latência)
        int lead_score = 0;
        if (data["income"].i() >= 15000) lead_score += 60;
        if (data["verified"].b()) lead_score += 40;

        crow::json::wrow response;
        response["score"] = lead_score;
        response["priority"] = (lead_score >= 80) ? "CRITICAL" : "NORMAL";
        response["engine"] = "Aivora-CPP-Core-v1";

        return crow::response(response);
    });

    // Rodando em modo Multithreaded para Alta Disponibilidade
    app.port(8080).multithreaded().run();
}
```

## 14. Pipeline de Deploy: Docker & K3s (ARM64)

Para integrar o binário C++ ao seu cluster K3s, use um build **multi-stage** para garantir a menor imagem possível.

```dockerfile
# Estágio 1: Build
FROM arm64v8/ubuntu:24.04 AS builder
RUN apt-get update && apt-get install -y g++ cmake libasio-dev
COPY . /app
WORKDIR /app
RUN g++ -O3 src/aivora_core/main.cpp -lpthread -o aivora_core

# Estágio 2: Runtime
FROM arm64v8/ubuntu:24.04
COPY --from=builder /app/aivora_core /usr/local/bin/aivora_core
EXPOSE 8080
CMD ["aivora_core"]
```

### Toque de "Hunter" (Segurança)

Você pode usar **libcurl** dentro do core C++ para scraping assíncrono direto, reduzindo dependências intermediárias e aumentando a furtividade da coleta.

## 15. Build & Compilação: Otimização ARM64

Para extrair cada gota de performance dos processadores Ampere da Oracle, use flags agressivas de otimização (`-O3`). O `Makefile` já está preparado para ARM64 e pode ser ajustado conforme a necessidade.

```makefile
# Variáveis
CXX = g++
CXXFLAGS = -std=c++20 -O3 -Wall -Wextra -pthread
LDFLAGS = -lrt -lasio
TARGET = aivora_core
SRC = src/aivora_core/main.cpp

# Alvo principal
all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET)

# Build focado em Docker
docker-build:
	docker build -t aivora/core-cpp:latest .
```

## 16. Ciclo de Vida do Lead no Core C++

No core compilado, o fluxo de dados é tratado com buffers eficientes:

1. **Ingestão:** requisição `POST` chega via Crow.
2. **Parsing:** o JSON é processado pela engine nativa do Crow.
3. **Avaliação:** a lógica de score calcula prioridade em microssegundos.
4. **Despacho:** o resultado é enviado ao banco (D1/Supabase) via chamadas assíncronas.

### Visão do Hunter (Cybersecurity)

Com controle total do binário, você pode habilitar **proteções de memória** (stack canaries, ASLR, RELRO) direto na compilação. Além disso, o core C++ dificulta engenharia reversa em comparação a scripts interpretados, protegendo o algoritmo Sniper.
