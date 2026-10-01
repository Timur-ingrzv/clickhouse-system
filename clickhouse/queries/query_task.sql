SELECT 
    us_state, 
    cat_id
FROM (
    SELECT 
        us_state,
        cat_id, 
        row_number() OVER (PARTITION BY us_state ORDER BY sum(amount)) as rank
    FROM transactions_store.transactions
    GROUP BY cat_id, us_state
) 
WHERE rank = 1
ORDER BY us_state;