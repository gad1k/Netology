select product_line_name, count(*)
  from (select io.act_date,
               io.invoice_tag, 
               ai.branch, 
               ai.city, 
               ai.customer_type, 
               ai.gender, 
               pl.product_line_name, 
               io.unit_price, 
               io.quantity,
               pt.payment_type_name, 
               io.cogs, 
               io.tax_5, 
               io.total, 
               io.gross_margin_percent,
               io.gross_income
          from FT_ITEM_ORDERS io
          join DIM_ADD_INFO ai
            on io.add_info_sk = ai.add_info_sk
          join DIM_PAYMENT_TYPES pt
            on io.payment_type_sk = pt.payment_type_sk
          join DIM_PRODUCT_LINES pl
            on io.product_line_sk = pl.product_line_sk
         order by item_order_sk)
 group by product_line_name;