-- ============================================================
-- Bookstore PL/SQL Demo
-- Step 3: RECORD + COLLECTION + GOTO Example
-- ============================================================

SET SERVEROUTPUT ON;

DECLARE
    -- =======================================
    -- 1. Define a RECORD type for one book
    -- =======================================
    TYPE book_rec IS RECORD (
        id            BOOK_SALES.BOOK_ID%TYPE,
        title         BOOK_SALES.BOOK_TITLE%TYPE,
        price         BOOK_SALES.UNIT_PRICE%TYPE,
        qty_sold      BOOK_SALES.QUANTITY_SOLD%TYPE
    );

    -- =======================================
    -- 2. Define a COLLECTION of the record
    -- =======================================
    TYPE book_table IS TABLE OF book_rec;
    book_list book_table;

    total_revenue NUMBER := 0;

BEGIN
    -- =======================================
    -- 3. Load data into the collection
    -- =======================================
    SELECT BOOK_ID, BOOK_TITLE, UNIT_PRICE, QUANTITY_SOLD
    BULK COLLECT INTO book_list
    FROM BOOK_SALES;

    DBMS_OUTPUT.PUT_LINE('--- Processing Bookstore Sales ---');

    -- =======================================
    -- 4. Loop through each record in collection
    -- =======================================
    FOR i IN 1 .. book_list.COUNT LOOP

        -- Check for high sales volume
        IF book_list(i).qty_sold > 20 THEN
            GOTO High_Sales_Section;
        END IF;

        -- Normal revenue calculation
        total_revenue := total_revenue + (book_list(i).price * book_list(i).qty_sold);
        DBMS_OUTPUT.PUT_LINE(
            'Normal Sale -> ' || book_list(i).title ||
            ' | Qty: ' || book_list(i).qty_sold ||
            ' | Revenue: ' || (book_list(i).price * book_list(i).qty_sold)
        );
        CONTINUE;

        -- =======================================
        -- GOTO destination for high sales
        -- =======================================
        <<High_Sales_Section>>
        total_revenue := total_revenue + (book_list(i).price * book_list(i).qty_sold * 1.15);
        DBMS_OUTPUT.PUT_LINE(
            'High Sale Bonus -> ' || book_list(i).title ||
            ' | Qty: ' || book_list(i).qty_sold ||
            ' | Revenue with Bonus: ' ||
            (book_list(i).price * book_list(i).qty_sold * 1.15)
        );

    END LOOP;

    -- =======================================
    -- 5. Display final revenue
    -- =======================================
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Store Revenue: ' || total_revenue);

END;
/
