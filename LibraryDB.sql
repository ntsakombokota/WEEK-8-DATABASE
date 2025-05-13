-- =============================================
-- LIBRARY MANAGEMENT SYSTEM DATABASE
-- =============================================
-- Created by: [Your Name]
-- Date: [Current Date]
-- Complete SQL file with schema, sample data, and all database objects
-- =============================================

-- =============================================
-- SECTION 1: DATABASE CREATION
-- =============================================

DROP DATABASE IF EXISTS LibraryDB;
CREATE DATABASE LibraryDB;
USE LibraryDB;

-- =============================================
-- SECTION 2: TABLE CREATION WITH CONSTRAINTS
-- =============================================

-- Publishers table
CREATE TABLE Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    established_date DATE,
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%')
) COMMENT 'Stores information about book publishers';

-- Authors table
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    CONSTRAINT full_name UNIQUE (first_name, last_name)
) COMMENT 'Contains details about book authors';

-- Categories table
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
) COMMENT 'Book genres/categories';

-- Books table
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publisher_id INT,
    publication_year INT,
    edition INT DEFAULT 1,
    pages INT,
    language VARCHAR(30),
    quantity INT NOT NULL DEFAULT 1,
    available_quantity INT NOT NULL DEFAULT 1,
    location VARCHAR(50),
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) 
        REFERENCES Publishers(publisher_id) ON DELETE SET NULL,
    CONSTRAINT chk_publication_year CHECK (publication_year BETWEEN 1000 AND YEAR(CURDATE())),
    CONSTRAINT chk_quantity CHECK (quantity >= 0 AND available_quantity >= 0 AND available_quantity <= quantity)
) COMMENT 'Main table storing all book information';

-- Book-Author relationship (Many-to-Many)
CREATE TABLE BookAuthors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id) 
        REFERENCES Books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id) 
        REFERENCES Authors(author_id) ON DELETE CASCADE
) COMMENT 'Junction table for book-author relationships';

-- Book-Category relationship (Many-to-Many)
CREATE TABLE BookCategories (
    book_id INT,
    category_id INT,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_bc_book FOREIGN KEY (book_id) 
        REFERENCES Books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_bc_category FOREIGN KEY (category_id) 
        REFERENCES Categories(category_id) ON DELETE CASCADE
) COMMENT 'Junction table for book-category relationships';

-- Members table
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(200),
    date_of_birth DATE,
    membership_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_expiry DATE,
    status ENUM('Active', 'Expired', 'Suspended') DEFAULT 'Active',
    CONSTRAINT chk_member_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_expiry CHECK (membership_expiry IS NULL OR membership_expiry > membership_date)
) COMMENT 'Library members/patrons information';

-- Loans table
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('On Loan', 'Returned', 'Overdue', 'Lost') DEFAULT 'On Loan',
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    CONSTRAINT fk_loan_book FOREIGN KEY (book_id) 
        REFERENCES Books(book_id) ON DELETE RESTRICT,
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) 
        REFERENCES Members(member_id) ON DELETE RESTRICT,
    CONSTRAINT chk_due_date CHECK (due_date > loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
) COMMENT 'Tracks book loans and returns';

-- Fines table
CREATE TABLE Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_date DATE,
    status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) 
        REFERENCES Loans(loan_id) ON DELETE CASCADE,
    CONSTRAINT chk_amount CHECK (amount >= 0),
    CONSTRAINT chk_payment_date CHECK (payment_date IS NULL OR payment_date >= issue_date)
) COMMENT 'Records fines associated with late returns';

-- Reservations table
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATETIME NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    CONSTRAINT fk_reservation_book FOREIGN KEY (book_id) 
        REFERENCES Books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_member FOREIGN KEY (member_id) 
        REFERENCES Members(member_id) ON DELETE CASCADE,
    CONSTRAINT chk_reservation_expiry CHECK (expiry_date > reservation_date)
) COMMENT 'Tracks book reservations by members';

-- =============================================
-- SECTION 3: INDEXES FOR PERFORMANCE
-- =============================================

CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_isbn ON Books(isbn);
CREATE INDEX idx_members_email ON Members(email);
CREATE INDEX idx_members_name ON Members(last_name, first_name);
CREATE INDEX idx_loans_dates ON Loans(loan_date, due_date, return_date);
CREATE INDEX idx_loans_status ON Loans(status);
CREATE INDEX idx_fines_status ON Fines(status);

-- =============================================
-- SECTION 4: SAMPLE DATA INSERTION
-- =============================================

-- Insert Publishers
INSERT INTO Publishers (name, address, phone, email, website, established_date) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com', '2013-07-01'),
('HarperCollins', '195 Broadway, New York, NY', '212-207-7000', 'contact@harpercollins.com', 'www.harpercollins.com', '1817-03-06'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com', '1924-01-02'),
('Macmillan', '120 Broadway, New York, NY', '646-307-5151', 'press@macmillan.com', 'www.macmillan.com', '1869-01-01'),
('Hachette Book Group', '1290 Avenue of the Americas, New York, NY', '212-364-1100', 'contact@hachettebookgroup.com', 'www.hachettebookgroup.com', '1837-01-01');

-- Insert Authors
INSERT INTO Authors (first_name, last_name, birth_date, nationality, biography) VALUES
('George', 'Orwell', '1903-06-25', 'British', 'Eric Arthur Blair, better known by his pen name George Orwell, was an English novelist, essayist, journalist, and critic.'),
('J.K.', 'Rowling', '1965-07-31', 'British', 'Joanne Rowling, best known by her pen name J.K. Rowling, is a British author and philanthropist.'),
('Stephen', 'King', '1947-09-21', 'American', 'Stephen Edwin King is an American author of horror, supernatural fiction, suspense, and fantasy novels.'),
('Agatha', 'Christie', '1890-09-15', 'British', 'Dame Agatha Mary Clarissa Christie was an English writer known for her detective novels.'),
('Ernest', 'Hemingway', '1899-07-21', 'American', 'Ernest Miller Hemingway was an American journalist, novelist, and short-story writer.');

-- Insert Categories
INSERT INTO Categories (name, description) VALUES
('Fiction', 'Imaginary stories and narratives'),
('Science Fiction', 'Fiction dealing with futuristic concepts, space travel, time travel, etc.'),
('Fantasy', 'Fiction involving magical or supernatural elements'),
('Mystery', 'Fiction dealing with the solution of a crime or puzzle'),
('Biography', 'Non-fiction account of a person''s life'),
('History', 'Non-fiction works about historical events'),
('Self-Help', 'Books designed to help readers solve personal problems');

-- Insert Books
INSERT INTO Books (title, isbn, publisher_id, publication_year, edition, pages, language, quantity, available_quantity, location) VALUES
('1984', '9780451524935', 1, 1949, 1, 328, 'English', 5, 5, 'A1'),
('Animal Farm', '9780451526342', 1, 1945, 1, 112, 'English', 3, 3, 'A2'),
('Harry Potter and the Philosopher''s Stone', '9780747532743', 2, 1997, 1, 223, 'English', 7, 7, 'B1'),
('The Shining', '9780307743657', 1, 1977, 1, 447, 'English', 4, 4, 'C3'),
('Murder on the Orient Express', '9780062073501', 2, 1934, 1, 256, 'English', 2, 2, 'D2'),
('The Old Man and the Sea', '9780684801223', 3, 1952, 1, 127, 'English', 3, 3, 'E4'),
('The Da Vinci Code', '9780307474278', 1, 2003, 1, 489, 'English', 6, 6, 'F1'),
('To Kill a Mockingbird', '9780061120084', 2, 1960, 1, 281, 'English', 4, 4, 'G2'),
('The Great Gatsby', '9780743273565', 3, 1925, 1, 180, 'English', 5, 5, 'H3'),
('Pride and Prejudice', '9780141439518', 4, 1813, 1, 279, 'English', 3, 3, 'I1');

-- Insert Book-Author relationships
INSERT INTO BookAuthors (book_id, author_id) VALUES
(1, 1), (2, 1), (3, 2), (4, 3), (5, 4), (6, 5);

-- Insert Book-Category relationships
INSERT INTO BookCategories (book_id, category_id) VALUES
(1, 1), (1, 2), (2, 1), (3, 3), (4, 1), (4, 3), (5, 4), (6, 1), (7, 1), (7, 4), (8, 1), (9, 1), (10, 1);

-- Insert 24 Members (exceeding 20-client requirement)
INSERT INTO Members (first_name, last_name, email, phone, address, date_of_birth, membership_date, membership_expiry, status) VALUES
('John', 'Smith', 'john.smith@email.com', '555-0101', '123 Main St, Anytown', '1985-03-15', '2022-01-10', '2024-01-10', 'Active'),
('Emily', 'Johnson', 'emily.j@email.com', '555-0102', '456 Oak Ave, Somewhere', '1990-07-22', '2022-02-15', '2024-02-15', 'Active'),
('Michael', 'Williams', 'michael.w@email.com', '555-0103', '789 Pine Rd, Nowhere', '1978-11-30', '2022-03-20', '2024-03-20', 'Active'),
('Sarah', 'Brown', 'sarah.b@email.com', '555-0104', '321 Elm St, Anycity', '1982-05-14', '2022-04-05', '2024-04-05', 'Active'),
('David', 'Jones', 'david.j@email.com', '555-0105', '654 Maple Dr, Yourtown', '1995-09-18', '2022-05-12', '2024-05-12', 'Active'),
('Jennifer', 'Garcia', 'jennifer.g@email.com', '555-0106', '987 Cedar Ln, Thistown', '1988-12-25', '2022-06-30', '2024-06-30', 'Active'),
('Robert', 'Miller', 'robert.m@email.com', '555-0107', '135 Birch Blvd, Mytown', '1975-04-05', '2022-07-15', '2024-07-15', 'Active'),
('Lisa', 'Davis', 'lisa.d@email.com', '555-0108', '246 Walnut Way, Ourcity', '1992-08-08', '2022-08-20', '2024-08-20', 'Active'),
('Thomas', 'Rodriguez', 'thomas.r@email.com', '555-0109', '369 Spruce Cir, Theirtown', '1980-01-30', '2022-09-10', '2024-09-10', 'Active'),
('Patricia', 'Martinez', 'patricia.m@email.com', '555-0110', '159 Oakwood Ave, Yourcity', '1972-06-12', '2022-10-05', '2024-10-05', 'Active'),
('James', 'Hernandez', 'james.h@email.com', '555-0111', '753 Willow St, Histown', '1998-03-03', '2022-11-15', '2024-11-15', 'Active'),
('Mary', 'Lopez', 'mary.l@email.com', '555-0112', '852 Aspen Dr, Hertown', '1987-07-19', '2022-12-01', '2024-12-01', 'Active'),
('William', 'Gonzalez', 'william.g@email.com', '555-0113', '147 Pinecone Ln, Mytown', '1979-10-22', '2023-01-10', '2025-01-10', 'Active'),
('Elizabeth', 'Wilson', 'elizabeth.w@email.com', '555-0114', '258 Chestnut Rd, Ourcity', '1993-02-14', '2023-02-14', '2025-02-14', 'Active'),
('Richard', 'Anderson', 'richard.a@email.com', '555-0115', '369 Redwood Blvd, Theirtown', '1968-09-09', '2023-03-20', '2025-03-20', 'Active'),
('Susan', 'Thomas', 'susan.t@email.com', '555-0116', '471 Magnolia Ave, Yourtown', '1974-04-30', '2023-04-05', '2025-04-05', 'Active'),
('Joseph', 'Taylor', 'joseph.t@email.com', '555-0117', '582 Sycamore St, Anytown', '1991-12-15', '2023-05-12', '2025-05-12', 'Active'),
('Nancy', 'Moore', 'nancy.m@email.com', '555-0118', '693 Juniper Dr, Somewhere', '1983-08-27', '2023-06-30', '2025-06-30', 'Active'),
('Charles', 'Jackson', 'charles.j@email.com', '555-0119', '714 Acorn Ln, Nowhere', '1977-05-18', '2023-07-15', '2025-07-15', 'Active'),
('Karen', 'Lee', 'karen.l@email.com', '555-0120', '825 Spruce St, Anycity', '1989-11-11', '2023-08-20', '2025-08-20', 'Active'),
('Daniel', 'Perez', 'daniel.p@email.com', '555-0121', '936 Birch Rd, Thistown', '1996-01-25', '2023-09-10', '2025-09-10', 'Active'),
('Jessica', 'White', 'jessica.w@email.com', '555-0122', '1047 Cedar Blvd, Mytown', '1981-07-07', '2023-10-05', '2025-10-05', 'Active'),
('Matthew', 'Harris', 'matthew.h@email.com', '555-0123', '1158 Walnut Cir, Ourcity', '1994-03-08', '2023-11-15', '2025-11-15', 'Active'),
('Betty', 'Clark', 'betty.c@email.com', '555-0124', '1269 Maple Way, Theirtown', '1965-10-31', '2023-12-01', '2025-12-01', 'Active');

-- Insert Loans
INSERT INTO Loans (book_id, member_id, loan_date, due_date, return_date, status) VALUES
(1, 1, '2023-01-15', '2023-01-29', '2023-01-28', 'Returned'),
(3, 2, '2023-02-10', '2023-02-24', NULL, 'On Loan'),
(5, 3, '2023-03-05', '2023-03-19', '2023-03-20', 'Returned'),
(7, 4, '2023-04-12', '2023-04-26', NULL, 'On Loan'),
(2, 5, '2023-05-20', '2023-06-03', '2023-06-02', 'Returned'),
(4, 6, '2023-06-15', '2023-06-29', NULL, 'On Loan'),
(6, 7, '2023-07-01', '2023-07-15', '2023-07-14', 'Returned'),
(8, 8, '2023-08-10', '2023-08-24', NULL, 'On Loan'),
(9, 9, '2023-09-05', '2023-09-19', '2023-09-18', 'Returned'),
(10, 10, '2023-10-12', '2023-10-26', NULL, 'On Loan');

-- Insert Fines
INSERT INTO Fines (loan_id, amount, issue_date, payment_date, status) VALUES
(3, 0.50, '2023-03-20', '2023-03-21', 'Paid'),
(5, 2.00, '2023-06-04', NULL, 'Pending');

-- Insert Reservations
INSERT INTO Reservations (book_id, member_id, reservation_date, expiry_date, status) VALUES
(1, 11, '2023-10-01 10:00:00', '2023-10-08 10:00:00', 'Fulfilled'),
(3, 12, '2023-10-15 14:30:00', '2023-10-22 14:30:00', 'Pending'),
(5, 13, '2023-11-01 09:15:00', '2023-11-08 09:15:00', 'Cancelled');

-- =============================================
-- SECTION 5: VIEWS
-- =============================================

-- View for currently available books
CREATE VIEW AvailableBooks AS
SELECT b.book_id, b.title, b.isbn, GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
       GROUP_CONCAT(DISTINCT c.name SEPARATOR ', ') AS categories, b.available_quantity
FROM Books b
LEFT JOIN BookAuthors ba ON b.book_id = ba.book_id
LEFT JOIN Authors a ON ba.author_id = a.author_id
LEFT JOIN BookCategories bc ON b.book_id = bc.book_id
LEFT JOIN Categories c ON bc.category_id = c.category_id
WHERE b.available_quantity > 0
GROUP BY b.book_id, b.title, b.isbn, b.available_quantity;

-- View for overdue loans
CREATE VIEW OverdueLoans AS
SELECT l.loan_id, l.book_id, b.title, l.member_id, 
       CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       l.loan_date, l.due_date, DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue,
       l.fine_amount
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id
WHERE l.status = 'On Loan' AND l.due_date < CURRENT_DATE;

-- =============================================
-- SECTION 6: STORED PROCEDURES
-- =============================================

-- Procedure for borrowing a book
DELIMITER //
CREATE PROCEDURE BorrowBook(
    IN p_book_id INT,
    IN p_member_id INT,
    IN p_loan_duration INT
)
BEGIN
    DECLARE v_available INT;
    DECLARE v_member_status VARCHAR(20);
    DECLARE v_current_loans INT;
    
    -- Check book availability
    SELECT available_quantity INTO v_available FROM Books WHERE book_id = p_book_id;
    
    -- Check member status
    SELECT status INTO v_member_status FROM Members WHERE member_id = p_member_id;
    
    -- Check how many books member currently has on loan
    SELECT COUNT(*) INTO v_current_loans FROM Loans 
    WHERE member_id = p_member_id AND status = 'On Loan';
    
    IF v_available <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is not available for loan';
    ELSEIF v_member_status != 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member account is not active';
    ELSEIF v_current_loans >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Member has reached maximum loan limit';
    ELSE
        -- Create the loan record
        INSERT INTO Loans (book_id, member_id, due_date)
        VALUES (p_book_id, p_member_id, DATE_ADD(CURRENT_DATE, INTERVAL p_loan_duration DAY));
        
        -- Update book availability
        UPDATE Books 
        SET available_quantity = available_quantity - 1 
        WHERE book_id = p_book_id;
        
        SELECT CONCAT('Book loan successful. Due date: ', DATE_ADD(CURRENT_DATE, INTERVAL p_loan_duration DAY)) AS message;
    END IF;
END //
DELIMITER ;

-- Procedure for returning a book
DELIMITER //
CREATE PROCEDURE ReturnBook(
    IN p_loan_id INT,
    IN p_book_condition VARCHAR(20) -- 'Good', 'Damaged', 'Lost'
)
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_days_overdue INT;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    -- Get loan details
    SELECT book_id, due_date, DATEDIFF(CURRENT_DATE, due_date)
    INTO v_book_id, v_due_date, v_days_overdue
    FROM Loans WHERE loan_id = p_loan_id AND status = 'On Loan';
    
    IF v_book_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan record not found or book already returned';
    ELSE
        -- Calculate fine if overdue
        IF v_days_overdue > 0 THEN
            SET v_fine_amount = v_days_overdue * 0.50; -- $0.50 per day fine
            INSERT INTO Fines (loan_id, amount)
            VALUES (p_loan_id, v_fine_amount);
        END IF;
        
        -- Update loan record
        UPDATE Loans
        SET return_date = CURRENT_DATE,
            status = CASE 
                WHEN p_book_condition = 'Lost' THEN 'Lost'
                ELSE 'Returned'
            END,
            fine_amount = CASE 
                WHEN v_days_overdue > 0 THEN v_fine_amount
                ELSE 0
            END
        WHERE loan_id = p_loan_id;
        
        -- Update book availability if not lost
        IF p_book_condition != 'Lost' THEN
            UPDATE Books
            SET available_quantity = available_quantity + 1
            WHERE book_id = v_book_id;
        END IF;
        
        SELECT CONCAT('Book returned successfully. ', 
               CASE WHEN v_days_overdue > 0 THEN CONCAT('Fine applied: $', v_fine_amount) 
               ELSE 'No fine applied' END) AS message;
    END IF;
END //
DELIMITER ;

-- =============================================
-- SECTION 7: TRIGGERS
-- =============================================

-- Trigger to update available quantity when a book is added
DELIMITER //
CREATE TRIGGER after_book_insert
AFTER INSERT ON Books
FOR EACH ROW
BEGIN
    -- Set available quantity to match quantity if not specified
    IF NEW.available_quantity IS NULL THEN
        UPDATE Books SET available_quantity = NEW.quantity WHERE book_id = NEW.book_id;
    END IF;
END //
DELIMITER ;

-- Trigger to prevent deletion of books with active loans
DELIMITER //
CREATE TRIGGER before_book_delete
BEFORE DELETE ON Books
FOR EACH ROW
BEGIN
    DECLARE v_active_loans INT;
    
    SELECT COUNT(*) INTO v_active_loans
    FROM Loans
    WHERE book_id = OLD.book_id AND status = 'On Loan';
    
    IF v_active_loans > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete book with active loans';
    END IF;
END //
DELIMITER ;

-- =============================================
-- SECTION 8: SCHEDULED EVENT
-- =============================================

-- Event to check for overdue books daily
DELIMITER //
CREATE EVENT check_overdue_books
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- Update status of overdue loans
    UPDATE Loans
    SET status = 'Overdue'
    WHERE status = 'On Loan' AND due_date < CURRENT_DATE;
    
    -- Update member status if they have too many overdue books
    UPDATE Members m
    JOIN (
        SELECT member_id, COUNT(*) AS overdue_count
        FROM Loans
        WHERE status = 'Overdue' AND due_date < CURRENT_DATE - INTERVAL 30 DAY
        GROUP BY member_id
    ) l ON m.member_id = l.member_id
    SET m.status = 'Suspended'
    WHERE l.overdue_count >= 3 AND m.status = 'Active';
END //
DELIMITER ;

-- =============================================
-- SECTION 9: FINAL VERIFICATION QUERIES
-- =============================================

-- Verify all tables were created with data
SELECT 
    TABLE_NAME, 
    TABLE_ROWS AS 'Row Count'
FROM 
    INFORMATION_SCHEMA.TABLES 
WHERE 
    TABLE_SCHEMA = 'LibraryDB';

-- Verify member count (should show 24)
SELECT COUNT(*) AS total_members FROM Members;

-- Verify sample loans
SELECT l.loan_id, b.title, CONCAT(m.first_name, ' ', m.last_name) AS member_name,
       l.loan_date, l.due_date, l.return_date, l.status
FROM Loans l
JOIN Books b ON l.book_id = b.book_id
JOIN Members m ON l.member_id = m.member_id
LIMIT 5;

-- =============================================
-- END OF LIBRARY MANAGEMENT SYSTEM DATABASE SCRIPT
-- =============================================
