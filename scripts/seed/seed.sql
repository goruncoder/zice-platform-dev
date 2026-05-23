-- Zice platform dev seed — Joliet Jaguars test org, team, roster, and users.
-- Run via: make seed

BEGIN;

-- Organization
INSERT INTO public.organizations (id, name, slug, branding_config, contact_email, metadata)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'Joliet Jaguars',
  'joliet-jaguars',
  '{"primary_color": "#1B365D", "accent_color": "#FFB81C", "logo_url": null}',
  'admin@jolietjaguars.org',
  '{"sport": "ice_hockey", "region": "Chicagoland", "league": "NWHL"}'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  slug = EXCLUDED.slug;

-- Memberships
INSERT INTO public.memberships (user_id, org_id, role) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'admin'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'coach'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', 'parent'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'viewer')
ON CONFLICT (user_id, org_id) DO UPDATE SET role = EXCLUDED.role;

-- Players (14U Gold roster)
INSERT INTO public.players (id, first_name, last_name, dob, usa_hockey_id) VALUES
  ('00000001-0001-0001-0001-000000000001', 'Liam',   'O''Brien',   '2012-03-15', 'USH20120315001'),
  ('00000001-0001-0001-0001-000000000002', 'Connor', 'Mitchell',   '2012-07-22', 'USH20120722002'),
  ('00000001-0001-0001-0001-000000000003', 'Jack',   'Kowalski',   '2013-01-08', 'USH20130108003'),
  ('00000001-0001-0001-0001-000000000004', 'Dylan',  'Petrov',     '2012-11-30', 'USH20121130004'),
  ('00000001-0001-0001-0001-000000000005', 'Ryan',   'Sullivan',   '2013-05-12', 'USH20130512005'),
  ('00000001-0001-0001-0001-000000000006', 'Nolan',  'Bergstrom',  '2012-09-03', 'USH20120903006'),
  ('00000001-0001-0001-0001-000000000007', 'Tyler',  'Marchetti',  '2013-02-28', 'USH20130228007')
ON CONFLICT (id) DO NOTHING;

-- Guardians
INSERT INTO public.player_guardians (player_id, user_id, relationship, permissions, is_primary, is_active) VALUES
  ('00000001-0001-0001-0001-000000000001', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'parent', '{financial,medical,legal_signer,schedule_view,pickup,messaging}', true, true),
  ('00000001-0001-0001-0001-000000000002', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'parent', '{financial,medical,legal_signer,schedule_view,pickup,messaging}', true, true),
  ('00000001-0001-0001-0001-000000000003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'parent', '{financial,medical,legal_signer,schedule_view,pickup,messaging}', true, true),
  ('00000001-0001-0001-0001-000000000004', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'caregiver', '{schedule_view,messaging}', false, true),
  ('00000001-0001-0001-0001-000000000005', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'caregiver', '{schedule_view,messaging}', false, true)
ON CONFLICT (player_id, user_id) DO NOTHING;

-- Roster
INSERT INTO public.rosters (player_id, org_id, team_designation, season, jersey_number, status) VALUES
  ('00000001-0001-0001-0001-000000000001', '11111111-1111-1111-1111-111111111111', '14U Gold', '2025-26', '11', 'active'),
  ('00000001-0001-0001-0001-000000000002', '11111111-1111-1111-1111-111111111111', '14U Gold', '2025-26', '7',  'active'),
  ('00000001-0001-0001-0001-000000000003', '11111111-1111-1111-1111-111111111111', '14U Gold', '2025-26', '19', 'active'),
  ('00000001-0001-0001-0001-000000000004', '11111111-1111-1111-1111-111111111111', '14U Gold', '2025-26', '4',  'active'),
  ('00000001-0001-0001-0001-000000000005', '11111111-1111-1111-1111-111111111111', '14U Gold', '2025-26', '22', 'active')
ON CONFLICT (player_id, org_id, team_designation, season) DO NOTHING;

COMMIT;
