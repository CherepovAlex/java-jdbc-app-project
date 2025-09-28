-- =======================================
--  Набор SQL-запросов для проверки БД
--  Файл: test-queries.sql
--  Автор: студент курса Java Черепов Александр
--  Дата: 2025-09-28
-- =======================================

-- ==============================
-- SELECT (чтение) — 5 запросов
-- ==============================

-- 1. Список всех заказов за последние 7 дней с именем покупателя и описанием товара
SELECT o.id AS order_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       p.description AS product_name,
       o.order_date,
       os.status_name
FROM orders o
JOIN customer c ON o.customer_id = c.id
JOIN product p ON o.product_id = p.id
JOIN order_status os ON o.status_id = os.id
WHERE o.order_date >= NOW() - INTERVAL '7 days'
ORDER BY o.order_date DESC;

-- 2. Топ-3 самых популярных товаров (по сумме заказанных quantity)
SELECT p.description,
       SUM(o.quantity) AS total_sold
FROM orders o
JOIN product p ON o.product_id = p.id
GROUP BY p.description
ORDER BY total_sold DESC
LIMIT 3;

-- 3. Количество заказов по статусам
SELECT os.status_name,
       COUNT(o.id) AS order_count
FROM order_status os
LEFT JOIN orders o ON os.id = o.status_id
GROUP BY os.status_name
ORDER BY order_count DESC;

-- 4. Список клиентов, у которых есть хотя бы один заказ
SELECT DISTINCT c.id,
       c.first_name,
       c.last_name,
       c.email
FROM customer c
JOIN orders o ON c.id = o.customer_id
ORDER BY c.last_name;

-- 5. Средняя стоимость заказов каждого клиента
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       ROUND(AVG(p.price * o.quantity), 2) AS avg_order_value
FROM orders o
JOIN customer c ON o.customer_id = c.id
JOIN product p ON o.product_id = p.id
GROUP BY c.first_name, c.last_name
ORDER BY avg_order_value DESC;

-- ==============================
-- UPDATE (изменение) — 3 запроса
-- ==============================

-- 6. Изменение статуса заказа (например, заказ #1 -> PAID)
UPDATE orders
SET status_id = (SELECT id FROM order_status WHERE status_name = 'PAID')
WHERE id = 1;

-- 7. Обновление количества на складе после покупки (уменьшаем quantity)
UPDATE product
SET quantity = quantity - 2
WHERE id = 1; -- товар с id=1

-- 8. Изменение email клиента
UPDATE customer
SET email = 'new.email@example.com'
WHERE id = 2;

-- ==============================
-- DELETE (удаление) — 2 запроса
-- ==============================

-- 9. Удаление клиентов без заказов
DELETE FROM customer
WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);

-- 10. Удаление заказов со статусом CANCELLED
DELETE FROM orders
WHERE status_id = (SELECT id FROM order_status WHERE status_name = 'CANCELLED');
