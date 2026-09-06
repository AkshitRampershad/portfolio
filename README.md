# Portfolio — Akshit Rampershad

Source repository for my personal portfolio website: **[akshitrampershad.github.io/portfolio](https://akshitrampershad.github.io/portfolio/)**

---

## Overview

A clean, responsive static site built with HTML5/CSS3 and hosted on GitHub Pages. It highlights my professional work as an **AI & Data Engineer**, focusing on enterprise AI systems, hybrid RAG pipelines, multi-agent orchestration, and production data architectures.

---

## Key Highlights

* **RAG-Powered Chatbot:** ask it anything about my background — see below for details.
* **Experience:** Cambrian Lab, 22nd Century Technology, Surge Infotech, and UKG.
* **Technical Stack & Tooling**
| Domain | Frameworks, Tools & Platforms |
| :--- | :--- |
| **LLM & Agentic AI** | OpenAI, Anthropic Claude, Gemini, LangChain, LlamaIndex, MCP |
| **RAG & Vector Search** | Qdrant, HNSW, BGE Embeddings, Cross-Encoders, Hybrid Search |
| **Data Engineering** | PySpark, SQL, Databricks (Auto Loader, DLT), Delta Lake, Medallion Architecture |
| **Cloud & Infrastructure** | AWS (S3, EC2), Snowflake, Docker, FastAPI, REST APIs |
| **Analytics & ML** | MLflow, Databricks AutoML, SAS, Tableau, Power BI |
* **Featured Repositories:**
  * **[CYBER-GPT](https://github.com/AkshitRampershad/CYBER-GPT):** RAG-powered SOC threat analysis and incident playbooks.
  * **[Project Management AI Workflows](https://github.com/AkshitRampershad/ai-agentic-workflow-project):** Multi-agent specification-to-task pipeline.
  * **[Credit Risk & Portfolio Optimization](https://github.com/AkshitRampershad/SAS-Financial-Project):** Large-scale statistical modeling in SAS.
  * **[Contradictory, My Dear Watson](https://github.com/AkshitRampershad/Contradictory-My-Dear-Watson):** Multilingual NLI with fine-tuned XLM-RoBERTa.
* **Certifications & Credentials:** Verified coursework and certifications from Anthropic (Claude API, MCP, Subagents), Databricks, Snowflake, Docker, Wolfram, and Atlassian.

---

## Akshit's Personal RAG Assistant

The chat widget on the site (bottom-right corner) is a real retrieval-augmented generation system, not a scripted FAQ bot — it can answer detailed questions about my background that aren't even written on the page itself, grounded in an actual knowledge corpus rather than a general-purpose model's guesses.

**How it works — two stages:**

1. **Retrieval (client-side, always on):** a ~160-chunk corpus (`rag-corpus.json`) built from my resume, official USF transcript, full certification curricula, project reports and READMEs, and the site's own content is BM25-searched entirely in the browser — no server round-trip, no API key needed, works even if the generation layer below is down.
2. **Generation (Cloudflare Worker + Groq):** the retrieved passages are sent to a small Worker (`worker/rag-worker.js`) that asks Groq to turn them into one fluent, grounded answer — instructed to answer *only* from what was retrieved, never from outside knowledge, so it won't invent facts about me. If the Worker is ever unreachable, the widget falls back to showing the raw retrieved passage instead of breaking.

**What it actually knows**, beyond what's visible on the page: which specific USF courses I took and the grades I got, the full sub-curriculum of every certification, exactly what I did vs. specified vs. designed at each job (title/dates/scope verified against my actual resume, not inflated), which industries I have — and explicitly don't have — real experience in, and how every technical skill, course, and certification connects back to a specific project or role rather than sitting on a list.

**Cost:** effectively $0 — Cloudflare Workers and Groq's free tiers cover normal portfolio traffic; the panel is resizable from any edge or corner if you want more room to read a longer answer.

---

## 🌐 Connect With Me

* **Website:** [akshitrampershad.github.io/portfolio](https://akshitrampershad.github.io/portfolio/)
* **LinkedIn:** [linkedin.com/in/akshit-rampershad](https://www.linkedin.com/in/akshit-rampershad/)
* **GitHub:** [github.com/AkshitRampershad](https://github.com/AkshitRampershad)

---

## 📄 License

© 2026 Akshit RamPershad. All rights reserved.
