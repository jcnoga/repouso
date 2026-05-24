-- Seed básico para desenvolvimento
INSERT INTO tenants (id, name, slug) VALUES ('11111111-1111-1111-1111-111111111111', 'Lar do Idoso Feliz', 'lar-feliz');
-- ATENÇÃO: para criar usuário administrador, crie via Supabase Auth e depois insira na tabela profiles:
-- INSERT INTO profiles (id, tenant_id, full_name, email, role) VALUES ('uuid-do-usuario', '11111111-1111-1111-1111-111111111111', 'Admin', 'admin@exemplo.com', 'admin');
