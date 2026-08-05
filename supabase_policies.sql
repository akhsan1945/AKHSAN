-- Jalankan di Supabase > SQL Editor setelah tabel selesai dibuat.
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;
alter table public.products enable row level security;
alter table public.profiles enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
drop policy if exists products_select on public.products; create policy products_select on public.products for select to authenticated using (true);
drop policy if exists products_admin_insert on public.products; create policy products_admin_insert on public.products for insert to authenticated with check (public.is_admin());
drop policy if exists products_admin_update on public.products; create policy products_admin_update on public.products for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists profiles_self on public.profiles; create policy profiles_self on public.profiles for select to authenticated using (id=auth.uid() or public.is_admin());
drop policy if exists orders_select on public.orders; create policy orders_select on public.orders for select to authenticated using (true);
drop policy if exists orders_insert on public.orders; create policy orders_insert on public.orders for insert to authenticated with check (cashier_id=auth.uid());
drop policy if exists items_select on public.order_items; create policy items_select on public.order_items for select to authenticated using (true);
drop policy if exists items_insert on public.order_items; create policy items_insert on public.order_items for insert to authenticated with check (exists(select 1 from public.orders o where o.id=order_id and o.cashier_id=auth.uid()));
