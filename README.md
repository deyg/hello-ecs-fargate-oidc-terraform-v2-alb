# Hello ECS Fargate + API Gateway (HTTP) via VPC Link com **ALB** (V2)

**O que muda na V2?** Substituimos o **NLB** por um **ALB interno**. O API Gateway (HTTP API) acessa o **ALB** via **VPC Link** e o ALB encaminha o trafego HTTP para o **ECS Fargate** (porta 3000). Usamos tres **Security Groups**: um para o VPC Link, um para o ALB (ingress 80 vindo do SG do VPC Link) e um para as tasks ECS (ingress 3000 vindo do SG do ALB).

Arquitetura:
```
Cliente ---> API Gateway (HTTP API, publico)
             |  (VPC Link + SG proprio)
             v
      ALB interno (porta 80, SG proprio)
             v
       ECS Fargate (porta 3000, SG proprio)
             v
          App Node.js (/hello, /health)
```

## Como rodar (resumo)
1. **Bootstrap**: `terraform apply` em `bootstrap/` (S3 + DynamoDB + OIDC + Role).  
2. Coloque o `role_arn` nos workflows (troque `<ACCOUNT_ID>`).  
3. **Push na main**: a pipeline cria VPC/ECR/ECS/ALB/API, gera a imagem e publica.  
4. Saida: `api_url` -> `GET /hello` responde JSON.

> ALB *health check*: configurado em `/health` (200). O app ja expoe esse endpoint.

## Seguranca
- OIDC (sem chaves estaticas), state remoto S3 + lock DynamoDB, SGs especificos por camada, `destroy.yml` protegido, e caminho claro para *least privilege* apos a POC.
