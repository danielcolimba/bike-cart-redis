# Bike CartRedis

This service uses Redis as an in-memory data store to efficiently handle cart operations such as adding, removing, and updating products. It is optimized for speed and scalability, making it suitable for cloud-based deployments.

## Technology & Dependencies

- **Redis**: In-memory key-value database for fast data access.
- **Python 3.x**: Main programming language.
- **redis-py**: Python client for Redis.
- **Docker**: For containerized deployment.

## Basic Setup

1. **Install Redis**  
    - On Ubuntu:  
      ```sh
      sudo apt-get install redis-server
      ```
    - Or use Docker:  
      ```sh
      docker run -d -p 6379:6379 redis
      ```

2. **Clone the Repository**  
    ```sh
    git clone <repo-url>
    cd bike-cartredis
    ```

3. **Install Python Dependencies**  
    ```sh
    pip install -r requirements.txt
    ```

4. **Run the Service**  
    ```sh
    python app.py
    ```

5. **Test the Service**  
    Use Postman or curl to interact with the API endpoints.

---