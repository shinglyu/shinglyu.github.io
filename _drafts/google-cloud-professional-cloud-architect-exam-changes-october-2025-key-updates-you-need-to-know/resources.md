- Announcement: (Review the case studies in the new version if you plan to take the exam on or after October 30.) from https://cloud.google.com/learn/certification/cloud-architect/
- New exam link: https://services.google.com/fh/files/misc/v6.1_pca_professional_cloud_architect_exam_guide_english.pdf
- New exam link: https://services.google.com/fh/files/misc/professional_cloud_architect_exam_guide_english.pdf

-------
my notes:

New version v6.1 live from October 30 2025
    * Here is a comparison of the two Professional Cloud Architect exam guides, highlighting the key additions and removals in the new v6.1 version.

### Summary of Key Changes in v6.1

The new v6.1 exam guide introduces two major themes:

1. **Google Cloud Well-Architected Framework (WAF):** This is now a "key requirement". The framework and its pillars (operational excellence, security, reliability, etc.) are explicitly mentioned multiple times, including a new dedicated section (6.1).
    
2. **Artificial Intelligence (AI) and Machine Learning (ML):** There is a heavy emphasis on Google's AI/ML solutions. This includes new sections on **Vertex AI** , **Gemini models** , **AI Hypercomputer** , **Model Garden** , and securing AI.
    

Additionally, the case studies have been almost entirely replaced, and many sections now list specific products and services (like **Apigee** , **Migration Center** , and **Google Cloud VMware Engine** ) where the old guide was more general.

---

### Key Additions (in v6.1)

Here are the most significant topics and concepts added to the new exam guide:

- **Role Description:**
    
    - Explicitly mentions designing for **"efficient, cost-effective, and flexible solutions"**.
        
    - Adds **"workload migration approaches, deployment and orchestration, optimization"** to the required proficiency list.
        
    - **Google Cloud Well-Architected Framework (WAF)** is introduced as a "key requirement".
        
- **Case Studies:**
    
    - **Altostrat Media**
        
    - **Cymbal Retail**
        
    - **KnightMotives Automotive**
        
    - A note that case studies may involve **Google Cloud's generative AI solutions**.
        
- **Section 1: Designing and Planning**
    
    - **Gemini Cloud Assist**
        
    - A large new topic on **"Google Cloud machine learning and artificial intelligence (ML/AI) solutions"** (listing **Gemini LLMs, Agent Builder, Model Garden, Gemini models, AI Hypercomputer**).
        
    - Specific networking services like **load balancers, routing, shared VPC, and Private Service Connect**.
        
    - Specific compute platforms like **GKE, Cloud Run, and Cloud Run functions**.
        
    - **Migration Center** as a specific tool.
        
    - "Cloud-first design approach".
        
- **Section 2: Managing and Provisioning**
    
    - **Google Cloud VMware Engine**.
        
    - **Serverless computing**.
        
    - **(NEW) Section 2.4: Leveraging Vertex AI for end-to-end ML workflows** (includes **Vertex AI Pipelines**, **AI Hypercomputer**, **GPUs**, and **TPUs**).
        
    - **(NEW) Section 2.5: Configuring pre-built solutions or APIs with Vertex AI** (includes **Google AI APIs**, **Gemini Enterprise features**, and **Model Garden**).
        
- **Section 3: Designing for Security and Compliance**
    
    - **Hierarchical firewall policy**.
        
    - Specific remote access tools: **Identity-Aware Proxy, service account impersonation, Chrome Enterprise Premium, Workload Identity Federation**.
        
    - **Securing software supply chain**.
        
    - **Securing AI** (listing **Model Armor, Sensitive Data Protection, secure model deployment**).
        
    - **Data sovereignty**.
        
- **Section 5: Managing Implementation**
    
    - **Apigee** for API management.
        
    - **Gemini Cloud Assist**.
        
    - **Cloud Shell Editor** and **Cloud Code**.
        
    - **Infrastructure as code (e.g., IaC, Terraform)**.
        
    - **Google API client libraries**.
        
- **Section 6: Ensuring Solution and Operations Excellence**
    
    - **(NEW) Section 6.1: Understanding the principles and recommendations of the operational excellence pillar of the Google Cloud Well-Architected Framework**.
        
    - "Profiling and **benchmarking**".
        
    - **Load testing**.
        

---

### Key Removals (from the Old Version)

These topics were present in the old guide but are no longer explicitly mentioned in v6.1:

- **Case Studies:**
    
    - Helicopter Racing League
        
    - Mountkirk Games
        
    - TerramEarth
        
- **Section 1: Designing and Planning**
    
    - "Elasticity of cloud resources with respect to quotas and limits" (Replaced by the more general "Flexibility of cloud resources" ).
        
    - "Evangelism and advocacy".
        
- **Section 5: Managing Implementation**
    
    - "Application development" (Replaced by "Application and infrastructure deployment" ).*
