-- Создание таблиц для учета заказов
-- Автор: студент курса Java Черепов Александр (итоговая аттестация)
-- Дата: 2025-09-28

-- Таблица: категории статусов заказов
CREATE TABLE IF NOT EXISTS order_status (
    id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE
);

COMMENT ON TABLE order_status IS 'Справочник статусов заказов';
COMMENT ON COLUMN order_status.id IS 'Уникальный идентификатор статуса';
COMMENT ON COLUMN order_status.status_name IS 'Название статуса (например, NEW, PAID, SHIPPED)';

-- Таблица: товары
CREATE TABLE IF NOT EXISTS product (
    id SERIAL PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    quantity INT NOT NULL CHECK (quantity >= 0),
    category VARCHAR(100) NOT NULL
);

COMMENT ON TABLE product IS 'Товары';
COMMENT ON COLUMN product.id IS 'Уникальный идентификатор товара';
COMMENT ON COLUMN product.price IS 'Стоимость товара (>= 0)';
COMMENT ON COLUMN product.quantity IS 'Количество товара на складе';

-- Таблица: клиенты
CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

COMMENT ON TABLE customer IS 'Клиенты';
COMMENT ON COLUMN customer.id IS 'Уникальный идентификатор клиента';

-- Таблица: заказы
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quantity INT NOT NULL CHECK (quantity > 0),
    status_id INT NOT NULL,

    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES product(id),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customer(id),
    CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES order_status(id)
);

COMMENT ON TABLE orders IS 'Заказы';
COMMENT ON COLUMN orders.id IS 'Уникальный идентификатор заказа';
COMMENT ON COLUMN orders.order_date IS 'Дата и время заказа';

-- Индексы
CREATE INDEX IF NOT EXISTS idx_orders_product ON orders(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status_id);

-- Тестовые данные
INSERT INTO order_status (status_name) VALUES
    ('NEW'),
    ('PAID'),
    ('SHIPPED'),
    ('CANCELLED')
ON CONFLICT DO NOTHING;

INSERT INTO product (description, price, quantity, category) VALUES
    ('Laptop Lenovo ThinkPad', 1200.00, 10, 'Electronics'),
    ('iPhone 15 Pro', 1500.00, 5, 'Electronics'),
    ('Office Chair', 250.00, 20, 'Furniture'),
    ('Gaming Mouse', 80.00, 50, 'Electronics');

INSERT INTO customer (first_name, last_name, phone, email) VALUES
    ('John', 'Doe', '+123456789', 'john.doe@example.com'),
    ('Alice', 'Smith', '+987654321', 'alice.smith@example.com'),
    ('Bob', 'Brown', '+112233445', 'bob.brown@example.com');

INSERT INTO orders (product_id, customer_id, quantity, status_id)
VALUES
    (1, 1, 1, 1), -- заказ ноутбука Джоном (NEW)
    (2, 2, 1, 2), -- заказ iPhone Элис (PAID)
    (3, 3, 2, 3); -- заказ кресла Бобом (SHIPPED)
