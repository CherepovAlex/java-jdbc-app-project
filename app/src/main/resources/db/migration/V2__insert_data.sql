-- =======================================
--  Тестовые данные для БД orders_db
--  Файл: test_data.sql
--  Автор: студент курса Java Черепов Александр
--  Дата: 2025-09-28
-- =======================================

-- Очистка таблиц (чтобы не было дублей при повторном запуске)
TRUNCATE TABLE orders RESTART IDENTITY CASCADE;
TRUNCATE TABLE product RESTART IDENTITY CASCADE;
TRUNCATE TABLE customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE order_status RESTART IDENTITY CASCADE;

-- ==============================
-- Таблица: order_status
-- ==============================
INSERT INTO order_status (status_name) VALUES
    ('NEW'),
    ('PAID'),
    ('SHIPPED'),
    ('CANCELLED'),
    ('PROCESSING'),
    ('RETURNED'),
    ('REFUNDED'),
    ('ON_HOLD'),
    ('DELIVERED'),
    ('FAILED');

-- ==============================
-- Таблица: product
-- ==============================
INSERT INTO product (description, price, quantity, category) VALUES
    ('Laptop Lenovo ThinkPad', 1200.00, 10, 'Electronics'),
    ('iPhone 15 Pro', 1500.00, 5, 'Electronics'),
    ('Office Chair', 250.00, 20, 'Furniture'),
    ('Gaming Mouse', 80.00, 50, 'Electronics'),
    ('Desk Lamp', 45.00, 100, 'Furniture'),
    ('Samsung Galaxy S23', 1100.00, 15, 'Electronics'),
    ('Wireless Headphones Sony', 300.00, 30, 'Electronics'),
    ('Smart TV LG 55"', 900.00, 7, 'Electronics'),
    ('Coffee Maker Philips', 150.00, 25, 'Appliances'),
    ('Backpack Samsonite', 120.00, 40, 'Accessories');

-- ==============================
-- Таблица: customer
-- ==============================
INSERT INTO customer (first_name, last_name, phone, email) VALUES
    ('John', 'Doe', '+123456789', 'john.doe@example.com'),
    ('Alice', 'Smith', '+987654321', 'alice.smith@example.com'),
    ('Bob', 'Brown', '+112233445', 'bob.brown@example.com'),
    ('Charlie', 'Wilson', '+998877665', 'charlie.wilson@example.com'),
    ('Diana', 'Miller', '+111222333', 'diana.miller@example.com'),
    ('Ethan', 'Taylor', '+444555666', 'ethan.taylor@example.com'),
    ('Fiona', 'Clark', '+777888999', 'fiona.clark@example.com'),
    ('George', 'Hall', '+121212121', 'george.hall@example.com'),
    ('Hannah', 'Walker', '+343434343', 'hannah.walker@example.com'),
    ('Ivan', 'Davis', '+565656565', 'ivan.davis@example.com');

-- ==============================
-- Таблица: orders
-- ==============================
INSERT INTO orders (product_id, customer_id, quantity, status_id) VALUES
    (1, 1, 1, 1),   -- John заказал Lenovo ThinkPad (NEW)
    (2, 2, 1, 2),   -- Alice заказала iPhone (PAID)
    (3, 3, 2, 3),   -- Bob заказал кресло (SHIPPED)
    (4, 4, 1, 4),   -- Charlie заказал мышь (CANCELLED)
    (5, 5, 3, 5),   -- Diana заказала лампы (PROCESSING)
    (6, 6, 1, 6),   -- Ethan заказал Samsung (RETURNED)
    (7, 7, 1, 7),   -- Fiona заказала наушники (REFUNDED)
    (8, 8, 1, 8),   -- George заказал телевизор (ON_HOLD)
    (9, 9, 1, 9),   -- Hannah заказала кофеварку (DELIVERED)
    (10, 10, 2, 10);-- Ivan заказал рюкзаки (FAILED)
