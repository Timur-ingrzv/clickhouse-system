import streamlit as st

st.set_page_config(
    page_title="Clickhouse process",
    page_icon=":chart_with_upwards_trend:",
    layout="wide",
)

# Make pages
upload_page = st.Page(
    "pages/upload_file.py",
    title="Uploading",
    icon=":material/dashboard:",
    default=True,
)

results_page = st.Page(
    "pages/get_results.py",
    title="Monitoring",
    icon=":material/analytics:",
)

pg = st.navigation(
    [upload_page, results_page],
    position="hidden",
)

with st.sidebar:
    st.title("Clickhouse process", icon=":material/shield:")
    st.caption("Interface for communication with clickhouse")

    st.divider()

    st.markdown("### Navigation")

    st.page_link(
        upload_page,
        label="Uploading files",
        icon=":material/dashboard:",
    )

    st.page_link(
            results_page,
            label="Show results",
            icon=":material/analytics:",
        )

pg.run()