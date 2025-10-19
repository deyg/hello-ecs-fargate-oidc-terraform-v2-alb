# Hello ECS Fargate + HTTP API via VPC Link (ALB)

Aplicação Node.js mínima servida em ECS Fargate, acessível por API Gateway HTTP através de VPC Link e ALB interno. A pipeline do GitHub Actions usa OIDC (sem chaves estáticas) para provisionar infraestrutura com Terraform e publicar a imagem Docker.

```
Cliente → API Gateway (HTTP API, público)
          │  (VPC Link + subnet privada + SG dedicado)
          ▼
   ALB interno (porta 80 + SG próprio)
          ▼
    ECS Fargate (porta 3000 + SG próprio)
          ▼
     App Node.js (/hello, /health)
```

## Requisitos

- Terraform ≥ 1.6.0 (testado com 1.8.2).
- AWS CLI configurada com permissões para criar S3, DynamoDB, IAM, ECR, ECS, API Gateway, VPC.
- Docker e Node.js 20 (para executar o app localmente).

## Variáveis e Secrets

| Contexto                | Nome                     | Valor padrão / origem                            | Uso                                        |
| ----------------------- | ------------------------ | ------------------------------------------------ | ------------------------------------------ |
| Ambiente do app         | `PORT`                   | `3000`                                           | Porta do servidor Express                  |
| Ambiente do app         | `API_STAGE`              | `prod`                                           | Prefixo das rotas montadas no Express      |
| Terraform (infra)       | `aws_region`             | `sa-east-1`                                      | Região AWS                                 |
| Terraform (bootstrap)   | `state_bucket_name`      | `deyg-hello-ecs-oidc-tfstate`                    | Bucket S3 de state remoto                  |
| Terraform (bootstrap)   | `lock_table_name`        | `deyg-hello-ecs-oidc-tf-locks`                   | Tabela DynamoDB de locks                   |
| Terraform (bootstrap)   | `gh_owner`/`gh_repo`     | `deyg` / `hello-ecs-fargate-oidc-terraform-v2-alb` | Repositório autorizado no OIDC             |
| GitHub Secrets          | `ACCOUNT_ID`             | —                                                | ID da conta AWS usada pela role OIDC       |
| Pipeline (deploy.yml)   | `IMAGE_TAG`              | `github.sha`                                     | Tag da imagem publicada no ECR             |
| Terraform via pipeline  | `TF_VAR_image_tag`       | `IMAGE_TAG` (exportado na etapa final)           | Tag aplicada à task definition             |

## Fluxo de uso

1. **Bootstrap local**  
   ```powershell
   cd bootstrap
   terraform init
   terraform apply -auto-approve
   ```
   Saídas: `state_bucket`, `lock_table`, `gha_role_arn`. Copie o ARN da role para referência.

2. **Configurar secrets no GitHub**  
   - Defina `ACCOUNT_ID` com o ID da conta AWS.
   - Garanta que os workflows tenham permissão para usar OIDC (padrão nas orgs modernas).

3. **Executar a pipeline**  
   - Faça push na branch `main`. O workflow `DEPLOY` irá:
     1. `terraform init && apply` em `infra/` (garante VPC, ECR, ECS, ALB, API Gateway).
     2. Logar no ECR, construir e publicar a imagem.
     3. Reaplicar Terraform com a tag da nova imagem (`TF_VAR_image_tag`).
   - Ao final, consulte os outputs `api_url` / `invoke_url` no log do GitHub Actions.

4. **Testar o endpoint**  
   ```bash
   curl https://<api-id>.execute-api.sa-east-1.amazonaws.com/prod/hello
   ```

5. **Destruir recursos (opcional)**  
   - Execute manualmente o workflow `DESTROY` (proteja com um ambiente/sandbox e approvals).

## Execução local do app

```bash
cd app
npm install
npm start
# Em outro terminal:
curl http://localhost:3000/hello
```

Para emular o stage do API Gateway:
```bash
API_STAGE=prod npm start
curl http://localhost:3000/prod/hello
```

## Observabilidade e próximos passos

- Ative o CloudWatch Logs para a task ECS (não habilitado nesta POC).
- Adicione alarmes/monitoração para API Gateway, ALB e ECS Service.
- Substitua `AdministratorAccess` da role OIDC por políticas mínimas antes de produção.
- Considere remover o passo `terraform apply -target=aws_ecr_repository.app` quando o repositório estiver estável (para evitar warnings).

## Segurança e LGPD

- Nenhum dado pessoal é armazenado; as rotas respondem apenas com mensagens estáticas.
- Credenciais são obtidas via OIDC (sem chaves estáticas); somente o ID da conta AWS é exposto nos workflows, via secret.
- Arquivos `.tfstate` permanecem fora do repositório (state remoto em S3). Não commitamos tokens ou senhas.

## Limitações conhecidas

- Warnings de atributo depreciado no módulo `terraform-aws-modules/vpc`; aguardar atualização oficial.
- Não há testes automatizados do app; sinta-se à vontade para adicionar (Jest/Supertest).
- Health check do ALB é somente HTTP 200; considerar incluir métrica/mensagem mais rica conforme necessidade.
