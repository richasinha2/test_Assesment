/*Minimal Oracle 19c and above.
● Construct your example with Customers and Products relationships.
● Customers fields (but not limited to, can have more relevant fields): First_Name,
Last_Name,
● Email (Office, Personal), Family Members.
● Products fields (but not limited to, can have more relevant fields): Book_Title,
Book_Price, Book_Quantity*/

CREATE TABLE Customers (
  Customer_ID NUMBER,
  First_Name VARCHAR2(50) NOT NULL,
  Last_Name VARCHAR2(50) NOT NULL,
  Email_Office VARCHAR2(100) NOT NULL UNIQUE,
  Email_Personal VARCHAR2(100),
  Family_Members VARCHAR2(200),
  PRIMARY KEY(Customer_ID)
);
CREATE TABLE Products (
  Product_ID NUMBER,
  Book_Title VARCHAR2(150) NOT NULL,
  Book_Price NUMBER(10, 2) NOT NULL CHECK (Book_Price > 0),
  Book_Quantity NUMBER NOT NULL CHECK (Book_Quantity >= 0) ,
  PRIMARY KEY(Product_ID)
);

Able to demonstrate how Indexing works.
Indexes improve query performance for frequently queried columns
CREATE INDEX idx_email_office ON Customers (Email_Office);
CREATE INDEX idx_book_title ON Products (Book_Title);

/* Able to demonstrate the right Transaction Management*/

--In the below example I have demonstrated transaction management in the PL/SQL block by performing multiple operations within a transaction, and rolling back if any operation fails :

DECLARE
  v_customer_id NUMBER;
  v_product_id NUMBER;
BEGIN
-- Start the transaction by inserting customer data
  INSERT INTO Customers
  (First_Name, Last_Name, Email_Office, Email_Personal, Family_Members)
  VALUES
  ('richa','sinha', 'richa.sinha@example.com', 'richa.sinha.personal@example.com','rishu');
  
  SELECT Customer_ID
  INTO v_customer_id
  FROM Customers
  WHERE Email_Office ='richa.sinha@example.com';
  -- Inserting product data for the customer
  INSERT INTO Products
  (Book_Title, Book_Price, Book_Quantity)
  VALUES
  ('k','Introduction to PL/SQL', 49.99, 100);
  SELECT Product_ID
  INTO v_product_id
  FROM Products
  WHERE Book_Title = 'plsql_book';
  -- Ensuring data integrity by checking if product quantity is valid
  IF (SELECT Book_Quantity FROM Products WHERE Product_ID = v_product_id)< 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Product quantity cannot be negative');
  END IF;
-- If all is well, commit the transaction
COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE;

END;

/*Able to demonstrate field validation and other exception handling.*/

-- Field validation is demonstrated in the Book_Price and Book_Quantity constraints in the table definitions
--Exception handling is demonstrated when trying to insert invalid data, such as a negative product quantity.


IF v_product_price <= 0 THEN
  RAISE_APPLICATION_ERROR(-20002, 'Price must be greater than zero');
END IF;
-- Example of exception handling for invalid data
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No data found');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error: ' || SQLERRM);
END;


/*Able to demonstrate in safeguarding sensitive data and preventing SQL Injection.*/


--To safeguard sensitive data and prevent SQL injection, avoid using dynamic SQL and also we can use bind variables in dynamic SQL.

DECLARE
  v_email VARCHAR2(100) := 'richa.sinha@example.com';
  v_sql VARCHAR2(500);
BEGIN
  v_sql := 'SELECT Customer_ID
            FROM Customers
            WHERE Email_Office = :email';
  EXECUTE IMMEDIATE v_sql USING v_email;
END;

/*Able to demonstrate Scheduling */


BEGIN
-- Create a scheduled job to update product quantity every day at midnight

  
  DBMS_SCHEDULER.create_job (
    job_name => 'update_product_quantity', -- Name of the job
    job_type => 'PLSQL_BLOCK', -- Type of job (PL/SQL code block)
    job_action => 'BEGIN UPDATE Products
                          SET Book_Quantity = Book_Quantity - 1
                          WHERE Product_ID = 1;
                    END', -- PL/SQL code to run

    start_date => SYSTIMESTAMP, -- When to start the job (immediately)
    enabled => TRUE -- Enable the job
  );
END;

/*You may have Caching and Bulk Processing*/


DECLARE
  TYPE ProductID_Array IS TABLE OF NUMBER;
  TYPE Price_Array IS TABLE OF NUMBER;
  TYPE Quantity_Array IS TABLE OF NUMBER;
  v_product_ids ProductID_Array := ProductID_Array(1, 2, 3);
  v_prices Price_Array := Price_Array(50.99, 79.99, 30.49);
  v_quantities Quantity_Array := Quantity_Array(200, 150, 300);
BEGIN
  FORALL i IN 1..v_product_ids.COUNT
  UPDATE Products
  SET Book_Price = v_prices(i),
      Book_Quantity = v_quantities(i)
  WHERE Product_ID = v_product_ids(i);
END;

/*You may have dedicated Oracle Services with specific Goal settings for your PLSQL block*/


BEGIN
  DBMS_SERVICE.create_service(
  service_name => 'high_priority_orders', -- Name of the service
  network_name => 'high_priority', -- Network name for the service
  goal => 'HIGH', -- Goal setting for the service (e.g., High priority)
  cardinality => 'DEDICATED' -- Ensures dedicated resources are
  allocated );
END;

BEGIN
-- Start a session and assign it the 'high_priority_orders' service
  DBMS_SESSION.set_service('high_priority_orders');
-- Now PL/SQL block for orders will use this dedicated service
  BEGIN
-- Example PL/SQL block to process orders
    UPDATE Products
    SET Book_Quantity = Book_Quantity - 1
    WHERE Product_ID = 1;
  END;
END;



