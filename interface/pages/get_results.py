import streamlit as st
import pandas as pd
import plotly.express as px
import os
import clickhouse_connect

CLICKHOUSE_CONFIG = {
    "username": os.getenv("CLICKHOUSE_USERNAME", "click"),
    "password": os.getenv("CLICKHOUSE_PASSWORD", "click"),
    "host": os.getenv("CLICKHOUSE_HOST", "clickhouse"),
    "port": os.getenv("CLICKHOUSE_PORT", "8123")
}

RESULT_COLUMNS = ["transaction_id", "score", "fraud_flag"]

class DBReader:
    def __init__(self):
        self.client = clickhouse_connect.get_client(**CLICKHOUSE_CONFIG)
    
    def get_largest_transaction_category(self):
        column_names = ['us_state', 'cat_id']
        try:
            with open('/app/queries/query_task.sql', 'r', encoding='utf-8') as f:
                query = f.read()
            result = self.client.query(query)
            df = pd.DataFrame(result.result_rows, columns=column_names)
            return df

        except Exception as e:
            st.error(f'Error while collecting data: {str(e)}')
            return pd.DataFrame([], columns=column_names)


@st.cache_resource
def get_reader() -> DBReader:
    return DBReader()

st.title("Statistics")
if st.button('Show results'):
    reader = get_reader()

    st.divider()

    st.subheader("Largest category of transactions by state")

    largest_category_per_state = reader.get_largest_transaction_category()
    largest_category_per_state.to_csv('/app/results/largest_category_per_state.csv')
    st.dataframe(
        largest_category_per_state,
        width='stretch',
        hide_index=True,
    )

