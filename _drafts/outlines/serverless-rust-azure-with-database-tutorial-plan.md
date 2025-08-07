# Serverless Rust on Azure with Database - Tutorial Plan

## **Refined Tutorial Structure:**

### **1. Introduction & Business Case**
- Quick reference to previous post (no detailed recap)
- **Business scenario**: Building a cake ordering API for a local bakery
  - Customers place custom cake orders with pickup dates
  - Shop needs to track orders, customer details, and cake specifications
  - RESTful API for potential web/mobile frontend integration
- Why this example showcases real-world serverless + database patterns

### **2. Understanding Azure Functions Architecture for Multi-Endpoint APIs**
- **Key concept**: One binary, multiple functions, shared code
- How the Function App host routes to your single custom handler
- Function.json files as routing configuration (not code isolation)
- Why this matters for database connections and shared state
- Contrast with AWS Lambda's function-per-file model

### **3. Database Choice: Azure Cosmos DB Emulator**
- Why Cosmos DB fits serverless (auto-scaling, global distribution, consumption pricing)
- **Local development focus**: Using emulator for this tutorial
- Note: Cloud deployment covered in next post
- Benefits of NoSQL for rapid prototyping

### **4. Building the Data Layer**
- Defining our domain model (Order, CreateOrderRequest)
- Adding Azure Cosmos SDK dependencies
- Serde annotations for JSON handling and Cosmos DB compatibility
- Setting up the emulator connection

### **5. Warp Framework Fundamentals**
- Why Warp for Rust APIs (filter composition, async-first)
- Core concepts: filters, handlers, and dependency injection
- How it differs from traditional MVC frameworks

### **6. Implementing RESTful Endpoints**
- **Progressive build approach**:
  1. Start with POST /api/orders (create)
  2. Add GET /api/orders (list all)
  3. Add GET /api/orders/{id} (get by ID)
- JSON request/response handling
- Error handling patterns

### **7. Input Validation & Security**
- Validation strategy (fail fast, clear error messages)
- UUID validation for IDs
- Business rule validation (cake styles, text limits)
- **Security highlight**: Parameterized queries vs SQL injection

### **8. Shared State Management**
- Why connection pooling matters in serverless
- Arc<ContainerClient> pattern for shared database connections
- Warp filters for dependency injection
- Performance implications

### **9. Testing the API**
- Local testing with curl/Postman
- Integration testing with reqwest
- Testing strategy for database-backed APIs

### **10. Next Steps Preview**
- Cloud Cosmos DB deployment
- Production considerations (authentication, logging, monitoring)
- CI/CD pipeline setup

## **Key Technical Deep Dives:**

1. **Azure Functions Custom Handler Architecture** - This will be a dedicated section explaining the one-binary-multiple-functions model
2. **Cosmos DB Document Model** - How NoSQL documents work vs relational tables
3. **Warp Filter Composition** - Show how to build complex routing with simple, composable filters
4. **Error Handling Patterns** - Consistent JSON error responses across endpoints

## **Code Snippets Strategy:**
- Focus on key architectural pieces, not full files
- Reference GitHub for complete implementation
- Highlight the progression: basic → validated → secure → tested

## **Tone Adjustments:**
- Present the final architecture as the goal, then show how we build toward it
- Mention alternative approaches briefly but don't dwell on dead ends
- Focus on the "why" behind each technical decision
- Keep it practical and implementation-focused

## **GitHub Repository Reference:**
- Repository: shinglyu/serverless-rust-on-azure
- Branch: api-with-db
- Complete implementation available for reference
