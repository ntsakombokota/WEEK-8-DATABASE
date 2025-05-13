# 📚 Library Management System (MySQL Project)

## 📝 Project Description

This is a relational database project for managing a library system. It includes core functionalities for managing books, members, authors, categories, loans, fines, and reservations. The database is designed using MySQL and incorporates data integrity constraints, normalization principles, sample data, and indexing for optimized query performance.

---

## 🗂️ Database Structure

### 1. **Tables**

| Table Name        | Description |
|-------------------|-------------|
| `Books`           | Stores details about books including title, ISBN, publication date, quantity, and availability. |
| `Authors`         | Contains author profiles. |
| `BookAuthors`     | Associates books with their authors (Many-to-Many). |
| `Categories`      | Stores categories for classifying books. |
| `BookCategories`  | Associates books with categories (Many-to-Many). |
| `Members`         | Stores member information. |
| `Loans`           | Tracks book loans including due dates, return dates, and loan status. |
| `Fines`           | Records fines imposed on members for overdue returns. |
| `Reservations`    | Manages book reservations with expiry control. |

---

## 🧱 Relationships

- **Books ↔ Authors**: Many-to-Many via `BookAuthors`
- **Books ↔ Categories**: Many-to-Many via `BookCategories`
- **Books ↔ Loans**: One-to-Many
- **Members ↔ Loans**: One-to-Many
- **Loans ↔ Fines**: One-to-One
- **Members ↔ Reservations**: One-to-Many
- **Books ↔ Reservations**: One-to-Many

---

## 🔐 Constraints & Features

- **Primary & Foreign Keys**: Enforced on all relationships.
- **CHECK Constraints**: Ensure data validity for fields like quantity and status.
- **ENUM Data Types**: Used for loan statuses (`Borrowed`, `Returned`, `Overdue`).
- **NOT NULL**: Critical fields require data input.
- **UNIQUE**: Applied to fields like ISBN and email.
- **DEFAULT Values**: Automatically set loan and fine statuses.

---

## 📊 Sample Data

- 25+ members with realistic personal data
- 10+ books linked to authors and categories
- Sample loans with status and return data
- Sample fines and reservations for testing

---

## 🧩 Indexes

Indexes are created on key columns to improve performance:
- `book_id`, `member_id`, `isbn`, `email`, etc.

---

```sql
SOURCE path/to/LibraryDB.sql;
# WEEK-8-DATABASE
