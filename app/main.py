from fastapi import FastAPI
from app.cart import router

app = FastAPI(title="Cart Service")

app.include_router(router)
