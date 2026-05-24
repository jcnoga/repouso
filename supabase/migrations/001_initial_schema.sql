-- EXTENSÕES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- FUNÇÕES AUXILIARES RLS
CREATE OR REPLACE FUNCTION auth.current_tenant_id() RETURNS UUID
LANGUAGE SQL STABLE SECURITY DEFINER AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION auth.current_user_role() RETURNS TEXT
LANGUAGE SQL STABLE SECURITY DEFINER AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- FUNÇÃO DE ISOLAMENTO POR TENANT (genérica)
CREATE OR REPLACE FUNCTION tenant_isolation_policy(table_name text) RETURNS void AS $$
BEGIN
  EXECUTE format('
    CREATE POLICY tenant_isolation ON %I
    USING (tenant_id = auth.current_tenant_id())
    WITH CHECK (tenant_id = auth.current_tenant_id())
  ', table_name);
END;
$$ LANGUAGE plpgsql;

-- TABELAS BASE
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID,
  updated_by UUID,
  version INT DEFAULT 1
);

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin','enfermeiro','cuidador','financeiro','recepcao')),
  avatar_url TEXT,
  phone TEXT,
  settings JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1,
  UNIQUE(tenant_id, email)
);

-- RESIDENTES
CREATE TABLE residents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  birth_date DATE NOT NULL,
  cpf TEXT UNIQUE,
  rg TEXT,
  sus_number TEXT,
  admission_date DATE NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive','transferred','deceased')),
  room_number TEXT,
  bed_number TEXT,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
  health_plan TEXT,
  allergies TEXT,
  observations TEXT,
  dietary_restrictions TEXT,
  mobility_description TEXT,
  mobility_aids TEXT,
  mobility_level TEXT CHECK (mobility_level IN ('independent','partial','dependent')) DEFAULT 'partial',
  blood_type TEXT,
  organ_donor BOOLEAN DEFAULT false,
  advance_directives TEXT,
  profile_photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- ALERGIAS (catálogo)
CREATE TABLE allergies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  severity TEXT CHECK (severity IN ('mild','moderate','severe','life_threatening')) DEFAULT 'moderate',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1,
  UNIQUE(tenant_id, name)
);

CREATE TABLE resident_allergies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  resident_id UUID NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  allergy_id UUID NOT NULL REFERENCES allergies(id),
  reaction TEXT,
  diagnosed_at DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  UNIQUE(resident_id, allergy_id)
);

-- HISTÓRICO CLÍNICO
CREATE TABLE clinical_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL CHECK (event_type IN ('diagnosis','surgery','hospitalization','accident','vaccination','exam','other')),
  title TEXT NOT NULL,
  description TEXT,
  event_date DATE NOT NULL,
  doctor_name TEXT,
  hospital_name TEXT,
  attachments JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- CONTATOS DE EMERGÊNCIA
CREATE TABLE emergency_contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  relationship TEXT NOT NULL,
  phone TEXT NOT NULL,
  secondary_phone TEXT,
  email TEXT,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- RESPONSÁVEIS FINANCEIROS
CREATE TABLE financial_responsibles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  cpf TEXT,
  phone TEXT NOT NULL,
  email TEXT,
  address TEXT,
  is_primary BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- DOCUMENTOS DO RESIDENTE (STORAGE)
CREATE TABLE resident_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL CHECK (document_type IN ('id_card','cpf','health_insurance','medical_report','contract','consent_form','other')),
  title TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_name TEXT,
  file_size INT,
  mime_type TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  uploaded_by UUID REFERENCES profiles(id),
  notes TEXT,
  deleted_at TIMESTAMPTZ,
  version INT DEFAULT 1
);

-- MEDICAMENTOS (CATÁLOGO)
CREATE TABLE medications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  active_ingredient TEXT,
  dosage_form TEXT,
  concentration TEXT,
  manufacturer TEXT,
  requires_prescription BOOLEAN DEFAULT true,
  current_stock INT DEFAULT 0,
  min_stock_threshold INT DEFAULT 5,
  unit TEXT DEFAULT 'unidade',
  batch_control BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1,
  UNIQUE(tenant_id, name)
);

-- PRESCRIÇÕES (AGENDAMENTO DE MEDICAÇÕES)
CREATE TABLE medication_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID NOT NULL REFERENCES residents(id),
  medication_id UUID NOT NULL REFERENCES medications(id),
  prescribed_by UUID NOT NULL REFERENCES profiles(id),
  start_date DATE NOT NULL,
  end_date DATE,
  dosage TEXT NOT NULL,
  route TEXT NOT NULL,
  frequency TEXT NOT NULL,
  schedule_times TIME[] NOT NULL,
  special_instructions TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','discontinued','completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- ADMINISTRAÇÕES DE MEDICAÇÕES
CREATE TABLE medication_administrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  schedule_id UUID NOT NULL REFERENCES medication_schedules(id) ON DELETE CASCADE,
  administered_by UUID NOT NULL REFERENCES profiles(id),
  scheduled_time TIMESTAMPTZ NOT NULL,
  administered_at TIMESTAMPTZ,
  status TEXT NOT NULL CHECK (status IN ('pending','administered','refused','missed','delayed')) DEFAULT 'pending',
  refusal_reason TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- MOVIMENTAÇÕES DE ESTOQUE
CREATE TABLE stock_movements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  medication_id UUID NOT NULL REFERENCES medications(id),
  movement_type TEXT NOT NULL CHECK (movement_type IN ('inbound','outbound','adjustment','return')),
  quantity INT NOT NULL,
  batch_number TEXT,
  expiry_date DATE,
  notes TEXT,
  moved_by UUID NOT NULL REFERENCES profiles(id),
  moved_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TAREFAS DE CUIDADO
CREATE TABLE care_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID REFERENCES residents(id),
  assigned_to UUID NOT NULL REFERENCES profiles(id),
  task_type TEXT NOT NULL CHECK (task_type IN ('bathing','feeding','toileting','mobility','vital_signs','recreation','other')),
  scheduled_start TIMESTAMPTZ NOT NULL,
  scheduled_end TIMESTAMPTZ NOT NULL,
  actual_start TIMESTAMPTZ,
  actual_end TIMESTAMPTZ,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','in_progress','completed','missed','cancelled')),
  notes TEXT,
  outcome TEXT,
  title TEXT,
  description TEXT,
  is_recurring BOOLEAN DEFAULT false,
  recurring_rule TEXT,
  parent_template_id UUID,
  checklist_template_id UUID,
  priority TEXT CHECK (priority IN ('low','medium','high')) DEFAULT 'medium',
  reminder_minutes_before INT DEFAULT 30,
  reminder_sent BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- MODELOS DE TAREFAS RECORRENTES
CREATE TABLE recurring_task_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  task_type TEXT NOT NULL CHECK (task_type IN ('bathing','feeding','toileting','mobility','vital_signs','recreation','other')),
  duration_minutes INT,
  priority TEXT NOT NULL DEFAULT 'medium',
  recurring_rule TEXT NOT NULL,
  assigned_to_role TEXT CHECK (assigned_to_role IN ('admin','enfermeiro','cuidador')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- CHECKLISTS
CREATE TABLE checklist_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

CREATE TABLE checklist_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  checklist_template_id UUID NOT NULL REFERENCES checklist_templates(id) ON DELETE CASCADE,
  order_index INT NOT NULL,
  description TEXT NOT NULL,
  is_required BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE task_checklists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID NOT NULL REFERENCES care_tasks(id) ON DELETE CASCADE,
  checklist_template_id UUID NOT NULL REFERENCES checklist_templates(id),
  completed_items JSONB DEFAULT '[]',
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- FINANCEIRO (entradas/saídas)
CREATE TABLE financial_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID REFERENCES residents(id),
  contract_id UUID,
  entry_type TEXT NOT NULL CHECK (entry_type IN ('revenue','expense')),
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  due_date DATE NOT NULL,
  payment_date DATE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','partial','paid','overdue','canceled')),
  payment_method TEXT,
  transaction_id TEXT,
  notes TEXT,
  paid_amount DECIMAL(12,2) DEFAULT 0,
  interest_amount DECIMAL(12,2) DEFAULT 0,
  fine_amount DECIMAL(12,2) DEFAULT 0,
  document_number TEXT,
  supplier_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- CONTRATOS (mensalidades recorrentes)
CREATE TABLE contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID NOT NULL REFERENCES residents(id),
  contract_number TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  monthly_amount DECIMAL(12,2) NOT NULL,
  discount_amount DECIMAL(12,2) DEFAULT 0,
  payment_day INT NOT NULL CHECK (payment_day BETWEEN 1 AND 31),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','terminated')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1,
  UNIQUE(tenant_id, contract_number)
);

-- FAMILY CONTACTS (CRM)
CREATE TABLE family_contacts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  resident_id UUID NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  relationship TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  is_primary BOOLEAN DEFAULT false,
  can_receive_notifications BOOLEAN DEFAULT true,
  can_authorize_medical BOOLEAN DEFAULT false,
  notes TEXT,
  pipeline_stage TEXT NOT NULL DEFAULT 'lead' CHECK (pipeline_stage IN ('lead','contacted','meeting_scheduled','follow_up','converted','lost')),
  relationship_status TEXT NOT NULL DEFAULT 'good' CHECK (relationship_status IN ('excellent','good','regular','critical')),
  assigned_to UUID REFERENCES profiles(id),
  last_contact_at TIMESTAMPTZ,
  lead_score INT DEFAULT 0,
  preferred_contact_method TEXT CHECK (preferred_contact_method IN ('phone','email','whatsapp','in_person')) DEFAULT 'phone',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- FOLLOW-UPS DO CRM
CREATE TABLE family_follow_ups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  family_contact_id UUID NOT NULL REFERENCES family_contacts(id) ON DELETE CASCADE,
  assigned_to UUID NOT NULL REFERENCES profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMPTZ NOT NULL,
  priority TEXT NOT NULL CHECK (priority IN ('low','medium','high')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','completed','cancelled')),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- INTERAÇÕES DO CRM
CREATE TABLE family_interactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  family_contact_id UUID NOT NULL REFERENCES family_contacts(id) ON DELETE CASCADE,
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('call','email','whatsapp','meeting','note','other')),
  subject TEXT NOT NULL,
  content TEXT,
  happened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  version INT DEFAULT 1
);

-- NOTIFICAÇÕES
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  recipient_type TEXT NOT NULL CHECK (recipient_type IN ('profile','family_contact')),
  recipient_id UUID NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('info','warning','alert','reminder')),
  is_read BOOLEAN DEFAULT false,
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  action_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id),
  updated_by UUID REFERENCES profiles(id),
  version INT DEFAULT 1
);

-- WORKFLOW EVENTS
CREATE TABLE workflow_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  event_name TEXT NOT NULL,
  entity_id UUID NOT NULL,
  payload JSONB NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed BOOLEAN DEFAULT FALSE,
  processed_at TIMESTAMPTZ,
  created_by UUID REFERENCES profiles(id)
);

-- VIEW MATERIALIZADA PARA MÉTRICAS MENSAIS
CREATE MATERIALIZED VIEW monthly_metrics AS
WITH monthly_revenue AS (
  SELECT tenant_id, DATE_TRUNC('month', due_date) AS month,
         SUM(amount) AS total_billed, SUM(paid_amount) AS total_collected
  FROM financial_entries WHERE entry_type = 'revenue' AND deleted_at IS NULL
  GROUP BY tenant_id, DATE_TRUNC('month', due_date)
),
monthly_expenses AS (
  SELECT tenant_id, DATE_TRUNC('month', due_date) AS month, SUM(amount) AS total_expenses
  FROM financial_entries WHERE entry_type = 'expense' AND deleted_at IS NULL
  GROUP BY tenant_id, DATE_TRUNC('month', due_date)
),
active_residents AS (
  SELECT tenant_id, DATE_TRUNC('month', created_at) AS month, COUNT(*) AS residents_count
  FROM residents WHERE status = 'active' AND deleted_at IS NULL
  GROUP BY tenant_id, DATE_TRUNC('month', created_at)
)
SELECT COALESCE(r.tenant_id, e.tenant_id, a.tenant_id) AS tenant_id,
       COALESCE(r.month, e.month, a.month) AS month,
       COALESCE(r.total_billed,0) AS total_billed,
       COALESCE(r.total_collected,0) AS total_collected,
       COALESCE(e.total_expenses,0) AS total_expenses,
       COALESCE(a.residents_count,0) AS active_residents,
       COALESCE(r.total_collected,0)-COALESCE(e.total_expenses,0) AS net_profit
FROM monthly_revenue r
FULL OUTER JOIN monthly_expenses e ON r.tenant_id=e.tenant_id AND r.month=e.month
FULL OUTER JOIN active_residents a ON COALESCE(r.tenant_id, e.tenant_id)=a.tenant_id
  AND COALESCE(r.month, e.month)=a.month;
CREATE UNIQUE INDEX idx_monthly_metrics ON monthly_metrics(tenant_id, month);

-- FUNÇÕES AUXILIARES (geração de mensalidades, métricas operacionais)
CREATE OR REPLACE FUNCTION generate_monthly_fees(target_month DATE)
RETURNS TABLE(contract_id UUID, entry_id UUID) AS $$
DECLARE contract_record RECORD; due_date_calc DATE; amount_calc DECIMAL; new_entry_id UUID;
BEGIN
  FOR contract_record IN SELECT c.* FROM contracts c WHERE c.status='active' AND c.deleted_at IS NULL AND (c.end_date IS NULL OR c.end_date>=target_month) LOOP
    due_date_calc := make_date(EXTRACT(YEAR FROM target_month)::INT, EXTRACT(MONTH FROM target_month)::INT, LEAST(contract_record.payment_day, (EXTRACT(DAY FROM (target_month + INTERVAL '1 month')::DATE - INTERVAL '1 day'))::INT));
    IF NOT EXISTS (SELECT 1 FROM financial_entries WHERE contract_id=contract_record.id AND due_date=due_date_calc AND entry_type='revenue') THEN
      amount_calc := contract_record.monthly_amount - contract_record.discount_amount;
      INSERT INTO financial_entries (tenant_id, resident_id, contract_id, entry_type, category, description, amount, due_date, status, created_by)
      VALUES (contract_record.tenant_id, contract_record.resident_id, contract_record.id, 'revenue', 'mensalidade',
              'Mensalidade referente a '||to_char(target_month,'Month/YYYY'), amount_calc, due_date_calc, 'pending', auth.uid())
      RETURNING id INTO new_entry_id;
      RETURN NEXT;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_operational_metrics(p_tenant_id UUID)
RETURNS TABLE(pending_medications BIGINT, overdue_tasks BIGINT, pending_financial BIGINT, low_stock_count BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT (SELECT COUNT(*) FROM medication_administrations ma JOIN medication_schedules ms ON ms.id=ma.schedule_id WHERE ms.tenant_id=p_tenant_id AND ma.status='pending' AND ma.scheduled_time<=NOW()+INTERVAL '24 hours'),
         (SELECT COUNT(*) FROM care_tasks WHERE tenant_id=p_tenant_id AND status='pending' AND scheduled_start<NOW()),
         (SELECT COUNT(*) FROM financial_entries WHERE tenant_id=p_tenant_id AND status='overdue'),
         (SELECT COUNT(*) FROM medications WHERE tenant_id=p_tenant_id AND current_stock<=min_stock_threshold);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- TRIGGERS PARA VERSIONAMENTO E AUDITORIA
CREATE OR REPLACE FUNCTION update_version_and_timestamp() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at=NOW(); NEW.version=OLD.version+1; RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_user_ids() RETURNS TRIGGER AS $$
BEGIN IF NEW.created_by IS NULL THEN NEW.created_by = auth.uid(); END IF; NEW.updated_by = auth.uid(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DO $$ DECLARE t text; BEGIN
  FOR t IN SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE' AND table_name NOT IN ('workflow_events') LOOP
    EXECUTE format('CREATE TRIGGER trigger_version_%I BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_version_and_timestamp();', t, t);
    EXECUTE format('CREATE TRIGGER trigger_user_ids_%I BEFORE INSERT OR UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION set_user_ids();', t, t);
  END LOOP;
END $$;

-- TRIGGER PARA GERAR ADMINISTRAÇÕES PENDENTES
CREATE OR REPLACE FUNCTION generate_administrations() RETURNS TRIGGER AS $$
DECLARE schedule_time TIME; current_date DATE; end_date DATE;
BEGIN
  IF TG_OP='INSERT' OR (TG_OP='UPDATE' AND NEW.status='active') THEN
    current_date := NEW.start_date; end_date := COALESCE(NEW.end_date, current_date+INTERVAL '1 year');
    WHILE current_date <= end_date LOOP
      FOREACH schedule_time IN ARRAY NEW.schedule_times LOOP
        INSERT INTO medication_administrations (tenant_id, schedule_id, scheduled_time, status)
        VALUES (NEW.tenant_id, NEW.id, (current_date+schedule_time), 'pending') ON CONFLICT DO NOTHING;
      END LOOP;
      current_date := current_date+1;
    END LOOP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_generate_administrations AFTER INSERT OR UPDATE OF start_date,end_date,schedule_times,status ON medication_schedules
FOR EACH ROW WHEN (NEW.status='active') EXECUTE FUNCTION generate_administrations();

-- TRIGGER PARA ATUALIZAR STATUS FINANCEIRO
CREATE OR REPLACE FUNCTION update_financial_entry_status() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.paid_amount >= NEW.amount THEN NEW.status:='paid'; NEW.payment_date:=COALESCE(NEW.payment_date,NOW());
  ELSIF NEW.paid_amount>0 AND NEW.paid_amount<NEW.amount THEN NEW.status:='partial';
  ELSIF NEW.due_date<CURRENT_DATE AND NEW.paid_amount=0 AND NEW.status NOT IN ('paid','canceled') THEN NEW.status:='overdue';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_update_financial_status BEFORE UPDATE ON financial_entries FOR EACH ROW EXECUTE FUNCTION update_financial_entry_status();

-- RLS: ativar e aplicar tenant_isolation para todas as tabelas que possuem tenant_id
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE residents ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergies ENABLE ROW LEVEL SECURITY;
ALTER TABLE resident_allergies ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_responsibles ENABLE ROW LEVEL SECURITY;
ALTER TABLE resident_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_administrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE care_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE recurring_task_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_checklists ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_follow_ups ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_events ENABLE ROW LEVEL SECURITY;

-- Aplicar política de isolamento por tenant (usando a função genérica)
SELECT tenant_isolation_policy('profiles');
SELECT tenant_isolation_policy('residents');
SELECT tenant_isolation_policy('allergies');
SELECT tenant_isolation_policy('resident_allergies');
SELECT tenant_isolation_policy('clinical_history');
SELECT tenant_isolation_policy('emergency_contacts');
SELECT tenant_isolation_policy('financial_responsibles');
SELECT tenant_isolation_policy('resident_documents');
SELECT tenant_isolation_policy('medications');
SELECT tenant_isolation_policy('medication_schedules');
SELECT tenant_isolation_policy('medication_administrations');
SELECT tenant_isolation_policy('stock_movements');
SELECT tenant_isolation_policy('care_tasks');
SELECT tenant_isolation_policy('recurring_task_templates');
SELECT tenant_isolation_policy('checklist_templates');
SELECT tenant_isolation_policy('checklist_items');
SELECT tenant_isolation_policy('task_checklists');
SELECT tenant_isolation_policy('financial_entries');
SELECT tenant_isolation_policy('contracts');
SELECT tenant_isolation_policy('family_contacts');
SELECT tenant_isolation_policy('family_follow_ups');
SELECT tenant_isolation_policy('family_interactions');
SELECT tenant_isolation_policy('notifications');
SELECT tenant_isolation_policy('workflow_events');

-- Políticas específicas para tenants (acesso direto)
CREATE POLICY tenants_select_policy ON tenants FOR SELECT USING (id = auth.current_tenant_id() OR EXISTS (SELECT 1 FROM profiles WHERE id=auth.uid() AND role='admin'));

-- Permissões adicionais baseadas em papel (exemplos)
CREATE POLICY financial_admin_only_update ON financial_entries FOR UPDATE USING (auth.current_user_role() IN ('admin','financeiro'));
CREATE POLICY financial_admin_only_delete ON financial_entries FOR DELETE USING (auth.current_user_role()='admin');
CREATE POLICY manage_templates_roles ON recurring_task_templates FOR ALL USING (auth.current_user_role() IN ('admin','enfermeiro'));
CREATE POLICY edit_follow_ups_role ON family_follow_ups FOR ALL USING (auth.current_user_role() IN ('admin','enfermeiro','recepcao'));

-- ÍNDICES ADICIONAIS PARA PERFORMANCE
CREATE INDEX idx_residents_tenant ON residents(tenant_id);
CREATE INDEX idx_residents_status ON residents(status);
CREATE INDEX idx_medication_schedules_resident ON medication_schedules(resident_id);
CREATE INDEX idx_care_tasks_scheduled ON care_tasks(scheduled_start);
CREATE INDEX idx_financial_entries_due_date ON financial_entries(due_date) WHERE status NOT IN ('paid','canceled');
CREATE INDEX idx_family_contacts_pipeline ON family_contacts(pipeline_stage);
CREATE INDEX idx_workflow_events_name ON workflow_events(event_name);
