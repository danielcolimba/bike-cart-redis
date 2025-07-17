from fastapi import APIRouter
import redis
import os
from pydantic import BaseModel

router = APIRouter()

r = redis.Redis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=int(os.getenv("REDIS_PORT", 6379)),
    decode_responses=True
)

class CartItem(BaseModel):
    user_id: str
    product_id: str
    quantity: int

@router.post("/cart/add")
def add_to_cart(item: CartItem):
    key = f"cart:{item.user_id}"
    r.hincrby(key, item.product_id, item.quantity)
    return {"message": "Producto agregado al carrito"}

@router.get("/cart/{user_id}")
def get_cart(user_id: str):
    key = f"cart:{user_id}"
    cart = r.hgetall(key)
    return cart

@router.delete("/cart/{user_id}/{product_id}")
def remove_item(user_id: str, product_id: str):
    key = f"cart:{user_id}"
    r.hdel(key, product_id)
    return {"message": "Producto eliminado"}
