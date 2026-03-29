import anthropic
import streamlit as st
import plotly.express as px
from db import run_query
import uuid
from datetime import datetime

CLAUDE_API_KEY = st.secrets["CLAUDE_API_KEY"]

st.set_page_config(page_title="Decision Intelligence Platform", layout="wide")
st.title("Closed Loop Decision Intelligence Platform")
st.markdown("### Olist Ecommerce Analytics")

tab1, tab2, tab3, tab4, tab5, tab6 = st.tabs(["Revenue", "Delivery", "Sellers", "Decisions", "Outcomes", "AI Insights"])

with tab1:
    st.subheader("Revenue by Category")
    df = run_query("SELECT * FROM analytics.mv_revenue_by_category ORDER BY total_revenue DESC LIMIT 15")
    fig = px.bar(df, x="product_category_name_english", y="total_revenue", color="total_orders", title="Revenue by Category")
    st.plotly_chart(fig, use_container_width=True)

    st.subheader("Revenue by State")
    df2 = run_query("SELECT * FROM analytics.mv_revenue_by_state ORDER BY total_revenue DESC")
    fig2 = px.bar(df2, x="customer_state", y="total_revenue", color="avg_review_score", title="Revenue by State")
    st.plotly_chart(fig2, use_container_width=True)

    st.subheader("Monthly Revenue Trend")
    df3 = run_query("SELECT * FROM analytics.mv_monthly_revenue ORDER BY month")
    fig3 = px.line(df3, x="month", y="total_revenue", title="Monthly Revenue")
    st.plotly_chart(fig3, use_container_width=True)

with tab2:
    st.subheader("Delivery Performance by State")
    df4 = run_query("SELECT * FROM analytics.mv_delivery_performance ORDER BY avg_delivery_days DESC")
    fig4 = px.bar(df4, x="customer_state", y="avg_delivery_days", color="delivered_late", title="Avg Delivery Days by State")
    st.plotly_chart(fig4, use_container_width=True)

    col1, col2 = st.columns(2)
    with col1:
        total_late = df4["delivered_late"].sum()
        st.metric("Total Late Deliveries", int(total_late))
    with col2:
        total_early = df4["delivered_early"].sum()
        st.metric("Total Early Deliveries", int(total_early))

with tab3:
    st.subheader("Seller Performance by State")
    df5 = run_query("SELECT * FROM analytics.mv_seller_performance ORDER BY total_revenue DESC")
    fig5 = px.bar(df5, x="seller_state", y="total_revenue", color="total_sellers", title="Revenue by Seller State")
    st.plotly_chart(fig5, use_container_width=True)

with tab4:
    st.subheader("Log a Decision")
    st.markdown("When you see an insight in the dashboard, log what decision you made here.")

    with st.form("decision_form"):
        insight = st.text_area("What insight did you see?", placeholder="e.g. Health beauty category revenue dropped 15% in SP state")
        decision = st.text_area("What decision did you make?", placeholder="e.g. Launch promotion campaign for SP customers in health beauty")
        owner = st.text_input("Owner name", placeholder="e.g. Vivek")
        deadline = st.date_input("Deadline")
        submitted = st.form_submit_button("Log Decision")

        if submitted:
            from db import get_connection
            conn = get_connection()
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO analytics.fct_decisions 
                (decision_id, insight_text, decision_text, owner_name, created_at)
                VALUES (%s, %s, %s, %s, %s)
            """, (str(uuid.uuid4()), insight, decision, owner, datetime.now()))
            conn.commit()
            conn.close()
            st.success("Decision logged successfully!")

    st.subheader("All Logged Decisions")
    df6 = run_query("SELECT * FROM analytics.fct_decisions ORDER BY created_at DESC")
    st.dataframe(df6)

with tab5:
    st.subheader("Log an Outcome")
    st.markdown("Come back at 30, 60 or 90 days and log what actually happened after your decision.")

    decisions_df = run_query("SELECT decision_id, decision_text, owner_name, created_at FROM analytics.fct_decisions ORDER BY created_at DESC")

    if len(decisions_df) == 0:
        st.warning("No decisions logged yet. Go to Decisions tab and log a decision first.")
    else:
        with st.form("outcome_form"):
            decision_options = decisions_df["decision_text"].tolist()
            selected_decision = st.selectbox("Which decision are you tracking outcome for?", decision_options)
            day_marker = st.selectbox("Measurement period", [30, 60, 90])
            revenue_impact = st.number_input("Revenue impact ($)", min_value=0.0, step=100.0)
            accounts_saved = st.number_input("Accounts/customers saved or retained", min_value=0, step=1)
            notes = st.text_area("Notes", placeholder="e.g. Campaign worked well, 8 of 47 accounts retained")
            outcome_submitted = st.form_submit_button("Log Outcome")

            if outcome_submitted:
                selected_row = decisions_df[decisions_df["decision_text"] == selected_decision].iloc[0]
                decision_id = selected_row["decision_id"]
                from db import get_connection
                conn = get_connection()
                cur = conn.cursor()
                cur.execute("""
                    INSERT INTO analytics.fct_outcomes
                    (outcome_id, decision_id, measured_at, day_marker, revenue_impact, accounts_saved, notes)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (str(uuid.uuid4()), decision_id, datetime.now(), day_marker, revenue_impact, accounts_saved, notes))
                conn.commit()
                conn.close()
                st.success("Outcome logged successfully!")

        st.subheader("All Logged Outcomes")
        df7 = run_query("""
            SELECT 
                o.outcome_id,
                d.decision_text,
                d.owner_name,
                o.day_marker,
                o.revenue_impact,
                o.accounts_saved,
                o.notes,
                o.measured_at
            FROM analytics.fct_outcomes o
            JOIN analytics.fct_decisions d ON o.decision_id = d.decision_id
            ORDER BY o.measured_at DESC
        """)
        st.dataframe(df7)

with tab6:
    st.subheader("AI Insights — Powered by Claude")
    st.markdown("Claude analyses your decisions and outcomes and tells you what is working.")

    if st.button("Generate AI Insights"):
        decisions_data = run_query("SELECT * FROM analytics.fct_decisions ORDER BY created_at DESC")
        outcomes_data = run_query("SELECT * FROM analytics.fct_outcomes ORDER BY measured_at DESC")
        revenue_data = run_query("SELECT * FROM analytics.mv_revenue_by_category ORDER BY total_revenue DESC LIMIT 5")

        prompt = f"""
        You are a business analytics assistant. Analyse this ecommerce data and give clear business insights.

        Top 5 revenue categories:
        {revenue_data.to_string()}

        Decisions logged by the team:
        {decisions_data.to_string()}

        Outcomes measured:
        {outcomes_data.to_string()}

        Give me:
        1. What is working well based on decisions and outcomes
        2. What needs attention
        3. What decisions should be made next
        Keep it short, clear and actionable. Max 200 words.
        """

        client = anthropic.Anthropic(api_key=CLAUDE_API_KEY)

        with st.spinner("Claude is analysing your data..."):
            message = client.messages.create(
                model="claude-opus-4-6",
                max_tokens=1024,
                messages=[{"role": "user", "content": prompt}]
            )
            insight = message.content[0].text
            st.markdown("### Claude's Analysis")
            st.write(insight)

            from db import get_connection
            conn = get_connection()
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO analytics.fct_decisions
                (decision_id, insight_text, decision_text, owner_name, created_at)
                VALUES (%s, %s, %s, %s, %s)
            """, (str(uuid.uuid4()), insight, "AI Generated Insight", "Claude AI", datetime.now()))
            conn.commit()
            conn.close()
            st.success("AI insight saved to Redshift!")
