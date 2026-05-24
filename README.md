# CareHome SaaS – Plataforma para ILPI e Casas de Repouso

## Início Rápido
1. `npm install`
2. Configure `.env` com suas credenciais Supabase
3. Execute as migrations SQL (pasta `supabase/migrations/`)
4. Crie um usuário administrador no Supabase Auth e insira na tabela `profiles`
5. `npm run dev`

## Estrutura
- `src/modules/` – domínios de negócio (residents, medications, care-schedule, financial, crm-family, dashboards, workflows)
- `src/shared/` – componentes, hooks e serviços reutilizáveis
- `supabase/migrations/` – esquema completo do banco

## Módulos implementados
- Gestão de Residentes (com histórico clínico, alergias, documentos)
- Gestão de Medicações (prescrições, administração, estoque)
- Agenda de Cuidados (tarefas recorrentes, checklist)
- Financeiro (contas a receber/pagar, mensalidades, fluxo de caixa)
- CRM Familiar (pipeline, follow-ups, interações)
- Dashboards (KPIs, gráficos, alertas)
- Workflow Engine (eventos e handlers)
