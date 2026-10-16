PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS OrderStatusHistory;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Role;

CREATE TABLE Role (
    RoleID INTEGER PRIMARY KEY AUTOINCREMENT,
    name   TEXT NOT NULL UNIQUE
);

CREATE TABLE Users (
    UserID       INTEGER PRIMARY KEY AUTOINCREMENT,
    login        TEXT NOT NULL UNIQUE,
    passwordHash TEXT NOT NULL,
    RoleID       INTEGER NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

CREATE TABLE Products (
    ProductID INTEGER PRIMARY KEY AUTOINCREMENT,
    name      TEXT NOT NULL,
    price     REAL NOT NULL CHECK (price >= 0),
    stock     INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

-- Заказ: UserID - покупатель, ManagerID - менеджер, взявший заказ в работу
CREATE TABLE Orders (
    OrderID       INTEGER PRIMARY KEY AUTOINCREMENT,
    UserID        INTEGER NOT NULL,
    ManagerID     INTEGER,
    address       TEXT NOT NULL,
    paymentMethod TEXT NOT NULL
                  CHECK (paymentMethod IN ('Картой онлайн', 'Картой при получении', 'Наличными')),
    status        TEXT NOT NULL DEFAULT 'Новый'
                  CHECK (status IN ('Новый', 'В обработке', 'Отправлен', 'Доставлен', 'Отменён')),
    createdAt     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID)    REFERENCES Users(UserID),
    FOREIGN KEY (ManagerID) REFERENCES Users(UserID)
);

-- Состав заказа; price - цена товара на момент оформления
CREATE TABLE OrderItems (
    OrderItemID INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID     INTEGER NOT NULL,
    ProductID   INTEGER NOT NULL,
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    price       REAL NOT NULL CHECK (price >= 0),
    FOREIGN KEY (OrderID)   REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE OrderStatusHistory (
    HistoryID INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID   INTEGER NOT NULL,
    UserID    INTEGER NOT NULL,
    status    TEXT NOT NULL,
    date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    comment   TEXT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (UserID)  REFERENCES Users(UserID)
);

-- Один отзыв на заказ
CREATE TABLE Review (
    ReviewID INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID  INTEGER NOT NULL UNIQUE,
    UserID   INTEGER NOT NULL,
    rating   INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    text     TEXT,
    date     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (UserID)  REFERENCES Users(UserID)
);


INSERT INTO Role (name) VALUES
    ('Покупатель'),
    ('Менеджер');

INSERT INTO Users (login, passwordHash, RoleID) VALUES
    ('ivanov',  'hash_1', 1),
    ('petrova', 'hash_2', 1),
    ('sidorov', 'hash_3', 2),
    ('kuznetsova', 'hash_4', 2);

INSERT INTO Products (name, price, stock) VALUES
    ('Наушники беспроводные', 3490.00, 25),
    ('Чехол для телефона',     590.00, 80),
    ('Powerbank 10000 мАч',   1790.00, 40),
    ('Клавиатура механическая', 5200.00, 12),
    ('Коврик для мыши',        450.00, 60);

INSERT INTO Orders (UserID, ManagerID, address, paymentMethod, status, createdAt) VALUES
    (1, 3,    'г. Москва, ул. Ленина, д. 5, кв. 12',  'Картой онлайн',        'Доставлен', '2026-10-10 09:00:00'),
    (2, 3,    'г. Казань, ул. Баумана, д. 20, кв. 7', 'Наличными',            'Отправлен', '2026-10-12 13:30:00'),
    (1, NULL, 'г. Москва, ул. Ленина, д. 5, кв. 12',  'Картой при получении', 'Новый',     '2026-10-15 18:45:00'),
    (2, NULL, 'г. Казань, ул. Баумана, д. 20, кв. 7', 'Картой онлайн',        'Отменён',   '2026-10-14 10:10:00');

INSERT INTO OrderItems (OrderID, ProductID, quantity, price) VALUES
    (1, 1, 1, 3490.00),
    (1, 2, 2,  590.00),
    (2, 4, 1, 5200.00),
    (2, 5, 1,  450.00),
    (3, 3, 2, 1790.00),
    (4, 2, 1,  590.00);

INSERT INTO OrderStatusHistory (OrderID, UserID, status, date, comment) VALUES
    (1, 1, 'Новый',       '2026-10-10 09:00:00', 'Заказ оформлен'),
    (1, 3, 'В обработке', '2026-10-10 12:00:00', 'Заказ взят в работу'),
    (1, 3, 'Отправлен',   '2026-10-11 10:00:00', 'Передан в службу доставки'),
    (1, 3, 'Доставлен',   '2026-10-13 15:00:00', 'Вручён покупателю'),
    (2, 2, 'Новый',       '2026-10-12 13:30:00', 'Заказ оформлен'),
    (2, 3, 'В обработке', '2026-10-12 15:00:00', 'Заказ взят в работу'),
    (2, 3, 'Отправлен',   '2026-10-14 11:00:00', 'Передан в службу доставки'),
    (3, 1, 'Новый',       '2026-10-15 18:45:00', 'Заказ оформлен'),
    (4, 2, 'Новый',       '2026-10-14 10:10:00', 'Заказ оформлен'),
    (4, 2, 'Отменён',     '2026-10-14 10:40:00', 'Отменён покупателем до отправки');


INSERT INTO Review (OrderID, UserID, rating, text, date) VALUES
    (1, 1, 5, 'Всё пришло быстро, наушники отличные', '2026-10-14 12:00:00');
