-- NAYAB STORE - SUPABASE / POSTGRES SQL
-- Run this in Supabase SQL Editor.
-- Includes products, categories, customers, orders, order items,
-- reviews, cart, stock movements, settings and publish/unpublish.

create extension if not exists pgcrypto;

create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references categories(id) on delete set null,
  name text not null,
  slug text unique,
  sku text unique,
  barcode text unique,
  description text default '',
  image_url text default '',
  price numeric(12,2) not null default 0,
  old_price numeric(12,2),
  stock integer not null default 0 check (stock >= 0),
  is_published boolean not null default false,
  rating numeric(3,2) not null default 0 check (rating between 0 and 5),
  review_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  email text,
  address text,
  created_at timestamptz not null default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  customer_id uuid references customers(id) on delete set null,
  customer_name text not null,
  phone text not null,
  address text not null,
  payment_method text not null check (payment_method in ('COD','ACCOUNT')),
  subtotal numeric(12,2) not null default 0,
  delivery_charge numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  status text not null default 'pending',
  estimated_delivery text default '',
  confirmation_message text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid references products(id) on delete set null,
  product_name text not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null default 0,
  line_total numeric(12,2) not null default 0
);

create table if not exists cart_items (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id) on delete cascade,
  session_id text,
  product_id uuid not null references products(id) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  created_at timestamptz not null default now(),
  unique(customer_id, product_id),
  unique(session_id, product_id)
);

create table if not exists reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  customer_id uuid references customers(id) on delete set null,
  customer_name text not null,
  rating integer not null check (rating between 1 and 5),
  review_text text default '',
  approved boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  quantity_change integer not null,
  movement_type text not null,
  reference_id uuid,
  note text default '',
  created_at timestamptz not null default now()
);

create table if not exists store_settings (
  id integer primary key default 1 check (id = 1),
  store_name text not null default 'Nayab Store',
  whatsapp text default '',
  delivery_charge numeric(12,2) not null default 0,
  currency text not null default 'PKR',
  updated_at timestamptz not null default now()
);

insert into store_settings (id) values (1)
on conflict (id) do nothing;

insert into categories (name, slug) values
('Milk & Dairy','milk-dairy'),
('Biscuits & Snacks','biscuits-snacks'),
('Grocery','grocery'),
('Beverages','beverages')
on conflict (slug) do nothing;

create index if not exists products_barcode_idx on products(barcode);
create index if not exists products_category_idx on products(category_id);
create index if not exists products_published_idx on products(is_published);
create index if not exists orders_status_idx on orders(status);
create index if not exists orders_created_idx on orders(created_at);

-- Auto-update timestamp
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists products_updated_at on products;
create trigger products_updated_at before update on products
for each row execute function set_updated_at();

drop trigger if exists orders_updated_at on orders;
create trigger orders_updated_at before update on orders
for each row execute function set_updated_at();

-- Keep product rating/count in sync with approved reviews
create or replace function refresh_product_rating()
returns trigger language plpgsql as $$
declare pid uuid;
begin
  pid := coalesce(new.product_id, old.product_id);
  update products p
  set rating = coalesce((select round(avg(r.rating)::numeric,2)
                         from reviews r
                         where r.product_id = pid and r.approved = true),0),
      review_count = (select count(*) from reviews r
                      where r.product_id = pid and r.approved = true),
      updated_at = now()
  where p.id = pid;
  return coalesce(new, old);
end $$;

drop trigger if exists reviews_rating_sync on reviews;
create trigger reviews_rating_sync after insert or update or delete on reviews
for each row execute function refresh_product_rating();

-- IMPORTANT:
-- Enable Row Level Security and create policies according to your
-- customer/admin authentication model before exposing this database publicly.
-- Do not put a service-role key in HTML.
