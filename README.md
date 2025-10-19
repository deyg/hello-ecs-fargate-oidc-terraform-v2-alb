# Hello ECS Fargate + API Gateway (HTTP) via VPC Link com **ALB** (V2)

**O QUE MUDA NA V2?** Substituímos o **NLB** por um **ALB interno**. O API Gateway (HTTP API) acessa o **ALB** via **VPC Link** e o ALB encaminha o tráfego HTTP para o **ECS Fargate** (porta 3000). Usamos três **Security Groups**: um para o VPC Link, um para o ALB (ingress 80 vindo do SG do VPC Link) e um para as tasks ECS (ingress 3000 vindo do SG do ALB).

Arquitetura:
```
Cliente ──► API Gateway (HTTP API, público)
                │  (VPC Link + SG próprio)
                ▼
        ALB interno (porta 80, SG próprio)
                ▼
         ECS Fargate (porta 3000, SG próprio)
                ▼
           App Node.js (/hello, /health)
```

## Como rodar (resumo)
1. **Bootstrap**: `terraform apply` em `bootstrap/` (S3 + DynamoDB + OIDC + Role).  
2. Coloque o `role_arn` nos workflows (troque `<ACCOUNT_ID>`).  
3. **Push na main**: a pipeline cria VPC/ECR/ECS/ALB/API, *builda* imagem e publica.  
4. Saída: `api_url` → `GET /hello` responde JSON.

> ALB *health check*: configurado em `/health` (200). O app já expõe esse endpoint.

## Segurança
- OIDC (sem chaves estáticas), state remoto S3 + lock DynamoDB, SGs específicos por camada, `destroy.yml` protegido, e caminho claro para *least privilege* pós-POC.
