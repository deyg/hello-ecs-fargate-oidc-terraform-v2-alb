# Curso: Deploy de Aplicações Node.js no AWS ECS Fargate com GitHub Actions e Terraform

## Estrutura Geral

1. **Parte 1 – Teoria e Boas Práticas**  
   Contextualiza os fundamentos antes da prática, preparando o aluno para entender cada decisão de arquitetura e segurança.
2. **Parte 2 – Hands-on passo a passo**  
   O aluno cria todos os artefatos do zero (aplicação, bootstrap Terraform, infraestrutura principal e pipelines GitHub Actions).

Cada módulo inclui objetivos claros, pré-requisitos, tempo estimado e entregáveis. Concluímos com desafios extras e checklist de revisão.

---

## Parte 1 – Teoria e Boas Práticas

### Módulo 1 – Visão Geral de Arquitetura (30 min)
- **Objetivo**: Entender os componentes do stack: API Gateway HTTP, VPC Link, ALB interno, ECS Fargate, ECR, Terraform, GitHub Actions com OIDC.
- **Conteúdo**:
  - Conceitos de microsserviços containerizados.
  - Fluxo de requisição (cliente → API Gateway → VPC Link → ALB → ECS).
  - Modalidades de balanceadores (ALB vs NLB) e motivação da escolha.
  - Diagrama da arquitetura alvo.
- **Entregável**: Desenho simplificado da arquitetura com anotações pessoais.

### Módulo 2 – Segurança na Prática (40 min)
- **Objetivo**: Fixar boas práticas de segurança.
- **Conteúdo**:
  - OIDC e GitHub Actions: por que abandonar chaves estáticas.
  - Remote state com S3 + DynamoDB para locking.
  - Security Groups em camadas (API Gateway, ALB, ECS).
  - Políticas IAM de least privilege (plano para trocar AdministratorAccess).
  - Considerações de LGPD e exposição de dados.
- **Atividade**: Checklist de segurança para aplicar na fase prática.

### Módulo 3 – Terraform e Estrutura de Repositório (35 min)
- **Objetivo**: Preparar a organização do código.
- **Conteúdo**:
  - Separação de diretórios (`app/`, `bootstrap/`, `infra/`, `.github/workflows/`).
  - Papel do bootstrap (prover state remoto + role OIDC).
  - Módulos vs recursos diretos.
  - Convenções de nomenclatura e formatação (HCL multilinha).
- **Atividade**: Planejar os arquivos que serão criados em cada etapa.

### Módulo 4 – Pipelines e Fluxo de CI/CD (30 min)
- **Objetivo**: Entender o fluxo de deploy destrinchado.
- **Conteúdo**:
  - Passos do workflow `DEPLOY`: init/apply, build/push, apply com tag.
  - Workflow `DESTROY` e controles de aprovação.
  - Estratégias de tags (`IMAGE_TAG = github.sha`) e variações.
  - Uso de secrets (`ACCOUNT_ID`) e variáveis de ambiente.
- **Atividade**: Esboçar um diagrama ou bullet list do pipeline.

### Módulo 5 – Observabilidade, Manutenção e Próximos Passos (25 min)
- **Objetivo**: Discutir extensões do projeto.
- **Conteúdo**:
  - Logging/monitoramento (CloudWatch Logs, alarmes).
  - Estratégias de rollback (revisões ECS, versão das imagens).
  - Estrutura de documentação (README, Curso.md).
- **Tarefa**: Montar um plano de evolução (ex.: adicionar testes, métricas).

> **Tempo total estimado Parte 1**: ~2h40

---

## Parte 2 – Hands-on

### Setup inicial (15 min)
- Criar repositório vazio.
- Configurar Git local (se necessário).
- Criar estrutura de diretórios: `app/`, `bootstrap/`, `infra/`, `.github/workflows/`.
- Preparar `.gitignore` (Terraform, Node, Docker).

### Módulo 6 – Construindo a API Node.js (30 min)
- **Passos**:
  1. Criar `app/package.json` manualmente.
  2. Implementar `app/index.js` (Express, rotas `/hello`, `/health`, suporte a `API_STAGE`).
  3. Rodar localmente (`npm install`, `npm start`, `curl` de teste).
  4. Adicionar README específico (opcional) sobre rotas e variáveis.
- **Checkpoint**: Commit “feat: cria API Node”.

### Módulo 7 – Dockerização (20 min)
- Criar `Dockerfile` (base `node:20-alpine`, `npm install --omit=dev`).
- Testar build local (`docker build`, `docker run`).
- Ajustar README com instrução de uso via Docker (opcional).
- **Checkpoint**: Commit “feat: Dockerfile”.

### Módulo 8 – Bootstrap Terraform (60 min)
- **Objetivo**: Provisionar:
  - Bucket S3 (`state_bucket_name`).
  - Tabela DynamoDB (`lock_table_name`).
  - Provedor OIDC do GitHub + role `gha-oidc-terraform` com `AdministratorAccess` (temporário).
- **Passos**:
  1. Criar arquivos: `backend_remote.tf`, `iam_oidc.tf`, `variables.tf`, `outputs.tf`, `main.tf`.
  2. Executar `terraform init` e `apply` manualmente.
  3. Registrar outputs (ARN da role, nomes do state/lock).
- **Checkpoint**: Commit “feat: bootstrap terraform”.
- **Atividade extra**: Documentar lições no README/curso (importância do state remoto).

### Módulo 9 – Infraestrutura Principal (120 min)
- **Criar recursos**:
  - `main.tf` com backend S3.
  - `vpc.tf` usando módulo oficial.
  - `security.tf` (SGs), `alb.tf`, `apigw.tf`, `ecs.tf`, `ecr.tf`, `outputs.tf`, `variables.tf`.
- **Ordem sugerida**:
  1. VPC + subnets + NAT.
  2. Security Groups (VPC Link, ALB, ECS).
  3. ALB, target group, listener.
  4. ECR e ECS (cluster, task definition, service).
  5. API Gateway (HTTP API, VPC Link, integração).
  6. Outputs finais.
- **Testes**:
  - `terraform init` + `plan` (com backend remoto).
  - Ajustes em nomes/rota (health check).
- **Checkpoint**: Commit “feat: infra terraform”.

### Módulo 10 – Workflows do GitHub Actions (60 min)
- Criar `.github/workflows/deploy.yml`:
  - `checkout`, `configure-aws-credentials`, `setup-terraform`.
  - `terraform init && apply` (sem target no primeiro momento).
  - `amazon-ecr-login`, `docker/build-push-action`.
  - Segundo `terraform apply` com `TF_VAR_image_tag`.
- Criar `.github/workflows/destroy.yml`.
- Configurar secrets (`ACCOUNT_ID`).
- **Testes**:
  - Push na main → acompanhar log de deploy.
  - Ajustar outputs/rota se necessário.
- **Checkpoint**: Commit “feat: pipelines GitHub Actions”.

### Módulo 11 – Refino e Observabilidade (opcional, 45 min)
- Ajustar README (instruções finais, diagramas).
- Adicionar monitoramento básico (ex.: enable CloudWatch Logs via ECS task definition).
- Planejar substituição de `AdministratorAccess`.
- Executar workflow `DESTROY` e confirmar limpeza.

> **Tempo total estimado Parte 2**: ~5h (pode variar conforme familiaridade com Terraform/AWS).

---

## Avaliações e Desafios

- **Checklist final**:
  - [ ] API responde localmente e no endpoint público (`/prod/hello`).
  - [ ] State remoto funcional (nenhum `.tfstate` versionado).
  - [ ] Workflow `DEPLOY` atualizado com imagem e task ECS.
  - [ ] Workflow `DESTROY` remove todos os recursos.
  - [ ] README e documentação compreensíveis.
  - [ ] Nenhuma credencial sensível versionada (confirmação via busca).
- **Desafios extras**:
  1. Adicionar autenticação simples via API Gateway (JWT/Cognito).
  2. Implementar layer de observabilidade (CloudWatch métricas + alarmes).
  3. Criar testes automatizados para a API e integrá-los no pipeline.
  4. Substituir `AdministratorAccess` por políticas específicas para Terraform.
  5. Automatizar destruição parcial (ex.: somente ECS/ECR) usando targets mais seguros.

## Recursos Complementares

- Documentação Terraform AWS: [https://registry.terraform.io/providers/hashicorp/aws/latest](https://registry.terraform.io/providers/hashicorp/aws/latest)
- Guia OIDC GitHub Actions: [https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- Módulo `terraform-aws-modules/vpc`: [https://github.com/terraform-aws-modules/terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc)
- Guia Express.js: [https://expressjs.com/pt-br/](https://expressjs.com/pt-br/)

---

**Dica final:** incentive os alunos a manterem um diário de experimentos e erros encontrados durante o hands-on. Isso fixa o aprendizado e gera material para discussões em grupo.
