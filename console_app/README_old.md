# Online Education Platform - Database Comparison Console App

> **Note:** The recommended way to run this tool is by using the Docker setup in the root of the project. See the main `README.md` for instructions. The instructions below are for manual setup.

## Setup Instructions

### Requirements
- Python 3.8+
- PostgreSQL client library
- requests library for HTTP calls

### Installation

```bash
# Install dependencies
pip install psycopg2-binary requests
```

### Configuration

1. **Update PostgreSQL connection details** in `comparison_tool.py`:
   ```python
   sql_db = SQLDatabase(
       host='your_host',
       database='education_platform',
       user='your_username',
       password='your_password'
   )
   ```

2. **Configure Back4app credentials**:
   ```python
   back4app_config = {
       'server_url': 'https://parseapi.back4app.com',
       'app_id': 'YOUR_APP_ID',
       'api_key': 'YOUR_API_KEY'
   }
   ```

### Running the Comparison

```bash
python comparison_tool.py
```

### What the Tool Tests

1. **Query 1**: Students not submitting more than 2 homeworks
   - Identifies at-risk students
   
2. **Query 2**: Course completion rates by student
   - Tracks progress across course structure
   
3. **Query 3**: Homework review cycle analysis
   - Shows submission and grading pipeline
   
4. **Query 4**: Teacher workload analysis
   - Monitors teaching load and pending reviews
   
5. **Query 5**: Course analytics and performance metrics
   - Comprehensive course statistics

### Expected Output

- Execution time for each query on both databases
- Number of results returned
- Performance ratio (Back4app vs SQL)
- Summary comparison table

### Notes

- SQL queries return actual results with full details
- Back4app equivalent operations may require multiple API calls
- Timing includes network latency for Back4app
- For accurate comparisons, run tests with similar network conditions
