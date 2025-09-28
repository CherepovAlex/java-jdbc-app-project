package com.innopolis;

import org.flywaydb.core.Flyway;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

public class App {

    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;

    public static void main(String[] args) {
        loadProperties();
        runMigrations();

        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            connection.setAutoCommit(false); // работа через транзакции
            try {
                // 1а. вставка нового товара
                int newProductId = insertProduct(connection, "Test Product", 99.99, 10,
                        "TestCategory");

                // 1б. вставка нового покупателя
                int newCustomerId = insertCustomer(connection, "Test User", "User",
                        "+79451234578", "test.user@example.com");

                // 2. создание заказа
                int newOrderId = insertOrder(connection, newProductId, newCustomerId, 2, 1);

                // 3. чтение последних 5 заказов
                printLastOrders(connection, 5);

                // 4. обновление цены товара и количества на складе
                updateProduct(connection, newProductId, 89.99, 8);

                // 5. удаление тестовых записей
                deleteOrder(connection, newOrderId);
                deleteCustomer(connection, newCustomerId);
                deleteProduct(connection, newProductId);

                connection.commit();
                System.out.printf("\nAll operations completed successfully and added in DB.");

            } catch (SQLException e) {
                connection.rollback();
                System.err.println("Error. Running rollback transaction: " + e.getMessage());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // метод добавления нового товара
    private static int insertProduct(Connection connection, String description, double price, int quantity,
                                     String category) throws SQLException {
        String sql = "INSERT INTO product (description, price, quantity, category) VALUES (?, ?, ?, ?) RETURNING id";
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, description);
            preparedStatement.setDouble(2, price);
            preparedStatement.setInt(3, quantity);
            preparedStatement.setString(4, category);

            ResultSet resultSet = preparedStatement.executeQuery();
            resultSet.next();
            int id = resultSet.getInt(1);
            System.out.println("Add product: " + description + " (ID=" + id + ")");
            return id;
        }
    }

    // метод добавления нового покупателя
    private static int insertCustomer(Connection connection, String firstName, String lastName, String phone,
                                      String email) throws SQLException {
        String sql = "INSERT INTO customer (first_name, last_name, phone, email) VALUES (?, ?, ?, ?) RETURNING id";
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, firstName);
            preparedStatement.setString(2, lastName);
            preparedStatement.setString(3, phone);
            preparedStatement.setString(4, email);

            ResultSet resultSet = preparedStatement.executeQuery();
            resultSet.next();
            int id = resultSet.getInt(1);
            System.out.println("Add customer: " + firstName + " " + lastName + " (ID=" + id + ")");
            return id;
        }
    }

    // метод добавления нового заказа
    private static int insertOrder(Connection connection, int productId, int customerId, int quantity, int statusId)
            throws SQLException {
        String sql = "INSERT INTO orders (product_id, customer_id, quantity, status_id) VALUES (?, ?, ?, ?) RETURNING id";
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, productId);
            preparedStatement.setInt(2, customerId);
            preparedStatement.setInt(3, quantity);
            preparedStatement.setInt(4, statusId);

            ResultSet resultSet = preparedStatement.executeQuery();
            resultSet.next();
            int id = resultSet.getInt(1);
            System.out.println("Created order (ID=" + id + ") для клиента ID=" + customerId);
            return id;
        }
    }

    // метод чтения последних заказов
    private static void printLastOrders(Connection connection, int limit) throws SQLException {
        String sql = """
                SELECT o.id, c.first_name || ' ' || c.last_name AS customer_name,
                       p.description AS product_name, o.quantity, o.order_date, os.status_name
                FROM orders o
                JOIN customer c ON o.customer_id = c.id
                JOIN product p ON o.product_id = p.id
                JOIN order_status os ON o.status_id = os.id
                ORDER BY o.order_date DESC
                LIMIT ?
                """;
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, limit);
            ResultSet resultSet = preparedStatement.executeQuery();
            System.out.println("\nLast " + limit + " orders:");
            while ((resultSet.next())) {
                System.out.printf("ID=%d | Customer=%s | Product=%s | Quantity=%d | Date=%s | Status=%s%n",
                        resultSet.getInt("id"),
                        resultSet.getString("customer_name"),
                        resultSet.getString("product_name"),
                        resultSet.getInt("quantity"),
                        resultSet.getTimestamp("order_date"),
                        resultSet.getString("status_name"));
            }
        }
    }

    // метод обновления цены товара и количества на складе
    private static void updateProduct(Connection connection, int productId, double newPrice, int newQuantity)
            throws SQLException {
        String sql = "UPDATE product SET price = ?, quantity = ? WHERE id = ?";
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setDouble(1, newPrice);
            preparedStatement.setInt(2, newQuantity);
            preparedStatement.setInt(3, productId);
            int rows = preparedStatement.executeUpdate();
            System.out.println("Updated product ID=" + productId + " (" + rows + " lines updated)");
        }
    }

    // метод удаления заказов
    private static void deleteOrder(Connection connection, int orderId) throws SQLException {
        String sql = "DELETE FROM orders WHERE id = ?";
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, orderId);
            int rows = preparedStatement.executeUpdate();
            System.out.println("Deleted order ID=" + orderId + " (" + rows + " lines deleted)");
        }
    }

    // метод удаления клиентов
    private static void deleteCustomer(Connection connection, int customerId) throws SQLException {
        String sql = "DELETE FROM customer WHERE id= ?";
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, customerId);
            int rows = preparedStatement.executeUpdate();
            System.out.println("Deleted client ID=" + customerId + " (" + rows + " lines deleted");
        }
    }

    // метод удаления продукта
    private static void deleteProduct(Connection connection, int productId) throws SQLException {
        String sql = "DELETE FROM product WHERE id = ?";
        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, productId); // пример для тестового продукта
            int rows = preparedStatement.executeUpdate();
            System.out.println("Deleted product ID=" + productId + " (" + rows + " lines deleted)");
        }
    }

    // загрузка параметров из application.properties
    private static void loadProperties() {
        try (InputStream inputStream = App.class.getClassLoader().getResourceAsStream("application.properties")) {
            Properties properties = new Properties();
            properties.load(inputStream);
            DB_URL = properties.getProperty("db.url");
            DB_USER = properties.getProperty("db.user");
            DB_PASSWORD = properties.getProperty("db.password");
        } catch (IOException e) {
            throw new RuntimeException("Error loading application.properties", e);
        }
    }

    // загрузка миграций
    private static void runMigrations() {
        Flyway flyway = Flyway.configure()
                .dataSource(DB_URL, DB_USER, DB_PASSWORD)
                .load();
        flyway.migrate();
        System.out.println("Migration Flyway completed successfully.");
    }
}
